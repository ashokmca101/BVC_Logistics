/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-09-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
import { LightningElement, track, wire } from 'lwc';  
import searchShipment from '@salesforce/apex/TMS_ShipmentStatusListView.searchShipment'; 
import saveDraftValues from '@salesforce/apex/TMS_ShipmentStatusListView.saveDraftValues';
import shipmentFilterList from '@salesforce/apex/TMS_ShipmentStatusListView.shipmentFilterList';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { NavigationMixin } from 'lightning/navigation';


const DELAY = 300;
const COLUMNS = [

    {  
        label: 'Shipping Note Number',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Shipping_Note_Number__c' },
            target: '_self'
        }
    },
    {
        label: 'Customer',
        fieldName: 'Customer__c',
        type: 'lookup',
        typeAttributes: {
            placeholder: 'Choose Customer',
            object: 'Shipment__c',
            fieldName: 'Customer__c',
            label: 'Customer',
            value: { fieldName: 'Customer__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Customer',
            fields: ['Account.Name'],
            target: '_self'
        }, 
        cellAttributes: {
            class: { fieldName: 'customerClass' }
        }
    },
    {
        label: 'Billing Account',
        fieldName: 'Billing_Account__c',
        type: 'lookup',
        typeAttributes: {
            placeholder: 'Choose Products',
            object: 'Shipment__c',
            fieldName: 'Billing_Account__c',
            label: 'billingAccount',
            value: { fieldName: 'Billing_Account__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'billingAccount',
            fields: ['Account.Name'],
            target: '_self'
        },
       // editable: true,
        cellAttributes: {
            class: { fieldName: 'billingAccountClass' }
        }
    },
    {
        label: 'BVC Product Code',
        fieldName: 'Product_Code__c',
        type:'text',
        editable: true
    },
    {
        label: 'Verified for Billing',
        fieldName: 'Verified_for_Billing__c',
        type: 'picklist', 
        typeAttributes: {
            placeholder: 'Choose Verified for Billing',
            options: [
                { label: 'False', value: 'false' },
                { label: 'True', value: 'true' } 
            ],
            value: { fieldName: 'Verified_for_Billing__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Verified for Billing',
            label: 'Verified for Billing'
        },
        cellAttributes: {
            class: { fieldName: 'verifiedforBillingClass' }
        }
    },
    {
        label: 'Billing Status',
        fieldName: 'Billing_Status__c',
        type: 'picklist', 
        typeAttributes: {
            placeholder: 'Choose Billing Status',
            options: [
                { label: 'Ready for Billing', value: 'Ready for Billing' },
                { label: 'Verified for Billing', value: 'Verified for Billing' },
                { label: 'Picked for Billing', value: 'Picked for Billing' } 
            ],
            value: { fieldName: 'Billing_Status__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Billing Status',
            label: 'Billing Status'
        },
        cellAttributes: {
            class: { fieldName: 'billingStatusClass' }
        }
    }
];


export default class TmsShipmentStatusListView extends NavigationMixin(LightningElement) {

    //
    @track filterDate = new Object();
    @track recordList ='';
    @track parent = false;
    @track billingAccount = false;
    @track recordCount = 0;
    @track accountName;
    @track billingAccountId;
    @track bvcHub;
    @track exhibition;
    @track dateFrom;
    @track dateTo;
    @track Billing;
    @track ReBilling;


    columns = COLUMNS;
    records;
    lastSavedData;
    error;
    accountId;
    Billing_Status__c;
    wiredRecords;
    showSpinner = false;
    draftValues = [];
    privateChildren = {};
    
    // Loading default Value to ready for billing picklist.
    get ReadyforBilling() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }, 
        ];
    } 

    // Loaading default value to ready for rebilling.
    get ReadyforRebilling() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }, 
        ];
    }

    searchShipment(event) {
        this.showSpinner = true;
        //window.console.log("======= Event =====", Object.values(event.target));
        //window.console.log("=======  Table Heading ======", this.tableHead);
        this.filterDate.account = this.template.querySelector('[data-id^="accountID"]').value;
        this.filterDate.billingAccount = this.template.querySelector('[data-id^="billingAccountID"]').value;
        this.filterDate.bvcBranch = this.template.querySelector('[data-id^="bvcBranchID"]').value;
        this.filterDate.exhibitionName = this.template.querySelector('[data-id^="exhibitionNameID"]').value;
        this.filterDate.shipmentDateFrom = this.template.querySelector('[data-id^="shipmentDateFromID"]').value;
        this.filterDate.shipmentDateTo = this.template.querySelector('[data-id^="shipmentDateToID"]').value;
        this.filterDate.ReadyforBilling = this.template.querySelector('[data-id^="readyforBillingID"]').value;
        this.filterDate.ReadyforRebilling = this.template.querySelector('[data-id^="readyforRebillingID"]').value;

        window.console.log("======= Filter Date =======", Object.values(this.filterDate));

        searchShipment({
            account : this.filterDate.account,
            billingAccount:  this.filterDate.billingAccount,
            bvcBranch: this.filterDate.bvcBranch,
            exhibitionName:  this.filterDate.exhibitionName,    
            shipmentDateTo:  this.filterDate.shipmentDateTo !=''? this.filterDate.shipmentDateTo : null ,
            shipmentDateFrom: this.filterDate.shipmentDateFrom != ''?this.filterDate.shipmentDateFrom : null ,
            readyforRebilling: this.filterDate.ReadyforRebilling,
            readyforbilling: this.filterDate.ReadyforBilling 
        }).then((result) => {
            if (result) {
                this.recordList = result;
                this.records = JSON.parse(JSON.stringify(result));
                console.log("===== Search Data =====",this.records);
                this.recordCount = result.length; 
                this.records.forEach(record => {
                    record.linkName = '/' + record.Id;
                    record.billingStatusClass = 'slds-cell-edit';
                    record.billingAccountClass = 'slds-cell-edit';
                    record.customerClass = 'slds-cell-edit';
                    record.verifiedforBillingClass = 'slds-cell-edit';                    
                }); 
                this.showSpinner = false;
            }
        }).catch((err) => {
            window.console.log("=====Error======",err);
            this.showSpinner = false;
        }); 
        this.showSpinner = false;
    } 

    
    exportdata(event) {

       // window.console.log("=====exportdata======", this.template.querySelectorAll('lightning-input'));
     //   console.log('======= Table +++++++:',this.records );
        shipmentFilterList({
            shipmentList : this.records
        }).then(result => {
            let columnHeader = ["S.No","BVC Service","Shipment Note Number", "Customer","BVC Product Code","Billing Account","Billing Address","Shipment date",
            "Shipper Account","Origin Address Name","Consignee Account","Destination Address Name","Product Description","Shipment Value","Net Weight","Net Weight UOM",
            "BVC Gross Weight","Gross Weight UOM","Insurance By","Origin Hub","Origin Type","Destination Hub","Destination Type","Billing Status","Exhibition?","Exhibition Name",
            "Exhibition Movement Type"];  // This array holds the Column headers to be displayd

            let jsonKeys = ["Customer_Product_Category__c","Shipping_Note_Number__c","Customer__r","Product_Code__c","Billing_Account__r","Billing_Address__r","Shipment_Date__c",
            "Shipper_Name_TMS__r","Origin_Address_Name__r","Consignee_Name_TMS__r","Destination_Address_Name__r","Product_Description__c","Shipment_Value__c","Net_Weight__c","Net_Weight_UOM_TMS__c",
            "Gross_Weight__c","Gross_Weight_UOM_TMS__c","Insurance_By__c","Origin_Hub__r","Origin_Type__c","Destination_Hub__r","Destination_Type__c","Billing_Status__c","IsExhibition__c","Exhibition__r",
            "Exhibition_Movement_Type__c"]; // This array holds the keys in the json data  
                var jsonRecordsData = JSON.parse(JSON.stringify(result));
                console.log('parsed value',jsonRecordsData);
                let csvIterativeData;  
                let csvSeperator  
                let newLineCharacter;  
                csvSeperator = ",";  
                newLineCharacter = "\n";  
                csvIterativeData = "";  
                csvIterativeData += columnHeader.join(csvSeperator);  
                csvIterativeData += newLineCharacter;  
                for (let i = 0; i < jsonRecordsData.length; i++) {  
                    let counter = 0;  
                    for (let iteratorObj in jsonKeys) {  
                        let dataKey = jsonKeys[iteratorObj];  
                        if (counter > 0) {  
                            csvIterativeData += csvSeperator;  
                        }  
                        if (  jsonRecordsData[i][dataKey] !== null && jsonRecordsData[i][dataKey] !== undefined ) {  
                            console.log("==== Data ====",jsonRecordsData[i][dataKey]);
                            console.log("==== Data Key ====", dataKey);
                            if(dataKey.includes("__r")){
                                csvIterativeData += '"' + jsonRecordsData[i][dataKey].Name + '"';
                            }else{
                                csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                            }
                              
                        } else {  
                            csvIterativeData += '""';  
                        }  
                        counter++;  
                    }  
                    csvIterativeData += newLineCharacter;  
                }  
                
               // console.log("csvIterativeData", csvIterativeData);  
                 
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: "data:text/csv;charset=utf-8" + encodeURI(csvIterativeData)
                    }
                });     

            //console.log("URL ", "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData)+"download=ship.csv");
                //this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);  
        }).catch(error => {

        });
    }

    //connectedCallback(){ 
    renderedCallback() {
       
        if (!this.isComponentLoaded) {
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-datatable-picklist', context);
        this.resetPopups('c-datatable-lookup', context);
    }

    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    } 

    accountNameHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const accountName = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.accountName = accountName;
            console.log("=====",this.accountName);
        }, DELAY);
    }

    billingAccountHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const billingAccountId = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.billingAccountId = billingAccountId;
            console.log("=====",this.billingAccountId);
        }, DELAY);
    }

    bvcHubHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const bvcHub = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.bvcHub = bvcHub;
            console.log("=====",this.bvcHub);
        }, DELAY);
    }

    ExhibitionHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const exhibition = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.exhibition = exhibition;
            console.log("=====",this.exhibition);
        }, DELAY);
    }

    DateFromHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const dateFrom = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.dateFrom = dateFrom;
            console.log("=====",this.dateFrom);
        }, DELAY);
    }

    DateToHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const dateTo = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.dateTo = dateTo;
            console.log("=====",this.dateTo);
        }, DELAY);
    }

    BillingHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const Billing = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.Billing = Billing;
            console.log("=====",this.Billing);
        }, DELAY);
    }

    ReBillingHandler(event){
        console.log("====dsds=");
        window.clearTimeout(this.delayTimeout);
        const ReBilling = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.ReBilling = ReBilling;
            console.log("=====",this.ReBilling);
        }, DELAY);
    }
 
    @wire(searchShipment,{
        account: '$accountName' , 
        billingAccount : '$billingAccountId' , 
        bvcBranch: '$bvcHub', 
        exhibitionName:'$exhibition', 
        shipmentDateTo:'$dateTo', 
        shipmentDateFrom:'$dateFrom', 
        readyforRebilling:'$ReBilling', 
        readyforbilling:'$Billing' 
    }) wiredRelatedRecords(result) {
        console.log("=== this.records c ===");
        this.wiredRecords = result;
        console.log("===  this.wiredRecords ===", this.wiredRecords);
        const { data, error } = result;
        if (data) {
            this.records = JSON.parse(JSON.stringify(data));
            console.log("=== this.records ===" , this.records);
            this.records.forEach(record => {
                record.linkName = '/' + record.Id;
                record.productNameClass = 'slds-cell-edit';
                record.billingStatusClass = 'slds-cell-edit';
                record.billingAccountClass = 'slds-cell-edit';
                record.customerClass = 'slds-cell-edit'; 
                
            });
            this.error = undefined;
        } else if (error) {
            this.records = undefined;
            this.error = error;
        } else {
            this.error = undefined;
            this.records = undefined;
        }
        this.lastSavedData = this.records;
        this.showSpinner = false;
    }
 


    handleItemRegister(event) {
        event.stopPropagation();
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    handleChange(event) {
        console.log("==== env ===",event.target.value);
        alert('===== handleChange(event) ===');
        
        event.preventDefault();
        this.Billing_Status__c = event.target.value;
        this.showSpinner = true;
    }

    handleCancel(event) {
        console.log('======= handleCancel ====',event);
        event.preventDefault();
        this.records = JSON.parse(JSON.stringify(this.lastSavedData));
        this.handleWindowOnclick('reset');
        this.draftValues = [];
    }

    handleCellChange(event) {
        console.log('======= handleCellChange ====',event);
        event.preventDefault();
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Product':
                updatedItem = {
                    Id: dataRecieved.context,
                    Product_Name__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'productNameClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Billing Status':
                updatedItem = {
                    Id: dataRecieved.context,
                    Billing_Status__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'billingStatusClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Customer':
                updatedItem = {
                    Id: dataRecieved.context,
                    Customer__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'customerClass',
                    'slds-cell-edit slds-is-edited'
                ); //billingAccount
                break;
            case 'billingAccount':
                updatedItem = {
                    Id: dataRecieved.context,
                    Billing_Account__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'billingAccountClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            
            case 'Verified for Billing':
                updatedItem = {
                    Id: dataRecieved.context,
                    Verified_for_Billing__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'verifiedforBillingClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Rebilling Required':
                updatedItem = {
                    Id: dataRecieved.context,
                    Ready_for_Rebilling__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'rebillingRequiredClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Rebilling Reason':
                updatedItem = {
                    Id: dataRecieved.context,
                    Rebilling_Reason__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'rebillingReasonClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        console.log('=========updateDataValues=====',updateItem );
        let copyData = JSON.parse(JSON.stringify(this.records));
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.records = [...copyData];
    }

    updateDraftValues(updateItem) {
        console.log('===== updateDraftValues====== ',updateItem);
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleEdit(event) {
        event.preventDefault();
        let dataRecieved = event.detail.data;
        window.console.log("===== Select ======",dataRecieved );
        this.handleWindowOnclick(dataRecieved.context);
        window.console.log("===== dataRecieved.label ======",dataRecieved.label );
        switch (dataRecieved.label) {
            case 'Product':
                this.setClassesOnData(
                    dataRecieved.context,
                    'productNameClass',
                    'slds-cell-edit'
                );
                break;
            case 'Billing Status':
                this.setClassesOnData(
                    dataRecieved.context,
                    'billingStatusClass',
                    'slds-cell-edit'
                );
                break;
            case 'Customer':
                this.setClassesOnData(
                    dataRecieved.context,
                    'customerClass',
                    'slds-cell-edit'
                );
                break;
            case 'billingAccount':
                this.setClassesOnData(
                    dataRecieved.context,
                    'billingAccountClass',
                    'slds-cell-edit'
                );
                break;
            case 'Verified for Billing':
                 
                this.setClassesOnData(
                    dataRecieved.context,
                    'verifiedforBillingClass',
                    'slds-cell-edit'
                );
                break;

            case 'Rebilling Required': 
                this.setClassesOnData(
                    dataRecieved.context,
                    'rebillingRequiredClass',
                    'slds-cell-edit'
                );
                break;
            case 'Rebilling Required': 
                this.setClassesOnData(
                    dataRecieved.context,
                    'rebillingReasonClass',
                    'slds-cell-edit'
                );
                break;    
                
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        };
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.records = JSON.parse(JSON.stringify(this.records));
        this.records.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }

    handleSave(event) {
        event.preventDefault();
        this.showSpinner = true;
        console.log("=== handleSave === Draft Value");
        saveDraftValues({ data: this.draftValues })
            .then(() => {
                console.log("====== Draft Value", this.draftValues);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Shipments updated successfully',
                        variant: 'success'
                    })
                );
                this.showSpinner = false;
                refreshApex(this.wiredRecords).then(() => {
                    this.records.forEach(record => { 
                        record.productNameClass = 'slds-cell-edit';
                        record.billingStatusClass = 'slds-cell-edit';
                        record.billingAccountClass = 'slds-cell-edit';
                        record.customerClass = 'slds-cell-edit';
                        record.verifiedforBillingClass = 'slds-cell-edit';
                        
                    });
                    this.draftValues = [];
                });
            })
            .catch(error => {
                console.log('error : ',error);
                console.log('error : ' + JSON.stringify(error));
                this.showSpinner = false;
            });
    }

}