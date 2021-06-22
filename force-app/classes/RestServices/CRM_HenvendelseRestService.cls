@RestResource(urlmapping='/henvendelse/*')
global without sharing class CRM_HenvendelseRestService {
    private enum HENVENDELSE_TYPES {
        SAMTALEREFERAT,
        SKRIFTLIG
    }

    @HttpPost
    global static void createHenvendelse(HenvendelseRequest req) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;

        String threadId = request.requestURI.substringAfterLast('/');
        //New message on existing thread
        if (String.isNotBlank(threadId)) {
            try {
                Thread__c thread = [SELECT Id FROM Thread__c WHERE Id = :threadId LIMIT 1];
            } catch (QueryException qEx) {
                response.statusCode = 404;
            }
        } else {
            //New henvendelse of input type
        }
    }

    private Boolean validateInput(HenvendelseRequest req) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        if (HENVENDELSE_TYPES.valueOf(req.henvendelseType) == null) {
            response.statusCode = 400;
            throw new RestServiceException('Ugyldig henvendelsestype');
        }

        return false;
    }

    @HttpGet
    global static void getHenvendelseByReference() {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;

        try {
        } catch (QueryException qEx) {
        }
    }

    global class RestServiceException extends Exception {
    }

    global class HenvendelseRequest {
        String henvendelseId;
        String kjedeId;
        String aktorId;
        String henvendelseType;
    }
}
