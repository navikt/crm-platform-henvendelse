@IsTest
public class ConvNoteCacheHandlerTest {
    @TestSetup
    private static void makeData() {
        CRM_HENV_TestDataFactory.createExperienceCloudUser(); //New Person Account is also created
        
    }

    @IsTest
    static void shouldPublishEventWhenConvNoteIsCreated() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = accountId,
                CRM_Conversation_Note__c = 'DUMMY TEXT',
                CRM_Henvendelse_BehandlingskjedeId__c = '123'
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
    static void shouldPublishEventWhenConvNoteIsUpdatedByExperienceCloudUser() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        User experienceCloudUser = [
            SELECT Id
            FROM User
            WHERE AccountId = :accountId
        ];
        Conversation_Note__c convNote = (Conversation_Note__c) CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = accountId,
                CRM_Conversation_Note__c = 'DUMMY TEXT',
                CRM_Henvendelse_BehandlingskjedeId__c = '123',
                OwnerId = experienceCloudUser.Id
            )
        );

        Test.startTest();
        System.runAs(experienceCloudUser) {
            convNote.CRM_Is_Read__c = true;
            update convNote;
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

    @IsTest
    static void shouldPublishEventWhenConvNoteIsUpdatedByInternalUser() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Conversation_Note__c convNote = (Conversation_Note__c) CRM_HENV_TestDataFactory.createRecord(
            new Conversation_Note__c(
                CRM_Account__c = accountId,
                CRM_Conversation_Note__c = 'DUMMY TEXT',
                CRM_Henvendelse_BehandlingskjedeId__c = '123'
            )
        );

        Test.startTest();
        convNote.CRM_Is_Read__c = true;
        update convNote;
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
