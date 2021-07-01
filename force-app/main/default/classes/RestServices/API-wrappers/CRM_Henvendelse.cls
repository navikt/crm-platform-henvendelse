global class CRM_Henvendelse extends CRM_HenvendelseApiUtils {
    global String fnr;
    global String aktorId;
    global String avsluttetDato;
    global String opprettetDato;
    global String henvendelseId;
    global String kjedeId;
    global String opprinneligGT;
    global Boolean erTilknyttetAnsatt;
    global String gjeldendeTemagruppe;
    global String gjeldendeTema;
    global String henvendelseType;
    global List<CRM_JournalfortInformasjon> journalposter;
    global List<CRM_Melding> meldinger;
    global List<CRM_Markering> markeringer;
    global String tilknyttetEnhet;

    global CRM_Henvendelse(Conversation_Note__c convNote, List<Journal_Entry__c> jeList) {
        this.fnr = convNote.CRM_Account__r.CRM_Person__r.Name;
        this.aktorId = convNote.CRM_Account__r.CRM_Person__r.INT_ActorId__c;
        this.gjeldendeTemagruppe = convNote.CRM_Theme_Group_Code__c;
        this.gjeldendeTema = convNote.CRM_Theme_Code__c;
        this.opprettetDato = gmtFormatDateTime(convNote.CRM_Date_Time_Registered__c);
        this.avsluttetDato = this.opprettetDato;
        this.kjedeId = null;
        this.henvendelseId = convNote.Id;
        this.henvendelseType = HENVENDELSE_TYPES.SAMTALEREFERAT.name();

        this.meldinger = new List<CRM_Melding>();
        this.meldinger.add(new CRM_Melding(convNote));

        if (jeList != null && jeList.size() > 0) {
            List<CRM_JournalfortInformasjon> journalPosts = new List<CRM_JournalfortInformasjon>();
            for (Journal_Entry__c jEntry : jeList) {
                journalPosts.add(new CRM_JournalfortInformasjon(jEntry));
            }
            this.journalposter = journalPosts;
        }
    }

    global CRM_Henvendelse(Thread__c thread, List<Message__c> messages, List<Journal_Entry__c> jeList) {
        this.kjedeId = thread.Id;
        this.henvendelseId = thread.Id;
        this.opprettetDato = gmtFormatDateTime(thread.CreatedDate);
        this.avsluttetDato = null; //TODO: Define when thread is closed
        this.meldinger = new List<CRM_Melding>();
        this.henvendelseType = HENVENDELSE_TYPES.MELDINGSKJEDE.name();

        for (Message__c message : messages) {
            this.meldinger.add(new CRM_Melding(message));
        }

        if (jeList != null && jeList.size() > 0) {
            List<CRM_JournalfortInformasjon> journalPosts = new List<CRM_JournalfortInformasjon>();
            for (Journal_Entry__c jEntry : jeList) {
                journalPosts.add(new CRM_JournalfortInformasjon(jEntry));
            }
            this.journalposter = journalPosts;
        }
    }

    global CRM_Henvendelse(Message__c message) {
        /*this.kjedeId = message.CRM_Thread__c;
        this.henvendelseId = message.Id;
        this.henvendelseType = HENVENDELSE_TYPES.MELDING.name();
        this.meldinger = new List<CRM_Melding>();
        this.meldinger.add(new CRM_Melding(message));*/
    }
}
