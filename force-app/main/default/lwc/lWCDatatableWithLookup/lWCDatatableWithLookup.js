import { LightningElement, track, wire } from 'lwc';
import fetchContact from '@salesforce/apex/AccountDataController.fetchShipments';
import searchData from '@salesforce/apex/AccountDataController.searchShipments';
import updateShipmentData from '@salesforce/apex/AccountDataController.updateShipments';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const actions = [
    { label: 'Delete', name: 'delete' },
];

const columns = [{
        label: 'Shipment Date',
        fieldName: 'Shipment_Date__c',
        type: 'date-local',
        editable: true,
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'
        }
    },
    { label: 'Shipping Note Number', fieldName: 'Shipping_Note_Number__c', editable: true },
    { label: 'Name', fieldName: 'Name', editable: false },
    {
        label: 'Consinee Account',
        fieldName: 'Consignee_Name_TMS__c',
        type: 'lookupColumn',
        typeAttributes: {
            object: 'Shipment__c',
            fieldName: 'Consignee_Name_TMS__c',
            value: { fieldName: 'Consignee_Name_TMS__c' },
            context: { fieldName: 'Id' },
            name: 'Account',
            fields: ['Account.Name'],
            target: '_self'
        },
        editable: false,
    },
    { label: 'Destination Address Line 1', fieldName: 'Destination_Address_Line1__c', editable: false },
    { label: 'Destination Address City', fieldName: 'Destination_Address_City__c', editable: false },
    {
        label: 'Delivery Route Assigned To',
        fieldName: 'Delivery_Route_Assigned_To__c',
        type: 'lookupColumn',
        typeAttributes: {
            object: 'Shipment__c',
            fieldName: 'Delivery_Route_Assigned_To__c',
            value: { fieldName: 'Delivery_Route_Assigned_To__c' },
            context: { fieldName: 'Id' },
            name: 'User',
            fields: ['User.Name'],
            target: '_self'
        },
        editable: false,
    },
    { label: 'Number of Packages', fieldName: 'Number_of_Packages__c', editable: false },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },

]

export default class LWCDatatableWithLookup extends LightningElement {
    columns = columns;
    showSpinner = false;
    @track data = [];
    @track contactData;
    @track draftValues = [];
    lastSavedData = [];
    @track clickSearch = false;
    @track queryTerm;
    @track searchdata;
    @track tempArray = [];
    @track listItem;
    @track isLoading = true;
    newone = false;
    oldone = true;
    isDisabled = true;
    selectedAccount;
    pageSizeOptions = [10, 25, 50, 75, 100]; //Page size options
    records = []; //All records available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = [];

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    //here I pass picklist option so that this wire method call after above method
    @wire(fetchContact, {})
    wireData(result) {
        this.contactData = result;
        if (result.data) {
            this.records = JSON.parse(JSON.stringify(result.data));
            this.totalRecords = this.records.length; // update total records count                 
            this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
            this.paginationHelper(); // call helper menthod to update pagination logic 
                
            this.isLoading = false;
            this.records.forEach(ele => {
                ele.accountLink = ele.Delivery_Route_Number__c != undefined ? '/' + ele.Delivery_Route_Number__c : '';
                ele.accountName = ele.Delivery_Route_Number__c != undefined ? ele.Delivery_Route_Number__r.Name : '';
            })

            this.lastSavedData = JSON.parse(JSON.stringify(this.records));

        } else if (result.error) {
            console.log(result.error);
            this.records = undefined;
            this.isLoading = false;
        }
    };
    
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        var row = event.detail.row;
        console.log('actionName====---',actionName);
        console.log('row====---',JSON.stringify(row));
        var arr = this.data;
        console.log('arr====---',JSON.parse(JSON.stringify(arr)));
       for( var i = 0; i < arr.length; i++){ 
        if ( arr[i].Id === row.Id) { 
            console.log('arr[i]====---',JSON.stringify(arr[i]));
            arr.splice(i, 1);
            this.totalRecords = this.totalRecords-1; 
        }        
      }    
      this.records = arr;
      this.tempArray = arr;
      console.log('this.data====---',JSON.parse(JSON.stringify(this.records)));
      this.paginationHelper();
      
    }
    handleSelection(event){
        this.selectedAccount = event.target.value;
        if(this.selectedAccount){
            this.isDisabled = false;
        }else{
            this.isDisabled = true;
        }
       // alert("The selected Accout id is"+this.selectedAccount);
    }
    handleBulkUpdate(){
        console.log('data====---',this.data);
        updateShipmentData({ shipdata: this.data, searcchKey: this.selectedAccount})
        .then(result => {
            console.log('data====---',result);
           // this.data = result;
              this.data = '';
              this.draftValues='';
              this.tempArray='';
              this.selectedAccount='';
              this.newone = true;
              this.oldone = false;
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.refresh();
        })
        .catch(error => {
            console.log('@@@@@@@@@@@@',error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        });
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
     // JS function to handel pagination logic 
     paginationHelper() {
        this.data = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.data.push(this.records[i]);
            console.log('11<==>data :'+this.data[i]);
        }
    }


    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));

        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        console.log('draft value---',copyDraftValues);
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
            console.log('draftValueChanged---',this.draftValues);
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
            console.log('draftValueNotChanged---',this.draftValues);
        }
        
    }

    //listener handler to get the context and data
    //updates datatable, here I used AccountId you can use your look field API name
    lookupChanged(event) {
        console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('Changed dataRecieved---',JSON.stringify(dataRecieved));
        let accountIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, Delivery_Route_Assigned_To__c: accountIdVal };
        console.log(updatedItem);
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
        console.log('<=>1.saveDraftValues :', this.saveDraftValues);
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            console.log('<=>1.draft :', draft);
            const fields = Object.assign({}, draft);
            return { fields };
        });
        console.log('<=>1.recordInputs :', recordInputs);
        //added line 05-01-2023
 /*       saveData ({ ShipList: this.data })
        .then(responce => {}).catch(error => {
                    console.log('error---', error);
                    this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');                    
                }); */
        // upto here
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            console.log('@@@@@@@@@@@@res@@',res);
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log('@@@@@@@@@@@@',error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        }); 
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.data);
    }

    handleClick() {
        this.clickSearch = true;
        this.data = '';
        this.pageSize = this.pageSizeOptions[3];
        
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        var res;
        if (isEnterKey) {
            var temp=0;
            console.log('tempdata---', this.tempArray);
            this.queryTerm = evt.target.value;
            evt.target.value = '';
            searchData({ searcchKey: this.queryTerm })
                .then(responce => {
                    console.log('current responce---)))))', responce);
                    console.log('current responce---@@@@', responce[0]);
                    res = responce[0];
                    console.log('current responce---@#@#@', res);
                    this.queryTerm ='';
                   // evt.target.value='';
                    if(res== null || res=='undefined')
                    {
                        console.log('error---1234'); 
                        const event = new ShowToastEvent({
                            title: 'Search Status',
                            message: 'Shipment Data Not Found',//error.body.message,
                            variant: 'error'
                        });
                        this.dispatchEvent(event);
                       // evt.target.value='';
                    }
                    else{
                       // this.tempArray = [...this.tempArray, responce[0]];
                        this.records = JSON.parse(JSON.stringify(this.tempArray));
                        if(this.records.length >= 1)
                        {
                            for(let count=0;count<this.records.length;count++)
                            {
                                if(responce[0].Shipping_Note_Number__c == this.records[count].Shipping_Note_Number__c)
                                {
                                    temp=1;
                                    console.log('error---1234'); 
                                    const event = new ShowToastEvent({
                                        title: 'Search Status',
                                        message: 'Duplicate Shipment,It is Already in the List',//error.body.message,
                                        variant: 'error'
                                    });
                                    this.dispatchEvent(event);                                    
                                  console.log('*** Count :'+count+' Value :'+this.records[count].Name+'Already in the LIST');

                                }
                                else
                                {
                                    
                                }
                                
                            }                            
                        }

                        if(temp==0)                        
                        {
                           // evt.target.value=''; 
                            console.log('<==>11.current responce---@@@@', responce[0].Shipping_Note_Number__c);
                            console.log('<==>11.this.queryTerm :'+this.queryTerm);
                            this.tempArray = [...this.tempArray, responce[0]];
                            console.log('current searchdata--->>>>>>>>>>', this.tempArray);                        
                            console.log(JSON.parse(JSON.stringify(this.tempArray)));                            
                            console.log('temp :'+temp);
                            this.records = JSON.parse(JSON.stringify(this.tempArray));
                            this.totalRecords = this.records.length; // update total records count                 
                            this.pageSize = this.pageSizeOptions[3]; //set pageSize with default value as first option
                            this.paginationHelper();                            
                            this.lastSavedData = JSON.parse(JSON.stringify(this.records));
                            
                        }
                        //evt.target.value='';
                    }
                   //evt.target.value=''; 
                   
                }).catch(error => {
                    console.log('error---', error);
                    this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');                    
                });
        }
    }
}