@isTest
public class CRM_HenvRedirectController_Test {
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Thread__c());
    }

    @isTest
    static void testGetHenvId() {
        Thread__c thread = [SELECT Id, CRM_API_reference__c FROM Thread__c LIMIT 1];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = thread.Id;
        //Simulating return of the thread ID for the SOSL
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        String threadId = CRM_HenvRedirectController.getHenvRecordId(thread.CRM_API_Reference__c);
        Test.stopTest();

        System.assertEquals(thread.Id, threadId, 'Wrong thread ID');
    }
}
