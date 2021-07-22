@RestResource(urlmapping='/henvendelseinfo/henvendelse/*')
global without sharing class CRM_HenvendelseinfoRestService extends CRM_HenvendelseApiUtils {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');
    @HttpGet
    global static void getHenvendelse() {
        if (!validate()) {
            return;
        }

        String correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);
        try {
            Id henvId = (Id) getLastPathParameter();

            String objectName = henvId.getSobjectType().getDescribe().getName();

            switch on objectName {
                when 'Thread__c' {
                    Thread__c thread = new CRM_ThreadSelector().selectById(henvId);
                    setResponse(
                        200,
                        JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r))
                    );
                }
                when 'Conversation_Note__c' {
                    Conversation_Note__c convNote = new CRM_ConversationNoteSelector().selectById(henvId);
                    setResponse(200, JSON.serializePretty(new CRM_Henvendelse(convNote, convNote.Journal_Entries__r)));
                }
                when else {
                    errorResponse(400, 'Invalid reference value for henv/thread ID: ' + henvId);
                }
            }
            logger.publish();
        } catch (StringException stringEx) {
            errorResponse(400, 'Invalid ID: ' + stringEx.getMessage());
        } catch (Exception ex) {
            errorResponse(500, 'Exception: ' + ex.getMessage());
            logger.error('Exception: ' + ex.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } finally {
            logger.publish();
        }
    }
}
