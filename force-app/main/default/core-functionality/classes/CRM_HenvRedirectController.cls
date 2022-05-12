public with sharing class CRM_HenvRedirectController {
    /**
     * SOSL query to find either a thread or conversation note with the input apiReference
     * @author Stian Ruud Schikora | 05-12-2022
     * @param apiReference
     * @return String
     **/
    @AuraEnabled(cacheable=true)
    public static String getHenvRecordId(String apiReference) {
        List<List<SObject>> searchList = [
            FIND :apiReference
            IN ALL FIELDS
            RETURNING
                Thread__c(Id WHERE CRM_API_Reference__c = :apiReference),
                Conversation_Note__c(Id WHERE CRM_API_Reference__c = :apiReference)
        ];

        for (List<SObject> retList : searchList) {
            if (!retList.isEmpty())
                return (String) retList[0].get('Id');
        }

        throw new NoRecordException('Could not find record');
    }

    private class NoRecordException extends Exception {
    }
}
