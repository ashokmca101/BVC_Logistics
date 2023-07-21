import CreateBVCQuote from '@salesforce/apex/CreateQuoteController.CreateBVCQuote';
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
import BUSINESS_TYPE_FIELD from '@salesforce/schema/SBQQ__Quote__c.Business_Type__c';
import BRANCH_FIELD from '@salesforce/schema/SBQQ__Quote__c.BVC_Branch__c';
import PRIMARY_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Primary__c';
import STARTDATE_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__StartDate__c';
import ACCOUNT_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c';
import EXHIBITION_FIELD from '@salesforce/schema/SBQQ__Quote__c.Exhibition__c';
import OPPORTUNITY_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__c';
import OPPORTUNITY_ACCOUNTID_FIELD from '@salesforce/schema/Opportunity.AccountId';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';



export default class CreateQuoteLWC extends NavigationMixin(LightningElement) {
    @track quoteRecord = {};
    @api recordId;
    @api isLoaded = false;
    quoteObject = QUOTE_OBJECT;
    quoteBusinessType = BUSINESS_TYPE_FIELD;
    quoteBranch = BRANCH_FIELD;
    quotePrimary = PRIMARY_FIELD;
    quoteStartDate = STARTDATE_FIELD;
    quoteOpportunity = OPPORTUNITY_FIELD;
    quoteAccount = ACCOUNT_FIELD;
    quoteExhibition = EXHIBITION_FIELD;
    retrievedRecordId = false;

    renderedCallback() {
        if (!this.retrievedRecordId && this.recordId) {
            
            this.retrievedRecordId = true; // Escape case from recursion
            this.quoteRecord['SBQQ__Opportunity2__c'] = this.recordId;
            this.quoteRecord['SBQQ__Primary__c'] = true;
            console.log('Found recordId: ' + this.recordId);
           
            // Execute some function or backend controller call that needs the recordId
        }
    }
    
    @wire(getRecord, { recordId: '$recordId', fields:  [OPPORTUNITY_ACCOUNTID_FIELD] })oppty;
    
    get accountId() {
        this.quoteRecord['SBQQ__Account__c'] = getFieldValue(this.oppty.data, OPPORTUNITY_ACCOUNTID_FIELD);
        return getFieldValue(this.oppty.data, OPPORTUNITY_ACCOUNTID_FIELD);
    }
    /*

    
    */
    get date() {
        let rightNow = new Date();
        console.log('Date format   '+rightNow.toISOString());
        let dd = rightNow.getDate();

        let mm = rightNow.getMonth()+1; 
        let yyyy = rightNow.getFullYear();
        if(dd<10) 
        {
            dd='0'+dd;
        } 

        if(mm<10) 
        {
            mm='0'+mm;
        } 
        var d = new Date();
        let today = yyyy+'-'+mm+'-'+dd;
        console.log('dateVal'+today);
        //this.quoteRecord['SBQQ__StartDate__c'] = today;
        return today
    }
    
    @track quoteId;
   

    
    handleFieldChange(e) {
        console.log('Value '+e.target.value);
        console.log('Value '+e.currentTarget.fieldName);
        this.quoteRecord[e.currentTarget.fieldName] = e.target.value;
        console.log('Values '+ this.quoteRecord);
        
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    saveAction(){
        this.isLoaded = true;
        CreateBVCQuote({ quote: { ...this.quoteRecord, sobjectType: QUOTE_OBJECT.objectApiName } })
        .then(result=>{
            this.quoteId = result;
            this.isLoaded = false;
            window.console.log('quoteId##Messi ' + this.quoteId);       
            const toastEvent = new ShowToastEvent({
                title:'Success!',
                message:'Quote created successfully',
                variant:'success'
              });
              this.dispatchEvent(toastEvent);
    
              /*Start Navigation*/
              this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/SBQQ__sb?id='+this.quoteId
                }
             });
             /*End Navigation*/
    
        })
        .catch(error => {
            this.isLoaded = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }
    
}