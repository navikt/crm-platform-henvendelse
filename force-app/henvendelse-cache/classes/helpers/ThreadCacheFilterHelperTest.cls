@IsTest
public class ThreadCacheFilterHelperTest {
    @TestSetup
    static void makeData() {
        myTriggers.disable(MessageCacheHandler.class);
        Account account=CRM_HENV_TestDataFactory.createPersonAccount();

        CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = account.Id,
                CRM_Thread_Type__c = 'STO',
                CRM_API_Reference__c='Abc134'
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
    static void shouldReturnOneEventWhenThreadTypeIsSto(){
        Thread__c t=[SELECT CRM_Thread_Type__c FROM Thread__c LIMIT 1];
        Id threadId = [SELECT Id FROM Thread__c WHERE CRM_Thread_Type__c = 'STO' LIMIT 1].Id;

        Test.startTest();
        List<CacheHenvendelse> result=ThreadCacheFilterHelper.getCacheEvents(new Set<Id>{threadId});
        Test.stopTest();

        Assert.areEqual(1, result.size());
       
    }

    @IsTest
    static void shouldNotReturnAnyEventsWhenThreadTypeIsNotHenvendelse(){

        Id accountId=[SELECT Id FROM Account LIMIT 1].Id;

        Thread__c thread=(Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'AG_MLØNN',
                CRM_API_Reference__c='Abc134'
            )
        );

        Thread__c t=[SELECT CRM_Thread_Type__c FROM Thread__c WHERE id=:thread.Id LIMIT 1];

        Test.startTest();
        List<CacheHenvendelse> result=ThreadCacheFilterHelper.getCacheEvents(new Set<Id>{thread.Id});
        Test.stopTest();

        Assert.areEqual(0, result.size());
       
    }
}
