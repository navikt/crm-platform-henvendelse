import { LightningElement, api } from 'lwc';

export default class MessageEvent extends LightningElement {
    @api message;
    get endOfChatMessage() {
        return 'avsluttet samtalen';
    }
    get transferMessage() {
        return this.message.CRM_Message_Text__c;
    }
    get isEndChatEvent() {
        /*
         *   return value should be depended on Message__c object Event Type,
         *   but for now (04.01.22) it is not available in data model
         *   So this method shouold be changed as soon as Event Type is available
         */
        if (this.message.CRM_Event_Type__c === 'END_OF_CHAT' || this.message.CRM_Message_Text__c.includes('avslutt'))
            return true;
        return false;
    }
    get isTransferEvent() {
        /*
         *   return value should be depended on Message__c object Event Type,
         *   but for now (04.01.22) it is not available in data model
         *   So this method shouold be changed as soon as Event Type is available
         */
        if (
            this.message.CRM_Event_Type__c === 'UNIT_TRANSFER' ||
            this.message.CRM_Event_Type__c === 'QUEUE_TRANSFER' ||
            this.message.CRM_Message_Text__c.includes('overført')
        )
            return true;
        return false;
    }
    get isOtherEvent() {
        if (this.isEndChatEvent || this.isTransferEvent) return false;
        return true;
    }

    get sender() {
        return this.message.CRM_External_Message__c === true ? 'NAV' : this.message.CRM_From_Label__c;
    }
}
