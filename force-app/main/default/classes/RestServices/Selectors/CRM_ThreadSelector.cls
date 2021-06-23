public with sharing class CRM_ThreadSelector extends CRM_ApiSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Thread__c.Id };
    }

    public Schema.SObjectType getSObjectType() {
        return Thread__c.sObjectType;
    }

    public List<Thread__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id in :idSet');
        return (List<Thread__c>) Database.query(query.toSOQL());
    }

    public List<Thread__c> selectByActorId(Set<String> actorIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('CRM_Account__r.CRM_Person__r.INT_ActorId__c in :idSet');
        //Adds the Journal entry selector query as a relationship query to the Thread query
        new CRM_JournalEntrySelector().addQueryFactorySubselect(query, 'Journal_Entries__r');
        //Adds the Journal entry selector query as a relationship query to the Thread query
        new CRM_MessageSelector(true).addQueryFactorySubselect(query, 'Messages__r');
        return (List<Thread__c>) Database.query(query.toSOQL());
    }
}
