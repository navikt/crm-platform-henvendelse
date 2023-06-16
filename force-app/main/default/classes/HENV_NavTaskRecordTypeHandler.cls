public with sharing class HENV_NavTaskRecordTypeHandler extends MyTriggers {
    private final String DIALOGUE_RECORD_TYPE = Schema.SObjectType.NavTask__c.getRecordTypeInfosByDeveloperName()
        .get('NAV_Dialogue_Task')
        .getRecordTypeId();

    public override void onBeforeInsert() {
        for (NavTask__c navTask : (List<NavTask__c>) records) {
            setRecordTypeId(navTask);
        }
    }

    public override void onBeforeUpdate(Map<Id, SObject> triggerOldMap) {
        for (NavTask__c navTask : (List<NavTask__c>) records) {
            setRecordTypeId(navTask);
        }
    }

    /**
     * Sets the dialogue task record type automatically. Does not run in core packages as field exist outside dependency tree
     * @author Stian Ruud Schikora | 05-20-2022
     * @param navTask
     **/
    private void setRecordTypeId(NavTask__c navTask) {
        try {
            if (String.isNotBlank((String) navTask.get('NKS_Henvendelse_BehandlingsId__c'))) {
                navTask.RecordTypeId = DIALOGUE_RECORD_TYPE;
            }
        } catch (System.SObjectException ex) {
            //Field does not exist
        }
    }
}
