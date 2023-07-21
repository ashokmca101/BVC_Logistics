import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LWCDatatablePicklist from '@salesforce/resourceUrl/LWCDatatablePicklist';
import { getRecord } from "lightning/uiRecordApi";
 
export default class LookupColumn extends LightningElement {
    @api value;
    @api fieldName;
    @api object;
    @api context;
    @api name;
    @api fields;
    @api target;
    @track showLookup = false;
 
    //get the sobject record info with fields to show as url navigation text
    @wire(getRecord, { recordId: '$value', fields: '$fields' })
    record;
 
    getFieldName() {
        let fieldName = this.fields[0];
        fieldName = fieldName.substring(fieldName.lastIndexOf('.') + 1, fieldName.length);
        return fieldName;
    }
 
   //label of formatted url
    get lookupName() {
        console.log(this.record.data);
        return (this.value != undefined && this.value != '' && this.record.data != null) ?  this.record.data.fields[this.getFieldName()].value : '';
    }
 
    //value of formatted url
    get lookupValue() {
        return (this.value != undefined && this.value != '' && this.record.data != null && this.record.data.fields[this.getFieldName()].value) ? '/' + this.value : '';
    }
 
    renderedCallback() {
        Promise.all([
            loadStyle(this, LWCDatatablePicklist),
        ]).then(() => { });
 
        let container = this.template.querySelector('div.container');
        container?.focus();
 
        window.addEventListener('click', (evt) => {
           if(container == undefined){
               this.showLookup = false;
           }
        });
    }
 
    /*closeLookup(event) {
        if (!event.currentTarget.contains(event.relatedTarget)) {
            this.showLookup = false;
        }
    }*/
 
    handleChange(event) {
        //show the selected value on UI
       // console.log('event value--',event.detail);
        //console.log('field value--',event.detail.fieldname[0]);
        this.value = event.detail.value[0];
       // this.fieldName = event.detail.fieldName[0];
        if(this.value == undefined){
            this.record.data = null;
        }
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('lookupchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }
 
    handleClick(event) {
        //wait to close all other lookup edit 
        setTimeout(() => {
            this.showLookup = true;
        }, 100);
    }
}