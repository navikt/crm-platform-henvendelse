public with sharing class ArchiveRerunner {
    
    // Input: Static resource in JSON format with ID of records to rerun
    public static void rerunFailedArchivation(String staticResourceName, String namespace) {
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
        List<Id> recordIds = new List<Id>();
        for (RecordsToArchive record : recordsToArchive) {
            recordIds.add(record.Id);
        }
        if (recordIds.isEmpty()) {
            System.debug('Error: No record ids found!');
            return;
        }
        System.debug('recordIds: ' + recordIds);
        ArchiveBatch ab = new ArchiveBatch(recordIds, namespace);
    }

    public class RecordsToArchive {
        public String id;
    }
}