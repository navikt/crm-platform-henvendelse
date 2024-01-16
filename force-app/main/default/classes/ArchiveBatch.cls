/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 19-06-2023
 * @last modified by  : mamikals
 **/
public with sharing class ArchiveBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    private String query = 'SELECT Id, Reference_Id__c, Reference_Object__c, Actor_Id__c, Confidential__c, Documentation_Id__c, Domain__c, Fnr__c, Orgnr__c, Status__c, Theme__c, Archive_Data__c FROM Archive_Entry__c WHERE Status__c = \'Failed\'';
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
                archiveEntry.Reference_Id__c,
                archiveEntry.Reference_Object__c
            );
            archiveRecordsToPost.add(reqWrapper);
        }

        // TODO: Send in list or send 1 by 1 to get unique response per record?
        // Map Archive Entry Id with Response
        for (ArchiveRequestWrapper archiveRequest : archiveRecordsToPost) {
            try {
                responseByArchiveEntryId.put(
                    archiveRequest.referenceId,
                    new ArchiveService().postToArchive(archiveRequest)
                );
            } catch (Exception e) {
                logger.error(e.getMessage(), null, CRM_ApplicationDomain.Domain.NKS);
            } finally {
                logger.publish();
            }
        }

        // Update Archive Entry status based on response
        for (Archive_Entry__c archiveEntry : scope) {
            ArchiveService.ArchiveResponseWrapper response = responseByArchiveEntryId.get(archiveEntry.Reference_Id__c)
                ?.get(0);

            if (response != null) {
                archiveEntry.Status__c = (response.dokumentasjonId != null) ? 'Completed' : 'Failed';
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
        Database.executeBatch(new ArchiveBatch(), 10);
    }

    public void finish(Database.BatchableContext BC) {
    }
}
