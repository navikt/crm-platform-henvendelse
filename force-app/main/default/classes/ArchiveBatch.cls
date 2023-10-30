/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 19-06-2023
 * @last modified by  : mamikals
 **/
public with sharing class ArchiveBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private final Date startDate;
    private final Date endDate;
    private String query;
    private final String opprettetAv;

    public ArchiveBatch(String query, String opprettetAv) {
        this.query = query;
        this.opprettetAv = opprettetAv;
    }

    public ArchiveBatch(Date startDate, Date endDate, String opprettetAv) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.opprettetAv = opprettetAv;

        //Starting two batches, one for Conv notes and one for threads.
        this.query = 'Select Id, CRM_Account__r.CRM_Person__r.INT_ActorId__c, CRM_Account__r.CRM_Person__r.Name, CRM_Theme__c from Conversation_note__c where (STO_Sensitive_Information_Date__c  <= :endDate and STO_Sensitive_Information_Date__c  >= :startDate) OR (createddate <= :endDate AND createddate >= :startDate AND CRM_Journal_Status__c = \'Not Journaled\')';
        Database.executeBatch(this);
        this.query = 'Select Id, CRM_Account__r.CRM_Person__r.Name, CRM_Account__r.CRM_Person__r.INT_ActorId__c, STO_Sensitive_Information__c, CRM_Theme__c from Thread__c where crm_thread_type__c IN (\'STO\', \'STB\', \'BTO\') AND ((STO_Sensitive_Information_Date__c  <= :endDate and STO_Sensitive_Information_Date__c >= :startDate) OR (CRM_Journal_Status__c=\'Not Journaled\' AND (CRM_Closed_Date__c <= :endDate and CRM_Closed_Date__c  >= :startDate)))';
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (query == null)
            return null;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<ArchiveHandler.ArchivePostWrapper> postList = new List<ArchiveHandler.ArchivePostWrapper>();
        for (sObject obj : scope) {
            postList.add(new ArchiveHandler.ArchivePostWrapper(obj, opprettetAv));
        }
        ArchiveHandler.postToArchive(postList);
    }

    public void finish(Database.BatchableContext BC) {
    }
}
