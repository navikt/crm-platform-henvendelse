@isTest
public class CRM_HenvendelseNyRestService_Test {
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Person__c(INT_ActorId__c = '123456789101112'));
    }

    @isTest
    static void testNewConversationNote() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        CRM_HenvendelseNyRestService.NewConversationNoteRequest convNoteReq = new CRM_HenvendelseNyRestService.NewConversationNoteRequest();
        convNoteReq.aktorId = '123456789101112';
        convNoteReq.enhet = '4100';
        convNoteReq.kanal = 'TELEFON';
        convNoteReq.temagruppe = 'ARBD';
        convNoteReq.fritekst = 'REFERAT';

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelse/ny/samtalereferat';
        req.httpMethod = 'POST';
        req.headers.put('X-Correlation-ID', '123RANDOM');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseNyRestService.createHenvendelse(JSON.serialize(convNoteReq));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Conversation_Note__c]);
    }

    @isTest
    static void testNewConversationNoteInvalidBody() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        String requestBody = '[]';

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelse/ny/samtalereferat';
        req.httpMethod = 'POST';
        req.headers.put('X-Correlation-ID', '123RANDOM');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseNyRestService.createHenvendelse(requestBody);
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(0, [SELECT COUNT() FROM Conversation_Note__c]);
    }

    @isTest
    static void testNewNonExistingActorConvNote() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        CRM_HenvendelseNyRestService.NewConversationNoteRequest convNoteReq = new CRM_HenvendelseNyRestService.NewConversationNoteRequest();
        convNoteReq.aktorId = '1234567890000';
        convNoteReq.enhet = '4100';
        convNoteReq.kanal = 'TELEFON';
        convNoteReq.temagruppe = 'ARBD';
        convNoteReq.fritekst = 'REFERAT';

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelse/ny/samtalereferat';
        req.httpMethod = 'POST';
        req.headers.put('X-Correlation-ID', '123RANDOM');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseNyRestService.createHenvendelse(JSON.serialize(convNoteReq));
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assertEquals(0, [SELECT COUNT() FROM Conversation_Note__c]);
    }

    @isTest
    static void testNewConversationNoteDmlException() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        CRM_HenvendelseNyRestService.NewConversationNoteRequest convNoteReq = new CRM_HenvendelseNyRestService.NewConversationNoteRequest();
        convNoteReq.aktorId = '123456789101112';
        convNoteReq.enhet = '4100';
        convNoteReq.kanal = 'TELEFON';
        convNoteReq.temagruppe = 'ARBD';
        convNoteReq.fritekst = 'REFERAT';

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelse/ny/samtalereferat';
        req.httpMethod = 'POST';
        req.headers.put('X-Correlation-ID', '123RANDOM');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseNyRestService.simulateException(new DmlException('TESTING'));
        CRM_HenvendelseNyRestService.createHenvendelse(JSON.serialize(convNoteReq));
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest
    static void testInvalidType() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        CRM_HenvendelseNyRestService.NewConversationNoteRequest convNoteReq = new CRM_HenvendelseNyRestService.NewConversationNoteRequest();

        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelse/ny/invalidtype';
        req.httpMethod = 'POST';
        req.headers.put('X-Correlation-ID', '123RANDOM');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseNyRestService.createHenvendelse(JSON.serialize(convNoteReq));
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testMissingCorrelationHeader() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        CRM_HenvendelseNyRestService.NewConversationNoteRequest convNoteReq = new CRM_HenvendelseNyRestService.NewConversationNoteRequest();

        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelse/ny/invalidtype';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseNyRestService.createHenvendelse(JSON.serialize(convNoteReq));
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }
}
