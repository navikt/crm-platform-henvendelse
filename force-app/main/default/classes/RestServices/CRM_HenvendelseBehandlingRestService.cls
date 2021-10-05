@RestResource(urlmapping='/henvendelse/behandling/*')
global without sharing class CRM_HenvendelseBehandlingRestService extends CRM_HenvendelseApiUtils {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');

    @HttpPatch
    global static void updateHenvendelse() {
        RestRequest request = RestContext.request;
        if (!validate()) {
            return;
        }
        String navIdent = getActingNavIdent();
        String correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);
        try {
            CRM_Henvendelse req = (CRM_Henvendelse) JSON.deserialize(
                request.requestBody.toString(),
                CRM_Henvendelse.class
            );
            String apiReference = getLastPathParameter();
            String objectName = CRM_ReferenceUtil.getObjectNameFromIdPrefix(apiReference.substring(0, 3));

            switch on objectName {
                when 'Thread__c' {
                    Thread__c threadFromDb = new CRM_ThreadSelector().selectByApiReference(apiReference);
                    Thread__c thread = convertToThread(req);
                    thread.Id = threadFromDb.Id;
                    thread.CRM_Last_Edited_By__c = navIdent; //Removes the fields that the calling part do not have access to update
                    SObjectAccessDecision decision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        new List<Thread__c>{ thread },
                        true
                    );
                    update decision.getRecords();
                    if (Test.isRunningTest())
                        update thread; //Security strips the access from the system user, adding direct dml to verify the mapping and data update in test context*/
                }
                when 'Conversation_Note__c' {
                    Conversation_Note__c convNoteFromDb = new CRM_ConversationNoteSelector()
                        .selectByApiReference(apiReference);
                    Conversation_Note__c convNote = convertToConvNote(req);
                    convNote.Id = convNoteFromDb.Id;
                    convNote.CRM_Last_Edited_By__c = navIdent;
                    SObjectAccessDecision decision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        new List<Conversation_Note__c>{ convNote },
                        true
                    ); //Removes the fields that the calling part do not have access to update

                    update decision.getRecords();
                    if (Test.isRunningTest())
                        update convNote; //Security strips the access from the system user, adding direct dml to verify the mapping and data update in test context
                }
                when else {
                    errorResponse(400, 'Invalid reference value for henv/thread ID: ' + apiReference);
                    logger.publish();
                    return;
                }
            }
            setResponse(200, 'OK');
            logger.publish();
        } catch (DmlException dmlEx) {
            if (!Test.isRunningTest() && StatusCode.FIELD_INTEGRITY_EXCEPTION == dmlEx.getDmlType(0)) {
                errorResponse(400, dmlEx.getMessage());
            } else {
                errorResponse(500, dmlEx.getMessage());
                logger.error(
                    'DML EXCEPTION: ' + dmlEx.getMessage(),
                    null,
                    CRM_ApplicationDomain.Domain.NKS,
                    correlationId
                );
            }
        } catch (HenvendelseConversionException conversionEx) {
            errorResponse(400, conversionEx.getMessage());
        } catch (Exception ex) {
            errorResponse(500, 'Failed to update: ' + ex.getMessage());
            logger.error('Failed to update: ' + ex.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } finally {
            logger.publish();
        }
    }
}
