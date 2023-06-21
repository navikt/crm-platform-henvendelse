/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 21-06-2023
 * @last modified by  : mamikals
 **/
public inherited sharing class ArchiveHandler {
    public static String checkNull(String value) {
        return String.isBlank(value) ? '' : value;
    }

    @InvocableMethod(
        label='Post data to archive server'
        description='Sends all the data of a query to the archive server.'
    )
    public static List<String> postToArchive(List<ArchivePostWrapper> inputs) {
        List<ArchiveRequestWrapper> archiveObjects = new List<ArchiveRequestWrapper>();
        ArchiveService service = new ArchiveService();
        Map<Id, Thread__c> threadMap = new Map<Id, Thread__c>();
        List<Id> threadList = new List<Id>();
        for (ArchivePostWrapper input : inputs) {
            if (input.archiveObject.getSObjectType().getDescribe().getName() == 'Thread__c') {
                threadList.add(input.archiveObject.Id);
            }
        }
        try {
            for (Thread__c thread : [
                SELECT
                    Id,
                    (
                        SELECT
                            Id,
                            Name,
                            CRM_Message_Text__c,
                            CRM_Thread_Type__c,
                            CRM_Read_Datetime__c,
                            CRM_Sent_date__c,
                            CRM_Henvendelse_BehandlingsId__c
                        FROM Messages__r
                    )
                FROM Thread__c
                WHERE Id IN :threadList
            ]) {
                threadMap.put(thread.Id, thread);
            }
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility('Arkiv');
            logger.error(
                'Feil med henting av tråder for arkivering: ' +
                e,
                null
            );
        }
        for (ArchivePostWrapper input : inputs) {
            SObject archiveObject = input.archiveObject;
            if (input.archiveObject.getSObjectType().getDescribe().getName() == 'Thread__c') {
                archiveObject = (SObject) threadMap.get(input.archiveObject.Id);
            }
            input.aktoerid = checkNull(input.aktoerid);
            input.fnr = checkNull(input.fnr);
            input.orgnr = checkNull(input.orgnr);
            input.tema = checkNull(input.tema);
            input.dokumentasjonId = checkNull(input.dokumentasjonId);

            ArchiveRequestWrapper inputWrapper = new ArchiveRequestWrapper(
                input.opprettetAv,
                input.aktoerid,
                input.fnr,
                input.orgnr,
                input.tema,
                input.konfidentiellt,
                input.dokumentasjonId,
                input.archiveObject
            );
            archiveObjects.add(inputWrapper);
        }
        List<ArchiveService.ArchiveResponseWrapper> resp = service.postToArchive(archiveObjects);
        List<String> returnStrings = new List<String>();
        for (ArchiveService.ArchiveResponseWrapper archive : resp) {
            returnStrings.add(archive.dokumentasjonId);
        }
        return returnStrings;
    }

    public class ArchivePostWrapper {
        @invocableVariable(required=true)
        public Sobject archiveObject;
        @invocableVariable(required=true)
        public String opprettetAv;
        @invocableVariable
        public String aktoerid;
        @invocableVariable
        public String fnr;
        @invocableVariable
        public String orgnr;
        @invocableVariable
        public String tema;
        @invocableVariable(required=true)
        public Boolean konfidentiellt;
        @invocableVariable
        public String dokumentasjonId;

        public ArchivePostWrapper() {
        }
        @TestVisible
        public ArchivePostWrapper(
            SObject archiveObject,
            String opprettetAv,
            String aktoerid,
            String fnr,
            String orgnr,
            String tema,
            Boolean konfidentiellt,
            String dokumentasjonId
        ) {
            this.archiveObject = archiveObject;
            this.opprettetAv = opprettetAv;
            this.aktoerid = aktoerid;
            this.fnr = fnr;
            this.orgnr = orgnr;
            this.tema = tema;
            this.konfidentiellt = konfidentiellt;
            this.dokumentasjonId = dokumentasjonId;
        }

        public ArchivePostWrapper(SObject archiveObject, String opprettetAv) {
            this.archiveObject = archiveObject;
            this.opprettetAv = opprettetAv;
            switch on archiveObject.getSObjectType().getDescribe().getName() {
                when 'Thread__c' {
                    this.fnr = ((Thread__c) archiveObject)?.CRM_Account__r?.CRM_Person__r?.Name;
                    this.aktoerid = ((Thread__c) archiveObject)?.CRM_Account__r?.CRM_Person__r?.INT_ActorId__c;
                    this.konfidentiellt = ((Thread__c) archiveObject)?.STO_Sensitive_Information__c;
                    this.tema = ((Thread__c) archiveObject).CRM_Theme__c;
                }
                when 'Conversation_note__c' {
                    this.konfidentiellt = true;
                    this.aktoerid = ((Conversation_Note__c) archiveObject)
                        ?.CRM_Account__r
                        ?.CRM_Person__r
                        ?.INT_ActorId__c;
                    this.fnr = ((Conversation_Note__c) archiveObject)?.CRM_Account__r?.CRM_Person__r?.Name;
                    this.tema = ((Conversation_Note__c) archiveObject).CRM_Theme__c;
                }
                when else {
                }
            }
        }
    }
}
