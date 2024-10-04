import { LightningElement, wire } from 'lwc';
import searchBill from '@salesforce/apex/BillController.searchBill';

export default class BillList extends LightningElement {
    searchTerm = '';
    billsWithUrl = [];
    isLoading = true;
    error;

    @wire(searchBill, { searchTerm: '$searchTerm' })
    wiredBills({ error, data }) {
        this.isLoading = true;  // Start loading indicator
        if (data) {
            // Map bills with URLs
            this.billsWithUrl = data.map(bill => ({
                ...bill,
                billUrl: `/lightning/r/Bill__c/${bill.Id}/view`
            }));
            this.error = undefined;
            this.isLoading = false; // Stop loading when data is ready
        } else if (error) {
            this.error = error;
            this.billsWithUrl = [];  // Clear any previous data
            this.isLoading = false; // Stop loading when there's an error
        }
    }

    handleSearchEvent(event) {
        const searchTerm = event.target.value;
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {
            this.searchTerm = searchTerm;
        }, 300);
    }

    // Getter to check if there are results
    get hasResults() {
        return this.billsWithUrl.length > 0;
    }

    // Getter to show "No Results Found" message when no results and not loading
    get showNoResults() {
        return !this.isLoading && !this.hasResults;
    }
}
