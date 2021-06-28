public inherited sharing class CRM_ConversationNoteSelector extends CRM_ApiSelector {
    private final List<String> QUERY_FIELDS = new List<String>{
        'Id',
        'Name',
        'CRM_Account__r.CRM_Person__r.INT_ActorId__c',
        'CRM_Account__r.CRM_Person__r.Name',
        'CRM_Theme_Group_Code__c',
        'CRM_Theme_Code__c',
        'CRM_Office_Restriction__c',
        'CRM_Read_Date__c',
        'CRM_Date_Time_Registered__c',
        'CRM_Conversation_Note__c',
        'CRM_Created_By__c'
    };

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
        query.selectFields(QUERY_FIELDS).setCondition('CRM_Account__r.CRM_Person__r.INT_ActorId__c in :actorIds');
        //Adds the Journal entry selector query as a relationship query to the Conversation Note query
        new CRM_JournalEntrySelector().addQueryFactorySubselect(query, 'Journal_Entries__r');
        return (List<Conversation_Note__c>) Database.query(query.toSOQL());
    }
}
