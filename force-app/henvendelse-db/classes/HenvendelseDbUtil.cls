public without sharing class HenvendelseDbUtil {
    public static List<Conversation_Note__c> getConversationNotes(List<String> behandlingskjedeIds){
        return [
        SELECT
        Id,
        Name,
        CRM_HenvendelseId__c,
        CRM_Henvendelse_BehandlingskjedeId__c,
        CRM_Account__r.CRM_Person__r.INT_ActorId__c,
        CRM_Account__r.CRM_Person__r.Name,
        CRM_Theme_Group_Code__c,
        CRM_Theme_Code__c,
        CRM_Office_Restriction__c,
        CRM_Read_Date__c,
        CRM_Date_Time_Registered__c,
        CRM_Conversation_Note__c,
        CRM_Created_By_Ident__c,
        CRM_Office_Restriction_Activated_By__c,
        CRM_Office_Restriction_Date__c,
        CRM_Incorrectly_Sent_Activated_By__c,
        CRM_Incorrectly_Sent_Date__c,
        CRM_Incorrectly_Sent__c,
        CRM_Disposal_Datetime__c,
        CRM_Communication_Channel__c,
        CRM_Created_By_NAV_Unit__c,
        CRM_Original_Person_GT__c,
        CRM_Original_Person_NAV_Unit__c,
        STO_Sensitive_Information__c,
        CRM_API_Reference__c,
        (SELECT Id,
                CRM_Created_By_Ident__c,
                CRM_Created_By_NAV_Unit__c,
                CRM_Journal_Date__c,
                Journal_Entry_ID__c,
                Journal_Entry_Status__c,
                NAV_Case_Reference__c,
                CRM_Theme_Code__c,
                CRM_Subtheme_Code__c,
                CRM_NAV_Case_Legacy_System__c
          FROM Journal_Entries__r )
        FROM Conversation_Note__c
        WHERE CRM_Henvendelse_BehandlingskjedeId__c in:behandlingskjedeIds
        AND CRM_Account__c !=null AND CRM_Account__r.CRM_Person__c!=null
        ORDER BY CRM_Date_Time_Registered__c DESC];
    }

    public static List<String> getBehandlingskjedeIds(Set<Id> convIds){
        List<String> behandlingskjedeIds=new List<String>();
        for(Conversation_Note__c convNote:[SELECT CRM_Henvendelse_BehandlingskjedeId__c FROM Conversation_Note__c WHERE Id in:convIds]){
            behandlingskjedeIds.add(convNote.CRM_Henvendelse_BehandlingskjedeId__c);
        }
        return behandlingskjedeIds;
    } 
}