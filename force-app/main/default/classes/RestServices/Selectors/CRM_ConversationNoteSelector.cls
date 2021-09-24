public inherited sharing class CRM_ConversationNoteSelector extends CRM_ApiSelector {
    private final List<String> QUERY_FIELDS = new List<String>{
        'Id',
        'Name',
        'CRM_HenvendelseId__c',
        'CRM_Henvendelse_BehandlingskjedeId__c',
        'CRM_Account__r.CRM_Person__r.INT_ActorId__c',
        'CRM_Account__r.CRM_Person__r.Name',
        'CRM_Theme_Group_Code__c',
        'CRM_Theme_Code__c',
        'CRM_Office_Restriction__c',
        'CRM_Read_Date__c',
        'CRM_Registered_Datetime_Formula__c',
        'CRM_Conversation_Note__c',
        'CRM_Created_By_Ident__c',
        'CRM_Office_Restriction_Activated_By__c',
        'CRM_Office_Restriction_Date__c',
        'CRM_Disposal_Datetime__c',
        'CRM_Communication_Channel__c',
        'CRM_Created_By_NAV_Unit__c',
        'CRM_Original_Person_GT__c',
        'CRM_Original_Person_NAV_Unit__c'
    };

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Conversation_Note__c.Id };
    }

    public Schema.SObjectType getSObjectType() {
        return Conversation_Note__c.sObjectType;
    }

    public Conversation_Note__c selectById(Id convId) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(QUERY_FIELDS).setCondition('Id=: convId');
        return (Conversation_Note__c) Database.query(query.toSOQL());
    }

    public List<Conversation_Note__c> selectByActorId(Set<String> actorIds) {
        fflib_QueryFactory query = newQueryFactory();
        query
            .selectFields(QUERY_FIELDS)
            .setCondition(
                'CRM_Account__r.CRM_Person__r.INT_ActorId__c in :actorIds AND CRM_Henvendelse_BehandlingsId__c != null'
            )
            .setOrdering('CRM_Registered_Datetime_Formula__c', fflib_QueryFactory.SortOrder.DESCENDING);
        //Adds the Journal entry selector query as a relationship query to the Conversation Note query
        new CRM_JournalEntrySelector().addQueryFactorySubselect(query, 'Journal_Entries__r');
        return (List<Conversation_Note__c>) Database.query(query.toSOQL());
    }

    public List<Conversation_Note__c> selectByBehandlingskjedeId(String behandlingskjedeId) {
        fflib_QueryFactory query = newQueryFactory();
        query
            .selectFields(QUERY_FIELDS)
            .setCondition('CRM_Henvendelse_BehandlingskjedeId__c =: behandlingskjedeId')
            .setOrdering('CRM_Registered_Datetime_Formula__c', fflib_QueryFactory.SortOrder.DESCENDING);
        //Adds the Journal entry selector query as a relationship query to the Conversation Note query
        new CRM_JournalEntrySelector().addQueryFactorySubselect(query, 'Journal_Entries__r');
        return (List<Conversation_Note__c>) Database.query(query.toSOQL());
    }
}
