import { LightningElement, wire, api, track } from 'lwc';
import getmessages from '@salesforce/apex/CRM_MessageHelper.getMessagesFromThread';
import markasread from '@salesforce/apex/CRM_MessageHelper.markAsRead';
import { refreshApex } from '@salesforce/apex';
import getContactId from '@salesforce/apex/CRM_MessageHelper.getUserContactId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import THREADNAME_FIELD from '@salesforce/schema/Thread__c.Name';

const fields = [THREADNAME_FIELD]; //Extract the name of the thread record

export default class CommityThreadViewer extends LightningElement {
    _mySendForSplitting;
    messages = [];
    buttonisdisabled = false;
    @api recordId;
    @track msgVal;
    userContactId;

    connectedCallback() {
        markasread({ threadId: this.recordId });
        getContactId({})
            .then((contactId) => {
                this.userContactId = contactId;
            })
            .catch((error) => {
                //Apex error
            });
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    thread;
    get name() {
        return getFieldValue(this.thread.data, THREADNAME_FIELD);
    }

    @wire(getmessages, { threadId: '$recordId' }) //Calls apex and extracts messages related to this record
    wiremessages(result) {
        this._mySendForSplitting = result;
        if (result.error) {
            this.error = result.error;
        } else if (result.data) {
            this.messages = result.data;
            this.showspinner = false;
        }
    }

    handlesubmit(event) {
        event.preventDefault();
        this.buttonisdisabled = true;
        const textInput = event.detail.fields;
        // If messagefield is empty, stop the submit
        textInput.CRM_Thread__c = this.recordId;

        textInput.CRM_From_Contact__c = this.userContactId;
        textInput.CRM_Message_Text__c = this.msgVal;

        if (textInput.CRM_Message_Text__c == null || textInput.CRM_Message_Text__c == '') {
            //TODO - Replace with custom labels, to ensure errormessages in correct language
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

    handlesuccess(event) {
        const inputFields = this.template.querySelectorAll('.msgText');
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }
        const i2 = this.template.querySelectorAll('lightning-textarea');
        if (i2) {
            i2.forEach((field) => {
                field.value = '';
            });
        }
        this.buttonisdisabled = false;
        return refreshApex(this._mySendForSplitting);
    }
    //catches changes in the text
    synchtext(event) {
        this.msgVal = event.target.value;
    }
}
