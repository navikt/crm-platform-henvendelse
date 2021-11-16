import { LightningElement, api } from 'lwc';

export default class CrmMessagingRedactMessage extends LightningElement {
    _message;
    messageId;
    messageText;
    redactedText;
    _isRedacting = false;

    @api get message() {
        return this._message;
    }

    get isEvent() {
        return this.message.CRM_Type__c === 'Event' ? true : false;
    }

    set isRedacting(value) {
        if (false === value) {
            this.revertRedacting();
        }
        this._isRedacting = value;
    }

    get isRedacting() {
        return this._isRedacting;
    }

    set message(value) {
        this._message = value;
        this.messageText = this.message.CRM_Message_Text__c;
        this.redactedText = this.message.CRM_Message_Text__c;
        this.messageId = this.message.Id;
    }

    revertRedacting() {
        this.redactTextComponent.reset();
    }

    undoRedacting() {
        this.redactTextComponent.undoChanges();
    }

    redoRedacting() {
        this.redactTextComponent.redoChanges();
    }

    handleSuccess(event) {
        const payload = event.detail;
        console.log(JSON.stringify(payload));
        this.isRedacting = false;
    }

    handleError(event) {
        const payload = event.detail;
        console.log(JSON.stringify(payload));
        this.isRedacting = false;
    }

    get liClasses() {
        const cssClass = this.message.CRM_External_Message__c
            ? 'slds-chat-listitem_inbound'
            : 'slds-chat-listitem_outbound';
        return `slds-chat-listitem ${cssClass}`;
    }

    get divClasses() {
        const cssClass = this.message.CRM_External_Message__c
            ? 'slds-chat-message__text_inbound'
            : 'slds-chat-message__text_outbound';
        return `slds-chat-message__text ${cssClass}`;
    }

    get redactTextComponent() {
        return this.template.querySelector('c-crm-redact-text');
    }

    get canRevertDisabled() {
        return this.canUndoDisabled && this.canRedoDisabled;
    }

    get canUndoDisabled() {
        return this.redactTextComponent ? !this.redactTextComponent.canUndo : true;
    }

    get canRedoDisabled() {
        return this.redactTextComponent ? !this.redactTextComponent.canRedo : true;
    }

    toggleRedacting() {
        this.isRedacting = !this.isRedacting;
    }

    handleRedactEvent(event) {
        event.preventDefault();
        this.redactedText = event.detail;
    }
}
