@isTest
public with sharing class ArchiveHandler_Test {
    @isTest
    static void postToArchiveTest() {
        ApiMock.setTestMock('POST_ARCHIVE', 201, 'Created');

        List<ArchiveHandler.ArchivePostWrapper> testList = new List<ArchiveHandler.ArchivePostWrapper>();
        ArchiveHandler.ArchivePostWrapper testInput = new ArchiveHandler.ArchivePostWrapper(
            'testdata',
            'NKS',
            null,
            null,
            null,
            'DAG',
            false,
            null,
            '123',
            'Thread__c'
        );
        testList.add(testInput);

        Test.startTest();
        List<String> testResult = ArchiveHandler.postToArchive(testList);
        Test.stopTest();

        Assert.areEqual(false, testResult.isEmpty(), 'testResult list from response was empty.');
    }
}
