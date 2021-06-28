public without sharing virtual class CRM_HenvendelseApiUtils extends ApexRestService {
    public enum HENVENDELSE_TYPES {
        SAMTALEREFERAT,
        CHAT,
        ASYNC_CHAT
    }

    public static Thread__c convertToThread(CRM_Henvendelse req) {
        Thread__c thread = new Thread__c();
        return thread;
    }

    public static Conversation_Note__c convertToConvNote(CRM_Henvendelse req) {
        Conversation_Note__c convNote = new Conversation_Note__c();
        return convNote;
    }
}
