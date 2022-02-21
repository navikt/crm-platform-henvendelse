@isTest
public class CRM_ThreadPdfController_Test {
    @TestSetup
    static void makeData() {
        Id contactId = (Id) CRM_HENV_TestDataFactory.createRecord(new Contact()).get('Id');
        Id threadId = (Id) CRM_HENV_TestDataFactory.createRecord(new Thread__c(CRM_Contact__c = contactId)).get('Id');
        CRM_HENV_TestDataFactory.createRecord(
            new Message__c(CRM_Thread__c = threadId, CRM_From_Contact__c = contactId)
        );
    }

    @isTest
    static void testPdfController() {
        PageReference pageRef = Page.CRM_Thread_PDF;
        Test.setCurrentPage(pageRef);
        Id threadId = [SELECT Id FROM Thread__c LIMIT 1].Id;

        ApexPages.currentPage().getParameters().put('Id', threadId);
        ApexPages.StandardController stdThread = new ApexPages.StandardController(new Thread__c(Id = threadId));

        CRM_ThreadPdfController pdfController = new CRM_ThreadPdfController(stdThread);
        System.assert(pdfController.threadMessages.size() > 0);
    }
}
