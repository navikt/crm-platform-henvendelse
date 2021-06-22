import { LightningElement, api } from '../crmMessagingCommunityMessageContainer/node_modules/lwc';
import logos from '@salesforce/resourceUrl/stoLogos';

export default class MessagingCommunityMessageOutbound extends LightningElement {
    @api message;
    navlogo = logos + '/person.svg';
}
