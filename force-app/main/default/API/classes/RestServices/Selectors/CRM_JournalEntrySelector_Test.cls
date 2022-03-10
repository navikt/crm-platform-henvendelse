@isTest
public class CRM_JournalEntrySelector_Test {
    @isTest
    static void testSelector() {
        Journal_Entry__c jEntry = (Journal_Entry__c) CRM_HENV_TestDataFactory.createRecord(new Journal_Entry__c());

        Test.startTest();
        List<Journal_Entry__c> jeList = new CRM_JournalEntrySelector().selectById(new Set<Id>{ jEntry.Id });
        Test.stopTest();

        System.assert(!jeList.isEmpty());
    }
}
