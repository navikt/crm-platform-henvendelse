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
        HttpResponse response;

        List<CRM_Henvendelse> henvendelseList=convertToHenvendelseList(convNoteList);

        if(henvendelseList.size()==1){
            String jsonBody=JSON.serializePretty(henvendelseList[0]);
            response=new HenvendelseDbCalloutService().postHenvendelse(jsonBody);
        }

        else if(henvendelseList.size()>1){
            String jsonBody='[';

            for(Integer i=0; i<convNoteList.size();i++){
                jsonBody+=JSON.serializePretty(henvendelseList[0]);
                if(i<convNoteList.size()-1){
                    jsonBody+=',';
                }
            }
            jsonBody+=']';
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

    
    private static List<CRM_Henvendelse>  convertToHenvendelseList(List<Conversation_Note__c> convNoteList){
        Map<String, List<Conversation_Note__c>> convNoteMap = new Map<String, List<Conversation_Note__c>>(); //Mapping behandlingskjedeId to a list of conversation notes
            for (Conversation_Note__c convNote : convNoteList) {
                String behandlingskjedeId = convNote.CRM_Henvendelse_BehandlingskjedeId__c;
                if (convNoteMap.containsKey(behandlingskjedeId)) {
                    List<Conversation_Note__c> tempNotes = convNoteMap.get(behandlingskjedeId);
                    tempNotes.add(convNote);
                    convNoteMap.put(behandlingskjedeId, tempNotes);
                } else {
                    convNoteMap.put(behandlingskjedeId, new List<Conversation_Note__c>{ convNote });
                }
            }
            List<CRM_Henvendelse> retList = new List<CRM_Henvendelse>();
            for (List<Conversation_Note__c> noteList : convNoteMap.values()) {
                retList.add(new CRM_Henvendelse(noteList));
            }
    
            return retList;
        }
}