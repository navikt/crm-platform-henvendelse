public without sharing virtual class CRM_HenvendelseApiUtils extends ApexRestService {
    public enum HENVENDELSE_TYPES {
        SAMTALEREFERAT,
        MELDINGSKJEDE,
        MELDING
    }

    public static Thread__c convertToThread(CRM_Henvendelse req) {
        Thread__c thread = new Thread__c();
        return thread;
    }

    public static Conversation_Note__c convertToConvNote(CRM_Henvendelse req) {
        Conversation_Note__c convNote = new Conversation_Note__c();
        return convNote;
    }

    public String gmtFormatDateTime(DateTime timestamp) {
        return timestamp != null ? timestamp.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : null;
    }
}
