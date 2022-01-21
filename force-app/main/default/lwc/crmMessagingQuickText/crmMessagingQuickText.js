import { LightningElement, track, api, wire } from 'lwc';
import searchRecords from '@salesforce/apex/CRM_HenvendelseQuicktextController.searchRecords';
import getQuicktexts from '@salesforce/apex/CRM_HenvendelseQuicktextController.getQuicktexts';
import BLANK_ERROR from '@salesforce/label/c.CRMHenveldelse_Blank';

const ESC_KEY_CODE = 27;
const ESC_KEY_STRING = 'Escape';
const TAB_KEY_CODE = 9;
const TAB_KEY_STRING = 'Tab';
const LIGHTNING_INPUT_FIELD = 'LIGHTNING-INPUT-FIELD';

export default class crmQuickText extends LightningElement {
    labels = { BLANK_ERROR };
    _conversationNote;
    loadingData = false;
    quicktexts;
    qmap;
    initialRender = true;

    @api comments;
    @api required = false;

    @track data = [];

    get textArea() {
        return this.template.querySelector('.conversationNoteTextArea');
    }

    renderedCallback() {
        if (this.initialRender === true) {
            let inputField = this.textArea;
            inputField.focus();
            inputField.blur();
            this.initialRender = false;
        }
    }

    /**
     * Functions for handling modal focus
     */

    disconnectedCallback() {
        document.removeEventListener('click', this.outsideClickListener);
    }

    @api
    isOpen() {
        return this.template.querySelector('[data-id="modal"]').className === 'modalShow';
    }

    toggleModal() {
        this.isOpen = !this.isOpen;
        if (this.isOpen) {
            this.focusFirstChild();
        }
    }

    @api
    get cssClass() {
        const baseClasses = ['slds-modal'];
        baseClasses.push([this.isOpen ? 'slds-visible slds-fade-in-open' : 'slds-hidden']);
        return baseClasses.join(' ');
    }

    @api
    get modalAriaHidden() {
        return !this.isOpen;
    }

    @api
    showModal() {
        this.template.querySelector('[data-id="modal"]').className = 'modalShow';
        this.template.querySelector('lightning-input').focus();
    }

    hideModal(event) {
        this.template.querySelector('[data-id="modal"]').className = 'modalHide';
        event.stopPropagation();
        this.toggleModal();
    }

    outsideClickListener = (e) => {
        e.stopPropagation();
        if (!this.isOpen) {
            return;
        }
        this.toggleModal();
    };

    innerKeyUpHandler(event) {
        if (event.keyCode === ESC_KEY_CODE || event.code === ESC_KEY_STRING) {
            this.hideModal();
        } else if (event.keyCode === TAB_KEY_CODE || event.code === TAB_KEY_STRING) {
            const el = this.template.activeElement;
            let focusableElement;
            if (el.classList.contains('lastLink') || el.classList.contains('firstlink')) {
                focusableElement = this._getCloseButton();
            }
            if (focusableElement) {
                focusableElement.focus();
            }
        }
    }

    _getCloseButton() {
        let closeButton = this.template.querySelector('lightning-button-icon[title="Lukk"]');
        if (!closeButton) {
            closeButton = this.template.querySelector('lightning-button-icon');
        }
        return closeButton;
    }

    _getSlotName(element) {
        let slotName = element.slot;
        while (!slotName && element.parentElement) {
            slotName = this._getSlotName(element.parentElement);
        }
        return slotName;
    }

    async focusFirstChild() {
        const children = [...this.querySelectorAll('*')];
        for (let child of children) {
            let hasBeenFocused = false;
            if (this._getSlotName(child) === 'body') {
                continue;
            }
            await this.setFocus(child).then((res) => {
                hasBeenFocused = res;
            });
            if (hasBeenFocused) {
                return;
            }
        }
        const closeButton = this._getCloseButton();
        if (closeButton) {
            closeButton.focus();
        }
    }

    setFocus(el) {
        return new Promise((resolve) => {
            if (el.disabled || (el.tagName === LIGHTNING_INPUT_FIELD && el.required)) {
                return resolve(false);
            }
            const promiseListener = () => resolve(true);
            try {
                el.addEventListener('focus', promiseListener);
                el.focus && el.focus();
                el.removeEventListener('focus', promiseListener);

                setTimeout(() => resolve(false), 0);
            } catch (ex) {
                return resolve(false);
            }
        });
    }

    innerClickHandler(event) {
        event.stopPropagation();
    }

    setFocusOnTextArea() {
        let inputField = this.textArea;
        inputField.focus();
    }

    /**
     * Functions for conversation note/quick text
     */
    @wire(getQuicktexts, {})
    wiredQuicktexts(value) {
        if (value.data) {
            this.quicktexts = value.data;
            this.qmap = new Map(value.data.map((key) => [key.nksAbbreviationKey__c.toUpperCase(), key.Message]));
        }
    }

    @api
    get conversationNote() {
        return this._conversationNote;
    }

    set conversationNote(value) {
        this._conversationNote = value;
    }

    @api
    get conversationNoteRich() {
        return this._conversationNote;
    }

    set conversationNoteRich(value) {
        this._conversationNote = value;
    }

    insertText(event) {
        const editor = this.textArea;
        editor.focus();
        editor.setRangeText(
            this.toPlainText(event.currentTarget.dataset.message),
            editor.selectionStart,
            editor.selectionEnd,
            'select'
        );

        this.hideModal(undefined);
        this._conversationNote = editor.value;
        const attributeChangeEvent = new CustomEvent('commentschange', {
            detail: this.conversationNote
        });
        this.dispatchEvent(attributeChangeEvent);
    }

    handleChange(event) {
        this._conversationNote = event.target.value;
        const attributeChangeEvent = new CustomEvent('commentschange', {
            detail: this.conversationNote
        });
        this.dispatchEvent(attributeChangeEvent);
    }

    handlePaste(evt) {
        const editor = this.textArea;
        editor.setRangeText(
            this.toPlainText((evt.clipboardData || window.clipboardData).getData('text')),
            editor.selectionStart,
            editor.selectionEnd,
            'end'
        );
        evt.preventDefault();
    }

    handleKeyUp(evt) {
        const queryTerm = evt.target.value;
        if (evt.key.length > 1 && evt.key !== 'Enter' && evt.key !== 'Backspace') {
            return;
        }

        if (evt.key === 'Enter' || (queryTerm.length > 2 && this.loadingData === false)) {
            evt.stopPropagation();
            this.loadingData = true;
            searchRecords({
                search: queryTerm
            })
                .then((result) => {
                    this.numberOfRows = result.length;
                    this.data = result;
                })
                .catch((error) => {
                    console.log(error);
                })
                .finally(() => {
                    this.loadingData = false;
                });
        }
    }

    insertquicktext(event) {
        if (event.keyCode === 32) {
            const editor = this.textArea;
            const carretPositionEnd = editor.selectionEnd;
            const lastItem = editor.value
                .substring(0, carretPositionEnd)
                .replace(/(\r\n|\n|\r)/g, ' ')
                .trim()
                .split(' ')
                .pop();
            const abbreviation = lastItem.toUpperCase();
            const quickText = this.qmap.get(abbreviation);

            if (this.qmap.has(abbreviation)) {
                const startindex = carretPositionEnd - lastItem.length - 1;

                if (lastItem.charAt(0) === lastItem.charAt(0).toLowerCase()) {
                    const lowerCaseQuickText = quickText.toLowerCase();
                    editor.setRangeText(lowerCaseQuickText + ' ', startindex, carretPositionEnd, 'end');
                } else {
                    const upperCaseQuickText = quickText.charAt(0).toUpperCase() + quickText.slice(1);
                    editor.setRangeText(upperCaseQuickText + ' ', startindex, carretPositionEnd, 'end');
                }
            }
        }
    }

    toPlainText(value) {
        let plainText = value ? value : '';
        plainText = plainText.replace(/<\/[^\s>]+>/g, '\n'); //Replaces all ending tags with newlines.
        plainText = plainText.replace(/<[^>]+>/g, ''); //Remove remaining html tags
        plainText = plainText.replace(/&nbsp;/g, ' '); //Removes &nbsp; from the html that can arise from copy-paste
        return plainText;
    }

    @api
    validate() {
        if (this.required === true) {
            return this.conversationNote && this.conversationNote.length > 0
                ? { isValid: true }
                : { isValid: false, errorMessage: this.labels.BLANK_ERROR }; //CUSTOM LABEL HERE
        }
        return { isValid: true };
    }

    @api
    clear() {
        this._conversationNote = '';
        this.textArea.value = this._conversationNote;
    }
}
