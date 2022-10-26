@isTest
public class CRM_PersonSelector_Test {
    @TestSetup
    static void makeData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '12345678910', INT_ActorId__c = '123456789101213')
        );
    }

    @isTest
    static void testSelector() {
        Test.startTest();
        Person__c person = new CRM_PersonSelector().selectByActorId('123456789101213');
        Test.stopTest();

        System.assert(person!=null);
    }
}
