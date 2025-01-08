public without sharing class HenvendelseDbThreadMigration implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private LoggerUtility logger;
    private DateTime createdDateStart;
    private DateTime createdDateEnd;

    public HenvendelseDbThreadMigration(DateTime createdDateStart, DateTime createdDateEnd ) {
        this.logger = new LoggerUtility('Henvendelse DB');
        this.createdDateStart=createdDateStart;
        this.createdDateEnd=createdDateEnd;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> threadTypes = new List<String>{ 'STO', 'STB', 'CHAT', 'BTO' };
        String query = 'SELECT Id FROM Thread__c';
        query += ' WHERE CreatedDate>=:createdDateStart AND CreatedDate<:createdDateEnd AND CRM_Account__c !=null AND CRM_Type__c in :threadTypes)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Thread__c> scope) {
        Set<Id> threadIds=new Set<Id>();
        for(Thread__c thread:scope){
            threadIds.add(thread.Id);
        }

        HenvendelseDbService.postConversationNotes(HenvendelseDbUtil.getThreads(threadIds));
    }

    public void finish(Database.BatchableContext BC) {
    }
    
}