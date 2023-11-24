@isTest
private class ArchiveRerunnerTest {
    @isTest
    static void testRerunFailedArchivation() {
        ApiMock.setTestMock('POST_ARCHIVE', 201, 'Created');
        Test.startTest();
        ArchiveRerunner.rerunFailedArchivation('ArchiveRerunnerTestResource', 'NKS');
        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob];
        Assert.areEqual(aaj.ApexClass.Name, 'ArchiveBatch', 'ArchiveBatch was not started.');
    }
}