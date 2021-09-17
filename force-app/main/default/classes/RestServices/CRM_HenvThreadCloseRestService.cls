@RestResource(urlmapping='/henvendelse/meldingskjede/lukk')
global without sharing class CRM_HenvThreadCloseRestService extends CRM_HenvendelseApiUtils {
    private static String correlationId;
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');

    @HttpPost
    global static void closeThread() {
        //Super validation handles setting the response so return if this fails
        if (!validate())
            return;

        correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);
        String encodedKjedeId = getRequestParam('kjedeId');
        String threadId = decodeReference(encodedKjedeId);

        try {
            Thread__c thread = new CRM_ThreadSelector().selectById(threadId);
            if (thread != null) {
                thread.CRM_isActive__c = false;
                update thread;
                setResponse(200, 'OK');
            } else {
                errorResponse(404, 'No henvendelse found with reference: ' + encodedKjedeId);
            }
        } catch (DmlException dmlEx) {
            errorResponse(500, 'Failed to close thread: ' + dmlEx.getMessage());
            logger.error('DML EXCEPTION: ' + dmlEx.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } catch (Exception ex) {
            errorResponse(500, 'Failed to close thread: ' + ex.getMessage());
            logger.error(
                'Failed to close thread: ' + ex.getMessage(),
                null,
                CRM_ApplicationDomain.Domain.NKS,
                correlationId
            );
        } finally {
            logger.publish();
        }
    }
}
