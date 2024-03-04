global class ConvNoteHenvendelseDbHandler extends MyTriggers {

    global override void onAfterInsert() {
        getRecordsIdsAndInitiatePostToDb((List<Conversation_Note__c>) records);
    }

    global override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        getRecordsIdsAndInitiatePostToDb((List<Conversation_Note__c>) records);
    }

    private void getRecordsIdsAndInitiatePostToDb(List<Conversation_Note__c> convNoteList){
        Set<Id> convNoteIds=new Set<Id>();

        for(Conversation_Note__c convNote:convNoteList){
            convNoteIds.add(convNote.Id);
        }

        if(convNoteIds.size()>0){
            postToHenvdelseDb(convNoteIds);
        }
    }

    @future(callout=true)
    public static void postToHenvdelseDb(Set<Id> convNoteIds)
    {   
        List<String> behandlingKjedeIds=HenvendelseDbUtil.getBehandlingskjedeIds(convNoteIds);
        HenvendelseDbService.postConversationNotes(HenvendelseDbUtil.getConversationNotes(behandlingKjedeIds));
    }
}