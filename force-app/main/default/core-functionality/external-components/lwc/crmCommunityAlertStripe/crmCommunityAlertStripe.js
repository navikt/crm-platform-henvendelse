import { LightningElement, api } from 'lwc';
import ALERTLOGOS from '@salesforce/resourceUrl/alertlogos';

const altTextMap = { info: 'Informasjon', suksess: 'Suksess', advarsel: 'Advarsel', feil: 'Feil' };

export default class Alertstripe extends LightningElement {
    @api type; //info, suksess, advarsel, feil,
    @api alerttext; //text to be displayed
    logopath;

    getalerttype() {
        if (this.type === 'info') {
            this.logopath = ALERTLOGOS + '/InformationFilled.svg';
            return 'navds-alert navds-alert--medium navds-alert--info ';
        } else if (this.type === 'suksess') {
            this.logopath = ALERTLOGOS + '/SuccessFilled.svg';
            return 'navds-alert navds-alert--medium navds-alert--success ';
        } else if (this.type === 'advarsel') {
            this.logopath = ALERTLOGOS + '/WarningFilled.svg';
            return 'navds-alert navds-alert--medium navds-alert--warning ';
        } else if (this.type === 'feil') {
            this.logopath = ALERTLOGOS + '/ErrorFilled.svg';
            return 'navds-alert navds-alert--medium navds-alert--error ';
        }
    }

    renderedCallback() {
        this.template.querySelector('[data-id="divblock"]').className = this.getalerttype();
    }

    get altText() {
        return altTextMap[this.type];
    }
}
