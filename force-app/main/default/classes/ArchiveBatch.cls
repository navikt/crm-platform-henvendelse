/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 19-06-2023
 * @last modified by  : mamikals
 **/
public with sharing class ArchiveBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    private String query = 'SELECT Id, Reference_Object__c, Actor_Id__c, Confidential__c, Documentation_Id__c, Domain__c, Fnr__c, Orgnr__c, Status__c, Theme__c, Archive_Data__c FROM Archive_Entry__c WHERE Status__c = \'Failed\'';
    private static LoggerUtility logger = new LoggerUtility('NKS');

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Archive_Entry__c> scope) {
        List<Archive_Entry__c> archiveEntriesToUpdate = new List<Archive_Entry__c>();
        Map<String, List<ArchiveService.ArchiveResponseWrapper>> responseByArchiveEntryId = new Map<String, List<ArchiveService.ArchiveResponseWrapper>>();

        // Collect data for callouts
        List<ArchiveRequestWrapper> archiveRecordsToPost = new List<ArchiveRequestWrapper>();
        for (Archive_Entry__c archiveEntry : scope) {
            ArchiveRequestWrapper reqWrapper = new ArchiveRequestWrapper(
                archiveEntry.Domain__c,
                archiveEntry.Actor_Id__c,
                archiveEntry.Fnr__c,
                archiveEntry.Orgnr__c,
                archiveEntry.Theme__c,
                archiveEntry.Confidential__c,
                archiveEntry.Documentation_Id__c,
                archiveEntry.Archive_Data__c,
                archiveEntry.Reference_Object__c
            );
            archiveRecordsToPost.add(reqWrapper);
        }

        List<ArchiveService.ArchiveResponseWrapper> response;
        try {
            response = new ArchiveService().postToArchive(archiveRecordsToPost);
        } catch (Exception e) {
            logger.error(e.getMessage() + '. ' + e.getStackTraceString(), null, CRM_ApplicationDomain.Domain.NKS);
        } finally {
            logger.publish();
        }

        // Update Archive Entry status based on response
        for (Archive_Entry__c archiveEntry : scope) {
            if (response != null) {
                archiveEntry.Status__c = (response[0].dokumentasjonId != null) ? 'Completed' : 'Failed';
                archiveEntry.Archived_Date__c = (archiveEntry.Status__c == 'Completed') ? System.now() : null;
                archiveEntriesToUpdate.add(archiveEntry);
            }
        }

        // Update Archive Entry records
        if (!archiveEntriesToUpdate.isEmpty()) {
            update archiveEntriesToUpdate;
        }
    }

    //Schedulable
    public void execute(System.SchedulableContext schContext) {
        ArchiveBatch batch = new ArchiveBatch();
        Database.executebatch(batch, 10);
    }

    public void finish(Database.BatchableContext BC) {
        if (!Test.isRunningTest()) {
            try {
                System.scheduleBatch(new ArchiveBatch(), 'ArchiveBatch', 1440, 10);
            } catch (Exception e) {
                logger.exception(e, CRM_ApplicationDomain.Domain.NKS);
                logger.publishSynch();
            }
        }
    }
}
