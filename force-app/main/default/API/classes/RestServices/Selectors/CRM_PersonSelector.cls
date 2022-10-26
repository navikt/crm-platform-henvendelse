public with sharing class CRM_PersonSelector extends CRM_ApiSelector {
    public CRM_PersonSelector() {
        super(false);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
           Person__c.INT_Confidential__c,
           Person__c.INT_IsNavEmployee__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Person__c.sObjectType;
    }

    public Person__c selectByActorId(String actorId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('INT_ActorId__c =: actorId').setLimit(1);
        return (Person__c) Database.query(query.toSOQL());
    }
}
