public without sharing class KafkaHenvendelseEngine implements Database.Batchable<SObject> {
    private Map<String, Conversation_Note__c> convNotes = new Map<String, Conversation_Note__c>();
    private Map<String, Thread__c> threads = new Map<String, Thread__c>();
    private Map<String, Message__c> messages = new Map<String, Message__c>();
    private List<Journal_Entry__c> journalEntries = new List<Journal_Entry__c>();
    private Map<String, KafkaMessage__c> kafkaMessageMap = new Map<String, KafkaMessage__c>();

    Set<String> actorIds = new Set<String>();
    Map<String, Id> actorAccMap = new Map<String, Id>();
    Map<String, Id> communityUserMap = new Map<String, Id>();
    Map<String, Id> internalUserMap = new Map<String, Id>();
    Map<String, Id> commonCodeMap = new Map<String, Id>();

    //TODO: HOW SHOULD RECORD OWNER BE HANDLED?

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, CRM_Key__c, CRM_Message__c, CRM_Topic__c, CreatedDate FROM KafkaMessage__c WHERE CRM_Topic__c = SOMETOPIC ORDER BY CreatedDate';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        initCommonCodeMap();
        doTransform((List<KafkaMessage__c>) scope);

        List<Database.UpsertResult> convUpsRes = Database.upsert(
            convNotes.values(),
            Conversation_Note__c.CRM_Henvendelse_BehandlingsId__c,
            false
        );
        List<Database.UpsertResult> threadsUpsRes = Database.upsert(
            threads.values(),
            Thread__c.CRM_Henvendelse_BehandlingsId__c,
            false
        );
        List<Database.UpsertResult> messageUpsRes = Database.upsert(
            messages.values(),
            Message__c.CRM_Henvendelse_BehandlingsId__c,
            false
        );
        List<Database.UpsertResult> jEntryUpsRes = Database.upsert(
            journalEntries,
            Journal_Entry__c.Journal_Entry_ID__c,
            false
        );

        verifyUpsertResults(convNotes.values(), convUpsRes);
        verifyUpsertResults(threads.values(), threadsUpsRes);
        verifyUpsertResults(messages.values(), messageUpsRes);
        verifyUpsertResults(journalEntries, jEntryUpsRes);

        update kafkaMessageMap.values();
    }

    /**
     * @description: Queries all existing persons records and maps the actorId to the account id
     * @author Stian Ruud Schikora | 07-14-2021
     **/
    private void initPersonMap() {
        for (Person__c person : [
            SELECT INT_ActorId__c, CRM_Account__c
            FROM Person__c
            WHERE INT_ActorId__c IN :this.actorIds
        ]) {
            actorAccMap.put(person.INT_ActorId__c, person.CRM_Account__c);
        }
    }

    /**
     * @description: Maps all community users to their respective account id
     * @author Stian Ruud Schikora | 07-14-2021
     **/
    private void initUserMap() {
        for (User user : [
            SELECT Id, AccountId
            FROM User
            WHERE AccountId IN :this.actorAccMap.values() OR CRM_NAV_Ident__c != NULL
        ]) {
            if (String.isNotBlank(user.AccountId)) {
                communityUserMap.put(user.AccountId, user.Id);
                continue;
            }
            if (String.isNotBlank(user.CRM_NAV_Ident__c)) {
                internalUserMap.put(user.CRM_NAV_Ident__c, user.Id);
            }
        }
    }

    /**
     * @description: Inits a map of common codes to their Common_Code SF ID
     * @author Stian Ruud Schikora | 07-14-2021
     **/
    private void initCommonCodeMap() {
        for (Common_Code__c comCode : [
            SELECT Id, CRM_Code__c
            FROM Common_Code__c
            WHERE CRM_Code_Set__c IN ('Temagrupper', 'Tema')
        ]) {
            commonCodeMap.put(comCode.CRM_Code__c, comCode.Id);
        }
    }

    /**
     * @description: Performs the conversion from kafka message to Kafka_Henvendelse. Only include data with no disposal date or if the date is in the future
     * @author Stian Ruud Schikora | 07-14-2021
     * @param kafkaMessages
     **/
    private void doTransform(List<KafkaMessage__c> kafkaMessages) {
        List<Kafka_Henvendelse> kfHenvList = new List<Kafka_Henvendelse>();
        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            Kafka_Henvendelse kfHenv = convertToKafkaHenvendelse(kafkaMessage);
            if (String.isBlank(kfHenv.utgaarDato) || Datetime.valueOf(kfHenv.utgaarDato) > System.now()) {
                kafkaMessageMap.put(kafkaMessage.CRM_Key__c, kafkaMessage); //Assume key is the behandlingsId
                actorIds.add(kfHenv.aktorId);
                kfHenvList.add(kfHenv);
            } else {
                setMessageCompleted(kafkaMessage);
            }
        }

        initPersonMap();
        initUserMap();

        for (Kafka_Henvendelse kfHenv : kfHenvList) {
            switch on kfHenv.henvendelseType {
                when 'REFERAT_TELEFON', 'REFERAT_OPPMOTE' {
                    //Convert to conversation note
                    convertToConversationNote(kfHenv);
                }
                when else {
                    //This is the chain starter so need to transform to Thread and message
                    if (kfHenv.behandlingsId == kfHenv.behandlingskjedeId)
                        convertToThread(kfHenv);
                    convertToMessage(kfHenv);
                }
            }
        }
    }

    /**
     * @description: Converts a Kafka_Henvendelse into a conversation note that is ready for upsert
     * @author Stian Ruud Schikora | 07-14-2021
     * @param kfHenv
     **/
    private void convertToConversationNote(Kafka_Henvendelse kfHenv) {
        Conversation_Note__c convNote = new Conversation_Note__c();
        if (!actorAccMap.containsKey(kfHenv.aktorId)) {
            //Update message error and return
            setMessageError(kfHenv.behandlingsId, 'Actor does not exist: ' + kfHenv.aktorId);
            return;
        } else {
            convNote.CRM_Account__c = actorAccMap.get(kfHenv.aktorId);
        }
        convNote.CRM_Created_By_NAV_Unit__c = kfHenv.tilknyttetEnhet;
        convNote.CRM_Henvendelse_BehandlingsId__c = kfHenv.behandlingsId;
        convNote.CRM_Read_Date__c = String.isNotBlank(kfHenv.lestDato) ? Datetime.valueOf(kfHenv.lestDato) : null;
        convNote.CRM_Date_Time_Registered__c = String.isNotBlank(kfHenv.opprettetDato)
            ? Datetime.valueOf(kfHenv.opprettetDato)
            : null;
        convNote.CRM_Theme_Group__c = commonCodeMap.containsKey(kfHenv.gjeldendeTemagruppe)
            ? commonCodeMap.get(kfHenv.gjeldendeTemagruppe)
            : null;

        if (kfHenv.journalfortInformasjon != null) {
            addConvNoteJournalEntry(kfHenv.journalfortInformasjon, kfHenv.behandlingsId);
            convNote.CRM_Theme__c = commonCodeMap.containsKey(kfHenv.journalfortInformasjon.journalfortTema)
                ? commonCodeMap.get(kfHenv.journalfortInformasjon.journalfortTema)
                : null;
        }

        if (kfHenv.markeringer != null) {
            if (kfHenv.markeringer.feilsendt != null) {
            }
            if (kfHenv.markeringer.kontorsperre != null) {
                convNote.CRM_Office_Restriction_Activated_By__c = kfHenv.markeringer.kontorsperre.aktor;
                convNote.CRM_Office_Restriction__c = true;
            }
        }
        if (
            kfHenv.metadataListe != null &&
            kfHenv.metadataListe.metadata != null &&
            !kfHenv.metadataListe.metadata.isEmpty()
        ) {
            convNote.CRM_Conversation_Note__c = kfHenv.metadataListe.metadata[0].fritekst;
            convNote.CRM_Created_By_Ident__c = kfHenv.metadataListe.metadata[0].navident;
        }

        this.convNotes.put(kfHenv.behandlingsId, convNote);
        setMessageCompleted(kfHenv.behandlingsId);
    }

    /**
     * @description: Converts a Kafka_Henvendelse into a Thread that is ready for upsert
     * @author Stian Ruud Schikora | 07-14-2021
     * @param kfHenv
     **/
    private void convertToThread(Kafka_Henvendelse kfHenv) {
        //The thread starter is a message in itself
        Thread__c thread = new Thread__c();
        if (!actorAccMap.containsKey(kfHenv.aktorId)) {
            //Update message error and return
            setMessageError(kfHenv.behandlingsId, 'Actor does not exist: ' + kfHenv.aktorId);
            return;
        }
        String accountId = actorAccMap.get(kfHenv.aktorId);
        if (!communityUserMap.containsKey(accountId)) {
            //Community users need to be created on beforehand
            setMessageError(kfHenv.behandlingsId, 'Community user not activated for actor: ' + kfHenv.aktorId);
            return;
        } else {
            //Check if the user if the recipient or initiatior of the dialogue and set from field accordingly
            if (
                kfHenv.metadataListe != null &&
                kfHenv.metadataListe.metadata != null &&
                !kfHenv.metadataListe.metadata.isEmpty()
            ) {
                if (String.isNotBlank(kfHenv.metadataListe.metadata[0].navident)) {
                    //If the navident is not blank, the dialogue was initiated by NAV
                    thread.CRM_Recipient__c = communityUserMap.get(accountId);
                    if (internalUserMap.containsKey(kfHenv.metadataListe.metadata[0].navident)) {
                        thread.CRM_From__c = internalUserMap.get(kfHenv.metadataListe.metadata[0].navident);
                    } else {
                        thread.CRM_Created_By_Ident__c = kfHenv.metadataListe.metadata[0].navident;
                    }
                } else {
                    thread.CRM_From__c = communityUserMap.get(accountId);
                }
            } else {
                setMessageError(kfHenv.behandlingsId, 'Could not determine thread creator');
                return;
            }
        }

        thread.CRM_Disposal_Datetime__c = String.isNotBlank(kfHenv.utgaarDato)
            ? Datetime.valueOf(kfHenv.utgaarDato)
            : null;
        thread.CRM_Date_Time_Registered__c = String.isNotBlank(kfHenv.opprettetDato)
            ? Datetime.valueOf(kfHenv.opprettetDato)
            : null;
        thread.CRM_Created_By_Ident__c = kfHenv.eksternAktor;
        thread.CRM_Theme_Group__c = commonCodeMap.containsKey(kfHenv.gjeldendeTemagruppe)
            ? commonCodeMap.get(kfHenv.gjeldendeTemagruppe)
            : null;

        if (kfHenv.markeringer != null) {
            if (kfHenv.markeringer.feilsendt != null) {
            }
            if (kfHenv.markeringer.kontorsperre != null) {
                thread.CRM_Office_Restriction_Activated_By__c = kfHenv.markeringer.kontorsperre.aktor;
                thread.CRM_Office_Restriction__c = true;
            }
        }

        if (kfHenv.journalfortInformasjon != null) {
            thread.CRM_Journal_Status__c = 'Journal Completed';
            addThreadJournalEntry(kfHenv.journalfortInformasjon, kfHenv.behandlingsId);
            thread.CRM_Theme__c = commonCodeMap.containsKey(kfHenv.journalfortInformasjon.journalfortTema)
                ? commonCodeMap.get(kfHenv.journalfortInformasjon.journalfortTema)
                : null;
        }

        this.threads.put(kfHenv.behandlingsId, thread);
        setMessageCompleted(kfHenv.behandlingsId);
    }

    /**
     * @description: Converts a Kafka_Henvendelse into a message that is ready for upsert
     * @author Stian Ruud Schikora | 07-14-2021
     * @param kfHenv
     **/
    private void convertToMessage(Kafka_Henvendelse kfHenv) {
        Message__c message = new Message__c();
        String accountId = actorAccMap.get(kfHenv.aktorId);
        message.CRM_Thread__r = new Thread__c(CRM_Henvendelse_BehandlingsId__c = kfHenv.behandlingsKjedeId);
        message.CRM_Henvendelse_BehandlingsId__c = kfHenv.behandlingsId;
        message.CRM_Read_Datetime__c = String.isNotBlank(kfHenv.lestDato) ? Datetime.valueOf(kfHenv.lestDato) : null;
        message.CRM_Read__c = String.isNotBlank(kfHenv.lestDato);

        if (
            kfHenv.metadataListe != null &&
            kfHenv.metadataListe.metadata != null &&
            !kfHenv.metadataListe.metadata.isEmpty()
        ) {
            message.CRM_Message_Text__c = kfHenv.metadataListe.metadata[0].fritekst;
            if (String.isNotBlank(kfHenv.metadataListe.metadata[0].navident)) {
                if (internalUserMap.containsKey(kfHenv.metadataListe.metadata[0].navident)) {
                    message.CRM_From__c = internalUserMap.get(kfHenv.metadataListe.metadata[0].navident);
                } else {
                    //No Salesforce user
                    message.CRM_From_Ident__c = kfHenv.metadataListe.metadata[0].navident;
                }
            }
        } else {
            setMessageError(kfHenv.behandlingsId, 'Could not determine message sender');
            return;
        }

        if (kfHenv.journalfortInformasjon != null) {
            //Adds the journal entry connected to the thread
            addThreadJournalEntry(kfHenv.journalfortInformasjon, kfHenv.behandlingskjedeId);
        }
        this.messages.put(kfHenv.behandlingsId, message);
        setMessageCompleted(kfHenv.behandlingsId);
    }

    /**
     * @description: Converts Kafka_JournalfortInformasjon into a valid Journal_Entry__c record
     * @author Stian Ruud Schikora | 07-14-2021
     * @param kfJournal
     * @param behandlingsId
     **/
    private void addConvNoteJournalEntry(Kafka_JournalfortInformasjon kfJournal, String behandlingsId) {
        journalEntries.add(
            new Journal_Entry__c(
                CRM_Conversation_Note__r = new Conversation_Note__c(CRM_Henvendelse_BehandlingsId__c = behandlingsId),
                CRM_Created_By_Ident__c = kfJournal.journalforerNavIdent,
                CRM_Created_By_NAV_Unit__c = kfJournal.journalforendeEnhet,
                Journal_Entry_Status__c = 'Completed',
                CRM_Journal_Date__c = Datetime.valueOf(kfJournal.journalfortDato),
                Journal_Entry_ID__c = kfJournal.journalpostId
            )
        );
    }

    /**
     * @description: Converts Kafka_JournalfortInformasjon into a valid Journal_Entry__c record
     * @author Stian Ruud Schikora | 07-14-2021
     * @param kfJournal
     * @param behandlingsId
     **/
    private void addThreadJournalEntry(Kafka_JournalfortInformasjon kfJournal, String behandlingsId) {
        journalEntries.add(
            new Journal_Entry__c(
                CRM_Thread__r = new Thread__c(CRM_Henvendelse_BehandlingsId__c = behandlingsId),
                CRM_Created_By_Ident__c = kfJournal.journalforerNavIdent,
                CRM_Created_By_NAV_Unit__c = kfJournal.journalforendeEnhet,
                Journal_Entry_Status__c = 'Completed',
                CRM_Journal_Date__c = Datetime.valueOf(kfJournal.journalfortDato),
                Journal_Entry_ID__c = kfJournal.journalpostId
            )
        );
    }

    //##########################################################//
    //##################     UTILS       #######################//
    //##########################################################//

    private void verifyUpsertResults(List<Sobject> upsertObjects, List<Database.UpsertResult> upsResList) {
        String objectName = upsertObjects[0].getSObjectType().getDescribe().getName();

        for (Integer i = 0; i < upsResList.size() - 1; i++) {
            if (upsResList[i].isSuccess()) {
            } else {
                for (Database.Error error : upsResList[i].getErrors()) {
                    //If the upsert of journal entries fail, there is no direct relation for the henvendelse id
                    if (objectName.equalsIgnoreCase('Journal_Entry__c')) {
                    } else {
                        String errorMessage = error.getMessage();
                        setMessageError(
                            (String) upsertObjects[i].get('CRM_Henvendelse_BehandlingsId__c'),
                            errorMessage
                        );
                    }
                }
            }
        }
    }

    private void setMessageError(String behandlingsId, String errorMessage) {
        KafkaMessage__c message = kafkaMessageMap.get(behandlingsId);

        message.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
        message.CRM_ErrorMessage__c = errorMessage;
    }

    private void setMessageCompleted(String behandlingsId) {
        KafkaMessage__c message = kafkaMessageMap.get(behandlingsId);
        setMessageCompleted(message);
    }

    private void setMessageCompleted(KafkaMessage__c message) {
        message.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
    }

    private Kafka_Henvendelse convertToKafkaHenvendelse(KafkaMessage__c kafkaMessage) {
        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(kafkaMessage.CRM_Value__c).toString();
        return (Kafka_Henvendelse) JSON.deserialize(decodedValue, Kafka_Henvendelse.class);
    }

    public void finish(Database.BatchableContext BC) {
    }
}
