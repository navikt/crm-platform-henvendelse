import { LightningElement, api } from 'lwc';
import Id from '@salesforce/user/Id';

export default class CommunityMessageContainer extends LightningElement {
    @api message;
    isreply = false;
    isevent = false;

    isoutbound;
    userid;
    @api userContactId;
    licensetype;

    connectedCallback() {
        console.dir(this.message);

        this.userid = Id;
        //Indicate if the message is inbound or outbound, i.e left or right hand of the screen.
        if (this.userid == this.message.CRM_From_User__c || this.userContactId == this.message.CRM_From_Contact__c) {
            this.isoutbound = true;
        } else {
            this.isoutbound = false;
        }

        if (this.message.CRM_Type__c == 'Event') {
            this.isevent = true;
        }
    }
}
