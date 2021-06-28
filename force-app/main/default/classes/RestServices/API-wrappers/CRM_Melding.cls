global class CRM_Melding extends CRM_HenvendelseApiUtils {
    global CRM_MessageFrom fra;
    global String fritekst;
    global String sendtDato;
    global String lestDato;
    global String temagruppe;

    global CRM_Melding(Message__c message) {
        this.fritekst = message.CRM_Message_Text__c;
        this.sendtDato = gmtFormatDateTime(message.CRM_Sent_date__c);
        this.lestDato = gmtFormatDateTime(message.CRM_Read_Datetime__c);

        this.fra = new CRM_MessageFrom();
        this.fra.identType = message.CRM_External_Message__c == true
            ? CRM_MessageFrom.IDENT_TYPES.AKTORID.name()
            : CRM_MessageFrom.IDENT_TYPES.NAVIDENT.name();
        this.fra.ident = null; //Use formula field?
    }

    global CRM_Melding(Conversation_Note__c convNote) {
        this.fritekst = convNote.CRM_Conversation_Note__c;
        this.lestDato = gmtFormatDateTime(convNote.CRM_Read_Date__c);
        this.sendtDato = gmtFormatDateTime(convNote.CRM_Date_Time_Registered__c);
        this.fra = new CRM_MessageFrom();
        //Conversation notes are always created by NAV employees
        this.fra.identType = CRM_MessageFrom.IDENT_TYPES.NAVIDENT.name();
        this.fra.ident = convNote.CRM_Created_By__c;
    }
}
