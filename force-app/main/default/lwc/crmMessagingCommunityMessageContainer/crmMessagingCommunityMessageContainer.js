import { LightningElement, api, track } from 'lwc';
import Id from '@salesforce/user/Id';

export default class CommunityMessageContainer extends LightningElement {
    @api message;
    isreply = false;
    isevent = false;

    @track isoutbound;
    @track userid;
    licensetype;

    connectedCallback() {
        console.dir(this.message);
        this.userid = Id;
        //Indicate if the message is inbound or outbound, i.e left or right hand of the screen. tea
        if (this.userid == this.message.CRM_From__c) {
            this.isoutbound = true;
        } else {
            this.isoutbound = false;
        }

        if (this.message.Type__c == 'Event') {
            this.isevent = true;
        }
    }
}
