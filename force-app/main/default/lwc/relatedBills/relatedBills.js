import { LightningElement, wire, api } from 'lwc';
import billsToAccount from '@salesforce/apex/BillController.billsToAccount';

export default class RelatedBills extends LightningElement {
    @api recordId; // This will automatically capture the Account record Id

    // Wire the Apex method, passing the accountId dynamically
    @wire(billsToAccount, { accountId: '$recordId' }) 
    relatedBills; // This will now be populated with related bills for the account

    get hasBills() {
        // Check if relatedBills is not undefined and has data
        return this.relatedBills && this.relatedBills.data && this.relatedBills.data.length > 0;
    }
}
