/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 21-02-2023
 * @last modified by  : mamikals
 **/
public with sharing class ArchiveBatch implements Database.Batchable<sObject> {
    public ArchiveBatch(Date startDate, Date endDate, String archiveObject) {
        this.startDate = startDate;
        this.endDate = endDate;
        if (archiveObject == 'thread__c') {
            query = 'Select Id from Thread__c where STO_Sensitive_Information_Date__c  <= :endDate OR (CRM_Journal_Status__c=\'Not Journaled\' AND (CRM_Closed_Date__c <= :endDate and CRM_Closed_Date__c  >= :startDate))';
        } else if (archiveObject == 'conversation_note__c') {
            query = 'Select Id from Conversation_note__c where STO_Sensitive_Information_Date__c  <= :endDate and STO_Sensitive_Information_Date__c  >= :startDate';
        }
    }
    private final Date startDate;
    private final Date endDate;
    private final String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (query == null)
            return null;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        LoggerUtility logger = new LoggerUtility();
        for (sObject nice : scope) {
            logger.info(nice.Id, null);
        }
        logger.publish();
    }

    public void finish(Database.BatchableContext BC) {
    }
}
