@RestResource(urlmapping='/henvendelse/*')
global without sharing class CRM_HenvendelseRestService extends ApexRestService {
    private enum HENVENDELSE_TYPES {
        SAMTALEREFERAT,
        CHAT,
        ASYNC_CHAT
    }

    @HttpPost
    global static void createHenvendelse(HenvendelseRequest req) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;

        String threadId = request.requestURI.substringAfterLast('/');
        //New message on existing thread
        if (String.isNotBlank(threadId)) {
            try {
                Thread__c thread = [SELECT Id FROM Thread__c WHERE Id = :threadId LIMIT 1];
            } catch (QueryException qEx) {
                response.statusCode = 404;
            }
        } else {
            //New henvendelse of input type
        }
    }

    @HttpGet
    global static void getHenvendelseByReference() {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        Id referenceId;

        try {
            referenceId = (Id) getLastPathParameter();
            String objName = referenceId.getSObjectType().getDescribe().getName();

            switch on objName {
                when 'Message__c' {
                    //Do message query
                }
                when 'Conversation_Note__c' {
                    //Do Conversation Note Query
                    List<Conversation_Note__c> convNotes = new CRM_ConversationNoteSelector()
                        .selectById(new Set<Id>{ referenceId });
                    setResponse(200, 'WRAPPER');
                }
                when else {
                    setResponse(400, 'Invalid reference');
                }
            }
        } catch (StringException stringEx) {
            setResponse(400, 'Invalid reference: ' + stringEx.getMessage());
        }
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//

    private Boolean validateInput(HenvendelseRequest req) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        if (HENVENDELSE_TYPES.valueOf(req.henvendelseType) == null) {
        }

        return false;
    }

    global class HenvendelseRequest {
        String henvendelseId;
        String kjedeId;
        String aktorId;
        String henvendelseType;
    }
}
