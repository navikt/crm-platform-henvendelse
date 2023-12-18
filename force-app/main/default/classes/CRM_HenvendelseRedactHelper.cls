public with sharing class CRM_HenvendelseRedactHelper {
    @AuraEnabled
    public static void redactConversationNote(String redactedText, Id recordId) {
        try {
            if (recordId == null || redactedText == null) {
                return;
            }
            Conversation_Note__c cNote = new Conversation_Note__c(
                Id = recordId,
                CRM_conversation_note__c = redactedText
            );
            update cNote;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
