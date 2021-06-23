public inherited sharing class CRM_JournalEntrySelector extends CRM_ApiSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Journal_Entry__c.Id };
    }

    public Schema.SObjectType getSObjectType() {
        return Journal_Entry__c.sObjectType;
    }

    public List<Journal_Entry__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id in :idSet');
        return (List<Journal_Entry__c>) Database.query(query.toSOQL());
    }
}
