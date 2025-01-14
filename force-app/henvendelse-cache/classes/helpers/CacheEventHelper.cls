public with sharing class CacheEventHelper {
    public static void publish(
        List<CacheHenvendelse> events,
        String henvendelseType
    ) {
        LoggerUtility logger = new LoggerUtility('HenvendelseCaching');
        try {
           
            for(CacheHenvendelse henvendelse:events){
                logger.info(henvendelseType + '-' + henvendelse.ActorId + '-' + henvendelse.BehandlingskjedeId, null, CRM_ApplicationDomain.Domain.NKS);
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