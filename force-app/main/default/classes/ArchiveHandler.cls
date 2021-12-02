public with sharing class ArchiveHandler {
    public static String checkNull(String value) {
        return String.isBlank(value) ? '' : value;
    }

    @InvocableMethod(
        label='Post data to archive server'
        description='Sends all the data of a query to the archive server.'
    )
    public static List<String> postToArchive(List<ArchivePostWrapper> inputs) {
        List<String> returnList = new List<String>();
        for (ArchivePostWrapper input : inputs) {
            SObject archiveObject = input.archiveObject;
            if(input.archiveObject.getSObjectType().getDescribe().getName() == 'Thread__c'){
                List<Thread__c> threadWithMessage = [
                SELECT Id,
                    (SELECT Id, Name, CRM_Message_Text__c, CRM_Thread_Type__c, CRM_Read_Datetime__c, CRM_Sent_date__c, CRM_Henvendelse_BehandlingsId__c 
                    FROM Messages__r) 
                FROM Thread__c
                WHERE Id=:input.archiveObject.Id
                ];
                archiveObject = (SObject) threadWithMessage[0];
            }
            input.aktoerid = checkNull(input.aktoerid);
            input.fnr = checkNull(input.fnr);
            input.orgnr = checkNull(input.orgnr);
            input.tema = checkNull(input.tema);
            input.dokumentasjonId = checkNull(input.dokumentasjonId);
            ArchiveService service = new ArchiveService();
            ArchiveService.ArchiveInputWrapper inputWrapper = new ArchiveService.ArchiveInputWrapper(
                input.opprettetAv,
                input.aktoerid,
                input.fnr,
                input.orgnr,
                input.tema,
                input.konfidentiellt,
                input.dokumentasjonId
            );
            List<ArchiveService.ArchiveResponseWrapper> resp = service.postToArchive(archiveObject, inputWrapper);
            returnList.add(JSON.serialize(resp));
        }
        return returnList;
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

        public ArchivePostWrapper(){}
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
    }
}
