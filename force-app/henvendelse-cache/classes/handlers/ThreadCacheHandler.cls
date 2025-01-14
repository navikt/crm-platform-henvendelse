global class ThreadCacheHandler extends MyTriggers  {
    private LoggerUtility logger = new LoggerUtility('HenvendelseCaching');

    global override void onAfterInsert() {
        publishEvents((List<Thread__c>) records);
    }
    global override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        //TODO: Post bare for felter som er relevante for cachingen
        publishEvents((List<Thread__c>) records);
    }
    private void publishEvents(List<Thread__c> threadList) {
       Set<Id> threadIds=ThreadCacheFilterHelper.getThreadIdsByThreads(threadList); 
       List<CacheHenvendelseEvent> events=ThreadCacheFilterHelper.getCacheEvents(threadIds);
       CacheEventHelper.publish(events, 'Thread');
    }
}