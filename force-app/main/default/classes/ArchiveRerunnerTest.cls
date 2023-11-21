@isTest
private class ArchiveRerunnerTest {
    // TODO: Upload actual static resource for testing so it works
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c());
        CRM_HENV_TestDataFactory.createRecord(new Thread__c(CRM_Henvendelse_BehandlingsId__c = '123TEST'));
    }

    @isTest
    static void testRerunFailedArchivation() {
        Test.startTest();
        ArchiveRerunner.rerunFailedArchivation('ArchiveRerunnerTestResource');
        Test.stopTest();

        // TODO: Assert something
    }

}