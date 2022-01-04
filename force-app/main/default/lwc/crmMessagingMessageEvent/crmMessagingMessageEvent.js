import { LightningElement, api } from 'lwc';

export default class MessageEvent extends LightningElement {
    @api message;
    get createdDateString(){
        if(message.CreatedDate) return '';
        let createdDate = new Date(message.CreatedDate);
        let formatter = new Intl.DateTimeFormat('no',{day: 'numeric', month: 'long', year: 'numeric'});
        let date = formatter.format(createdDate);
        formatter = new Intl.DateTimeFormat('no',{hour: 'numeric', minute: 'numeric'});
        let timeParts = formatter.formatToParts(createdDate);
        let hour = timeParts.find( e => e.type === 'hour').value;
        let minute = timeParts.find( e => e.type === 'minute').value;
        return date + ', kl. ' + hour+ '.' + minute;
    }
}
