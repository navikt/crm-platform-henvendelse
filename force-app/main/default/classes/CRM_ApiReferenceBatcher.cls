public without sharing class CRM_ApiReferenceBatcher implements Database.Batchable<SObject> {
    public CRM_ApiReferenceBatcher(String query) {
        this.query = query;
    }
    private final String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (sobject sObj : scope) {
            sObj.put('CRM_API_Reference__c', CRM_ReferenceUtil.generateReference(sObj));
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }
}
