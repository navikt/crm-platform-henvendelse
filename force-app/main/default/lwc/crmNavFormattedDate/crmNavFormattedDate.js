import { LightningElement, api } from 'lwc';
import { getDateTimeFormat } from '@salesforce/i18n-service';

export default class navFormattedDate extends LightningElement {
    @api date;

    get formattedDate() {
        if (!this.date) return '';
        let rawDate = new Date(this.date);
        if (rawDate == 'Invalid Date' || isNaN(rawDate)) {
            console.log('navFormattedDate: Bad date format.');
            return '';
        }
        let formatter = getDateTimeFormat('no', { day: 'numeric', month: 'long', year: 'numeric' });
        let date = formatter.format(rawDate);
        formatter = getDateTimeFormat('no', { hour: 'numeric', minute: 'numeric' });
        let timeParts = formatter.formatToParts(rawDate);
        let hour = timeParts.find((e) => e.type === 'hour').value;
        let minute = timeParts.find((e) => e.type === 'minute').value;
        return date + ', kl. ' + hour + '.' + minute;
    }
}
