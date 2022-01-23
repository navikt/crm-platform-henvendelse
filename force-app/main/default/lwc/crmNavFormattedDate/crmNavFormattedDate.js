import { LightningElement, api } from 'lwc';

export default class navFormattedDate extends LightningElement {
    @api date;

    get formattedDate() {
        if (!this.date) return '';
        let createdDate = new Date(this.date);
        if (createdDate == 'Invalid Date' || isNaN(createdDate)) {
            console.log('navFormattedDate: Bad date format.');
            return '';
        }
        let formatter = new Intl.DateTimeFormat('no', { day: 'numeric', month: 'long', year: 'numeric' });
        let date = formatter.format(createdDate);
        formatter = new Intl.DateTimeFormat('no', { hour: 'numeric', minute: 'numeric' });
        let timeParts = formatter.formatToParts(createdDate);
        let hour = timeParts.find((e) => e.type === 'hour').value;
        let minute = timeParts.find((e) => e.type === 'minute').value;
        return date + ', kl. ' + hour + '.' + minute;
    }
}
