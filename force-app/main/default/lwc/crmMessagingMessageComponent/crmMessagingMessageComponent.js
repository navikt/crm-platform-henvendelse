import { LightningElement, api, wire } from 'lwc';
import getThreads from '@salesforce/apex/CRM_MessageHelper.getThreadsCollection';
import createThread from '@salesforce/apex/CRM_MessageHelper.createThread';
import { refreshApex } from '@salesforce/apex';

export default class CrmMessagingMessageComponent extends LightningElement {
    showmodal = false;
    showtaskmodal = false;
    shownewbutton = false;
    activeSectionMessage = '';
    threads = [];
    singlethread;
    _threadsforRefresh;
    @api recordId;
    @api singleThread;

    handleToggleSection(event) {
        this.activeSectionMessage = 'Open section name:  ' + event.detail.openSections;
    }

    @wire(getThreads, { recordId: '$recordId', singleThread: '$singleThread' }) //Calls apex and extracts messages related to this record
    wiredThreads(result) {
        this._threadsforRefresh = result;

        if (result.error) {
            this.error = result.error;
        } else if (result.data) {
            this.threads = result.data;

            if (this.threads.length == 0) {
                this.shownewbutton = true;
            }
            this.showspinner = false;
        }
    }
    handlenewpressed() {
        createThread({ recordId: this.recordId })
            .then((result) => {
                this.shownewbutton = false;
                return refreshApex(this._threadsforRefresh);
            })
            .catch((error) => {});
    }
}
