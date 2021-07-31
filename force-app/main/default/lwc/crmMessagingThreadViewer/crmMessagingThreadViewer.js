import { LightningElement, api, wire } from 'lwc';
import getmessages from '@salesforce/apex/CRM_MessageHelper.getMessagesFromThread';
import getJournalInfo from '@salesforce/apex/CRM_MessageHelper.getJournalEntries';

import getusertype from '@salesforce/apex/CRM_MessageHelper.getUserLisenceType';
import userId from '@salesforce/user/Id';
import { updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACTIVE_FIELD from '@salesforce/schema/Thread__c.CRM_isActive__c';
import THREAD_ID_FIELD from '@salesforce/schema/Thread__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class messagingThreadViewer extends LightningElement {
    usertype;
    otheruser;
    _mySendForSplitting;
    @api thread;
    threadheader;
    threadid;
    messages = [];
    //Constructor, called onload
    connectedCallback() {
        if (this.thread) {
            this.threadid = this.thread.Id;
        }
        //this.threadheader = this.thread.From__r.FirstName + ' ' + this.thread.From__r.LastName + ' - ' + this.thread.Recipient__r.FirstName + ' ' + this.thread.Recipient__r.LastName ;
    }
    @wire(getusertype, { otheruserId: '$otheruser' })
    wiretype(result) {
        this.usertype = result.data;
    }

    @wire(getJournalInfo, { threadId: '$threadid' })
    wiredJournalEntries;

    @wire(getRecord, { recordId: '$threadid', fields: [ACTIVE_FIELD] })
    wiredThread;

    @wire(getmessages, { threadId: '$threadid' }) //Calls apex and extracts messages related to this record
    wiremessages(result) {
        this._mySendForSplitting = result;
        if (result.error) {
            this.error = result.error;
        } else if (result.data) {
            this.messages = result.data;
            this.showspinner = false;
            this.setheader();
        }
    }
    //If empty, stop submitting.
    handlesubmit(event) {
        console.log('submit');
        event.preventDefault();
        const textInput = event.detail.fields;
        // If messagefield is empty, stop the submit
        textInput.CRM_Thread__c = this.thread.Id;
        textInput.CRM_From__c = userId;

        if (textInput.CRM_Message_Text__c == null || textInput.CRM_Message_Text__c == '') {
            const event1 = new ShowToastEvent({
                title: 'Message Body missing',
                message: 'Make sure that you fill in the message text',
                variant: 'error'
            });
            this.dispatchEvent(event1);
        } else {
            this.template.querySelector('lightning-record-edit-form').submit(textInput);
        }
    }

    //Enriching the toolbar event with reference to the thread id
    //A custom toolbaraction event can be passed from the component in the toolbar slot that the thread viewer enrich with the thread id
    handleToolbarAction(event) {
        let threadId = this.threadid;
        let eventDetails = event.detail;
        eventDetails.threadId = threadId;
        event.threadId = threadId;
    }

    closeThread() {
        const fields = {};
        fields[THREAD_ID_FIELD.fieldApiName] = this.threadid;
        fields[ACTIVE_FIELD.fieldApiName] = false;

        const threadInput = { fields };

        updateRecord(threadInput)
            .then(() => {})
            .catch((error) => {
                console.log(JSON.stringify(error, null, 2));
            });
    }

    handlesuccess(event) {
        console.log('Success start');
        this.recordId = event.detail;

        const inputFields = this.template.querySelectorAll('.msgText');
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }
        return refreshApex(this._mySendForSplitting);
    }

    get journalEntries() {
        if (this.wiredJournalEntries) {
            return this.wiredJournalEntries.data;
        }

        return null;
    }

    get closedThread() {
        return !getFieldValue(this.wiredThread.data, ACTIVE_FIELD);
    }

    setheader() {}
}
