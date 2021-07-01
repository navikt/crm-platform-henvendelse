global class CRM_Markering {
    global enum MARKING_TYPES {
        FEILSENDT,
        KONTORSPERRE
    }

    global String markeringsType;
    global String markertAv; //NAV Ident of the user activating the marking
    global String dato;
}
