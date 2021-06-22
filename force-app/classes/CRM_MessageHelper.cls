/**
 * Helper class for the Messaging solution
 * @Author Lars Petter Johnsen
 * @Date 20.05.2021
 */
public with sharing class CRM_MessageHelper {
    @AuraEnabled(cacheable=true)
    public static String getRecordObjectType(Id recordId) {
        String objectType = recordId.getSObjectType().getDescribe().getName();
        return objectType;
    }

    @AuraEnabled(cacheable=true)
    public static List<Thread__c> getThreadsCollection(Id recordId, Boolean singleThread) {
        if (singleThread == false) {
            return getThreads(recordId);
        } else {
            List<Thread__c> tList = new List<Thread__c>();
            tList.add(getSingleThread(recordId));
            return tList;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Thread__c> getThreads(Id recordId) {
        Id currentUser = UserInfo.getUserId();

        List<Thread__c> threadList;
        try {
            threadList = [
                SELECT
                    Id,
                    CRM_From__c,
                    CRM_From__r.FirstName,
                    CRM_From__r.LastName,
                    CRM_Recipient__r.FirstName,
                    CRM_Recipient__r.LastName,
                    CRM_isPublic__c,
                    CRM_Number_of_External_Messages__c,
                    CRM_Related_Object__c
                FROM Thread__c
                WHERE
                    CRM_Related_Object__c = :recordId
                    AND (CRM_From__c = :currentUser
                    OR CRM_Recipient__c = :currentUser)
            ];
        } catch (Exception e) {
        }
        return threadList;
    }
    @AuraEnabled(cacheable=true)
    public static Thread__c getSingleThread(Id recordId) {
        try {
            Thread__c t = [
                SELECT
                    Id,
                    CRM_From__c,
                    CRM_From__r.FirstName,
                    CRM_From__r.LastName,
                    CRM_Recipient__r.FirstName,
                    CRM_Recipient__r.LastName,
                    CRM_isPublic__c,
                    CRM_Number_of_External_Messages__c,
                    CRM_Related_Object__c
                FROM Thread__c
                WHERE CRM_isPublic__c = TRUE AND CRM_Related_Object__c = :recordId
                LIMIT 1
            ];

            return t;
        } catch (Exception e) {
            return null;
        }
    }
    @AuraEnabled
    public static void createThread(Id recordId) {
        Thread__c newThread = new Thread__c();
        newThread.CRM_isPublic__c = true;
        newThread.CRM_Related_Object__c = recordId;
        insert newThread;
    }

    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessagesFromThread(Id threadId) {
        try {
            List<Message__c> msgList = [
                SELECT
                    Id,
                    CRM_Message_Text__c,
                    CRM_Type__c,
                    CreatedDate,
                    CRM_From__c,
                    CRM_From_Label__c,
                    CRM_From__r.FirstName,
                    CRM_From__r.LastName,
                    CRM_External_Message__c
                FROM Message__c
                WHERE CRM_Thread__c = :threadId
                ORDER BY CreatedDate ASC
            ];
            return msgList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static string getUserLisenceType(Id userId) {
        try {
            String userLicenseType = [SELECT UserType FROM User WHERE Id = :userId LIMIT 1].UserType;
            return userLicenseType;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * Method for marking unread messages - called onload fromt the end user perspective. Does only represent customer read.
     * @Lars Petter Johnsen
     * @Date 31052021
     */
    @AuraEnabled
    public static void markAsRead(Id threadId) {
        List<Message__c> msgList = [SELECT Id FROM Message__c WHERE CRM_Read__c = FALSE AND CRM_Thread__c = :threadId];
        for (Message__c msg : msgList) {
            msg.CRM_Read__c = true;
        }
        update msgList;
    }
}
