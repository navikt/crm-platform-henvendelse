@isTest
private class ArchiveRerunnerTest {
    @isTest
    static void testRerunFailedArchivation() {
        Test.startTest();
        ArchiveRerunner.rerunFailedArchivation('ArchiveRerunnerTestResource');
        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob];
        System.assertEquals(aaj.ApexClass.Name, 'ArchiveBatch', 'ArchiveBatch was not started.');
    }
}