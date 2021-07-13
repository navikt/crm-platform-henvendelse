global class CRM_Henvendelse extends CRM_HenvendelseApiUtils {
    global String fnr;
    global String aktorId;
    global String kasseringsDato;
    global String avsluttetDato;
    global String opprettetDato;
    global String henvendelseId;
    global String kjedeId;
    global String opprinneligGT;
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
        this.opprettetDato = gmtFormatDateTime(convNote.CRM_Registered_Datetime_Formula__c);
        this.avsluttetDato = this.opprettetDato;
        this.kjedeId = null;
        this.henvendelseId = convNote.Id;
        this.henvendelseType = HENVENDELSE_TYPE.SAMTALEREFERAT.name();

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
        //this.fnr =
        //this.aktorId =
        this.henvendelseId = thread.Id;
        this.kasseringsDato = gmtFormatDateTime(thread.CRM_Disposal_Datetime__c);
        this.opprettetDato = gmtFormatDateTime(thread.CRM_Registered_Datetime_Formula__c);
        this.avsluttetDato = gmtFormatDateTime(thread.CRM_Closed_Date__c);
        this.meldinger = new List<CRM_Melding>();
        this.henvendelseType = HENVENDELSE_TYPE.MELDINGSKJEDE.name();

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
}
