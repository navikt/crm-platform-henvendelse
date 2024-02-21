public with sharing class HenvendelseDbConNoteMigration  implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private LoggerUtility logger;
    private DateTime createdDateStart;
    private DateTime createdDateEnd;

    public HenvendelseDbConNoteMigration(DateTime createdDateStart, DateTime createdDateEnd ) {
        this.logger = new LoggerUtility('Henvendelse DB');
        this.createdDateStart=createdDateStart;
        this.createdDateEnd=createdDateEnd;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, CRM_HenvendelseId__c, CRM_Henvendelse_BehandlingskjedeId__c, CRM_Account__r.CRM_Person__r.INT_ActorId__c, CRM_Account__r.CRM_Person__r.Name, CRM_Theme_Group_Code__c, CRM_Theme_Code__c, CRM_Office_Restriction__c, CRM_Read_Date__c, CRM_Date_Time_Registered__c,  CRM_Conversation_Note__c, CRM_Created_By_Ident__c, CRM_Office_Restriction_Activated_By__c, CRM_Office_Restriction_Date__c, CRM_Incorrectly_Sent_Activated_By__c, CRM_Incorrectly_Sent_Date__c, CRM_Incorrectly_Sent__c, CRM_Disposal_Datetime__c, CRM_Communication_Channel__c, CRM_Created_By_NAV_Unit__c, CRM_Original_Person_GT__c, CRM_Original_Person_NAV_Unit__c, STO_Sensitive_Information__c, CRM_API_Reference__c FROM Conversation_Note__c ';
        query += ' WHERE CreatedDate>=:createdDateStart AND CreatedDate<:createdDateEnd';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Conversation_Note__c> scope) {
    }

    public void finish(Database.BatchableContext BC) {
    }
    
}