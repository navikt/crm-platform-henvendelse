public inherited sharing class CRM_MessageSelector extends CRM_ApiSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Message__c.Id };
    }

    public Schema.SObjectType getSObjectType() {
        return Message__c.sObjectType;
    }

    public List<Message__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id in :idSet');
        return (List<Message__c>) Database.query(query.toSOQL());
    }
}
