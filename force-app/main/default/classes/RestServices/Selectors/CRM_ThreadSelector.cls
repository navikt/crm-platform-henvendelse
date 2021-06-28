public with sharing class CRM_ThreadSelector extends CRM_ApiSelector {
    public CRM_ThreadSelector() {
        super(false);
    }

    public CRM_ThreadSelector(Boolean includeFieldSetFields) {
        super(includeFieldSetFields);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }

    public override List<Schema.FieldSet> getSObjectFieldSetList() {
        return new List<Schema.FieldSet>{ SObjectType.Thread__c.FieldSets.CRM_API_Field_Set };
    }

    public Schema.SObjectType getSObjectType() {
        return Thread__c.sObjectType;
    }

    public Thread__c selectById(Id id) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id =: id').setLimit(1);
        return (Thread__c) Database.query(query.toSOQL());
    }

    public List<Thread__c> selectByIds(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id in :idSet');
        return (List<Thread__c>) Database.query(query.toSOQL());
    }

    public List<Thread__c> selectByActorId(Set<String> actorIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            '(CRM_Recipient__r.Account.CRM_Person__r.INT_ActorId__c in :actorIds OR CRM_From__r.Account.CRM_Person__r.INT_ActorId__c in :actorIds)'
        );
        //Adds the Journal entry selector query as a relationship query to the Thread query
        new CRM_JournalEntrySelector().addQueryFactorySubselect(query, 'Journal_Entries__r');
        //Adds the Journal entry selector query as a relationship query to the Thread query
        new CRM_MessageSelector(true).addQueryFactorySubselect(query, 'Messages__r');
        return (List<Thread__c>) Database.query(query.toSOQL());
    }
}
