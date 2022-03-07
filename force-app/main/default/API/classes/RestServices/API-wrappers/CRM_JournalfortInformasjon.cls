global class CRM_JournalfortInformasjon {
    global String journalforerNavIdent;
    global String journalforendeEnhet;
    global String journalfortDato;
    global String journalfortTema;
    global String fagsakId;
    global String fagsaksystem;
    global String journalpostId;

    global CRM_JournalfortInformasjon(Journal_Entry__c jEntry) {
        this.journalpostId = jEntry.Journal_Entry_ID__c;
        this.journalfortDato = jEntry.CRM_Journal_Date__c != null
            ? jEntry.CRM_Journal_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
            : null;
        this.journalfortTema = jEntry.CRM_Theme_Code__c;
        this.journalforerNavIdent = jEntry.CRM_Created_By_Ident__c;
        this.journalforendeEnhet = jEntry.CRM_Created_By_NAV_Unit__c;
        this.fagsakId = jEntry.NAV_Case_Reference__c;
        this.fagsaksystem = jEntry.CRM_NAV_Case_Legacy_System__c;
    }
}
