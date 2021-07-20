global class CRM_Markering {
    global enum MARKING_TYPES {
        FEILSENDT,
        KONTORSPERRE
    }

    global String markeringstype;
    global String markertAv; //NAV Ident of the user activating the marking
    global String markertDato;
}
