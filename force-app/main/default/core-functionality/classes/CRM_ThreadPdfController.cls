public without sharing class CRM_ThreadPdfController {
    private static final Integer MAX_LINE_LENGTH = 80;
    private transient string threadId;
    public List<Message__c> threadMessages { get; set; }

    public CRM_ThreadPdfController(ApexPages.StandardController stdController) {
        threadId = stdController.getId();
        threadMessages = [
            SELECT
                CRM_Type__c,
                CRM_External_Message__c,
                CRM_From_Contact__r.Name,
                CRM_From_Ident_Formula__c,
                CRM_Sent_date__c,
                CRM_Message_Text__c
            FROM Message__c
            WHERE CRM_Thread__c = :threadId
            ORDER BY CRM_Sent_date__c ASC
        ];
        if(threadMessages != null){
            LongWordSplitter splitter = new LongWordSplitter(MAX_LINE_LENGTH);
            for(Integer i = 0; i < threadMessages.size(); i++){
                threadMessages[i].CRM_Message_Text__c = splitter.splitWordsInMessage(threadMessages[i].CRM_Message_Text__c);
            }
        }
    }
    
    public class LongWordSplitter{
        private Integer length;
        public LongWordSplitter(Integer length){
            this.length = length;
        }
        public String splitWordsInMessage(String message){
            if(message == null || message.length() <= length){
                return message;
            }
            return String.join(splitWordsInLines(message.split('\n|\n\r')),'\n');
        }
        @TestVisible
        private List<String> splitWordsInLines(List<String> lines){
            if(lines == null){
                return null;
            }
            List<String> newLines = new List<String>();
            for(String line : lines){
                newLines.add(splitWordsInLine(line));
            }
            return newLines;
        }
        @TestVisible
        private String splitWordsInLine(String line){
            if(line == null){
                return null;
            }
            return String.join(splitWords(line.split('\\s')),' ');
        }
        @TestVisible
        private List<String> splitWords(List<String> words){
            if(words == null){
                return null;
            }
            List<String> newWords = new List<String>();
            for(String word : words){
                newWords.add(splitWord(word));
            }
            return newWords;
        }
        public String splitWord(String word){
            if(word == null){
                return null;
            }
            List<String> wordParts = new List<String>();
            do{
                wordParts.add(word.left(length));
                word = word.right(word.length()-length);
            }while(word.length() > 0);
            return String.join(wordParts, ' ');
        }
    }
}