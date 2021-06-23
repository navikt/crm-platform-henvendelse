public inherited sharing class CRM_ConversationNoteSelector extends CRM_ApiSelector {
    private final List<String> QUERY_FIELDS = new List<String>{ 'Id', 'CRM_Account__r.CRM_Person__r.INT_ActorId__c' };

    //TODO: Formula fields to easier define the returned fields? Can be included in field sets but still need to be wrapped in generic model

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Conversation_Note__c.Id };
    }

    public Schema.SObjectType getSObjectType() {
        return Conversation_Note__c.sObjectType;
    }

    public List<Conversation_Note__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(QUERY_FIELDS).setCondition('Id in :idSet');
        return (List<Conversation_Note__c>) Database.query(query.toSOQL());
    }

    public List<Conversation_Note__c> selectByActorId(Set<String> actorIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(QUERY_FIELDS).setCondition('CRM_Account__r.CRM_Person__r.INT_ActorId__c in :idSet');
        //Adds the Journal entry selector query as a relationship query to the Conversation Note query
        new CRM_JournalEntrySelector().addQueryFactorySubselect(query, 'Journal_Entries__r');
        return (List<Conversation_Note__c>) Database.query(query.toSOQL());
    }
}
