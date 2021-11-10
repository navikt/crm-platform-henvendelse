import { LightningElement, api } from 'lwc';

export default class CrmRedactText extends LightningElement {
    _originalValue = '';
    _redactedValue = '';
    _textAreaclass = 'slds-textarea slds-text-color_default';

    @api get textToRedact() {
        return this._originalValue;
    }

    set textToRedact(value) {
        if (value) {
            this._originalValue = value;
            this.redactedValue = value;
        } else {
            throw new Error('Need original value!');
        }
    }

    set textAreaclass(value) {
        this._textAreaclass = value;
    }

    @api get textAreaclass() {
        return this._textAreaclass;
    }

    get redactedValue() {
        return this._redactedValue;
    }

    set redactedValue(value) {
        this._redactedValue = value;
        this.dispatchRedactedEvent();
    }

    @api cancel() {
        this.redactedValue = this._originalValue;
    }

    onSelectText(event) {
        event.preventDefault();
        const len = this.redactedValue.length;
        const start = event.target.selectionStart;
        const end = event.target.selectionEnd;
        const selection = event.target.value.substring(start, end);

        const redacted = selection.replace(/\S/g, '*');

        this.redactedValue = this.redactedValue.substring(0, start) + redacted + this.redactedValue.substring(end, len);
    }

    dispatchRedactedEvent() {
        this.dispatchEvent(new CustomEvent('text_redacted', { detail: this.redactedValue }));
    }
}
