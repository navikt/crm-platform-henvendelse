@isTest
public class CRM_HenvendelseInfoListRestService_Test {
    @TestSetup
    static void makeData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '12345678910', INT_ActorId__c = '123456789101213')
        );

        Account personAcc = [
            SELECT Id, FirstName, LastName, PersonContactId
            FROM Account
            WHERE CRM_Person__c = :dummyPerson.Id
            LIMIT 1
        ];
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
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Account__c = personAcc.Id));
        Thread__c thread = (Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(CRM_From__c = portalUser.Id)
        );
        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = 'DUMMY TEXT')
        );
    }

    @isTest
    static void testGetHenvendelseList() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelseinfo/henvendelseliste';
        req.httpMethod = 'GET';
        req.params.put('aktorid', '123456789101213');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseInfoListRestService.getHenvendelseList();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void testGetHenvedelseListQueryException() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelseinfo/henvendelseliste';
        req.httpMethod = 'GET';
        req.params.put('aktorid', '123456789101213');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseInfoListRestService.simulateException(new QueryException('DUMMY ERROR'));
        CRM_HenvendelseInfoListRestService.getHenvendelseList();
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest
    static void testGetHenvedelseListException() {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/henvendelseinfo/henvendelseliste';
        req.httpMethod = 'GET';
        req.params.put('aktorid', '123456789101213');
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseInfoListRestService.simulateException(new JSONException('DUMMY ERROR'));
        CRM_HenvendelseInfoListRestService.getHenvendelseList();
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode);
    }
}
