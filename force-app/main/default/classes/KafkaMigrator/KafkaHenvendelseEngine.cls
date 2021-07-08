public without sharing class KafkaHenvendelseEngine implements Database.Batchable<SObject> {
    private Map<String, Conversation_Note__c> convNotes = new Map<String, Conversation_Note__c>();
    private Map<String, Thread__c> threads = new Map<String, Thread__c>();
    private Map<String, Message__c> messages = new Map<String, Message__c>();
    private List<Journal_Entry__c> journalEntries = new List<Journal_Entry__c>();

    Set<String> actorIds = new Set<String>();
    Map<String, Id> actorAccMap = new Map<String, Id>();
    Map<String, Id> commonCodeMap = new Map<String, Id>();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, CRM_Key__c, CRM_Message__c, CRM_Topic__c FROM KafkaMessage__c WHERE CRM_Topic__c = SOMETOPIC';
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

        verifyUpsertResults(convUpsRes);
        verifyUpsertResults(threadsUpsRes);
        verifyUpsertResults(messageUpsRes);
        verifyUpsertResults(jEntryUpsRes);
    }

    private void verifyUpsertResults(List<Database.UpsertResult> upsRes) {
    }

    private void initPersonMap() {
        for (Person__c person : [
            SELECT INT_ActorId__c, CRM_Account__c
            FROM Person__c
            WHERE INT_ActorId__c IN :this.actorIds
        ]) {
            actorAccMap.put(person.INT_ActorId__c, person.CRM_Account__c);
        }
    }

    private void initCommonCodeMap() {
        for (Common_Code__c comCode : [
            SELECT Id, CRM_Code__c
            FROM Common_Code__c
            WHERE CRM_Code_Set__c IN ('Temagrupper', 'Tema')
        ]) {
            commonCodeMap.put(comCode.CRM_Code__c, comCode.Id);
        }
    }

    private void doTransform(List<KafkaMessage__c> kafkaMessages) {
        List<Kafka_Henvendelse> kfHenvList = new List<Kafka_Henvendelse>();
        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            Kafka_Henvendelse kfHenv = convertToKafkaHenvendelse(kafkaMessage);
            actorIds.add(kfHenv.aktorId);
            kfHenvList.add(kfHenv);
        }

        initPersonMap();

        for (Kafka_Henvendelse kfHenv : kfHenvList) {
            switch on kfHenv.henvendelseType {
                when 'SAMTALEREFERAT TYPES' {
                    //Convert to conversation note
                    convertToConversationNote(kfHenv);
                }
                when else {
                    //This is the chain starter so need to transform to Thread and message
                    if (kfHenv.behandlingsId == kfHenv.behandlingskjedeId) {
                        convertToThread(kfHenv);
                    } else {
                        convertToMessage(kfHenv);
                    }
                }
            }
        }
    }

    private void convertToConversationNote(Kafka_Henvendelse kfHenv) {
        Conversation_Note__c convNote = new Conversation_Note__c();
        if (!actorAccMap.containsKey(kfHenv.aktorId)) {
            //Actor does not exist in Salesforce, Set message to error status and return
            return;
        } else {
            convNote.CRM_Account__c = actorAccMap.get(kfHenv.aktorId);
        }

        convNote.CRM_Henvendelse_BehandlingsId__c = kfHenv.behandlingsId;
        convNote.CRM_Read_Date__c = String.isNotBlank(kfHenv.lestDato) ? Datetime.valueOf(kfHenv.lestDato) : null;
        convNote.CRM_Date_Time_Registered__c = String.isNotBlank(kfHenv.opprettetDato)
            ? Datetime.valueOf(kfHenv.opprettetDato)
            : null;
        convNote.CRM_Theme_Group__c = commonCodeMap.containsKey(kfHenv.gjeldendeTemagruppe)
            ? commonCodeMap.get(kfHenv.gjeldendeTemagruppe)
            : null;

        if (kfHenv.journalfortInformasjon != null) {
            addJournalEntry(kfHenv.journalfortInformasjon, kfHenv.behandlingsId);
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
    }

    private void convertToThread(Kafka_Henvendelse kfHenv) {
        //The thread starter is a message in itself
        Thread__c thread = new Thread__c();

        if (kfHenv.journalfortInformasjon != null) {
            thread.CRM_Journal_Status__c = 'Journal Completed';
            addJournalEntry(kfHenv.journalfortInformasjon, kfHenv.behandlingsId);
        }
    }

    private void convertToMessage(Kafka_Henvendelse kfHenv) {
    }

    private void addJournalEntry(Kafka_JournalfortInformasjon kfJournal, String behandlingsId) {
        journalEntries.add(
            new Journal_Entry__c(
                CRM_Conversation_Note__r = new Conversation_Note__c(CRM_Henvendelse_BehandlingsId__c = behandlingsId),
                CRM_Created_By_Ident__c = kfJournal.journalforerNavIdent,
                Journal_Entry_Status__c = 'Completed',
                CRM_Journal_Date__c = Datetime.valueOf(kfJournal.journalfortDato),
                Journal_Entry_ID__c = kfJournal.journalpostId
            )
        );
    }

    private Kafka_Henvendelse convertToKafkaHenvendelse(KafkaMessage__c kafkaMessage) {
        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(kafkaMessage.CRM_Value__c).toString();
        return (Kafka_Henvendelse) JSON.deserialize(decodedValue, Kafka_Henvendelse.class);
    }

    public void finish(Database.BatchableContext BC) {
    }
}
