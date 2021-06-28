@RestResource(urlmapping='/henvendelse/ny/*')
global without sharing class CRM_HenvendelseRestService extends CRM_HenvendelseApiUtils {
    @HttpPost
    global static void createHenvendelse(CRM_Henvendelse req) {
        RestRequest request = RestContext.request;

        try {
            String henvType = getLastPathParameter();
            String threadId = getRequestParam('kjedeId');

            if (String.isBlank(henvType)) {
                setResponse(400, 'Henvendelse type cannot be blank or null');
                return;
            } else if (HENVENDELSE_TYPES.valueOf(henvType.toUpperCase()) == null) {
                setResponse(
                    400,
                    'Invalid henvendelse type: ' +
                    henvType +
                    '\n Approved types are: ' +
                    JSON.serializePretty(HENVENDELSE_TYPES.values())
                );
                return;
            }
        } catch (Exception ex) {
        }
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//

    private static Boolean validateInput(CRM_Henvendelse req) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        if (HENVENDELSE_TYPES.valueOf(req.henvendelseType) == null) {
        }

        return false;
    }
}
