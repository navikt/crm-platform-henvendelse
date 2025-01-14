public without sharing class ConvNoteCacheFilterHelper {
   
    public static List<CacheHenvendelse> getConvNotesToBeCached(
                List<Conversation_Note__c> convNoteList){
                    Set<Id> recordIds = getRecordIds(convNoteList);

                    List<CacheHenvendelse> convNotesToBeCached = new List<CacheHenvendelse>();
                    for (Conversation_Note__c convNote : [
                        SELECT
                            CRM_Account__r.CRM_Person__r.INT_ActorId__c,
                            CRM_Henvendelse_BehandlingskjedeId__c
                        FROM Conversation_Note__c
                        WHERE Id IN :recordIds
                    ]) {
                        if (
                            convNote.CRM_Account__r.CRM_Person__r.INT_ActorId__c != null &&
                            convNote.CRM_Henvendelse_BehandlingskjedeId__c != null
                        ) {
                            convNotesToBeCached.add(
                                new CacheHenvendelse(
                                    convNote.CRM_Account__r.CRM_Person__r.INT_ActorId__c,
                                    convNote.CRM_Henvendelse_BehandlingskjedeId__c
                                )
                            );
                        }
                    }
                    return convNotesToBeCached;
                }
            
                public static Set<Id> getRecordIds(
                    List<Conversation_Note__c> convNoteList
                ) {
                    ModiaIntegrationUser modiaIntegrationUser = new ModiaIntegrationUser();
                    Set<Id> recordIds = new Set<Id>();
                    for (Conversation_Note__c convNote : convNoteList) {
                        //Only cache records modified in Salesforce
                        if (convNote.LastModifiedById != modiaIntegrationUser.UserId) {
                            recordIds.add(convNote.Id);
                        }
                    }
                    return recordIds;
                }
            }