@isTest
public  class HenvendelseDbService_Test {
    private static HenvendelseDbService service=new HenvendelseDbService();

    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT'));
        Thread__c thread = (Thread__c) CRM_HENV_TestDataFactory.createRecord(new Thread__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c(CRM_Thread__c = thread.Id));
    }


    @isTest
    static void testPostThread(){
        Thread__c thread = [SELECT Id FROM Thread__c LIMIT 1];
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE.name(), 200, 'OK');

        Test.startTest();
        Boolean result=service.postThread(thread.Id);
        Test.stopTest();

        Assert.areEqual(true,result,'Post to db should be successful');
    }
}