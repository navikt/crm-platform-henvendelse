@IsTest
public with sharing class CRM_HenvendelseRedactHelperTest {
    @TestSetup
    static void makeData() {
        insert new Conversation_Note__c(CRM_Conversation_note__c = 'Skal sladdes', CRM_Is_Redacted__c = false);
    }

    @IsTest
    static void testRedactCNote() {
        Conversation_Note__c cNote = [
            SELECT Id
            FROM Conversation_note__c
            WHERE CRM_Is_Redacted__c = FALSE
        ];
        String redactedText = 'Skal *******';
        Test.startTest();
        CRM_HenvendelseRedactHelper.redactConversationNote(redactedText, cNote.Id);
        Test.stopTest();
        Conversation_Note__c newCNote = [
            SELECT Id, CRM_Conversation_note__c
            FROM Conversation_note__c
            WHERE Id = :cNote.Id
        ];
        Assert.areEqual(redactedText, newCNote.CRM_Conversation_note__c, 'Conversation note was not redacted');
    }
}
