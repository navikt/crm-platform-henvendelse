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
        CRM_API_Reference__c
        FROM Conversation_Note__c
        WHERE Id in:convIds];
    }


    
}