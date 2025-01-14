global class MessageCacheHandler extends MyTriggers {
    private LoggerUtility logger = new LoggerUtility('HenvendelseCaching');

    global override void onAfterInsert() {
        publishEvents((List<Message__c>) records);
    }
    global override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        //TODO: Post bare for felter som er relevante for cachingen
        publishEvents((List<Message__c>) records);
    }
    private void publishEvents(List<Message__c> messageList) {
       Set<Id> threadIds=ThreadCacheFilterHelper.getThreadIdsByMessages(messageList); 
       List<CacheHenvendelseEvent> events=ThreadCacheFilterHelper.getCacheEvents(threadIds);
       CacheEventHelper.publish(events, ' Message');
    }
}
