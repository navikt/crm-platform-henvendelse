@isTest
public class CRM_ApiReferenceBatcher_Test {
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c());
        CRM_HENV_TestDataFactory.createRecord(new Thread__c(CRM_Henvendelse_BehandlingsId__c = '123TEST'));
    }

    @isTest
    static void testBatchReferenceGeneration() {
        String query = 'SELECT Id, CRM_API_Reference__c FROM Conversation_Note__c';
        CRM_ApiReferenceBatcher batcher = new CRM_ApiReferenceBatcher(query);
        String initialRef = [SELECT Id, CRM_API_Reference__c FROM Conversation_Note__c LIMIT 1]?.CRM_API_Reference__c;

        Test.startTest();
        Database.executeBatch(batcher);
        Test.stopTest();

        System.assertNotEquals(
            initialRef,
            [SELECT Id, CRM_API_Reference__c FROM Conversation_Note__c LIMIT 1]
            ?.CRM_API_Reference__c
        );
        System.assertNotEquals(
            null,
            [SELECT Id, CRM_API_Reference__c FROM Conversation_Note__c LIMIT 1]
            ?.CRM_API_Reference__c
        );
    }

    @isTest
    static void testThreadRefSwitch() {
        String query = 'SELECT Id, CRM_API_Reference__c, CRM_Henvendelse_BehandlingsId__c FROM Thread__c';
        CRM_ApiReferenceBatcher batcher = new CRM_ApiReferenceBatcher(true, query);

        Test.startTest();
        Database.executeBatch(batcher);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Thread__c WHERE CRM_API_Reference__c = '123TEST']);
    }
}
