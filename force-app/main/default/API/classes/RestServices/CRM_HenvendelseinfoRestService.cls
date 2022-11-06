@RestResource(urlmapping='/henvendelseinfo/henvendelse/*')
global without sharing class CRM_HenvendelseinfoRestService extends CRM_HenvendelseApiUtils {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');
    private static CRM_HenvendelseAccessControlService accessControlService;

    @HttpGet
    global static void getHenvendelse() {
        if (!validate()) {
            return;
        }



        String correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);
        
        try {
            String apiReference = getLastPathParameter();

            String microsoftGraphToken=getMicrosoftGraphToken();         
            accessControlService=new CRM_HenvendelseAccessControlService(microsoftGraphToken);
            
            Id objectId = getObjectId(apiReference);
            String objectName = objectId != null ? objectId.getSobjectType().getDescribe().getName() : null;

            switch on objectName {
                when 'Thread__c' {
                    Thread__c thread = new CRM_ThreadSelector().selectByApiReference(apiReference);
                    Boolean hasPersonAccess=accessControlService.checkPersonAccess(thread.CRM_Account__r.CRM_Person__r.INT_Confidential__c, thread.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c);
                    
                      if(microsoftGraphToken==null){
                        errorResponse(401, 'Invalid AD-token: ' + apiReference);    
                    }
                    else if(hasPersonAccess){
                        setResponse(
                            200,
                            JSON.serializePretty(new CRM_Henvendelse(thread, thread.Messages__r, thread.Journal_Entries__r))
                        );
                    }
                    else{
                        errorResponse(403, 'No access to thread ID: ' + apiReference);    
                    }
                }
                when 'Conversation_Note__c' {
                    List<Conversation_Note__c> noteList = new CRM_ConversationNoteSelector()
                        .selectByBehandlingskjedeId(apiReference);
                    Boolean hasPersonAccess=accessControlService.checkPersonAccess(noteList[0].CRM_Account__r.CRM_Person__r.INT_Confidential__c, noteList[0].CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c);
                    if(microsoftGraphToken==null){
                        errorResponse(401, 'Invalid AD-token: ' + apiReference);    
                    }
                    else if(hasPersonAccess){
                        setResponse(200, JSON.serializePretty(new CRM_Henvendelse(noteList)));
                    }
                    else{
                        errorResponse(403, 'No access to conversation note ID: ' + apiReference);    
                    }
                    

                }
                when else {
                    errorResponse(400, 'Invalid reference value for henv/thread ID: ' + apiReference);
                }
            }
            logger.publish();
        } catch (Exception ex) {
            system.debug('Exception: ' + ex.getMessage());
            errorResponse(500, 'Exception: ' + ex.getMessage());
            logger.error(
                'Exception: ' +
                ex.getMessage() +
                '\n' +
                ex.getStackTraceString(),
                null,
                CRM_ApplicationDomain.Domain.NKS,
                correlationId
            );
        } finally {
            logger.publish();
        }
    }
}
