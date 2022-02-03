import { LightningElement, wire, api, track } from 'lwc';
import getmessages from '@salesforce/apex/CRM_MessageHelper.getMessagesFromThread';
import markasread from '@salesforce/apex/CRM_MessageHelper.markAsRead';
import { refreshApex } from '@salesforce/apex';
import getContactId from '@salesforce/apex/CRM_MessageHelper.getUserContactId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import createmsg from '@salesforce/apex/CRM_MessageHelper.createMessage';
import getThreadId from '@salesforce/apex/CRM_MessageHelper.getThreadId';

import THREADNAME_FIELD from '@salesforce/schema/Thread__c.STO_ExternalName__c';
import THREADCLOSED_FIELD from '@salesforce/schema/Thread__c.CRM_Is_Closed__c';

const fields = [THREADNAME_FIELD, THREADCLOSED_FIELD]; //Extract the name of the thread record

export default class CommityThreadViewer extends LightningElement {
    _mySendForSplitting;
    messages = [];
    buttonisdisabled = false;
    @api recordId;
    @track msgVal;
    userContactId;
    @api alerttext;
    @api header;
    @api secondheader;
    @api alertopen;
    threadId;

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

    @wire(getThreadId, { recordId: '$recordId' })
    wirerelatedthread(result) {
        if (result.error) {
            console.log(result.error);
        }
        if (result.data) {
            this.threadId = result.data;
        }
    }

    @wire(getRecord, { recordId: '$threadId', fields })
    thread;

    get showopenwarning() {
        if (this.alertopen) {
            return true;
        }
        return false;
    }

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
    get isclosed() {
        return getFieldValue(this.thread.data, THREADCLOSED_FIELD);
    }
    /**
     * Blanks out all text fields, and enables the submit-button again.
     * @Author lars Petter Johnsen
     */
    handlesuccess() {
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

    /**
     * Creates a message through apex
     */
    createMessage() {
        this.buttonisdisabled = true;
        const i2 = this.template.querySelectorAll('lightning-textarea');
        var textVal;
        i2.forEach((field) => {
            this.textVal = field.value;
        });
        console.log(this.userContactId);
        console.log(this.recordId);
        createmsg({ threadId: this.recordId, messageText: this.textVal, fromContactId: this.userContactId }).then(
            (result) => {
                this.handlesuccess();
            }
        );
    }
}
