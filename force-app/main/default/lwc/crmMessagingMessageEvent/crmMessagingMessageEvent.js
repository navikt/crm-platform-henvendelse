import { LightningElement, api } from 'lwc';

export default class MessageEvent extends LightningElement {
    @api message;
    get createdDateString(){
        if(!this.message.CreatedDate) return '';
        let createdDate = new Date(this.message.CreatedDate);
        let formatter = new Intl.DateTimeFormat('no',{day: 'numeric', month: 'long', year: 'numeric'});
        let date = formatter.format(createdDate);
        formatter = new Intl.DateTimeFormat('no',{hour: 'numeric', minute: 'numeric'});
        let timeParts = formatter.formatToParts(createdDate);
        let hour = timeParts.find( e => e.type === 'hour').value;
        let minute = timeParts.find( e => e.type === 'minute').value;
        return date + ', kl. ' + hour+ '.' + minute;
    }
    get isEndChatEvent(){
        /* 
        *   return value should be depended on Message__c object Event Type, 
        *   but for now (04.01.22) it is not available in data model
        *   So this method shouold be changed as soon as Event Type is available
        */
        if(this.message.CRM_Message_Text__c.startsWith('a')) return true;
        return false;
    }
    get isTransferEvent(){
        /* 
        *   return value should be depended on Message__c object Event Type, 
        *   but for now (04.01.22) it is not available in data model
        *   So this method shouold be changed as soon as Event Type is available
        */
       if(this.message.CRM_Message_Text__c.startsWith('S')) return true;
        return false;
    }
    get isOtherEvent(){
        if( this.isEndChatEvent && this.isTransferEvent) return false;
        return true;
    }
}
