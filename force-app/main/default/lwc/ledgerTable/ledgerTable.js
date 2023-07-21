import { LightningElement, track, wire, api } from 'lwc';
import getLedgers from "@salesforce/apex/BVC_LedgerTableController.getLedgers";


export default class LedgerTable extends LightningElement {
    @track columns = [
        { label: 'Legal Entity', fieldName: 'Legal_Entity__c' },
        { label: 'PAN', fieldName: 'PAN__c' },
        { label: 'Customer', fieldName: 'Customer_Name' },
        { label: 'Account Number', fieldName: 'Account_Number__c' },
        { label: 'Accounting Date', fieldName: 'Accounting_Date__c' },
        { label: 'Invoice Number', fieldName: 'Invoice_Number__c' },
        { label: 'Applied Invoice Number', fieldName: 'Applied_Invoice_Number__c' },
        { label: 'Original Doc No', fieldName: 'Original_Doc_No__c' },
        { label: 'Vch Type', fieldName: 'Vch_Type__c' },
        { label: 'Particular', fieldName: 'Particular__c' },
        { label: 'Debit', fieldName: 'Debit__c' },
        { label: 'Credit', fieldName: 'Credit__c' },
        { label: 'Currency Code', fieldName: 'Currency_Code__c' },
        { label: 'Exchange Rate', fieldName: 'Exchange_Rate__c' },
        { label: 'Debit(INR)', fieldName: 'Debit_INR__c' },
        { label: 'Credit(INR)', fieldName: 'Credit_INR__c' },
        { label: 'Due Date', fieldName: 'Due_Date__c' },
        { label: 'Site Name', fieldName: 'Site_Name__c' },
        { label: 'Site Number', fieldName: 'Site_Number__c' },
        { label: 'BVC Site ID', fieldName: 'BVC_Site_ID__c' },
        { label: 'BVC Company ID', fieldName: 'BVC_Company_ID__c' },
        { label: 'Trade Name', fieldName: 'Trade_Name__c' },
        { label: 'Bill-To Site Number', fieldName: 'Bill_To_Site_Number__c' },
        { label: 'BVC Master ID', fieldName: 'BVC_Master_ID__c' },
        { label: 'BVC Branch', fieldName: 'BVC_Branch__c' }
        
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

    searchLedgers() {
        getLedgers({startdate: this.starDate, endDate: this.endDate})
            .then(result => {
                this.data = [];
                let currentData = [];
                
                result.forEach((row) =>{
                    let rowData = {};
                    rowData.Legal_Entity__c = row.Legal_Entity__c;
                    rowData.PAN__c = row.PAN__c;
                    rowData.Customer_Name = row.Customer__r.Name;
                    rowData.Account_Number__c = row.Account_Number__c;
                    rowData.Accounting_Date__c = row.Accounting_Date__c;
                    rowData.Invoice_Number__c = row.Invoice_Number__c;
                    rowData.Applied_Invoice_Number__c = row.Applied_Invoice_Number__c;
                    rowData.Original_Doc_No__c = row.Original_Doc_No__c;
                    rowData.Vch_Type__c = row.Vch_Type__c;
                    rowData.Particular__c = row.Particular__c;
                    rowData.Debit__c = row.Debit__c;
                    rowData.Credit__c = row.Credit__c;
                    rowData.Currency_Code__c = row.Currency_Code__c;
                    rowData.Exchange_Rate__c = row.Exchange_Rate__c;
                    rowData.Debit_INR__c = row.Debit_INR__c;
                    rowData.Credit_INR__c = row.Credit_INR__c;
                    rowData.Due_Date__c = row.Due_Date__c;
                    rowData.Site_Name__c = row.Site_Name__c;
                    rowData.BVC_Site_ID__c = row.BVC_Site_ID__c;
                    rowData.Trade_Name__c = row.Trade_Name__c;
                    rowData.Bill_To_Site_Number__c = row.Bill_To_Site_Number__c;
                    rowData.BVC_Master_ID__c = row.BVC_Master_ID__c;
                    rowData.BVC_Branch__c = row.BVC_Branch__c;

                    currentData.push(rowData);
                })
                if (currentData != null) {
                    this.data = currentData;
                    this.datafound = true;
                }else {
                    this.dataFound = false;
                }
                
                                
            })
            .catch(error => {
                this.error = error;
                this.dataFound = false;
            });
    }

    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.data.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.data.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.data[i][rowKey] === undefined ? '' : this.data[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Ledger Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }

}