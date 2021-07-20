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
        Thread__c convertedThread = new Thread__c();
        if (String.isNotBlank(henv.kasseringsDato)) {
            convertedThread.CRM_Disposal_Datetime__c = Datetime.valueOfGmt(henv.kasseringsDato.replace('T', ' '));
        }
        if (henv.kontorsperre != null) {
            convertedThread.CRM_Office_Restriction__c = henv.kontorsperre;
        }
        if (String.isNotBlank(henv.gjeldendeTemagruppe)) {
            Id themeGroupId = getThemeGroup(henv.gjeldendeTemagruppe);

            if (themeGroupId == null)
                throw new HenvendelseConversionException('Invalid code for theme group: ' + henv.gjeldendeTemagruppe);
            convertedThread.CRM_Theme_Group__c = themeGroupId;
        }
        return convertedThread;
    }

    public static Conversation_Note__c convertToConvNote(CRM_Henvendelse henv) {
        Conversation_Note__c convNote = new Conversation_Note__c();

        if (String.isNotBlank(henv.kasseringsDato)) {
            convNote.CRM_Disposal_Datetime__c = Datetime.valueOfGmt(henv.kasseringsDato.replace('T', ' '));
        }
        if (henv.kontorsperre != null) {
            convNote.CRM_Office_Restriction__c = henv.kontorsperre;
        }
        if (String.isNotBlank(henv.gjeldendeTemagruppe)) {
            Id themeGroupId = getThemeGroup(henv.gjeldendeTemagruppe);

            if (themeGroupId == null)
                throw new HenvendelseConversionException('Invalid code for theme group: ' + henv.gjeldendeTemagruppe);
            convNote.CRM_Theme_Group__c = themeGroupId;
        }
        return convNote;
    }

    public static Id getThemeGroup(String code) {
        return [SELECT Id FROM Common_Code__c WHERE CRM_Code_Set__c = 'Temagrupper' AND CRM_Code__c = :code]?.Id;
    }

    /**
     * @description: Formats a datetime to a valid ISO string
     * @author Stian Ruud Schikora | 07-20-2021
     * @param timestamp
     * @return String
     **/
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

    public class HenvendelseConversionException extends exception {
    }
}
