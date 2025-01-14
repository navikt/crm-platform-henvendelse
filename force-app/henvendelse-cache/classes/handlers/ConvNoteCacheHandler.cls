global class ConvNoteCacheHandler extends MyTriggers {
    global override void onAfterInsert() {
        publishCacheEvents((List<Conversation_Note__c>) records);
    }
    global override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        //TODO: Sjekk kun for felter som er relevante for cachingen
        publishCacheEvents((List<Conversation_Note__c>) records);
    }

    private void publishCacheEvents(List<Conversation_Note__c> convNoteList){
        List<CacheHenvendelse> events = ConvNoteCacheFilterHelper.getConvNotesToBeCached(
            convNoteList
        );
        CacheEventHelper.publish(events, 'ConversationNote');
    }
   
}
