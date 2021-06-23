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
}
