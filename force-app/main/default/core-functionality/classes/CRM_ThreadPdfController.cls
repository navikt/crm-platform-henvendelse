public without sharing class CRM_ThreadPdfController {
    private transient string threadId;
    public List<Message__c> threadMessages { get; set; }

    public CRM_ThreadPdfController(ApexPages.StandardController stdController) {
        threadId = stdController.getId();
        threadMessages = [
            SELECT
                CRM_Type__c,
                CRM_External_Message__c,
                CRM_From_Contact__r.Name,
                CRM_From_Ident_Formula__c,
                CRM_Sent_date__c,
                CRM_Message_Text__c
            FROM Message__c
            WHERE CRM_Thread__c = :threadId
            ORDER BY CRM_Sent_date__c ASC
        ];
    }
}
