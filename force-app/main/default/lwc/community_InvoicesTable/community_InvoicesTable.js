import { LightningElement, track, wire, api } from 'lwc';
import getInvoices from "@salesforce/apex/Community_InvoicesTableController.getInvoices";

export default class Community_InvoicesTable extends LightningElement {

    @track columns = [
        { label: 'Invoice Number', fieldName: 'invoiceName' },
        { label: 'Date', fieldName: 'invoiceDate', type: 'Date' },
        { type: 'url',fieldName: 'docLink',typeAttributes: { label: 'Download Invoice',target: '_blank'} }
    ];
    starDate;
    endDate;
    @track data;
    @track error;
    dataFound = true;

    startDateChange(event){
        this.starDate = event.target.value;
        console.log('Start Date: ' + this.starDate);
    }
    endDateChange(event){
        this.endDate = event.target.value;
        console.log('End Date: ' + this.endDate);
    }

    searchInvoices() {
        getInvoices({startDate: this.starDate, endDate: this.endDate})
            .then(result => {
                this.data = result;
            })
            .catch(error=> {
                this.error = error;
            })
    }

    callRowAction( event ) {  
        
        const actionName = event.detail.action.name; 
        const row =  event.detail.row;  
         
        if ( actionName === 'DownloadInvoice' ) {  
            console.log('Doc: '+ row.docLink);
            window.open(row.docLink,'_blank');
    
        }
    }
}