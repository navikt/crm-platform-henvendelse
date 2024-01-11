/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 01-11-2023
 * @last modified by  : mamikals
 **/
public inherited sharing class ArchiveHandler {
    @InvocableMethod(
        label='Post data to archive server'
        description='Sends all the data of a query to the archive server.'
    )
    public static List<String> postToArchive(List<Archive_Entry__c> archiveEntryInputs) {
        List<ArchiveRequestWrapper> archiveRecordsToPost = new List<ArchiveRequestWrapper>();

        // TODO: Make sure the queried messages related to Thread are added properly in the thread flow
        for (Archive_Entry__c archiveEntry : archiveEntryInputs) {
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
        System.debug('archiveRecordsToPost: ' + archiveRecordsToPost);
        List<ArchiveService.ArchiveResponseWrapper> response = new ArchiveService().postToArchive(archiveRecordsToPost);

        List<String> returnStrings = new List<String>();
        for (ArchiveService.ArchiveResponseWrapper archiveResponse : response) {
            returnStrings.add(archiveResponse.dokumentasjonId);
        }
        System.debug('returnStrings: ' + returnStrings);
        return returnStrings; // TODO: Set status based on response on Archive Entry record (what is dokumentasjonId?)
    }
}