import { LightningElement, api, wire } from '../crmMessagingCommunityMessageContainer/node_modules/lwc';
import logos from '@salesforce/resourceUrl/stoLogos';
import getlicenses from '@salesforce/apex/CRM_MessageHelper.getUserLisenceType';

export default class CommunityMessageInbound extends LightningElement {
    @api message;
    fromId;

    showNavlogo;
    navlogo = logos + '/navLogoRed.svg';
    connectedCallback() {
        console.log('Correct comp Loaded');

        console.log(this.message.CRM_From_Label__c);
        console.log(this.message.CRM_Message_Text__c);
        this.fromId = this.message.From__c;
    }

    @wire(getlicenses, { userId: '$fromId' })
    wirelicence(result) {
        if (result.data == 'Standard') {
            this.showNavlogo = true;
        }
    }
}
