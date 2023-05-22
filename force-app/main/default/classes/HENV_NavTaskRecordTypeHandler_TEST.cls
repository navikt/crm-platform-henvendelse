@isTest
public class HENV_NavTaskRecordTypeHandler_TEST {
    @isTest
    static void testRecordTypeHandling() {
        NavTask__c testTask = (NavTask__c) CRM_HENV_TestDataFactory.createRecord(new NavTask__c());

        Test.startTest();
        testTask.name = 'testing more';
        update testTask;
        Test.stopTest();

        //No asserts as actual function not triggered in core package
    }
}
