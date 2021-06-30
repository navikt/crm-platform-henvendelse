@isTest
public class CRM_ThreadSelector_Test {
    @TestSetup
    static void makeData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '12345678910', INT_ActorId__c = '123456789101213')
        );

        User accountOwner = [
            SELECT Id
            FROM User
            WHERE UserRoleId != NULL AND isActive = TRUE AND IsPortalEnabled = FALSE
            LIMIT 1
        ];

        Account personAcc = [
            SELECT Id, FirstName, LastName, PersonContactId
            FROM Account
            WHERE CRM_Person__c = :dummyPerson.Id
            LIMIT 1
        ];
        personAcc.OwnerId = accountOwner.Id;
        update personAcc;

        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1];
        User portalUser = (User) CRM_HENV_TestDataFactory.createRecord(
            new User(
                FirstName = personAcc.FirstName,
                LastName = personAcc.LastName,
                ContactId = personAcc.PersonContactId,
                ProfileId = portalProfile.Id,
                Username = personAcc.FirstName + '.' + personAcc.LastName + '@testing.com'
            )
        );
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Account__c = personAcc.Id));
        Thread__c thread = (Thread__c) CRM_HENV_TestDataFactory.createRecord(
            new Thread__c(CRM_From__c = portalUser.Id)
        );
        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = 'DUMMY TEXT')
        );
    }

    @isTest
    static void testSelector() {
        Test.startTest();
        List<Thread__c> threads = new CRM_ThreadSelector().selectByActorId(new Set<String>{ '123456789101213' });
        Test.stopTest();

        System.assert(!threads.isEmpty());
        Thread__c selectedThread = new CRM_ThreadSelector().selectById(threads[0].Id);
        System.assertNotEquals(null, selectedThread);
        threads = new CRM_ThreadSelector().selectByIds(new Set<Id>{ threads[0].Id });
        System.assert(!threads.isEmpty());
    }
}
