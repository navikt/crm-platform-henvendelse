/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 19-06-2023
 * @last modified by  : mamikals
 **/
public with sharing class ArchiveBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    private String query = 'SELECT Id, Name, Actor_Id__c, Confidential__c, Documentation_Id__c, Domain__c, Fnr__c, Orgnr__c, Reference_Id__c, Reference_Object__c, Status__c, Theme__c, Archive_Data__c FROM Archive_Entry__c WHERE Status = \'Failed\'';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Archive_Entry__c> archiveEntriesToUpdate = new List<Archive_Entry__c>();
        Map<Id, ArchiveService.ArchiveResponseWrapper> responseByArchiveEntryId = new Map<Id, ArchiveService.ArchiveResponseWrapper>();

        // Collect data for callouts
        List<ArchiveRequestWrapper> archiveRecordsToPost = new List<ArchiveRequestWrapper>();
        for (Archive_Entry__c archiveEntry : (List<Archive_Entry__c>) scope) {
            ArchiveRequestWrapper reqWrapper = new ArchiveRequestWrapper(
                archiveEntry.Domain__c,
                archiveEntry.Actor_Id__c,
                archiveEntry.Fnr__c,
                archiveEntry.Orgnr__c,
                archiveEntry.Theme__c,
                archiveEntry.Confidential__c,
                archiveEntry.Documentation_Id__c,
                archiveEntry.Archive_Data__c,
                archiveEntry.Reference_Object__c,
                archiveEntry.Reference_Id__c
            );
            archiveRecordsToPost.add(reqWrapper);
        }

        // Map Archive Entry Id with Response
        for (ArchiveRequestWrapper archiveRequest : archiveRecordsToPost) {
            responseByArchiveEntryId.put(
                archiveRequest.Reference_Id__c,
                new ArchiveService().postToArchive(archiveRequest)
            );
        }

        // Update Archive Entry status based on response
        for (Archive_Entry__c archiveEntry : (List<Archive_Entry__c>) scope) {
            ArchiveService.ArchiveResponseWrapper response = responseByArchiveEntryId.get(archiveEntry.Id)
                .dokumentasjonId; // TODO: Set correct value to check for err

            if (response != null) {
                // TODO: Set correct err to check
                archiveEntry.Status__c = (response.dokumentasjonId == 'HTTP Err') ? 'Failed' : 'Completed';
                archiveEntry.Archived_Date__c = (archiveEntry.Status__c == 'Completed') ? System.now() : null;
                archiveEntriesToUpdate.add(archiveEntry);
            }
        }

        // Update Archive Entry records
        if (!archiveEntriesToUpdate.isEmpty()) {
            update archiveEntriesToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (!Test.isRunningTest()) {
            try {
                System.scheduleBatch(new ArchiveBatch(), 'ArchiveBatch', 1440, 10); // TODO: Might be better to go with CRON exp on specific time of day
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.NKS);
                logger.publishSynch();
            }
        }
    }
}
