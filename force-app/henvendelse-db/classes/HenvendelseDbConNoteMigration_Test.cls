@IsTest
private class HenvendelseDbConNoteMigration_Test {
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        myTriggers.disable(ConvNoteHenvendelseDbHandler.class);
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT'));
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT 2'));
    }

    @IsTest
    static void testMigrationBatch(){
        DateTime createdDateStart=DateTime.now().addDays(-1);
        DateTime createdDateEnd=DateTime.now().addDays(11);

        Test.startTest();
        Id batchJobId = Database.executeBatch(new HenvendelseDbConNoteMigration(createdDateStart, createdDateEnd));
        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE Id = :batchJobId];
        Assert.areEqual(aaj.ApexClass.Name, 'HenvendelseDbConNoteMigration', 'HenvendelseDbConNoteMigration was not started.');

    }


}