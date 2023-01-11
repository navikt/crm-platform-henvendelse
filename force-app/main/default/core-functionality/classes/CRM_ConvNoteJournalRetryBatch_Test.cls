@isTest
public class CRM_ConvNoteJournalRetryBatch_Test {
    @TestSetup
    static void makeData() {
        Conversation_Note__c convNote = (Conversation_Note__c) CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c()
        );
        Common_Code__c aapCode = (Common_Code__c) CRM_HENV_TestDataFactory.createRecord(
            new Common_Code__c(CRM_Code__c = 'AAP', CRM_Code_Set__c = 'Tema', CRM_Active__c = true)
        );

        Journal_Entry__c je1 = new Journal_Entry__c(
            CRM_Conversation_Note__c = convNote.Id,
            Journal_Entry_Status__c = 'Failed',
            Theme__c = aapCode.Id,
            NAV_Case_Reference__c = '123TEST'
        );
        Journal_Entry__c je2 = new Journal_Entry__c(
            CRM_Conversation_Note__c = convNote.Id,
            Journal_Entry_Status__c = 'Failed',
            Theme__c = aapCode.Id,
            NAV_Case_Reference__c = '456TEST'
        );
        List<Journal_Entry__c> jeList = new List<Journal_Entry__c>{ je1, je2 };
        CRM_HENV_TestDataFactory.createRecordList(jeList);
    }

    @isTest
    static void testJournalRetry() {
        ApiMock.setTestMock('POST_CREATE_JOURNAL', 200, 'OK');

        Test.startTest();
        CRM_ConvNoteJournalRetryBatch.initJournalBatcher();
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Journal_Entry__c WHERE Journal_Entry_Status__c = 'Completed']);
    }
}
