@isTest
public class CRM_ThreadReferenceHandler_Test {
    @isTest
    static void testReferenceGeneration() {
        Test.startTest();
        CRM_HENV_TestDataFactory.createRecord(new Thread__c());
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Thread__c WHERE CRM_API_Reference__c != NULL]);
    }
}
