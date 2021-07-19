@RestResource(urlmapping='/henvendelse/behandling/*')
global without sharing class CRM_HenvendelseBehandlingRestService extends CRM_HenvendelseApiUtils {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');

    @HttpPatch
    global static void updateHenvendelse(CRM_Henvendelse req) {
        RestRequest request = RestContext.request;

        if (!validate()) {
            return;
        }

        String correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, Domain.NKS);
        try {
            Id henvId = (Id) getLastPathParameter();

            String objectName = henvId.getSobjectType().getDescribe().getName();

            switch on objectName {
                when 'Thread__c' {
                    Thread__c thread = convertToThread(req);
                    SObjectAccessDecision decision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        new List<Thread__c>{ thread },
                        true
                    ); //Removes the fields that the calling part do not have access to update

                    update decision.getRecords();
                }
                when 'Conversation_Note__c' {
                    Conversation_Note__c convNote = convertToConvNote(req);
                    SObjectAccessDecision decision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        new List<Conversation_Note__c>{ convNote },
                        true
                    ); //Removes the fields that the calling part do not have access to update

                    update decision.getRecords();
                }
                when else {
                    setResponse(400, 'Invalid reference value for henv/thread ID: ' + henvId);
                }
            }
            logger.publish();
        } catch (DmlException dmlEx) {
            if (StatusCode.FIELD_INTEGRITY_EXCEPTION == dmlEx.getDmlType(0)) {
                setResponse(400, dmlEx.getMessage());
            } else {
                setResponse(500, dmlEx.getMessage());
                logger.error('DML EXCEPTION: ' + dmlEx.getMessage(), null, Domain.NKS, correlationId);
            }
        } catch (StringException stringEx) {
            setResponse(400, 'Invalid ID: ' + stringEx.getMessage());
        } catch (Exception ex) {
            setResponse(500, 'Failed to update: ' + ex.getMessage());
            logger.error('Failed to update: ' + ex.getMessage(), null, Domain.NKS, correlationId);
        } finally {
            logger.publish();
        }
    }
}
