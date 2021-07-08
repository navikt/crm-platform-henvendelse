public without sharing virtual class CRM_HenvendelseApiUtils extends ApexRestService {
    public enum HENVENDELSE_TYPES {
        SAMTALEREFERAT,
        MELDINGSKJEDE,
        MELDING
    }

    public static Thread__c convertToThread(CRM_Henvendelse henv) {
        return new Thread__c();
    }
    public static Conversation_Note__c convertToConvNote(CRM_Henvendelse henv) {
        return new Conversation_Note__c();
    }

    public String gmtFormatDateTime(DateTime timestamp) {
        return timestamp != null ? timestamp.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : null;
    }

    /**
     * @description: For system integration the NAV ident of the user performing the action should be included in a request header
     * @author Stian Ruud Schikora | 07-07-2021
     * @return String
     **/
    public static String getActingNavIdent() {
        return getRequestHeader('X-ACTING-NAV-IDENT');
    }
}
