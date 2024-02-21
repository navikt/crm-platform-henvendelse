@isTest
public  class HenvendelseDbService_Test {
 
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        myTriggers.disable(ConvNoteHenvendelseDbHandler.class);
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
        Boolean result=HenvendelseDbService.postThreads(new Set<Id>{thread.Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostConversationNote_oneNote(){
        List<Conversation_Note__c> convNoteList = getConversationNotes(1);

        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=HenvendelseDbService.postConversationNotes(convNoteList);
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostThreads_twoThreads(){
        List<Thread__c> threads = [SELECT Id FROM Thread__c LIMIT 2];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.PUT_HENVENDELSER_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=HenvendelseDbService.postThreads(new Set<Id>{threads[0].Id, threads[1].Id});
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostConversationNote_twoNotes(){
        List<Conversation_Note__c> convNoteList = getConversationNotes(2);
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.PUT_HENVENDELSER_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=HenvendelseDbService.postConversationNotes(convNoteList);
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }

    @isTest
    static void testPostThreads_wrongId(){
        Conversation_Note__c convNote = [SELECT Id FROM Conversation_Note__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        Boolean result=HenvendelseDbService.postThreads(new Set<Id>{convNote.Id});
        Test.stopTest();

        Assert.areEqual(false,result,'Post to db is not successful');
        Assert.areEqual(1,[SELECT COUNT() FROM Application_Log__c], 'Expect error to be logged');
    }
    @isTest
    static void testPostThreads_whenApiReturns500(){
        Thread__c thread = [SELECT Id FROM Thread__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 500, 'Internal error');

        Test.startTest();
        Boolean result=HenvendelseDbService.postThreads(new Set<Id>{thread.Id});
        Test.stopTest();

        Assert.areEqual(false,result,'Post to db has failed');
        Assert.areEqual(1,[SELECT COUNT() FROM Application_Log__c], 'Expect error to be logged');
    }

    @isTest
    static void testPostConversationNote_whenApiReturns500(){
        List<Conversation_Note__c> convNoteList =getConversationNotes(1);
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 500, 'Internal error');

        Test.startTest();
        Boolean result=HenvendelseDbService.postConversationNotes(convNoteList);
        Test.stopTest();

        Assert.areEqual(false,result,'Post to db has failed');
        Assert.areEqual(1,[SELECT COUNT() FROM Application_Log__c], 'Expect error to be logged');
    }

    private static List<Conversation_Note__c> getConversationNotes(Integer numberOfRecords){
        return [
        SELECT
        Id,
        Name,
        CRM_HenvendelseId__c,
        CRM_Henvendelse_BehandlingskjedeId__c,
        CRM_Account__r.CRM_Person__r.INT_ActorId__c,
        CRM_Account__r.CRM_Person__r.Name,
        CRM_Theme_Group_Code__c,
        CRM_Theme_Code__c,
        CRM_Office_Restriction__c,
        CRM_Read_Date__c,
        CRM_Date_Time_Registered__c,
        CRM_Conversation_Note__c,
        CRM_Created_By_Ident__c,
        CRM_Office_Restriction_Activated_By__c,
        CRM_Office_Restriction_Date__c,
        CRM_Incorrectly_Sent_Activated_By__c,
        CRM_Incorrectly_Sent_Date__c,
        CRM_Incorrectly_Sent__c,
        CRM_Disposal_Datetime__c,
        CRM_Communication_Channel__c,
        CRM_Created_By_NAV_Unit__c,
        CRM_Original_Person_GT__c,
        CRM_Original_Person_NAV_Unit__c,
        STO_Sensitive_Information__c,
        CRM_API_Reference__c
        FROM Conversation_Note__c
        LIMIT: numberOfRecords];
    }
}