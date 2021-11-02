public with sharing class ArchiveHandler{
    
    @InvocableMethod(
        label='Post data to archive server'
        description='Sends all the data of a query to the archive server.'
    )
    public static List<String> postToArchive(List<ArchivePostWrapper> inputs) {
        List<String> test = new List<String>();
        for(ArchivePostWrapper input : inputs){
            ArchiveService service = new ArchiveService();
            List<Id> idList = (List<Id>) input.ids;
            String testString = input.query + ' WHERE Id IN :idList';
            List<SObject> archiveObjects = Database.query(testString);
            ArchiveService.ArchiveInputWrapper inputWrapper = new ArchiveService.ArchiveInputWrapper(input.opprettetAv,
            input.aktoerid,
            input.fnr,
            input.orgnr,
            input.tema,
            input.konfidentiellt);
            List<ArchiveService.ArchiveResponseWrapper> resp =  service.postToArchive(archiveObjects, inputWrapper);
            test.add(JSON.serialize(resp));
        }
        return test;
    }

    public class ArchivePostWrapper {
        @invocableVariable(required=true)
        public String query;
        @invocableVariable(required=true)
        public List<String> ids;
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
    }
}
