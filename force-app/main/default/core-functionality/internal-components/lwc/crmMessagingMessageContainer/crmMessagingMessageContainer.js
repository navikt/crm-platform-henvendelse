import { LightningElement, api } from 'lwc';
import Id from '@salesforce/user/Id';

export default class messagingMessageContainer extends LightningElement {
    showpopover = false;
    isreply = false;
    @api message;
    userid;

    connectedCallback() {
        console.log('Id er: ' + Id);
        console.log('Message er: ');
        console.log(JSON.parse(JSON.stringify(this.message)));
        this.userid = Id;
    }

    //Indicate if the message is inbound or outbound, i.e left or right hand of the screen. tea
    get isoutbound() {
        return !this.message.CRM_External_Message__c;
    }

    get isevent() {
        return this.message.CRM_Type__c === 'Event';
    }

    get externalEvent() {
        console.log('external btw');
        console.log(this.message.CRM_From_Contact__c);
        console.log(!this.message.CRM_From_Contact__c);
        console.log(!!this.message.CRM_From_Contact__c);
        return !!this.message.CRM_From_Contact__c;
    }

    // get test() {
    //     return this.message.CRM_From_First_Name__c;
    // }

    //if there is a reply, hide it
    get showReplyButton() {
        return typeof this.message.Previous_Message__c !== 'undefined';
    }

    showdata() {
        this.showpopover = true;
    }
    hidedata() {
        this.showpopover = false;
    }
    replythreadPressed() {
        const selectedEvent = new CustomEvent('answerpressed', { detail: this.message.Id });
        this.dispatchEvent(selectedEvent);
    }
}
