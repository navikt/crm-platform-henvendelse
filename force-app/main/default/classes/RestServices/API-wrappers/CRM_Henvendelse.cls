global class CRM_Henvendelse extends CRM_HenvendelseApiUtils implements Comparable {
    global String fnr;
    global String aktorId;
    global String kasseringsDato;
    global String avsluttetDato;
    global Boolean aapen; //Defines if the chain is still open
    global String opprettetDato;
    global Boolean kontorsperre;
    global Boolean feilsendt;
    global String kjedeId;
    global String opprinneligGT;
    global String opprinneligEnhet;
    global String gjeldendeTemagruppe;
    global String gjeldendeTema;
    global String henvendelseType;
    global List<CRM_JournalfortInformasjon> journalposter;
    global List<CRM_Melding> meldinger;
    global List<CRM_Markering> markeringer;
    global String tilknyttetEnhet;
    global String henvendelseId; //Legacy ID for verification purposes, not included in swagger documentation

    global CRM_Henvendelse() {
    }

    /**
     * @description: Converting Conversation_Note__c and journal entries into wrappers
     * @author Stian Ruud Schikora | 07-23-2021
     * @param convNote
     * @param jeList
     **/
    global CRM_Henvendelse(Conversation_Note__c convNote, List<Journal_Entry__c> jeList) {
        this.fnr = convNote.CRM_Account__r.CRM_Person__r.Name;
        this.henvendelseId = convNote.CRM_HenvendelseId__c;
        this.aktorId = convNote.CRM_Account__r.CRM_Person__r.INT_ActorId__c;
        this.gjeldendeTemagruppe = convNote.CRM_Theme_Group_Code__c;
        this.gjeldendeTema = convNote.CRM_Theme_Code__c;
        this.opprinneligGT = convNote.CRM_Original_Person_GT__c;
        this.opprinneligEnhet = convNote.CRM_Original_Person_NAV_Unit__c;
        this.opprettetDato = gmtFormatDateTime(convNote.CRM_Registered_Datetime_Formula__c);
        this.avsluttetDato = this.opprettetDato;
        this.kjedeId = convNote.CRM_Henvendelse_BehandlingskjedeId__c;
        this.henvendelseType = HENVENDELSE_TYPE.SAMTALEREFERAT.name();

        this.meldinger = new List<CRM_Melding>();
        this.meldinger.add(new CRM_Melding(convNote));

        if (jeList != null && jeList.size() > 0) {
            List<CRM_JournalfortInformasjon> journalPosts = new List<CRM_JournalfortInformasjon>();
            for (Journal_Entry__c jEntry : jeList) {
                journalPosts.add(new CRM_JournalfortInformasjon(jEntry));
            }
            this.journalposter = journalPosts;
        }

        if (convNote.CRM_Office_Restriction__c == true) {
            CRM_Markering_Kontorsperre officeRest = new CRM_Markering_Kontorsperre();
            this.kontorsperre = true;
            officeRest.markertAv = convNote.CRM_Office_Restriction_Activated_By__c;
            officeRest.markertDato = gmtFormatDateTime(convNote.CRM_Office_Restriction_Date__c);
            officeRest.kontorsperreGT = String.isNotBlank(this.opprinneligGT) ? this.opprinneligGT : null;
            officeRest.kontorsperreEnhet = String.isNotBlank(this.opprinneligEnhet) ? this.opprinneligEnhet : null;
            this.markeringer = new List<CRM_Markering>();
            this.markeringer.add(officeRest);
        }
    }

    /**
     * @description: Converting a Thread__c and its list of messages and journal entries into wrappers
     * @author Stian Ruud Schikora | 07-23-2021
     * @param thread
     * @param messages
     * @param jeList
     **/
    global CRM_Henvendelse(Thread__c thread, List<Message__c> messages, List<Journal_Entry__c> jeList) {
        this.kjedeId = thread.Id;
        this.henvendelseId = thread.CRM_HenvendelseId__c;
        this.fnr = thread.CRM_External_Person_Ident__c;
        this.aktorId = thread.CRM_External_ActorId__c;
        this.opprinneligGT = thread.CRM_Original_Person_GT__c;
        this.opprinneligEnhet = thread.CRM_Original_Person_NAV_Unit__c;
        this.kasseringsDato = gmtFormatDateTime(thread.CRM_Disposal_Datetime__c);
        this.opprettetDato = gmtFormatDateTime(thread.CRM_Registered_Datetime_Formula__c);
        this.avsluttetDato = gmtFormatDateTime(thread.CRM_Closed_Date__c);
        this.meldinger = new List<CRM_Melding>();
        this.henvendelseType = HENVENDELSE_TYPE.MELDINGSKJEDE.name();
        this.gjeldendeTemagruppe = thread.CRM_Theme_Group_Code__c;
        this.gjeldendeTema = thread.CRM_Theme_Code__c;

        for (Message__c message : messages) {
            this.meldinger.add(new CRM_Melding(message));
        }

        if (jeList != null && jeList.size() > 0) {
            List<CRM_JournalfortInformasjon> journalPosts = new List<CRM_JournalfortInformasjon>();
            for (Journal_Entry__c jEntry : jeList) {
                journalPosts.add(new CRM_JournalfortInformasjon(jEntry));
            }
            this.journalposter = journalPosts;
        }

        if (thread.CRM_Office_Restriction__c == true) {
            CRM_Markering_Kontorsperre officeRest = new CRM_Markering_Kontorsperre();
            this.kontorsperre = true;
            officeRest.markertAv = thread.CRM_Office_Restriction_Activated_By__c;
            officeRest.markertDato = gmtFormatDateTime(thread.CRM_Office_Restriction_Date__c);
            officeRest.kontorsperreGT = String.isNotBlank(this.opprinneligGT) ? this.opprinneligGT : null;
            officeRest.kontorsperreEnhet = String.isNotBlank(this.opprinneligEnhet) ? this.opprinneligEnhet : null;
            this.markeringer = new List<CRM_Markering>();
            this.markeringer.add(officeRest);
        }
    }

    /**
     * @description: Sort functionality which sorts entries by opprettetDato, newest first
     * @author Stian Ruud Schikora | 07-23-2021
     * @param compareTo
     * @return Integer
     **/
    global Integer compareTo(Object compareTo) {
        CRM_Henvendelse compHenv = (CRM_Henvendelse) compareTo;

        Integer retVal = 0;

        if (
            Datetime.valueOf(this.opprettetDato.replace('T', ' ')) >
            Datetime.valueOf(compHenv.opprettetDato.replace('T', ' '))
        ) {
            retVal = -1;
        } else if (
            Datetime.valueOf(this.opprettetDato.replace('T', ' ')) >
            Datetime.valueOf(compHenv.opprettetDato.replace('T', ' '))
        ) {
            retVal = 1;
        }

        return retVal;
    }
}
