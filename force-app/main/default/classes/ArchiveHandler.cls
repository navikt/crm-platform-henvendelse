/**
 * @description       :
 * @author            : mamikals
 * @group             :
 * @last modified on  : 01-11-2023
 * @last modified by  : mamikals
 **/
public inherited sharing class ArchiveHandler {
    @InvocableMethod(label='Post data to archive server' description='Sends data to the archive server.')
    public static List<String> postToArchive(List<ArchivePostWrapper> inputs) {
        List<ArchiveRequestWrapper> archiveRecordsToPost = new List<ArchiveRequestWrapper>();
        for (ArchivePostWrapper input : inputs) {
            ArchiveRequestWrapper reqWrapper = new ArchiveRequestWrapper(
                input.opprettetAv,
                input.aktoerid,
                input.fnr,
                input.orgnr,
                input.tema,
                input.konfidentiellt,
                input.dokumentasjonId,
                input.archiveData,
                input.referenceObject
            );
            archiveRecordsToPost.add(reqWrapper);
        }

        CRM_ApplicationDomain myDomain = new CRM_ApplicationDomain();
        Map<String, CRM_ApplicationDomain.Domain> domainNameMap = myDomain.domainNameMap;

        List<ArchiveService.ArchiveResponseWrapper> response;
        try {
            response = new ArchiveService().postToArchive(archiveRecordsToPost);
            if (response == null) {
                throw new ArchiveException('Response was null.');
            }
        } catch (Exception e) {
            logger.error(
                e.getMessage() +
                '. ' +
                e.getStackTraceString(),
                null,
                domainNameMap.get(archiveRecordsToPost[0].opprettetAv)
            );
        } finally {
            logger.publish();
        }

        List<String> responseIds = new List<String>(); // The API returns id attribute on success
        if (response != null) {
            for (ArchiveService.ArchiveResponseWrapper archiveResponse : response) {
                responseIds.add(String.valueOf(archiveResponse.id));
            }
        }
        return responseIds;
    }

    public class ArchiveException extends Exception {
    }

    public class ArchivePostWrapper {
        @invocableVariable(required=true)
        public String archiveData;
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
        public String dokumentasjonId; // Reference_Id__c
        @invocableVariable
        public String referenceObject;

        public ArchivePostWrapper() {
        }

        @TestVisible
        public ArchivePostWrapper(
            String archiveData,
            String opprettetAv,
            String aktoerid,
            String fnr,
            String orgnr,
            String tema,
            Boolean konfidentiellt,
            String dokumentasjonId,
            String referenceObject
        ) {
            this.archiveData = archiveData;
            this.opprettetAv = opprettetAv;
            this.aktoerid = aktoerid;
            this.fnr = fnr;
            this.orgnr = orgnr;
            this.tema = tema;
            this.konfidentiellt = konfidentiellt;
            this.dokumentasjonId = dokumentasjonId;
            this.referenceObject = referenceObject;
        }
    }
}
