@IsTest
public class ThreadCacheFilterHelperTest {
    @TestSetup
    static void makeData() {
        myTriggers.disable(MessageCacheHandler.class);
        myTriggers.disable(ThreadCacheHandler.class);
        Account account=CRM_HENV_TestDataFactory.createPersonAccount();

        CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = account.Id,
                CRM_Thread_Type__c = 'CHAT'
            )
        );
    }

    @IsTest
    static void shouldReturnOneThreadIdFromOneMessage() {
        Id expectedThreadId = [SELECT Id FROM Thread__c LIMIT 1].Id;
        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(
                CRM_Thread__c = expectedThreadId,
                CRM_Message_Text__c = 'Test'
            )
        );
        List<Message__c> messages = [
            SELECT CRM_Thread__c, LastModifiedById
            FROM Message__c
        ];

        Test.startTest();
        Set<Id> result = ThreadCacheFilterHelper.getThreadIdsByMessages(messages);
        Test.stopTest();

        Assert.areEqual(1, result.size());
        Id actualThreadIdId = new List<Id>(result)[0];
        Assert.areEqual(expectedThreadId, actualThreadIdId);
    }

    @IsTest
    static void shouldNotReturnThreadIdForMessageCreatedByModiaIntegrationUser() {
        Id expectedThreadId = [SELECT Id FROM Thread__c LIMIT 1].Id;
        //Create record as Modia Integration User
        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ]
        .Id;
        User modiaIntegrationUser = (User) CRM_HENV_TestDataFactory.createRecord(
            new User(
                username = 'modia.integrasjon@nav.no.test',
                ProfileId = profileId
            )
        );

        System.runAs(modiaIntegrationUser) {
            CRM_HENV_TestDataFactory.createRecord(
                new Message__c(
                    CRM_Thread__c = expectedThreadId,
                    CRM_Message_Text__c = 'Test'
                )
            );
        }

        List<Message__c> messages = [
            SELECT CRM_Thread__c, LastModifiedById
            FROM Message__c
        ];

        Test.startTest();
        Set<Id> result = ThreadCacheFilterHelper.getThreadIdsByMessages(messages);
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }

    @IsTest
    static void shouldReturnOneEventWhenThreadTypeIsChat(){
        Thread__c t=[SELECT CRM_Thread_Type__c FROM Thread__c LIMIT 1];
        Id threadId = [SELECT Id FROM Thread__c WHERE CRM_Thread_Type__c = 'CHAT' LIMIT 1].Id;

        Test.startTest();
        List<CacheHenvendelseEvent> result=ThreadCacheFilterHelper.getCacheEvents(new Set<Id>{threadId});
        Test.stopTest();

        Assert.areEqual(1, result.size());
       
    }

    @IsTest
    static void shouldNotReturnAnyEventsWhenThreadTypeIsNotHenvendelse(){

        Id accountId=[SELECT Id FROM Account LIMIT 1].Id;

        Thread__c thread=(Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'AG_MLØNN'
            )
        );

        Thread__c t=[SELECT CRM_Thread_Type__c FROM Thread__c WHERE id=:thread.Id LIMIT 1];

        Test.startTest();
        List<CacheHenvendelseEvent> result=ThreadCacheFilterHelper.getCacheEvents(new Set<Id>{thread.Id});
        Test.stopTest();

        Assert.areEqual(0, result.size());
       
    }

    @IsTest
    static void shouldReturnOneThreadIdFromOneThread() {
        Thread__c thread = [SELECT Id, LastModifiedById, CRM_Thread_Type__c FROM Thread__c LIMIT 1];

        Test.startTest();
        Set<Id> result = ThreadCacheFilterHelper.getThreadIdsByThreads(new List<Thread__c>{thread});
        Test.stopTest();

        Assert.areEqual(1, result.size());
        Id actualThreadIdId = new List<Id>(result)[0];
        Assert.areEqual(thread.Id, actualThreadIdId);
    }

    @IsTest
    static void shouldNotReturnThreadIdForThreadsCreatedByModiaIntegrationUser() {
        Id accountId =[SELECT Id FROM Account LIMIT 1].Id;
        
        //Create record as Modia Integration User
        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ]
        .Id;
        User modiaIntegrationUser = (User) CRM_HENV_TestDataFactory.createRecord(
            new User(
                username = 'modia.integrasjon@nav.no.test',
                ProfileId = profileId
            )
        );
        Thread__c thread;
        System.runAs(modiaIntegrationUser) {
           thread=(Thread__c) CRM_HENV_TestDataFactory.createRecord(
                new Thread__c(
                    CRM_Account__c = accountId,
                    CRM_Thread_Type__c = 'CHAT'
                )
            );
        }
        List<Thread__c> threads=[SELECT Id, CRM_Thread_Type__c, LastModifiedById FROM Thread__c WHERE Id =:thread.Id];
        Test.startTest();
        Set<Id> result = ThreadCacheFilterHelper.getThreadIdsByThreads(threads);
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }

    @IsTest
    static void shouldNotReturnThreadIdsForThreadsOtherThanChat() {
        Id accountId =[SELECT Id FROM Account LIMIT 1].Id;
        
        CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'STO'
            )
        );
        List<Thread__c> threads=[SELECT Id, CRM_Thread_Type__c, LastModifiedById FROM Thread__c WHERE CRM_Thread_Type__c='STO'];
        Test.startTest();
        Set<Id> result = ThreadCacheFilterHelper.getThreadIdsByThreads(threads);
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }
}
