@RestResource(urlmapping='/henvendelse/ny/*')
global without sharing class CRM_HenvendelseNyRestService extends CRM_HenvendelseApiUtils {
    private static final String SAMTALEREFERAT_TYPE = HENVENDELSE_TYPE.SAMTALEREFERAT.name();
    private static final String MELDING_TYPE = HENVENDELSE_TYPE.MELDING.name();
    private static String correlationId;
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');

    @HttpPost
    global static void createHenvendelse() {
        //Super validation handles setting the response so return if this fails
        if (!validate())
            return;

        correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);

        RestRequest request = RestContext.request;

        try {
            HENVENDELSE_TYPE henvType = getHenvendelseType(getLastPathParameter());
            String kjedeId = getRequestParam('kjedeId');

            switch on henvType {
                when SAMTALEREFERAT {
                    handleNewConversationNote(request.requestBody.toString(), kjedeId);
                }
                when MELDING {
                    handleNewMessage(request.requestBody.toString(), kjedeId);
                }
                when else {
                    errorResponse(
                        400,
                        'Invalid henvendelse type: ' +
                        henvType +
                        '\n Approved types are: ' +
                        JSON.serializePretty(HENVENDELSE_TYPE.values())
                    );
                }
            }
            logger.publish();
        } catch (Exception ex) {
            errorResponse(500, 'Unknown error: ' + ex.getMessage());
            logger.error('Unknown error: ' + ex.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } finally {
            logger.publish();
        }
    }

    private static void handleNewConversationNote(String req, String kjedeId) {
        Conversation_Note__c newNote = validateNewConversationNote(req, kjedeId);
        if (newNote == null)
            return; //Failed validation

        try {
            insert newNote;
            setResponse(200, newNote.Id);
        } catch (DmlException dmlEx) {
            errorResponse(500, 'Insertion failed: ' + dmlEx.getMessage());
            logger.error(
                'Insertion failed: ' + dmlEx.getMessage(),
                null,
                CRM_ApplicationDomain.Domain.NKS,
                correlationId
            );
        }
    }

    private static void handleNewMessage(String req, String threadId) {
        Message__c newMessage = validateNewMessage(req, threadId);
        if (newMessage == null)
            return; //Failed validation

        try {
            insert newMessage;
            setResponse(200, newMessage.CRM_Thread__c); //Returns the ID of the thread
        } catch (DmlException dmlEx) {
            errorResponse(500, 'Insertion failed: ' + dmlEx.getMessage());
            logger.error(
                'Insertion failed: ' + dmlEx.getMessage(),
                null,
                CRM_ApplicationDomain.Domain.NKS,
                correlationId
            );
        }
    }

    @future
    private static void closeThread(String threadId) {
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//

    /**
     * @description: Gets the CRM_Account__c from the Person record with the matching actorId, null if not found
     * @author Stian Ruud Schikora | 07-08-2021
     * @param actorId
     * @return String
     **/
    private static String getAccountId(String actorId) {
        return [SELECT CRM_Account__c FROM Person__c WHERE INT_ActorId__c = :actorId]?.CRM_Account__c;
    }

    /**
     * @description: Validates an incoming request for insertion of a new conversation note. If the request validates
     * a valid Conversation_Note__c record is returned, else null
     * @author Stian Ruud Schikora | 07-08-2021
     * @param req
     * @return Conversation_Note__c
     **/
    private static Conversation_Note__c validateNewConversationNote(String req, String kjedeId) {
        NewConversationNoteRequest convRequest;
        Conversation_Note__c newNote = new Conversation_Note__c();
        try {
            convRequest = (NewConversationNoteRequest) JSON.deserializeStrict(req, NewConversationNoteRequest.class);
        } catch (JSONException jsonEx) {
            errorResponse(400, 'Invalid request body: ' + jsonEx.getMessage());
            return null;
        }

        if (String.isNotBlank(kjedeId)) {
            //Validate if the conversation note chain exists
            Conversation_Note__c chainStarter = new CRM_ConversationNoteSelector().selectById(kjedeId);
            if (chainStarter == null) {
                errorResponse(404, 'Conversation note chain does not exists: ' + kjedeId);
                return null;
            } else {
                newNote.CRM_Henvendelse_BehandlingskjedeId__c = kjedeId;
            }
        }

        String accountId = getAccountId(convRequest.aktorId);
        if (String.isBlank(accountId)) {
            errorResponse(404, 'No person with actor ID: ' + convRequest.aktorId);
            return null;
        }

        //Method from CRM_HenvendelseApiUtils
        String actingNavIdent = getActingNavIdent();
        newNote.CRM_Account__c = accountId;
        newNote.CRM_Conversation_Note__c = convRequest.fritekst;
        newNote.CRM_Created_By_Ident__c = actingNavIdent;
        newNote.CRM_Created_By_NAV_Unit__c = convRequest.enhet;
        newNote.CRM_Theme_Group__c = getThemeGroup(convRequest.temagruppe);
        newNote.CRM_Theme__c = getTheme(convRequest.tema);
        return newNote;
    }

    /**
     * @description: Validates an incoming request for insertion of a new message. If the request validates
     * a valid Message__c record is returned, else null
     * @author Stian Ruud Schikora | 07-08-2021
     * @param req
     * @param threadId
     * @return Message__c
     **/
    private static Message__c validateNewMessage(String req, String threadId) {
        NewMessageRequest messageRequest;
        Message__c newMessage = new Message__c();
        String actingNavIdent = getActingNavIdent();

        try {
            messageRequest = (NewMessageRequest) JSON.deserializeStrict(req, NewMessageRequest.class);
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
            try {
                Thread__c newThread = new Thread__c(
                    Name = 'Skriv til bruker',
                    CRM_Account__c = accountId,
                    CRM_Created_By_Ident__c = actingNavIdent,
                    CRM_Created_By_NAV_Unit__c = messageRequest.enhet,
                    CRM_Theme_Group__c = getThemeGroup(messageRequest.temagruppe),
                    CRM_Theme__c = getTheme(messageRequest.tema),
                    CRM_isActive__c = messageRequest.lukkTraad
                );
                insert newThread;
                newMessage.CRM_Thread__c = newThread.Id;
            } catch (DmlException dmlEx) {
                errorResponse(500, 'Unexpected error: ' + dmlEx.getMessage());
                logger.error(
                    'Unexpected error: ' + dmlEx.getMessage(),
                    null,
                    CRM_ApplicationDomain.Domain.NKS,
                    correlationId
                );
                return null;
            }
        }

        newMessage.CRM_Message_Text__c = messageRequest.fritekst;
        newMessage.CRM_From_NAV_Unit__c = messageRequest.enhet;
        newMessage.CRM_From_Ident__c = actingNavIdent;
        if (messageRequest.lukkTraad)
            closeThread(threadId);

        return newMessage;
    }

    global class NewMessageRequest {
        global String aktorId;
        global String temagruppe;
        global String tema;
        global String enhet;
        global String fritekst;
        global Boolean lukkTraad = false; //Boolean to automatically close thread after posting the new message
    }

    global class NewConversationNoteRequest {
        global String aktorId;
        global String temagruppe;
        global String tema;
        global String enhet;
        global String fritekst;
        global String kanal; //Separate between phone and physical meet?
    }
}
