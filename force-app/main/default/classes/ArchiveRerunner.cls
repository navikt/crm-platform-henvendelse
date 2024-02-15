public with sharing class ArchiveRerunner {
    // Input: Static resource in JSON format with ID of records to rerun
    public static void rerunFailedArchivation(String staticResourceName, String namespace) {
        StaticResource sr;
        if (!Test.isRunningTest()) {
            sr = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        }

        String body = Test.isRunningTest()
            ? '[{ "attributes": { "type": "Thread__c", "url": "/services/data/v56.0/sobjects/Thread__c/a0W1l0000039XlPEAU"}, "Id": "a0W1l0000039XlPEAU"}]'
            : sr.Body.toString();
        if (body == null) {
            System.debug('Error: No body found!');
            return;
        }

        List<RecordsToArchive> recordsToArchive = (List<RecordsToArchive>) JSON.deserialize(
            body,
            List<RecordsToArchive>.class
        );
        List<Id> recordIds = new List<Id>();
        for (RecordsToArchive record : recordsToArchive) {
            recordIds.add(record.Id);
        }
        if (recordIds.isEmpty()) {
            System.debug('Error: No record ids found!');
            return;
        }
        System.debug('recordIds: ' + recordIds);
        ArchiveRerunBatch ab = new ArchiveRerunBatch(recordIds, namespace);
    }

    // For manual ArchiveRerunBatch
    public static void postToArchive(List<ArchivePostWrapper> inputs) {
        LoggerUtility logger = new LoggerUtility('Arkiv');

        List<ArchiveRequestWrapper> archiveRequestWrappers = new List<ArchiveRequestWrapper>();
        for (ArchivePostWrapper input : inputs) {
            archiveRequestWrappers.add(
                new ArchiveRequestWrapper(
                    input.opprettetAv,
                    input.aktoerid,
                    input.fnr,
                    input.tema,
                    input.konfidentiellt,
                    input.archiveObject
                )
            );
        }

        System.debug('archiveRequestWrappers: ' + archiveRequestWrappers);
        List<ArchiveService.ArchiveResponseWrapper> res = new ArchiveService().postToArchive(archiveRequestWrappers);
        if (res == null) {
            logger.error('Feil med arkivering, response == null', null);
        }
        for (ArchiveService.ArchiveResponseWrapper archiveResponse : res) {
            if (archiveResponse.id == null) {
                logger.error('Feil med arkivering, response.Id == null', null);
            }
        }
        logger.publish();
    }

    // WRAPPERS //
    public class RecordsToArchive {
        public String id;
    }

    public class ArchivePostWrapper {
        public SObject archiveObject;
        public String opprettetAv;
        public String aktoerid;
        public String fnr;
        public String tema;
        public Boolean konfidentiellt;

        // For manual ArchiveRerunBatch
        public ArchivePostWrapper(SObject archiveObject, String opprettetAv) {
            this.archiveObject = archiveObject;
            this.opprettetAv = opprettetAv;
            switch on archiveObject.getSObjectType().getDescribe().getName() {
                when 'Thread__c' {
                    this.fnr = ((Thread__c) archiveObject)?.CRM_Account__r?.CRM_Person__r?.Name;
                    this.aktoerid = ((Thread__c) archiveObject)?.CRM_Account__r?.CRM_Person__r?.INT_ActorId__c;
                    this.konfidentiellt = ((Thread__c) archiveObject)?.STO_Sensitive_Information__c;
                    this.tema = ((Thread__c) archiveObject).CRM_Theme__c;
                }
                when 'Conversation_note__c' {
                    this.konfidentiellt = true;
                    this.aktoerid = ((Conversation_Note__c) archiveObject)
                        ?.CRM_Account__r
                        ?.CRM_Person__r
                        ?.INT_ActorId__c;
                    this.fnr = ((Conversation_Note__c) archiveObject)?.CRM_Account__r?.CRM_Person__r?.Name;
                    this.tema = ((Conversation_Note__c) archiveObject).CRM_Theme__c;
                }
            }
        }
    }
}
