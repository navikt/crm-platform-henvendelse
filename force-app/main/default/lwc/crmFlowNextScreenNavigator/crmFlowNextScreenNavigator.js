import { LightningElement } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class CrmFlowNextScreenNavigator extends LightningElement {
    connectedCallback() {
        this.fireFlowNext();
    }

    fireFlowNext() {
        // navigate to the next screen
        const nextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextEvent);
    }
}
