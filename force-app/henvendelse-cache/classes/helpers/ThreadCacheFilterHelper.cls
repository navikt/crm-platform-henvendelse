public without sharing class ThreadCacheFilterHelper {
    private static LoggerUtility logger = new LoggerUtility('HenvendelseCaching');

    public static List<CacheHenvendelseEvent> getCacheEvents(
        Set<Id> threadIds
    ) {
        List<CacheHenvendelseEvent> threadsToBeCached = new List<CacheHenvendelseEvent>();
        List<String> threadTypes = new List<String>{ 'STO', 'STB', 'CHAT', 'BTO' };
                    for (Thread__c thread : [
                        SELECT
                            CRM_Account__r.CRM_Person__r.INT_ActorId__c,
                            CRM_API_Reference__c
                        FROM Thread__c
                        WHERE Id IN :threadIds
                        AND CRM_Thread_Type__c in :threadTypes
                    ]) {
                        if (
                            thread.CRM_Account__r.CRM_Person__r.INT_ActorId__c != null &&
                            thread.CRM_API_Reference__c!= null
                        ) {
                            threadsToBeCached.add(
                                new CacheHenvendelseEvent(
                                    thread.CRM_Account__r.CRM_Person__r.INT_ActorId__c,
                                    thread.CRM_API_Reference__c
                                )
                            );
                        }
                    }
                    return threadsToBeCached;
    }

    public static Set<Id> getThreadIdsByMessages(List<Message__c> messages) {
        ModiaIntegrationUser modiaIntegrationUser = new ModiaIntegrationUser();
        Set<Id> threadIds = new Set<Id>();

        for (Message__c msg : messages) {
            //Only cache records created by Salesforce internal users
            if (msg.LastModifiedById != modiaIntegrationUser.UserId) {
                threadIds.add(msg.CRM_Thread__c);
            }
        }

        return threadIds;
    }
}
