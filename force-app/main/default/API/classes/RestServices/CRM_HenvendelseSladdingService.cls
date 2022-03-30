@RestResource(urlmapping='/henvendelse/sladding/*')
public without sharing class CRM_HenvendelseSladdingService {
    private static LoggerUtility logger = new LoggerUtility('Henvendelse API');

    @HttpPost
    global static void setToRedaction() {
        RestRequest request = RestContext.request;
        if (!validate()) {
            return;
        }

        //NEED TO SERIALIZE RESPONSE TO GET THE REDACTION CAUSE AND OPTIONAL FREE TEXT
        //SladdeRequest slReq = JSON.deserialize(request.requestBody.toString(), SladdeRequest.class);

        String navIdent = getActingNavIdent();
        String correlationId = getXCorrelation();
        logger.apiTransaction(correlationId, RestContext.request, CRM_ApplicationDomain.Domain.NKS);

        try {
            String apiReference = getLastPathParameter();
            Id objectId = getObjectId(apiReference);
            String objectName = objectId != null ? objectId.getSobjectType().getDescribe().getName() : null;

            switch on objectName {
                when 'Thread__c' {
                    update new Thread__c(
                        Id = objectId,
                        CRM_Sensitive_Information__c = true,
                        CRM_Cause__c = 'CAUSE FROM BODY'
                    );
                }
                when 'Conversation_Note__c' {
                    update new Conversation_Note__c(
                        Id = objectId,
                        CRM_Sensitive_Information__c = true,
                        CRM_Cause__c = 'CAUSE FROM BODY'
                    );
                }
                when else {
                    errorResponse(400, 'Invalid reference value for henv/thread ID: ' + apiReference);
                    logger.publish();
                    return;
                }
            }
        } catch (DmlException dmlEx) {
            errorResponse(500, dmlEx.getMessage());
            logger.error('DML EXCEPTION: ' + dmlEx.getMessage(), null, CRM_ApplicationDomain.Domain.NKS, correlationId);
        } catch (Exception ex) {
            errorResponse(500, 'Failed to update: ' + ex.getMessage());
            logger.error(
                'Failed to update: ' +
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

    private class SladdeRequest {
        public REDACTION_CAUSE aarsakskode;
        public String fritekst; //Optional free text
    }

    //CHALLENGE WITH DIFFERENT REDACTION CAUSES FOR DIFFERENT HENV TYPES?
    private String getConvertedRedactionCause(REDACTION_CAUSE cause) {
        switch on cause {
            when SENDT_FEIL_BRUKER {
                return 'Sendt feil bruker';
            }
            when OKONOMISK_SOSIALHJELP {
                return 'Økonomisk sosialhjelp';
            }
            when SIKKERHETSHENDELSE {
                return 'Sikkerhetshendelse';
            }
            when UTENFOR_NAVS_BEHANDLINGSOMRADE {
                return 'Utenfor NAVs behandlingsområde';
            }
            when ANNEN {
                return '';
            }
            when else {
                return null;
            }
        }
    }

    private enum REDACTION_CAUSE {
        SENDT_FEIL_BRUKER,
        OKONOMISK_SOSIALHJELP,
        SIKKERHETSHENDELSE,
        UTENFOR_NAVS_BEHANDLINGSOMRADE,
        ANNEN
    }
}
