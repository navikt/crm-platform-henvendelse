import { LightningElement, api, wire } from 'lwc';
import getmessages from '@salesforce/apex/CRM_MessageHelper.getMessagesFromThread';

import getusertype from '@salesforce/apex/CRM_MessageHelper.getUserLisenceType';
import userId from '@salesforce/user/Id';
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

    setheader() {}
}
