global class ConvNoteHenvendelseDbHandler extends MyTriggers {

    global override void onAfterInsert() {
        getRecordsIdsAndInitiatePostToDb((List<Conversation_Note__c>) records);
    }

    global override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        getRecordsIdsAndInitiatePostToDb((List<Conversation_Note__c>) records);
    }

    private void getRecordsIdsAndInitiatePostToDb(List<Conversation_Note__c> convNoteList){
        Set<Id> convNoteIds=new Set<Id>();

        for(Conversation_Note__c convNote:convNoteList){
            convNoteIds.add(convNote.Id);
        }

        if(convNoteIds.size()>0){
            postToHenvdelseDb(convNoteIds);
        }
    }

    @future(callout=true)
    public static void postToHenvdelseDb(Set<Id> convNoteIds)
    {   
        HenvendelseDbService.postConversationNotes(getConversationNotes(convNoteIds));
    }

    
    private static List<Conversation_Note__c> getConversationNotes(Set<Id> convIds){
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
        WHERE CRM_Henvendelse_BehandlingskjedeId__c in:getBehandlingskjedeIds(convIds)
        ORDER BY CRM_Date_Time_Registered__c DESC];
    }

    private static Set<String> getBehandlingskjedeIds(Set<Id> convIds){
        Set<String> behandlingskjedeIds=new Set<String>();
        for(Conversation_Note__c convNote:[SELECT CRM_Henvendelse_BehandlingskjedeId__c FROM Conversation_Note__c WHERE Id in:convIds]){
            behandlingskjedeIds.add(convNote.CRM_Henvendelse_BehandlingskjedeId__c);
        }
        return behandlingskjedeIds;
    } 
}