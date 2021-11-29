public with sharing class ArchiveHandler{
    
    public static String checkNull(String value) {
        return String.isBlank(value) ? '' : value;
    }

    @InvocableMethod(
        label='Post data to archive server'
        description='Sends all the data of a query to the archive server.'
    )
    public static List<String> postToArchive(List<ArchivePostWrapper> inputs) {
        List<String> returnList = new List<String>();
        System.debug('Running');
        for(ArchivePostWrapper input : inputs){
            System.debug(input);
            input.aktoerid += checkNull(input.aktoerid);
            input.fnr += checkNull(input.fnr);
            input.orgnr += checkNull(input.orgnr);
            input.tema += checkNull(input.tema);
            System.debug('Paul');
            ArchiveService service = new ArchiveService();
            List<Id> idList = (List<Id>) input.ids;
            System.debug(idList);
            String queryString = input.query + ' WHERE Id IN :idList';
            List<SObject> archiveObjects = Database.query(queryString);
            System.debug('Thing is ');
            ArchiveService.ArchiveInputWrapper inputWrapper = new ArchiveService.ArchiveInputWrapper(input.opprettetAv,
            input.aktoerid,
            input.fnr,
            input.orgnr,
            input.tema,
            input.konfidentiellt);
            List<ArchiveService.ArchiveResponseWrapper> resp = service.postToArchive(archiveObjects, inputWrapper);
            returnList.add(JSON.serialize(resp));
        }
        return returnList;
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

        @TestVisible
        public ArchivePostWrapper(String query, List<String> ids, String opprettetAv, String aktoerid, String fnr, String orgnr, String tema, Boolean konfidentiellt
        ) {
            this.query = query;
            this.ids = ids;
            this.opprettetAv = opprettetAv;
            this.aktoerid = aktoerid;
            this.fnr = fnr;
            this.orgnr = orgnr;
            this.tema = tema;
            this.konfidentiellt = konfidentiellt;
    }
    }
}
