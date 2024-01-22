@isTest
private class ArchiveBatch_Test {
    @TestSetup
    static void makeData() {
        Archive_Entry__c ae = new Archive_Entry__c(
            Domain__c = 'NKS',
            Status__c = 'Failed',
            Archive_Data__c = 'testdata',
            Reference_Id__c = 'testid123'
        );
        insert ae;
    }

    @isTest
    static void archiveBatchTest() {
        ApiMock.setTestMock('POST_ARCHIVE', 201, 'Created');

        Test.startTest();
        Id batchJobId = Database.executeBatch(new ArchiveBatch('NKS'));
        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE Id = :batchJobId];
        Assert.areEqual(aaj.ApexClass.Name, 'ArchiveBatch', 'ArchiveBatch was not started.');

        Archive_Entry__c ae = [SELECT Status__c FROM Archive_Entry__c LIMIT 1];
        Assert.areEqual('Completed', ae.Status__c, 'Status was not completed.');
    }

    @isTest
    static void archiveBatchScheduleTest() {
        ApiMock.setTestMock('POST_ARCHIVE', 201, 'Created');
        String cron_exp = '0 0 0 3 9 ? 2030';

        Test.startTest();
        String jobId = System.schedule('ArchiveBatch', cron_exp, new ArchiveBatch('NKS'));
        Test.stopTest();
        Assert.areNotEqual(null, jobId, 'Job id was null');
    }
}
