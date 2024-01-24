public with sharing class HenvendelseDbService {

    public Boolean postThread(Id threadId){
        Thread__c thread = new CRM_ThreadSelector().selectById(threadId);
        string jsonBody=JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r));
        HttpResponse response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        return response.getStatusCode()==200;
    }
}