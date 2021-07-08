@RestResource(urlmapping='/henvendelse/ny/*')
global without sharing class CRM_HenvendelseNyRestService extends CRM_HenvendelseApiUtils {
    private static final String SAMTALEREFERAT_TYPE = HENVENDELSE_TYPE.SAMTALEREFERAT.name();
    private static final String MELDING_TYPE = HENVENDELSE_TYPE.MELDING.name();

    @HttpPost
    global static void createHenvendelse(String requestBody) {
        //Super validation handles setting the response so return if this fails
        if (!validate())
            return;

        RestRequest request = RestContext.request;

        try {
            HENVENDELSE_TYPE henvType = getHenvendelseType(getLastPathParameter());
            String threadId = getRequestParam('kjedeId');

            switch on henvType {
                when SAMTALEREFERAT {
                    handleNewConversationNote(requestBody);
                }
                when MELDING {
                    handleNewMessage(requestBody, threadId);
                }
                when else {
                    errorResponse(
                        400,
                        'Invalid henvendelse type: ' +
                        henvType +
                        '\n Approved types are: ' +
                        JSON.serializePretty(HENVENDELSE_TYPE.values())
                    );
                    return;
                }
            }
        } catch (Exception ex) {
            errorResponse(500, 'Unknown error: ' + ex.getMessage());
        }
    }

    private static void handleNewConversationNote(String req) {
        Conversation_Note__c newNote = validateNewConversationNote(req);
        if (newNote == null)
            return; //Failed validation

        try {
            insert newNote;
            setResponse(200, newNote.Id);
        } catch (DmlException dmlEx) {
            errorResponse(500, 'Insertion failed: ' + dmlEx.getMessage());
        }
    }

    private static String getAccountId(String actorId) {
        return [SELECT CRM_Account__c FROM Person__c WHERE INT_ActorId__c = :actorId]?.CRM_Account__c;
    }

    private static void handleNewMessage(String req, String threadId) {
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//

    private static Conversation_Note__c validateNewConversationNote(String req) {
        NewConversationNoteRequest convRequest;
        try {
            convRequest = (NewConversationNoteRequest) JSON.deserializeStrict(req, NewConversationNoteRequest.class);
        } catch (JSONException jsonEx) {
            errorResponse(400, 'Invalid request body: ' + jsonEx.getMessage());
            return null;
        }

        String accountId = getAccountId(convRequest.aktorId);
        if (String.isBlank(accountId)) {
            errorResponse(404, 'No person with actor ID: ' + convRequest.aktorId);
            return null;
        }

        String actingNavIdent = getActingNavIdent();
        return new Conversation_Note__c(
            CRM_Account__c = accountId,
            CRM_Conversation_Note__c = convRequest.fritekst,
            CRM_Created_By_Ident__c = actingNavIdent,
            CRM_Created_By_NAV_Unit__c = convRequest.enhet
        );
    }

    private static Message__c validateNewMessage(String req, String threadId) {
        NewMessageRequest messageRequest;
        Message__c newMessage = new Message__c();
        try {
            messageRequest = (NewMessageRequest) JSON.deserializeStrict(req, NewConversationNoteRequest.class);
        } catch (JSONException jsonEx) {
            errorResponse(400, 'Invalid request body: ' + jsonEx.getMessage());
            return null;
        }

        String accountId = getAccountId(messageRequest.aktorId);
        if (String.isBlank(accountId)) {
            errorResponse(404, 'No person with actor ID: ' + messageRequest.aktorId);
            return null;
        }

        if (String.isNotBlank(threadId)) {
            //Validate if the thread is open and existing
            try {
                Thread__c thread = new CRM_ThreadSelector().selectById(threadId);
                if (thread.CRM_isActive__c == false) {
                    errorResponse(403, 'Cannot insert new message on closed thread');
                    return null;
                } else {
                    newMessage.CRM_Thread__c = thread.Id;
                }
            } catch (QueryException queryEx) {
                //The thread does not exist
                errorResponse(404, 'Message thread does not exist: ' + queryEx.getMessage());
                return null;
            }
        } else {
            //Create new thread?
        }

        newMessage.CRM_Message_Text__c = messageRequest.fritekst;
        newMessage.CRM_From_NAV_Unit__c = messageRequest.enhet;

        return newMessage;
    }

    global class NewMessageRequest {
        global String aktorId;
        global String temagruppe;
        global String enhet;
        global String fritekst;
    }

    global class NewConversationNoteRequest {
        global String aktorId;
        global String temagruppe;
        global String enhet;
        global String fritekst;
        global String kanal; //Separate between phone and physical meet?
    }
}
