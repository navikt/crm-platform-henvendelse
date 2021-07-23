@RestResource(urlmapping='/henvendelse/journal/*')
global without sharing class CRM_HenvendelseJournalRestService extends CRM_HenvendelseApiUtils {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');
    @HttpPost
    global static void createJournalPost(HenvendelseJournalRequest request) {
        //Super validation handles setting the response so return if this fails
        if (!validate())
            return;

        String correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);

        try {
            Id henvId = (Id) request.kjedeId;

            String objectType = henvId.getSobjectType().getDescribe().getName();
            Map<String, Object> flowInputs = new Map<String, Object>{
                'recordId' => request.kjedeId,
                'Journal_Case_ID' => request.saksId,
                'Journal_Theme_Code' => request.temakode,
                'Journal_Entry_Unit' => request.journalforendeEnhet,
                'Journal_Entry_NAV_Ident' => getActingNavIdent()
            };

            switch on objectType {
                when 'Conversation_Note__c' {
                    initiateJournalFlow('CRM_Journal_Conversation_Note', JSON.serialize(flowInputs));
                    setResponse(200);
                }
                when 'Thread__c' {
                    initiateJournalFlow('CRM_Journal_Message_Thread', JSON.serialize(flowInputs));
                    setResponse(200);
                }
                when else {
                    errorResponse(400, 'No journal flow defined for ID: ' + henvId);
                    logger.error(
                        'No journal flow defined for ID: ' + henvId,
                        null,
                        CRM_ApplicationDomain.Domain.NKS,
                        correlationId
                    );
                }
            }
            logger.publish();
            return;
        } catch (StringException stringEx) {
            errorResponse(400, 'Invalid ID: ' + stringEx.getMessage());
            logger.error('Invalid ID: ' + stringEx.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } catch (Exception ex) {
            errorResponse(500, ex.getMessage());
            logger.error(ex.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } finally {
            logger.publish();
        }
    }

    private static void initiateJournalFlow(String flowName, String inputParams) {
        Map<String, Object> flowInputs = (Map<String, Object>) JSON.deserializeUntyped(inputParams);

        Flow.Interview journalFlow = Flow.Interview.createInterview(flowName, flowInputs);
        journalFlow.start();
    }

    global class HenvendelseJournalRequest {
        global String journalforendeEnhet;
        global String saksId;
        global String kjedeId;
        global String temakode;
    }
}
