public class CRM_Henvendelse {
    public String fnr;
    public String aktorId;
    public String avsluttetDato;
    public String behandlingsId;
    public String behandlingskjedeId;
    public String behandlingstema;
    public String brukersEnhet;
    public Boolean erTilknyttetAnsatt;
    public Boolean ferdigstiltUtenSvar;
    public String gjeldendeTemagruppe;
    public String henvendelseType;
    public CRM_JournalfortInformasjon journalfortInformasjon;
    public String kontorsperreEnhet;
    public String lestDato;
    public CRM_Markeringer markeringer;
    public CRM_HenvendelseMetadataListe metadataListe;
    public String markertSomFeilsendtAv;
    public String oppgaveIdGsak;
    public String opprettetDato;
    public String tema;
    public String tilknyttetEnhet;

    public CRM_Henvendelse(Conversation_Note__c convNote, List<Journal_Entry__c> jeList) {
    }

    public CRM_Henvendelse(Thread__c thread, List<Message__c> messages, List<Journal_Entry__c> jeList) {
    }
}
