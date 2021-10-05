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
            String apiReference = request.kjedeId;
            String objectType = CRM_ReferenceUtil.getObjectNameFromIdPrefix(apiReference.substring(0, 3));

            switch on objectType {
                when 'Conversation_Note__c' {
                    doConversationNoteJournal(apiReference, request);
                    setResponse(200);
                }
                when 'Thread__c' {
                    doThreadJournal(apiReference, request);
                    setResponse(200);
                }
                when else {
                    errorResponse(400, 'No journal flow defined for ID: ' + apiReference);
                    logger.error(
                        'No journal flow defined for ID: ' + apiReference,
                        null,
                        CRM_ApplicationDomain.Domain.NKS,
                        correlationId
                    );
                }
            }
            logger.publish();
            return;
        } catch (Exception ex) {
            errorResponse(500, ex.getMessage());
            logger.error(ex.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } finally {
            logger.publish();
        }
    }

    private static void doConversationNoteJournal(String apiReference, HenvendelseJournalRequest request) {
        List<Conversation_Note__c> noteList = new CRM_ConversationNoteSelector()
            .selectByBehandlingskjedeId(apiReference);

        for (Conversation_Note__c convNote : noteList) {
            Map<String, Object> flowInputs = new Map<String, Object>{
                'recordId' => convNote.Id,
                'Journal_Case_ID' => request.saksId,
                'Journal_Theme_Code' => request.temakode,
                'Journal_Entry_Unit' => request.journalforendeEnhet,
                'Journal_Entry_NAV_Ident' => getActingNavIdent()
            };
            initiateJournalFlow('CRM_Journal_Conversation_Note', JSON.serialize(flowInputs));
        }
    }

    private static void doThreadJournal(String apiReference, HenvendelseJournalRequest request) {
        Thread__c thread = new CRM_ThreadSelector().selectByApiReference(apiReference);

        Map<String, Object> flowInputs = new Map<String, Object>{
            'recordId' => thread.Id,
            'Journal_Case_ID' => request.saksId,
            'Journal_Theme_Code' => request.temakode,
            'Journal_Entry_Unit' => request.journalforendeEnhet,
            'Journal_Entry_NAV_Ident' => getActingNavIdent()
        };

        initiateJournalFlow('CRM_Thread_Create_Journal_Entry', JSON.serialize(flowInputs));
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
