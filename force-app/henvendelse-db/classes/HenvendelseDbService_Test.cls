@isTest
public  class HenvendelseDbService_Test {
    private static HenvendelseDbService service=new HenvendelseDbService();

    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT'));
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT 2'));
        
        Thread__c thread1 = (Thread__c) CRM_HENV_TestDataFactory.createRecord(new Thread__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c(CRM_Thread__c = thread1.Id));

        Thread__c thread2 = (Thread__c) CRM_HENV_TestDataFactory.createRecord(new Thread__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c(CRM_Thread__c = thread2.Id));
    }


    @isTest
    static void testPostThreads_oneThread(){
        Thread__c thread = [SELECT Id FROM Thread__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postThreads(new Set<Id>{thread.Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostConversationNote_oneNote(){
        Conversation_Note__c convNote = [SELECT Id FROM Conversation_Note__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postConversationNotes(new Set<Id>{convNote.Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostThreads_twoThreads(){
        List<Thread__c> threads = [SELECT Id FROM Thread__c LIMIT 2];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.PUT_HENVENDELSER_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postThreads(new Set<Id>{threads[0].Id, threads[1].Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostConversationNote_twoNotes(){
        List<Conversation_Note__c> convNotes = [SELECT Id FROM Conversation_Note__c LIMIT 2];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.PUT_HENVENDELSER_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postConversationNotes(new Set<Id>{convNotes[0].Id, convNotes[1].Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostThreads_wrongId(){
        Conversation_Note__c convNote = [SELECT Id FROM Conversation_Note__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postThreads(new Set<Id>{convNoted.Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostConversationNote_wrongId(){
        Thread__c thread = [SELECT Id FROM Thread__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postConversationNotes(new Set<Id>{thread.Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    
}