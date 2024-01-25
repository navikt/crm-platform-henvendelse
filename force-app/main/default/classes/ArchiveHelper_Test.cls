@isTest
public with sharing class ArchiveHelper_Test {
    @isTest
    static void testConvertRecordsToJson() {
        List<Conversation_Note__c> convNotes = new List<Conversation_Note__c>();
        convNotes.add(new Conversation_Note__c(CRM_Conversation_Note__c = 'Test'));
        convNotes.add(new Conversation_Note__c(CRM_Conversation_Note__c = 'Test 2'));

        List<List<SObject>> recordsList = new List<List<SObject>>();
        recordsList.add(convNotes);

        Test.startTest();
        List<String> jsonResults = ArchiveHelper.convertRecordsToJson(recordsList);
        Test.stopTest();

        Assert.areNotEqual(0, jsonResults.size(), 'JSON result list should not be empty');
        Assert.isTrue(
            jsonResults[0].contains('"CRM_Conversation_Note__c":"Test 2"'),
            'JSON should contain the Conversation Note'
        );
    }
}
