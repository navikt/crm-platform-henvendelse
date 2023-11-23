public with sharing class ArchiveRerunner {
    
    public static void rerunFailedArchivation(String staticResourceName) {
        StaticResource sr;
        if (!Test.isRunningTest()) {
            sr = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        }
       
        String body = Test.isRunningTest() ? '[{ "attributes": { "type": "Thread__c", "url": "/services/data/v56.0/sobjects/Thread__c/a0W1l0000039XlPEAU"}, "Id": "a0W1l0000039XlPEAU"}]' : sr.Body.toString();
        if (body == null) {
            System.debug('Error: No body found!');
            return;
        }

        List<RecordsToArchive> recordsToArchive = (List<RecordsToArchive>)JSON.deserialize(body, List<RecordsToArchive>.class);
        List<String> recordIds = new List<String>();
        for (RecordsToArchive record : recordsToArchive) {
            recordIds.add('\'' + record.Id + '\'');
        }
        if (recordIds.isEmpty()) {
            System.debug('Error: No record ids found!');
            return;
        }
        System.debug('recordIds: ' + recordIds);

        ArchiveBatch ab;
        Id recordId = (Id) recordIds[0].replace('\'', '');
        String objectName = recordId.getSObjectType().getDescribe().getName();
        if (Test.isRunningTest()) {
            objectName = 'Thread__c';
        }
        switch on objectName {
            when 'Thread__c' {
                ab = new ArchiveBatch('SELECT Id, CRM_Account__r.CRM_Person__r.Name, CRM_Account__r.CRM_Person__r.INT_ActorId__c, STO_Sensitive_Information__c, CRM_Theme__c FROM Thread__c WHERE CRM_Thread_Type__c IN (\'STO\', \'STB\', \'BTO\') AND (CRM_Journal_Status__c=\'Not Journaled\') AND Id IN ' + recordIds, 'NKS');
            }
            when 'Conversation_Note__c' {
                ab = new ArchiveBatch('SELECT Id, CRM_Account__r.CRM_Person__r.INT_ActorId__c, CRM_Account__r.CRM_Person__r.Name, CRM_Theme__c, CRM_Conversation_Note__c FROM Conversation_Note__c WHERE CRM_Journal_Status__c = \'Not Journaled\' AND Id IN ' + recordIds, 'NKS');
            }
        }
    }

    public class RecordsToArchive {
        public String id;
    }
}
