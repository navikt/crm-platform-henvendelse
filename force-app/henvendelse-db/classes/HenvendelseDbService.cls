public with sharing class HenvendelseDbService {

    public Boolean postThreads(Set<Id> threadIds){
        List<Thread__c> threads = new CRM_ThreadSelector().selectByIds(threadIds);
        String jsonBody;
        for(Thread__c thread:threads){
            jsonBody+=JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r));
        }
        HttpResponse response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        return response.getStatusCode()==200;
    }

    public Boolean postConversationNotes(Set<Id> convIds){
        List<Conversation_Note__c> convNoteList=new CRM_ConversationNoteSelector().selectByIds(convIds);
        String jsonBody;
        for(Conversation_Note__c convNote:convNoteList){
            jsonBody+=JSON.serializePretty(new CRM_Henvendelse(new List<Conversation_Note__c>{convNote}));
        }
        HttpResponse response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        return response.getStatusCode()==200;
    }
}