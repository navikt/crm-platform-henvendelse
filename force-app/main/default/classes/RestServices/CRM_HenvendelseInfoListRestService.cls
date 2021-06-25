@RestResource(urlmapping='/henvendelseinfo/henvendelseliste/*')
global without sharing class CRM_HenvendelseInfoListRestService extends ApexRestService {
    @HttpGet
    global static void getHenvendelseList() {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        String actorId = getRequestParam('aktorid');

        if (String.isBlank(actorId)) {
            setResponse(400, 'Missing required query input: aktorid');
            return;
        }

        try {
            List<CRM_Henvendelse> returnList = new List<CRM_Henvendelse>();
            List<Conversation_Note__c> convList = new CRM_ConversationNoteSelector()
                .selectByActorId(new Set<String>{ actorId });
            returnList.addAll(convertToHenvendelseList(convList));

            List<Thread__c> threadList = new CRM_ThreadSelector().selectByActorId(new Set<String>{ actorId });
            returnList.addAll(convertToHenvendelseList(threadList));

            setResponse(200, JSON.serializePretty(returnList));
        } catch (QueryException queryEx) {
            setResponse(500, 'Query exception: ' + queryEx.getMessage());
        } catch (Exception ex) {
            setResponse(500, 'Exception: ' + ex.getMessage() + ex.getStackTraceString());
        }
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//

    private static List<CRM_Henvendelse> convertToHenvendelseList(List<Conversation_Note__c> convList) {
        List<CRM_Henvendelse> retList = new List<CRM_Henvendelse>();
        for (Conversation_Note__c convNote : convList) {
            retList.add(new CRM_Henvendelse(convNote, convNote.Journal_Entries__r));
        }

        return retList;
    }

    private static List<CRM_Henvendelse> convertToHenvendelseList(List<Thread__c> threadList) {
        List<CRM_Henvendelse> retList = new List<CRM_Henvendelse>();
        for (Thread__c thread : threadList) {
            retList.add(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r));
        }

        return retList;
    }
}
