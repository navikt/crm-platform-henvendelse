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

        List<Account> accountList = [SELECT Id, Name FROM Account LIMIT 1];
        List<ArchiveHandler.ArchivePostWrapper> testList = new List<ArchiveHandler.ArchivePostWrapper>();
        ArchiveHandler.ArchivePostWrapper testInput = new ArchiveHandler.ArchivePostWrapper(
            accountList[0],
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
