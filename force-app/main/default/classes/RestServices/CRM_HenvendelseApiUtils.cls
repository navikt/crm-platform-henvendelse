public without sharing virtual class CRM_HenvendelseApiUtils extends ApexRestService {
    public enum HENVENDELSE_TYPE {
        SAMTALEREFERAT,
        MELDINGSKJEDE,
        MELDING
    }

    /**
     * @description: Helper method to return the correct HENVENDELSE_TYPE
     * @author Stian Ruud Schikora | 07-08-2021
     * @param typeName
     * @return HENVENDELSE_TYPE
     **/
    public static HENVENDELSE_TYPE getHenvendelseType(String typeName) {
        HENVENDELSE_TYPE returnType;
        for (HENVENDELSE_TYPE henvType : HENVENDELSE_TYPE.values()) {
            if (henvType.name().equalsIgnoreCase(typeName)) {
                returnType = henvType;
            }
        }
        return returnType;
    }

    public static Thread__c convertToThread(CRM_Henvendelse henv) {
        return new Thread__c(
            CRM_Office_Restriction__c = henv.kontorsperre != null ? henv.kontorsperre : false,
            CRM_Disposal_Datetime__c = Datetime.valueOfGmt(henv.kasseringsDato.replace('T', ' '))
        );
    }
    public static Conversation_Note__c convertToConvNote(CRM_Henvendelse henv) {
        return new Conversation_Note__c(
            CRM_Office_Restriction__c = henv.kontorsperre != null ? henv.kontorsperre : false,
            CRM_Disposal_Datetime__c = Datetime.valueOfGmt(henv.kasseringsDato.replace('T', ' '))
        );
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
