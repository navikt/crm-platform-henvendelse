@isTest
private class ArchiveRerunnerTest {
    @isTest
    static void testRerunFailedArchivation() {
        Test.startTest();
        ArchiveRerunner.rerunFailedArchivation('ArchiveRerunnerTestResource', 'NKS');
        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob];
        Assert.areEqual(aaj.ApexClass.Name, 'ArchiveBatch', 'ArchiveBatch was not started.');
    }
}