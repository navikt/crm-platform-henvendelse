@isTest
public with sharing class ArchiveHandler_Test {
    @TestSetup
    static void makeData() {
        Account a1 = new Account(Name = 'Account 1');
        insert a1;
        Account a2 = new Account(Name = 'Account 2');
        insert a2;
    }

    @isTest
    static void searchRecordsTest() {
        ApiMock.setTestMock('POST_ARCHIVE', 201, 'Created');

        List<String> testIDs = new List<String>();
        List<Account> accountQueryList = [SELECT Id FROM Account LIMIT 2];
        for (Account account : accountqueryList) {
            testIDs.add(account.Id);
        }
        List<ArchiveHandler.ArchivePostWrapper> testList = new List<ArchiveHandler.ArchivePostWrapper>();
        ArchiveHandler.ArchivePostWrapper testInput = new ArchiveHandler.ArchivePostWrapper(
            'select Id from Account',
            testIDs,
            'NKS',
            null,
            null,
            null,
            'DAG',
            false
        );

        testList.add(testInput);

        Test.startTest();
        List<String> testResult = ArchiveHandler.postToArchive(testList);
        Test.stopTest();
        System.assertEquals(false, testResult.isempty());
    }
}
