public inherited sharing class CRM_MessageSelector extends CRM_ApiSelector {
    public CRM_MessageSelector() {
        super(false);
    }

    public CRM_MessageSelector(Boolean includeFieldSetFields) {
        super(includeFieldSetFields);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }

    public override List<Schema.FieldSet> getSObjectFieldSetList() {
        return new List<Schema.FieldSet>{ SObjectType.Message__c.FieldSets.CRM_API_Field_Set };
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
