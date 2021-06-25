global class CRM_Henvendelse {
    global String fnr;
    global String aktorId;
    global String avsluttetDato;
    global String behandlingsId;
    global String behandlingskjedeId;
    global String behandlingstema;
    global String brukersEnhet;
    global Boolean erTilknyttetAnsatt;
    global Boolean ferdigstiltUtenSvar;
    global String gjeldendeTemagruppe;
    global String henvendelseType;
    global CRM_JournalfortInformasjon journalfortInformasjon;
    global String kontorsperreEnhet;
    global String lestDato;
    global CRM_Markeringer markeringer;
    global CRM_HenvendelseMetadataListe metadataListe;
    global String markertSomFeilsendtAv;
    global String oppgaveIdGsak;
    global String opprettetDato;
    global String tema;
    global String tilknyttetEnhet;

    global CRM_Henvendelse(Conversation_Note__c convNote, List<Journal_Entry__c> jeList) {
    }

    global CRM_Henvendelse(Thread__c thread, List<Message__c> messages, List<Journal_Entry__c> jeList) {
    }
}
