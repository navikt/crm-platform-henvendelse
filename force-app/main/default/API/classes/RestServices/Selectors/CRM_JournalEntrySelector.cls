public inherited sharing class CRM_JournalEntrySelector extends CRM_ApiSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Journal_Entry__c.Id,
            Journal_Entry__c.CRM_Created_By_Ident__c,
            Journal_Entry__c.CRM_Created_By_NAV_Unit__c,
            Journal_Entry__c.CRM_Journal_Date__c,
            Journal_Entry__c.Journal_Entry_ID__c,
            Journal_Entry__c.Journal_Entry_Status__c,
            Journal_Entry__c.NAV_Case_Reference__c,
            Journal_Entry__c.CRM_Theme_Code__c,
            Journal_Entry__c.CRM_Subtheme_Code__c,
            Journal_Entry__c.CRM_NAV_Case_Legacy_System__c
        };
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
