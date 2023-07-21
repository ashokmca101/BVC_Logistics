import { LightningElement, api,track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveShips from '@salesforce/apex/ShipmentBulkVerificationHndlr.retrieveShips';
import VerifyForShips from '@salesforce/apex/ShipmentBulkVerificationHndlr.VerifyForShips';
const columns = [
    { label: 'Name', fieldName: 'Shipment__r.Name' },
    { label: 'Customer', fieldName: 'SBQQ__Account__r.Name' },
    { label: 'Net Amount', fieldName: 'SBQQ__NetAmount__c' ,cellAttributes: { alignment: 'center' }},
    { label: 'Billing Frequency', fieldName: 'SBQQ__Account__r.Billing_Frequency__c' },
    { label: 'Invoice Batch', fieldName: 'SBQQ__Account__r.Invoice_Batch__c',cellAttributes: { alignment: 'center' } },
    { label: 'Created Date', fieldName: 'Shipment__r.CreatedDate' , type: 'date', typeAttributes: {day: 'numeric',month: 'short',year: 'numeric',hour: '2-digit',minute: '2-digit',second: '2-digit',hour12: true}  },   
];
 
export default class ShipmentOrderBulkVerification extends LightningElement {
    @track data;
    @track columns = columns;
    @track error;
    @api shipmentFrom;
    @api shipmentTo;
    @api bvcservice;
    @api customerName;
    haveData= false;
    showLoadingSpinner =false;
    get options() {
        return [
            { label: 'BATH', value: 'BATH' },
            { label: 'eSHIP', value: 'eSHIP' },
        ];
    }
    Picklist_Value;
    
 
    getSelectedRec() {
        this.shipmentFrom = this.template.querySelector("[data-field='shipmentFrom']").value;
        this.shipmentTo = this.template.querySelector("[data-field='shipmentTo']").value;
        this.bvcservice = this.template.querySelector("[data-field='bvcservice']").value;
        this.customerName = this.template.querySelector("[data-field='customerName']").value;
          console.log('selectedRecords are ', this.shipmentFrom);
          console.log('selectedRecords are ', this.shipmentTo);
          console.log('selectedRecords are ', this.bvcservice);
          console.log('selectedRecords are ', this.customerName);
        retrieveShips({shipmentFrom :this.shipmentFrom,shipmentTo :this.shipmentTo, bvcservice :this.bvcservice ,customerName :this.customerName })
            .then((result) => {
                this.haveData=true;
                this.data =  result.map(
                    record => Object.assign(
                    { "Shipment__r.Name": (record.Shipment__r != null && record.Shipment__r != '') ? record.Shipment__r.Name: '' },
                    { "Shipment__r.CreatedDate": (record.Shipment__r != null && record.Shipment__r != '') ? record.Shipment__r.CreatedDate: '' },
                    { "SBQQ__Account__r.Name": (record.SBQQ__Account__r != null && record.SBQQ__Account__r != '') ? record.SBQQ__Account__r.Name: '' },
                    { "SBQQ__Account__r.Billing_Frequency__c": (record.SBQQ__Account__r != null && record.SBQQ__Account__r != '') ? record.SBQQ__Account__r.Billing_Frequency__c: '' },
                    { "SBQQ__Account__r.Invoice_Batch__c": (record.SBQQ__Account__r != null && record.SBQQ__Account__r != '') ? record.SBQQ__Account__r.Invoice_Batch__c: '' },
                    record
            )
            );
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }
    verifiedForBilling(){
        //showLoadingSpinner=true;
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
          this.haveData=false;
          let ids = '';
          selectedRecords.forEach(currentItem => {
              ids = ids + ',' + currentItem.Shipment__c;
          });
          this.selectedIds = ids.replace(/^,/, '');
          this.lstSelectedRecords = selectedRecords;
          //alert(this.selectedIds);
          VerifyForShips({ShipsIds :ids})
            .then((result) => {
                //this.data =  result;
                const event = new ShowToastEvent({
                title: 'success',
                variant: 'success',
                message:
                    'Your Verification is on Process, check your Mail',
                });
                this.dispatchEvent(event);
            })
            .catch((error) => {
                this.error = error;
                const event = new ShowToastEvent({
                title: 'Error',
                message:error,
                });
                this.dispatchEvent(event);
            });
        
      }   
    }
    shipmentFromMT(event){
        //console.log('selectedRecords are ', this.shipmentFrom);
        this.shipmentFrom = event.target.value;
        
    }
    shipmentToMT(event){     
       
        this.shipmentTo = event.target.value;
        
    }
    bvcserviceMT(event){       
        
        this.bvcservice = event.target.value;
        
    }
     customerNameMT(event){       
        
        this.customerName = event.target.value;
        
    }
}