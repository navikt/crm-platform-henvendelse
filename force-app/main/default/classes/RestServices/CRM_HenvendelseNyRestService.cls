@RestResource(urlmapping='/henvendelse/ny/*')
global without sharing class CRM_HenvendelseNyRestService extends CRM_HenvendelseApiUtils {
    private static final String SAMTALEREFERAT_TYPE = HENVENDELSE_TYPES.SAMTALEREFERAT.name();
    private static final String MELDING_TYPE = HENVENDELSE_TYPES.MELDING.name();

    @HttpPost
    global static void createHenvendelse(String requestBody) {
        RestRequest request = RestContext.request;

        try {
            HENVENDELSE_TYPES henvType = HENVENDELSE_TYPES.valueOf(getLastPathParameter());
            String threadId = getRequestParam('kjedeId');

            switch on henvType {
                when SAMTALEREFERAT {
                    handleNewConversationNote(requestBody);
                }
                when MELDING {
                    handleNewMessage(requestBody);
                }
                when else {
                    setResponse(
                        400,
                        'Invalid henvendelse type: ' +
                        henvType +
                        '\n Approved types are: ' +
                        JSON.serializePretty(HENVENDELSE_TYPES.values())
                    );
                    return;
                }
            }
        } catch (Exception ex) {
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
            setResponse(500, 'Insertion failed: ' + dmlEx.getMessage());
        }
    }

    private static String getAccountId(String actorId) {
        return [SELECT CRM_Account__c FROM Person__c WHERE INT_ActorId__c = :actorId]?.CRM_Account__c;
    }

    private static void handleNewMessage(String req) {
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//

    private static Conversation_Note__c validateNewConversationNote(String req) {
        NewConversationNoteRequest convRequest;
        try {
            convRequest = (NewConversationNoteRequest) JSON.deserializeStrict(req, NewConversationNoteRequest.class);
        } catch (JSONException jsonEx) {
            setResponse(400, 'Invalid request body: ' + jsonEx.getMessage());
            return null;
        }

        String accountId = getAccountId(convRequest.aktorId);
        if (String.isBlank(accountId)) {
            setResponse(404, 'No person with actor ID: ' + convRequest.aktorId);
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

    private static NewMessageRequest validateNewMessage(String req) {
        NewMessageRequest messageRequest;
        try {
            messageRequest = (NewMessageRequest) JSON.deserializeStrict(req, NewConversationNoteRequest.class);
        } catch (JSONException jsonEx) {
            setResponse(400, 'Invalid request body: ' + jsonEx.getMessage());
        }
        return messageRequest;
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
