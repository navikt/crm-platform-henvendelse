@isTest
public class CRM_HenvendelseinfoRestService_Test {
    @TestSetup
    static void makeData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '12345678910', INT_ActorId__c = '123456789101213')
        );

        User accountOwner = [
            SELECT Id
            FROM User
            WHERE UserRoleId != NULL AND isActive = TRUE AND IsPortalEnabled = FALSE
            LIMIT 1
        ];

        Account personAcc = [
            SELECT Id, FirstName, LastName, PersonContactId
            FROM Account
            WHERE CRM_Person__c = :dummyPerson.Id
            LIMIT 1
        ];
        personAcc.OwnerId = accountOwner.Id;
        update personAcc;

        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1];
        User portalUser = (User) CRM_HENV_TestDataFactory.createRecord(
            new User(
                FirstName = personAcc.FirstName,
                LastName = personAcc.LastName,
                ContactId = personAcc.PersonContactId,
                ProfileId = portalProfile.Id,
                Username = personAcc.FirstName + '.' + personAcc.LastName + '@testing.com'
            )
        );

        Conversation_Note__c convNote = (Conversation_Note__c) CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(CRM_Account__c = personAcc.Id)
        );
        Thread__c thread = (Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(CRM_From__c = portalUser.Id)
        );
        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = 'DUMMY TEXT')
        );

        List<Journal_Entry__c> jeList = new List<Journal_Entry__c>();
        jeList.add(new Journal_Entry__c(CRM_Conversation_Note__c = convNote.Id));
        jeList.add(new Journal_Entry__c(CRM_Thread__c = thread.Id));
        CRM_HENV_TestDataFactory.createRecordList(jeList);
    }

    @isTest
    static void testGetConversationNote() {
        String convNoteId = [SELECT Id FROM Conversation_Note__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            convNoteId;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void testGetThread() {
        String threadId = [SELECT Id FROM Thread__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            threadId;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void testInvalidObjextId() {
        String account = [SELECT Id FROM Account LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            account;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testInvalidId() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            'INVALID';
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testException() {
        String threadId = [SELECT Id FROM Thread__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            threadId;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.simulateException(new QueryException('TEST'));
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode);
    }
}
