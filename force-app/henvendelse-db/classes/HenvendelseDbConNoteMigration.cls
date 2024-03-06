public without sharing class HenvendelseDbConNoteMigration  implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private LoggerUtility logger;
    private DateTime createdDateStart;
    private DateTime createdDateEnd;

    public HenvendelseDbConNoteMigration(DateTime createdDateStart, DateTime createdDateEnd ) {
        this.logger = new LoggerUtility('Henvendelse DB');
        this.createdDateStart=createdDateStart;
        this.createdDateEnd=createdDateEnd;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Conversation_Note__c';
        query += ' WHERE CreatedDate>=:createdDateStart AND CreatedDate<:createdDateEnd';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Conversation_Note__c> scope) {
        Set<Id> convNoteIds=new Set<Id>();
        for(Conversation_Note__c convNote:scope){
            convNoteIds.add(convNote.Id);
        }

        List<String> behandlingKjedeIds=HenvendelseDbUtil.getBehandlingskjedeIds(convNoteIds);
        HenvendelseDbService.postConversationNotes(HenvendelseDbUtil.getConversationNotes(behandlingKjedeIds));
    }

    public void finish(Database.BatchableContext BC) {
    }
    
}