@isTest
public class CRM_HenvendelseinfoRestService_Test {
    private static final String THREAD_PREFIX = Thread__c.getSObjectType().getDescribe().getKeyPrefix();
    private static final String CONV_NOTE_PREFIX = Conversation_Note__c.getSObjectType().getDescribe().getKeyPrefix();

    @TestSetup
    static void makeData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '12345678910', INT_ActorId__c = '123456789101213', INT_Confidential__c='UGRADERT', INT_LastName__c='Last')
        );

        Contact personCon = [SELECT Id, AccountId FROM Contact WHERE Account.CRM_Person__c = :dummyPerson.Id LIMIT 1];

        Conversation_Note__c convNote = (Conversation_Note__c) CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = personCon.AccountId,
                CRM_Henvendelse_BehandlingskjedeId__c = CONV_NOTE_PREFIX + '1234TEST'
            )
        );
        //Adding a follow up note to the test data
        CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = personCon.AccountId,
                CRM_Henvendelse_BehandlingskjedeId__c = CONV_NOTE_PREFIX + '1234TEST'
            )
        );
        Thread__c thread = (Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(CRM_Contact__c = personCon.Id, CRM_Account__c = personCon.AccountId)
        );

        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = 'DUMMY TEXT')
        );

        List<Journal_Entry__c> jeList = new List<Journal_Entry__c>();
        jeList.add(new Journal_Entry__c(CRM_Conversation_Note__c = convNote.Id));
        jeList.add(new Journal_Entry__c(CRM_Thread__c = thread.Id));
        CRM_HENV_TestDataFactory.createRecordList(jeList);


        AccessTokenScope__c accessTokenScope=new AccessTokenScope__c(MicrosoftGraph__c='scope');
        insert accessTokenScope;
    }

    @isTest
    static void testGetConversationNote() {        
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "X99"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        Conversation_Note__c convNote = [
            SELECT Id, CRM_Henvendelse_BehandlingskjedeId__c
            FROM Conversation_Note__c
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            convNote.CRM_Henvendelse_BehandlingskjedeId__c;
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
    static void testGetConversationNote_whenNoPersonAccess() {        
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "X99"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        makeConfidentialData();
        Conversation_Note__c convNote = [
            SELECT Id, CRM_Henvendelse_BehandlingskjedeId__c
            FROM Conversation_Note__c
            WHERE CRM_Henvendelse_BehandlingskjedeId__c =: CONV_NOTE_PREFIX + 'FORTROLIG'
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            convNote.CRM_Henvendelse_BehandlingskjedeId__c;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(403, RestContext.response.statusCode);
    }

    @isTest
    static void testGetThread() {
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', getTokenResponse(), null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        Thread__c thread = [SELECT Id, CRM_API_Reference__c FROM Thread__c LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            thread.CRM_API_Reference__c;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.headers.put('X-Azure-Token', 'token');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void testGetThread_whenNoPersonAccess() {
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "X99"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        makeConfidentialData();
        Thread__c thread = [
            SELECT Id, CRM_API_Reference__c, CRM_Henvendelse_BehandlingsId__c
            FROM Thread__c
            WHERE CRM_Henvendelse_BehandlingsId__c=:CONV_NOTE_PREFIX + 'FORTROLIG'
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            thread.CRM_API_Reference__c;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(403, RestContext.response.statusCode);
    }

    @isTest
    static void testInvalidObjextId() {
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "X99"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);       
        String accountRef = [SELECT Id FROM Account LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            accountRef;
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
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "X99"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);
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
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "X99"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);
        Thread__c thread = [SELECT Id, CRM_API_Reference__c FROM Thread__c LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            thread.CRM_API_Reference__c;
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

    @isTest
    static void testInvalidAzureToken() {
        String body = '{}';
        SingleRequestMock httpMock = new SingleRequestMock(500, 'Error', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        Thread__c thread = [SELECT Id, CRM_API_Reference__c FROM Thread__c LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestURI =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/apexrest/henvendelseinfo/henvendelse/' +
            thread.CRM_API_Reference__c;
        req.headers.put('X-Correlation-ID', '123TEST');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resp;

        Test.startTest();
        CRM_HenvendelseinfoRestService.getHenvendelse();
        Test.stopTest();

        System.assertEquals(401, RestContext.response.statusCode);
    }


    
    private static void makeConfidentialData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '92345678919', INT_ActorId__c = '923456789101219', INT_Confidential__c='FORTROLIG', INT_LastName__c='Skjermet')
        );

        Contact personCon = [SELECT Id, AccountId FROM Contact WHERE Account.CRM_Person__c = :dummyPerson.Id LIMIT 1];

        Conversation_Note__c convNote = (Conversation_Note__c) CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = personCon.AccountId,
                CRM_Henvendelse_BehandlingskjedeId__c = CONV_NOTE_PREFIX + 'FORTROLIG'
            )
        );
        //Adding a follow up note to the test data
        CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = personCon.AccountId,
                CRM_Henvendelse_BehandlingskjedeId__c = CONV_NOTE_PREFIX + 'FORTROLIG'
            )
        );
        Thread__c thread = (Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(CRM_Contact__c = personCon.Id, CRM_Account__c = personCon.AccountId, 	CRM_Henvendelse_BehandlingsId__c=CONV_NOTE_PREFIX + 'FORTROLIG')
        );

        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = 'DUMMY TEXT')
        );
    }

    private static String getTokenResponse(){
        String response='{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5HVEZ2ZEstZnl0aEV1Q...","token_type": "Bearer","expires_in": 3599,"scope": "https%3A%2F%2Fgraph.microsoft.com%2Fmail.read","refresh_token": "AwABAAAAvPM1KaPlrEqdFSBzjqfTGAMxZGUTdM0t4B4...","id_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJhdWQiOiIyZDRkMTFhMi1mODE0LTQ2YTctOD..."}';
        return response;

    }
}
