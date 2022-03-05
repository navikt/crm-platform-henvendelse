@isTest
public class CRM_ConvNoteJournalHelper_Test {
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT'));
    }

    @isTest
    static void testAsyncJournal() {
        ApiMock.setTestMock('POST_CREATE_JOURNAL', 200, 'OK');
        Conversation_Note__c convNote = [SELECT Id, CRM_API_Reference__c FROM Conversation_Note__c LIMIT 1];
        CRM_ConvNoteJournalHelper.JournalRequest jRequest = new CRM_ConvNoteJournalHelper.JournalRequest();
        List<CRM_ConvNoteJournalHelper.JournalRequest> requestList = new List<CRM_ConvNoteJournalHelper.JournalRequest>();

        jRequest.Journal_Case_ID = '123TESTABC';
        jRequest.Journal_Case_Legacy_System = 'A01';
        jRequest.Journal_Entry_NAV_Ident = 'Z999999';
        jRequest.Journal_Entry_Unit = '4100';
        jRequest.Journal_Theme_Code = 'DAG';
        jRequest.recordId = convNote.Id;

        requestList.add(jRequest);

        Test.startTest();
        CRM_ConvNoteJournalHelper.handleRequest(requestList);
        Test.stopTest();

        Conversation_Note__c updatedConvNote = [
            SELECT Id, CRM_Journal_Status__c
            FROM Conversation_Note__c
            WHERE Id = :convNote.Id
        ];
        System.assert(updatedConvNote.CRM_Journal_Status__c.equalsIgnoreCase('Journal Completed'));
        System.assertEquals(1, [SELECT COUNT() FROM Journal_Entry__c WHERE CRM_NAV_Case_Legacy_System__c = 'A01']);
    }
}
