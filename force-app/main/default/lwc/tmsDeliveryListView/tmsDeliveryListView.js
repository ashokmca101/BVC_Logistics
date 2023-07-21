import { LightningElement,track } from 'lwc';
import viewAllDelivery from "@salesforce/apex/TMS_DeliveryListView.viewAllDelivery"; 
import updateDelivery from "@salesforce/apex/TMS_DeliveryListView.updateDelivery"; 
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'Lookup' },
    { label: 'Customer Name', fieldName: 'Customer_Name__c', type: 'text' },
    { label: 'Shipping Note Number', fieldName: 'Shipping_Note_Number__c', type: 'text' } 
];

export default class TmsDeliveryListView extends NavigationMixin(LightningElement) {

    @track deliveryRecord ;
    @track columns = columns; 
    @track selectedDelivery;
    @track isLoading = false;

    connectedCallback(){

        this.isLoading = true; 
        viewAllDelivery( ).then(result=>{
            this.deliveryRecord = result;
            this.isLoading = false;
        }).catch(erorr=>{
            if (erorr) { 
                if (Array.isArray(erorr.body)) {
                    this.erorrmessage = erorr.body.map(e => e.message).join(', ');
                } else if (typeof erorr.body.message === 'string') {
                    this.erorrmessage = erorr.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Alert",
                        message: "Alert : "+this.erorrmessage+".",
                        variant: "warning"
                    })
                ); 
            }  
            
        }).finally(()=>{
            this.isLoading = false;
        });  
    }

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedDelivery =selectedRows;
       console.log("Selected Record ",this.selectedDelivery);
    }


    fileDetails(event){ 
        this.isLoading = true;
        let tempRecord = [];         

        this.selectedDelivery.forEach((item, index) => {
            tempRecord.push(item);
        }); 

        console.log("==== tempRecord====",tempRecord);

        updateDelivery({ 
            deliveryList : tempRecord 
        }).then(recordData =>{
            console.log("Selected B Record ",tempRecord); 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Accepted.",
                    variant: "success"
                })
            );  
            eval("$A.get('e.force:refreshView').fire();"); 
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: { 
                    objectApiName: 'Delivery__c', 
                    actionName: 'list'
                },
                state: {
                    filterName: '00B5g00000WYOHcEAP'
                },
            });
        }).catch(erorr=>{
            console.log("Selectederorr ",erorr);
            if (erorr) { 
                if (Array.isArray(erorr.body)) {
                    this.erorrmessage = erorr.body.map(e => e.message).join(', ');
                } else if (typeof erorr.body.message === 'string') {
                    this.erorrmessage = erorr.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Alert",
                        message: "Alert : "+this.erorrmessage+".",
                        variant: "warning"
                    })
                ); 
            } 

        }).finally(()=>{
            this.isLoading = false;
            this.selectedDelivery = [];
        }); 

    }



}