@IsTest
public  class ConvNoteHenvendelseDbHandler_Test {
    
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        
    }

    @IsTest
    private static void testOnAfterInsert(){
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Test.startTest();
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT'));
        Test.stopTest();

        Assert.areEqual(0,[SELECT COUNT() FROM Application_Log__c], 'Expect no error logs');
    }

    @IsTest
    private static void testOnAfterUpdate(){
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        Conversation_Note__c convNote=(Conversation_Note__c)CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT'));
        Test.startTest();
        convNote.CRM_Is_Read__c=true;
        update convNote;
        Test.stopTest();

        Assert.areEqual(0,[SELECT COUNT() FROM Application_Log__c], 'Expect no error logs');
    }

}