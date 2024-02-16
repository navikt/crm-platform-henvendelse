public with sharing class HenvendelseDbService {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse DB');

    public Static Boolean postThreads(Set<Id> threadIds){
        List<Thread__c> threads = new CRM_ThreadSelector().selectByIds(threadIds);
        String jsonBody;
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

    public Static Boolean postConversationNotes(Set<Id> convIds){
        List<Conversation_Note__c> convNoteList=getConversationNotes(convIds);
        String jsonBody;
        for(Conversation_Note__c convNote:convNoteList){
            jsonBody+=JSON.serializePretty(new CRM_Henvendelse(new List<Conversation_Note__c>{convNote}));
        }

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

    private static List<Conversation_Note__c> getConversationNotes(Set<Id> convIds){
        return [
        SELECT
        Id,
        Name,
        CRM_HenvendelseId__c,
        CRM_Henvendelse_BehandlingskjedeId__c,
        CRM_Account__r.CRM_Person__r.INT_ActorId__c,
        CRM_Account__r.CRM_Person__r.Name,
        CRM_Theme_Group_Code__c,
        CRM_Theme_Code__c,
        CRM_Office_Restriction__c,
        CRM_Read_Date__c,
        CRM_Date_Time_Registered__c,
        CRM_Conversation_Note__c,
        CRM_Created_By_Ident__c,
        CRM_Office_Restriction_Activated_By__c,
        CRM_Office_Restriction_Date__c,
        CRM_Incorrectly_Sent_Activated_By__c,
        CRM_Incorrectly_Sent_Date__c,
        CRM_Incorrectly_Sent__c,
        CRM_Disposal_Datetime__c,
        CRM_Communication_Channel__c,
        CRM_Created_By_NAV_Unit__c,
        CRM_Original_Person_GT__c,
        CRM_Original_Person_NAV_Unit__c,
        STO_Sensitive_Information__c,
        CRM_API_Reference__c
        FROM Conversation_Note__c
        WHERE Id in:convIds];
    }
}