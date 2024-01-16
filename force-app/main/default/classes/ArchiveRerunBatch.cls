public with sharing class ArchiveRerunBatch implements Database.Batchable<Id>, Database.AllowsCallouts {
    private List<Id> idsToArchive;
    private string opprettetAv;

    public ArchiveRerunBatch(List<Id> idsToArchive, String opprettetAv) {
        this.idsToArchive = idsToArchive;
        this.opprettetAv = opprettetAv;
        Database.executeBatch(this);
    }

    public Iterable<Id> start(Database.BatchableContext BC) {
        return idsToArchive;
    }

    public void execute(Database.BatchableContext BC, List<Id> scope) {
        String objName = scope[0].getSObjectType().getDescribe().getName();
        List<SObject> records = new List<SObject>();
        if (objName == 'Thread__c') {
            records = [
                SELECT
                    Id,
                    CRM_Account__r.CRM_Person__r.Name,
                    CRM_Account__r.CRM_Person__r.INT_ActorId__c,
                    STO_Sensitive_Information__c,
                    CRM_Theme__c
                FROM Thread__c
                WHERE
                    CRM_Thread_Type__c IN ('STO', 'STB', 'BTO')
                    AND CRM_Journal_Status__c = 'Not Journaled'
                    AND Id IN :scope
            ];
        } else if (objName == 'Conversation_Note__c') {
            records = [
                SELECT
                    Id,
                    CRM_Account__r.CRM_Person__r.INT_ActorId__c,
                    CRM_Account__r.CRM_Person__r.Name,
                    CRM_Theme__c,
                    CRM_Conversation_Note__c
                FROM Conversation_Note__c
                WHERE CRM_Journal_Status__c = 'Not Journaled' AND Id IN :scope
            ];
        }

        List<ArchiveRerunner.ArchivePostWrapper> postList = new List<ArchiveRerunner.ArchivePostWrapper>();
        for (SObject obj : records) {
            postList.add(new ArchiveRerunner.ArchivePostWrapper(obj, opprettetAv));
        }
        ArchiveRerunner.postToArchive(postList);
    }

    public void finish(Database.BatchableContext BC) {
    }
}
