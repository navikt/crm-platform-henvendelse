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

    @AuraEnabled
    public static string getUserContactId() {
        return [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()]?.ContactId;
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
    public static List<Journal_Entry__c> getJournalEntries(Id threadId) {
        return [
            SELECT
                Id,
                Theme__c,
                NAV_Case_Reference__c,
                CRM_Journal_Date__c,
                Journal_Entry_ID__c,
                CRM_Created_By_Ident__c
            FROM Journal_Entry__c
            WHERE CRM_Thread__c = :threadId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Thread__c> getThreads(Id recordId) {
        List<Thread__c> threadList;
        try {
            threadList = [
                SELECT Id, CRM_Number_of_External_Messages__c, CRM_Related_Object__c, CRM_isActive__c
                FROM Thread__c
                WHERE CRM_Related_Object__c = :recordId
            ];
        } catch (Exception e) {
        }
        return threadList;
    }
    @AuraEnabled(cacheable=true)
    public static Thread__c getSingleThread(Id recordId) {
        try {
            if (recordId.getSobjectType() == Thread__c.sObjectType) {
                return getThreadFromThreadId(recordId);
            }
            Thread__c t = [
                SELECT Id, CRM_Number_of_External_Messages__c, CRM_Related_Object__c, CRM_isActive__c
                FROM Thread__c
                WHERE CRM_Related_Object__c = :recordId
                LIMIT 1
            ];

            return t;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Thread__c getThreadFromThreadId(Id recordId) {
        try {
            Thread__c t = [
                SELECT Id, CRM_Number_of_External_Messages__c, CRM_Related_Object__c, CRM_isActive__c
                FROM Thread__c
                WHERE Id = :recordId
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
        newThread.CRM_Related_Object__c = recordId;
        insert newThread;
    }

    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessagesFromThread(Id threadId) {
        try {
            List<Message__c> msgList = new List<Message__c>();
            String query =
                'SELECT Id, CRM_Message_Text__c, CRM_Type__c, CRM_Event_Type__c, crm_sent_date__c, CRM_From_User__c, CRM_From_Contact__c, CRM_From_First_Name__c, CRM_External_Message__c, CRM_From_Label__c FROM Message__c WHERE ' +
                getThreadQuery(threadId) +
                ' ORDER BY CRM_Sent_date__c ASC';
            for (Message__c m : Database.query(query)) {
                if (m.CRM_Message_Text__c != null) {
                    msgList.add(m);
                }
            }
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
        String query = 'SELECT Id FROM Message__c WHERE CRM_Read__c = FALSE AND ' + getThreadQuery(threadId);
        List<Message__c> msgList = Database.query(query);
        for (Message__c msg : msgList) {
            msg.CRM_Read__c = true;
            msg.CRM_Read_Datetime__c = DateTime.now();
        }
        update msgList;
    }

    @AuraEnabled(cacheable=true)
    public static Id getThreadId(Id recordId) {
        return (recordId.getSobjectType() == Thread__c.sObjectType
            ? recordId
            : [SELECT Id FROM Thread__c WHERE CRM_Related_Object__c = :recordId LIMIT 1].Id);
    }

    /**
     * Creates a message
     * Used in the community components
     * @Author Lars Petter Johnsen
     */
    @AuraEnabled
    public static Boolean createMessage(Id threadId, String messageText, Id fromContactId) {
        Message__c m = new Message__c();
        m.CRM_Message_Text__c = messageText;
        m.CRM_Thread__c = threadId;
        m.CRM_From_Contact__c = fromContactId;
        m.CRM_Read__c = true;
        m.CRM_Read_Datetime__c = DateTime.now();

        Thread__c t = [SELECT Id, CRM_isActive__c FROM Thread__c WHERE Id = :threadId LIMIT 1][0];
        if (!t.CRM_isActive__c) {
            return false;
        }

        try {
            insert m;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getThreadQuery(Id threadId) {
        if (threadId.getSobjectType() == Thread__c.sObjectType) {
            return 'CRM_Thread__c = :threadId';
        } else {
            return 'CRM_Thread__r.CRM_Related_Object__c = :threadId';
        }
    }
}
