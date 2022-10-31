import { LightningElement, api, wire } from 'lwc';
import getThreads from '@salesforce/apex/CRM_MessageHelper.getThreadsCollection';
import createThread from '@salesforce/apex/CRM_MessageHelper.createThread';
import { refreshApex } from '@salesforce/apex';

export default class CrmMessagingMessageComponent extends LightningElement {
    showmodal = false;
    showtaskmodal = false;
    activeSectionMessage = '';
    threads;
    singlethread;
    _threadsforRefresh;
    @api recordId;
    @api singleThread;
    @api showClose;
    setCardTitle;
    hasError = false;
    @api englishTextTemplate;
    @api checkMedskriv;

    @api hasChecked = false;

    @api textTemplate; //Support for conditional text template

    @wire(getThreads, { recordId: '$recordId', singleThread: '$singleThread' }) //Calls apex and extracts messages related to this record
    wiredThreads(result) {
        this._threadsforRefresh = result;

        if (result.error) {
            this.error = result.error;
            this.hasError = true;
            console.log(JSON.stringify(result.error, null, 2));
        } else if (result.data) {
            this.threads = result.data;
        }
    }
    handlenewpressed() {
        createThread({ recordId: this.recordId })
            .then((result) => {
                return refreshApex(this._threadsforRefresh);
            })
            .catch((error) => {});
    }

    get showSpinner() {
        return !this.threads && !this.hasError;
    }

    get shownewbutton() {
        return this.threads && this.threads.length == 0 && this.recordId;
    }

    get cardTitle() {
        return this.setCardTitle ?? (this.singleThread === true ? 'Samtale' : 'Samtaler');
    }

    @api
    set cardTitle(cardTitle) {
        this.setCardTitle = cardTitle;
    }

    handleEnglishEvent(event) {
        const englishEvent = new CustomEvent('englisheventtwo', {
            detail: event.detail
        });
        this.dispatchEvent(englishEvent);
    }

    renderedCallback() {
        console.log('Rendering');
        const slot = this.template.querySelector('.slotContent');
        console.log(slot);
        if (!slot) return;
        console.log('Running extra');
        const hasContent = slot.assignedElements().length !== 0;
        console.log('hasContent');
        console.log(hasContent);
        this.hasContent = hasContent;
    }

    hasContent = true;

    @api
    checkSlotChange() {
        this.hasContent = true;
    }
}
