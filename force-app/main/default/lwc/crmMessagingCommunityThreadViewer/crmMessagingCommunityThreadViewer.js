import { LightningElement, wire, api, track } from 'lwc';
import getmessages from '@salesforce/apex/CRM_MessageHelper.getMessagesFromThread';
import markasread from '@salesforce/apex/CRM_MessageHelper.markAsRead';
import { refreshApex } from '@salesforce/apex';
import getContactId from '@salesforce/apex/CRM_MessageHelper.getUserContactId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import createmsg from '@salesforce/apex/CRM_MessageHelper.createMessage';

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
    thread;
    @api alerttext;
    @api header;
    @api secondheader;
    @api alertopen;
    @api maxLength;
    showTextboxEmptyWarning = false;
    showTextboxFullWarning = false;

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
    wirethread(result) {
        this.thread = result;
    }
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
        const textBoks = this.template.querySelector('c-community-textarea');
        textBoks.clearText();
        this.buttonisdisabled = false;
        return refreshApex(this._mySendForSplitting);
    }

    /**
     * Creates a message through apex
     */
    createMessage() {
        if (!this.valid()) {
            return;
        }
        this.buttonisdisabled = true;
        createmsg({ threadId: this.recordId, messageText: this.msgVal, fromContactId: this.userContactId })
            .then((result) => {
                this.handlesuccess();
            })
            .catch((error) => console.log(error));
    }

    valid() {
        this.showTextboxEmptyWarning = false;
        this.showTextboxFullWarning = false;
        if (!this.msgVal || this.msgVal.length == null) {
            this.showTextboxEmptyWarning = true;
        } else if (this.maxLength !== 0 && this.msgVal.length >= this.maxLength) {
            this.showTextboxFullWarning = true;
        } else {
            return true;
        }
        let errorSummary = this.template.querySelector('.errorSummary');
        errorSummary.focusHeader();
        return false;
    }

    handleTextChange(event) {
        this.msgVal = event.detail;
    }

    get errors() {
        let errorList = [];
        if (this.showTextboxEmptyWarning) {
            errorList.push({ Id: 1, EventItem: '.inputTextbox', Text: 'Tekstboksen kan ikke være tom.' });
        }
        if (this.showTextboxFullWarning) {
            errorList.push({
                Id: 2,
                EventItem: '.inputTextbox',
                Text: 'Det er for mange tegn i tekstboksen.'
            });
        }
        return errorList;
    }

    get showWarnings() {
        return this.showTextboxEmptyWarning || this.showTextboxFullWarning;
    }

    handleErrorClick(event) {
        let item = this.template.querySelector(event.detail);
        item.focus();
    }
}
