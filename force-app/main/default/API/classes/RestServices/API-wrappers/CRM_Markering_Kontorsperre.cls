global class CRM_Markering_Kontorsperre extends CRM_Markering {
    global String kontorsperreEnhet;
    global String kontorsperreGT;

    global CRM_Markering_Kontorsperre() {
        this.markeringstype = MARKING_TYPES.KONTORSPERRE.name();
    }
}
