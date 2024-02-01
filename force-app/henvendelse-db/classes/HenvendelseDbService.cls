public with sharing class HenvendelseDbService {

    public Boolean postThread(Id threadId){
        Thread__c thread = new CRM_ThreadSelector().selectById(threadId);
        String jsonBody=JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r));
        HttpResponse response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        return response.getStatusCode()==200;
    }

    public Boolean postConversationNote(Id convId){
        Conversation_Note__c convNote=new CRM_ConversationNoteSelector().selectById(convId);
        String jsonBody=JSON.serializePretty(new CRM_Henvendelse(new List<Conversation_Note__c>{convNote}));
        HttpResponse response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        return response.getStatusCode()==200;
    }
}