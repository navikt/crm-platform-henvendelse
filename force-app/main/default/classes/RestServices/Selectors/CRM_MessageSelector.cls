public inherited sharing class CRM_MessageSelector extends CRM_ApiSelector {
    public CRM_MessageSelector() {
        super(false);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Message__c.CRM_Type__c,
            Message__c.CRM_Read__c,
            Message__c.CRM_Thread__c,
            Message__c.CRM_Recipient__c,
            Message__c.CRM_Message_Text__c,
            Message__c.Id,
            Message__c.CRM_Sent_Datetime_Formula__c,
            Message__c.CRM_From__c,
            Message__c.CRM_Read_Datetime__c,
            Message__c.CRM_External_Message__c,
            Message__c.CRM_From_Ident_Formula__c,
            Message__c.CRM_From_NAV_Unit__c
        };
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
