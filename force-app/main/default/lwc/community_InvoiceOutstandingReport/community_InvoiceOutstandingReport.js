import { LightningElement, track, wire, api } from 'lwc';
import getData from "@salesforce/apex/Community_InvoiceOutstandingCtrl.getData";

export default class Community_InvoiceOutstandingReport extends LightningElement {
    @track columns = [
        { label: 'Trade name', fieldName: 'Trade_Name__c' },
        { label: 'Shipping Note Number', fieldName: 'Shipping_Number__c' },
        { label: 'Document Type', fieldName: 'Document_Type__c' },
        { label: 'Document Number', fieldName: 'Document_Number__c' },
        { label: 'Document Date', fieldName: 'Document_Date__c' },
        { label: 'Amount Due', fieldName: 'Amount_Due__c' },
        { label: 'Due Date', fieldName: 'Due_date__c' },
        { label: 'Original Amount', fieldName: 'Original_Amount__c' }
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
    searchInvoice() {
        console.log('button clicked');
        getData({startdate: this.starDate, endDate: this.endDate})
            .then(result => {
                console.log('method invoked');
                this.data = [];
                let currentData = [];
                
                result.forEach((row) =>{
                    console.log('data'+row);
                    let rowData = {};
                    rowData.Trade_Name__c = row.Trade_Name__c;
                    rowData.Shipping_Number__c = row.Shipping_Number__c;
                    rowData.Document_Type__c = row.Document_Type__c;
                    rowData.Document_Number__c = row.Document_Number__c;
                    rowData.Document_Date__c = row.Document_Date__c;
                    rowData.Amount_Due__c = row.Amount_Due__c;
                    rowData.Due_date__c = row.Due_date__c;
                    rowData.Original_Amount__c = row.Original_Amount__c;
                    rowData.Customer__c = row.Customer__c;
                    rowData.id = row.id;
                    

                    currentData.push(rowData);
                })
                if (currentData != null) {
                    this.data = currentData;
                    console.log('data'+ this.data);
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
        downloadElement.download = 'Invoice Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }

}