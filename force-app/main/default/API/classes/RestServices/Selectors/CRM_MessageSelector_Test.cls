@isTest
public class CRM_MessageSelector_Test {
    @isTest
    static void testSelector() {
        Message__c msg = (Message__c) CRM_HENV_TestDataFactory.createRecord(new Message__c());

        Test.startTest();
        List<Message__c> messages = new CRM_MessageSelector().selectById(new Set<Id>{ msg.Id });
        Test.stopTest();

        System.assert(!messages.isEmpty());
    }
}
