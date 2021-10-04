public without sharing class CRM_ThreadReferenceHandler extends MyTriggers {
    public override void onBeforeInsert() {
        for (Thread__c thread : (List<Thread__c>) Records) {
            thread.CRM_API_Reference__c = CRM_ReferenceUtil.generateReference(thread);
        }
    }
}
