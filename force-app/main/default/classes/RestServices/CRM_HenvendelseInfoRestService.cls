@RestResource(urlmapping='/henvendelseinfo/henvendelse/*')
global without sharing class CRM_HenvendelseInfoRestService extends ApexRestService {
    @HttpGet
    global static void getHenvendelseInfo() {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
    }

    //###########################################################//
    //###############     HELPER METHODS       ##################//
    //###########################################################//
}
