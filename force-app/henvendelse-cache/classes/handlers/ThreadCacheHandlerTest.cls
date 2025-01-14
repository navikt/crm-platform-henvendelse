@IsTest
public class ThreadCacheHandlerTest {
    @TestSetup
    private static void makeData() {
        User experienceCloudUser = (User) CRM_HENV_TestDataFactory.createExperienceCloudUser(); //New Person Account is also created
    }

    @IsTest
    static void shouldPublishEventWhenThreadCreatedByInternalUser() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'CHAT'
            )
        );
        Test.stopTest();

        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='INFO']
        );

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='ERROR']
        );
    }

    @IsTest
    static void shouldPublishEventWhenThreadIsCreatedByExperienceCloudUser() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        User experienceCloudUser = [
            SELECT Id
            FROM User
            WHERE AccountId = :accountId
        ];
        Test.startTest();
        System.runAs(experienceCloudUser) {
            Thread__c thread=new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'CHAT'
            );
            insert thread;
        }
        Test.stopTest();

        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='INFO']
        );

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='ERROR']
        );
    }

    @IsTest
    static void shouldPublishEventWhenThreadIsUpdatedByInternalUser() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Thread__c thread=(Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'CHAT'
            )
        );

        Test.startTest();
        thread.STO_Medskriv__c=true;
        update thread;
        Test.stopTest();

        Assert.areEqual(
            2,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='INFO']
        );

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='ERROR']
        );
    }

    @IsTest
    static void shouldPublishEventWhenThreadIsUpdatedByExperienceCloudUser() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        User experienceCloudUser = [
            SELECT Id
            FROM User
            WHERE AccountId = :accountId
        ];
        
        Thread__c thread=(Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(
                CRM_Account__c = accountId,
                CRM_Thread_Type__c = 'CHAT',
                OwnerId = experienceCloudUser.Id
            )
        );

        Test.startTest();
        System.runAs(experienceCloudUser) {
            thread.STO_Medskriv__c=true;
            update thread;
        }

        Test.stopTest();

        Assert.areEqual(
            2,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='INFO']
        );

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='ERROR']
        );
    }
}
