@IsTest
private class HenvendelseDbUtil_Test {
    
    @TestSetup
    static void makeData() {
        CRM_HENV_TestDataFactory.createRecord(new Common_Code__c(CRM_Code_Set__c = 'Tema', CRM_Code__c = 'DAG'));
        myTriggers.disable(ConvNoteHenvendelseDbHandler.class);
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT',	CRM_Henvendelse_BehandlingskjedeId__c='abc'));
        CRM_HENV_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Conversation_Note__c = 'DUMMY TEXT 2', CRM_Henvendelse_BehandlingskjedeId__c='def'));
        
        Thread__c thread1 = (Thread__c) CRM_HENV_TestDataFactory.createRecord(new Thread__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c(CRM_Thread__c = thread1.Id));

        Thread__c thread2 = (Thread__c) CRM_HENV_TestDataFactory.createRecord(new Thread__c());
        CRM_HENV_TestDataFactory.createRecord(new Message__c(CRM_Thread__c = thread2.Id));
    }

    @IsTest
    private static void testGetBehandlingskjedeIds(){
        Set<Id> convIds=new Set<Id>{};
        for(Conversation_Note__c convNote:[SELECT Id FROM Conversation_Note__c]){
            convIds.add(convNote.Id);
        }
    
        List<String> behandlingskjedeIds = HenvendelseDbUtil.getBehandlingskjedeIds(convIds);
        Assert.areEqual(2,behandlingskjedeIds.size());
        Assert.areEqual('abc', behandlingskjedeIds[0]);
    }

    @IsTest
    private static void testGetConversationNotes(){
        List<String> behandlingKjedeIds=new List<String>{'abc','def'};
        
        List<Conversation_Note__c> convNoteList= HenvendelseDbUtil.getConversationNotes(behandlingKjedeIds);
        Assert.areEqual(2,convNoteList.size());
    }
}