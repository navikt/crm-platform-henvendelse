global class ConvNoteCacheHandler extends MyTriggers {
    private LoggerUtility logger = new LoggerUtility('HenvendelseCaching');

    global override void onAfterInsert() {
        publishCacheEvents((List<Conversation_Note__c>) records);
    }
    global override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        //TODO: Sjekk kun for felter som er relevante for cachingen
        publishCacheEvents((List<Conversation_Note__c>) records);
    }
    private void publishCacheEvents(
        List<Conversation_Note__c> convNoteList
    ) {
        try {
            List<CacheHenvendelse> events = ConvNoteCacheFilterHelper.getConvNotesToBeCached(
                convNoteList
            );
            for(CacheHenvendelse henvendelse:events){
                logger.info('Henvendelse Caching-' + henvendelse.ActorId + '-' + henvendelse.BehandlingskjedeId, null, CRM_ApplicationDomain.Domain.NKS);
            }
            if (events.size() > 0) {
                logger.publishSynch();
            }
        } catch (exception e) {
            logger.exception(e);
            logger.publish();
        }
    }
}
