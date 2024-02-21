public with sharing class HenvendelseDbService {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse DB');

    public Static Boolean postThreads(Set<Id> threadIds){
        List<Thread__c> threads = new CRM_ThreadSelector().selectByIds(threadIds);
        String jsonBody='';
        for(Thread__c thread:threads){
            jsonBody+=JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r));
        }

        HttpResponse response;
        if(threads.size()==1){
            response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        }

        else if(threads.size()>1){
            response=new HenvendelseDbCalloutService().putHenvendelser(jsonBody);
        }

        else{
            logger.error('Unbale to find thread ' + threadIds.tostring() , null, CRM_ApplicationDomain.Domain.NKS);
            logger.publish();
            return false;
        }

        if(response.getStatusCode()!=200){
            logger.error('Unbale to publish thread to db ' + response.getBody() , null, CRM_ApplicationDomain.Domain.NKS);
            logger.publish();
            return false;
        }

    
        return true;
    }

    public Static Boolean postConversationNotes(List<Conversation_Note__c> convNoteList){
        String  jsonBody+=JSON.serializePretty(new CRM_Henvendelse(convNoteList));
       
        HttpResponse response;
        if(convNoteList.size()==1){
            response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        }
        else if(convNoteList.size()>1){
            response=new HenvendelseDbCalloutService().putHenvendelser(jsonBody);
        }
        else{
            logger.error('Unbale to find conversation note' + convNoteList.tostring() , null, CRM_ApplicationDomain.Domain.NKS);
            logger.publish();
            return false;
        }

        if(response.getStatusCode()!=200){
            logger.error('Unbale to publish conversation note to db ' + response.getBody() , null, CRM_ApplicationDomain.Domain.NKS);
            logger.publish();
            return false;
        }
        return true;
    }
}