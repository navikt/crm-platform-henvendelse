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
                input.referenceId,
                input.referenceObject
            );
            archiveRecordsToPost.add(reqWrapper);
        }

        List<ArchiveService.ArchiveResponseWrapper> response = new ArchiveService().postToArchive(archiveRecordsToPost);
        List<String> documentationIdResponses = new List<String>(); // The API returns documentationId attribute on success
        for (ArchiveService.ArchiveResponseWrapper archiveResponse : response) {
            documentationIdResponses.add(archiveResponse.dokumentasjonId);
        }
        return documentationIdResponses;
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
        public String dokumentasjonId;
        @invocableVariable
        public String referenceId;
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
            String referenceId,
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
            this.referenceId = referenceId;
            this.referenceObject = referenceObject;
        }
    }
}
