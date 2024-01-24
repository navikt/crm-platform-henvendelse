public with sharing class HenvendelseDbService {
    
    public static void postThread(Id threadId){
        Thread__c thread = new CRM_ThreadSelector().selectById(threadId);
        string jsonBody=JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r));
        postToHenvendelseDbApi(jsonBody);
    }

    private static void postToHenvendelseDbApi(String jsonBody){

    }
}