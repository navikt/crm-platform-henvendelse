global class CRM_Henvendelse {
    global String fnr;
    global String aktorId;
    global String avsluttetDato;
    global String opprettetDato;
    global String henvendelseId;
    global String kjedeId;
    global String behandlingstema;
    global String brukersEnhet;
    global Boolean erTilknyttetAnsatt;
    global Boolean ferdigstiltUtenSvar;
    global String gjeldendeTemagruppe;
    global String henvendelseType;
    global List<CRM_JournalfortInformasjon> journalposter;
    global String kontorsperreEnhet;
    global String lestDato;
    global CRM_Markeringer markeringer;
    global String tilknyttetEnhet;

    global CRM_Henvendelse(Conversation_Note__c convNote, List<Journal_Entry__c> jeList) {
        this.fnr = convNote.CRM_Account__r.CRM_Person__r.Name;
        this.aktorId = convNote.CRM_Account__r.CRM_Person__r.INT_ActorId__c;
        this.gjeldendeTemagruppe = convNote.CRM_Theme_Group_Code__c;
        this.opprettetDato = gtmFormatDateTime(convNote.CreatedDate);
        this.kjedeId = null;
        this.henvendelseId = convNote.Id;
        this.lestDato = gtmFormatDateTime(convNote.CRM_Read_Date__c);

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

        if (jeList != null && jeList.size() > 0) {
            List<CRM_JournalfortInformasjon> journalPosts = new List<CRM_JournalfortInformasjon>();
            for (Journal_Entry__c jEntry : jeList) {
                journalPosts.add(new CRM_JournalfortInformasjon(jEntry));
            }
            this.journalposter = journalPosts;
        }
    }

    private String gtmFormatDateTime(DateTime datetime) {
        return datetime != null ? datetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : null;
    }
}
