/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc 
 * @group             : 
 * @last modified on  : 12-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
import { LightningElement, api, track,wire } from 'lwc';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities'; 
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import SHIPMENT from '@salesforce/schema/Shipment__c'; 
import shipmentRecordGet from "@salesforce/apex/TMS_ScanningBarCodeWithoutShipment.shipmentRecordGet";
import createShipmentRecord from "@salesforce/apex/TMS_ScanningBarCodeWithoutShipment.createShipmentRecord"; 
import createSecureBagRecords from "@salesforce/apex/TMS_ScanningBarCodeWithoutShipment.createSecureBagRecords";
import createTrackingRecord from "@salesforce/apex/TMS_ScanningBarCodeWithoutShipment.createTrackingRecord";

import { NavigationMixin } from 'lightning/navigation';
import SHIPMENT_TRACKING from '@salesforce/schema/Shipment_Tracking__c';

export default class TmsScanningBarCodeWithoutShipment  extends NavigationMixin(LightningElement) {
    
    @api pickupid;
    @track barCodeData = ''; 
    @track barcodeScanner;
    @track scanningOptions;
    @track isShipmentFound ;
    @track secureBags=[];
    @track currentSecureBags = '';
    @track shipmentRecord;
    @track shipmentRecordId='';
    @track secureBagRecord;
    @track shipmentCreationflage = true;
    @track numberofbags = 0;
    @track scanButton = false;
    @track secureBagsID = ''; 
    @track sploadShippingNotePhoto = 0;
    @track sploadInvoicePhoto = 0;
    @track sploadSecureBagPhoto = 0;
    @track isShippingNumberManual = false;

    @track shippingNoteNumberManual = ''; 
    @track isShipmentPage = true;

    @track isBagPage = false;
    @track bagManual = '';
    @track isBagIdManual = false;
    @track updatesecurebag = [];
    @track recordTypeId;
    @track SBID;
    
    
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg','.mp4','.docs','.xlxs'];
    }

    
    
    connectedCallback() {
        
         if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => { 
                SHIPMENT_TRACKING.Geocode__Latitude__s = position.coords.latitude;
                SHIPMENT_TRACKING.Geocode__Longitude__s = position.coords.longitude; 
            });
        }

        this.beginScanning();
    }

    handleDestinationPincodeChange(event) {
        SHIPMENT.Destination_Pincode__c = event.target.value;
        
    }

    handleConsigneeNameCategoryChange(event){
        SHIPMENT.Consignee_Name_TMS__c = event.target.value;
    }

    handleDestinationAddressCategoryChange(event){
        SHIPMENT.Destination_Address_Name__c = event.target.value;
    }

    handleCustomerProductCategoryChange(event){
        SHIPMENT.Customer_Product_Category__c = event.target.value;

    }

    handleProductDescriptionChange(event) {
        SHIPMENT.Product_Description__c = event.target.value;
        
    }
    
    handleNumberofPackagesChange(event) { 
        SHIPMENT.Number_of_Packages__c = event.target.value;
        this.numberofbags = event.target.value;

    }

    checkshipmentRecord(codeDatab, pickupId) {
        
        shipmentRecordGet({ 
            shippingNoteNumber: codeDatab,
            pickupID: pickupId
            
        }).then(result => {
            if (result) {
                this.isShipmentFound = true;
                this.shipmentCreationflage = false;
                this.shipmentRecord = result;
                this.shipmentRecordId = result.Id;
                this.numberofbags = this.shipmentRecord.Number_of_Packages__c;

            } else { 
                this.isShipmentFound = false;
                this.shipmentRecordId = '';
            }

        }).catch(error => {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Information",
                    message: "Please scan a valid shipping note number.",
                    variant: "information"
                })
            );
  
            this.isShippingNumberManual = true;
            this.shippingNoteNumberManual = '';
            
        });
    }

    tagbagWithShipment(bagId, shipmentRecordID) {
        
        createSecureBagRecords({
            bagId: bagId,
            shipmentID: shipmentRecordID
        }).then(result => {
            //Added By Imran
            console.log('11.Inside createSecureBagRecords Res :'+result.Id);
            this.SBID = result.Id;  // this value declared at the top
            // Added By Imran upto here
            this.isBagIdManual = false;
            
            this.processScannedBarcode(result);
            this.numberofbags--;
            if (this.numberofbags <= 0) {
                 
                this.numberofbags = 0; 
                this.completeButton= false;
                this.scanButton = true;
            } else {
                this.scanButton = false;
                this.completeButton = true;
            }
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Secure Added!',
                    variant: 'success',
                }),
            );
            
            
        }).catch(erorr => { 
            let errormessage ='';
            if (erorr) {
                    errormessage = 'Unknown error';
                if (Array.isArray(erorr.body)) {
                    errormessage = erorr.body.map(e => e.message).join(', ');
                } else if (typeof erorr.body.message === 'string') {
                    errormessage = erorr.body.message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Information ",
                        message: "Please scan a valid secure bag, or "+ errormessage,
                        variant: "information"
                    })
                );
                this.isBagIdManual = true;
                this.bagManual = ''; 
            } 
        }); 
    } 
    
    beginScanning() {

        let pid = this.pickupid;
        this.barcodeScanner = getBarcodeScanner(); 
        this.scanningOptions = {
            barcodeTypes: [ 
                this.barcodeScanner.barcodeTypes.CODE_128,
                this.barcodeScanner.barcodeTypes.CODE_39,
                this.barcodeScanner.barcodeTypes.CODE_93,
                this.barcodeScanner.barcodeTypes.DATA_MATRIX,
                this.barcodeScanner.barcodeTypes.EAN_13,
                this.barcodeScanner.barcodeTypes.EAN_8,
                this.barcodeScanner.barcodeTypes.ITF 
            ]
        }
        
        if (this.barcodeScanner.isAvailable()) {
            
            this.barcodeScanner.beginCapture(this.scanningOptions).then((result) => { 
                this.barCodeData = result.value;
                this.checkshipmentRecord(this.barCodeData, pid); 

            }).catch((error) => {
                this.barcodeScanner.endCapture(); 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Information",
                        message: "Failed to scan barcode, try again.",
                        variant: "warning"
                    })
                ); 
                
                this.isShippingNumberManual = true;
                this.shippingNoteNumberManual = '';
               

            }).finally(() => { 
                this.barcodeScanner.endCapture(); 
            }); 

        } else {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Information",
                    message: "Scanner not available or turned off.",
                    variant: "information"
                })
            );

            this.isShippingNumberManual = true;
            this.shippingNoteNumberManual = '';

        }  
    }

    handleShippingNoteNumberManualChange(event) {

        this.shippingNoteNumberManual = event.target.value; 
        let pid = this.pickupid;
       
        if(this.shippingNoteNumberManual != '' && this.shippingNoteNumberManual != null) { 
            this.barCodeData = this.shippingNoteNumberManual;
            this.checkshipmentRecord(this.shippingNoteNumberManual,this.pickupid);
        }
    }

    handleSecureBagsManualChange(event) {

        this.bagManual = event.target.value; 
        console.log('11.this.bagManual :'+this.bagManual);
        let pid = this.pickupid;
        
        if(this.bagManual != '' && this.bagManual != null) { 
            this.secureBagsID = this.bagManual;
            this.tagbagWithShipment(this.bagManual, this.shipmentRecord.Id);
            console.log('11.this.secureBagsID :'+this.secureBagsID);
            
        } 
    }
    

    addSecureBags(event) {

        this.isShipmentPage = false;
        this.isBagPage = true;
        
        let pid = this.pickupid; 
        if (this.shipmentCreationflage) {

            this.shipmentCreationflage = false;
            
            createShipmentRecord({
                shipmentRecord: SHIPMENT,
                pickupId: pid,
                sNoteNumber: this.barCodeData

            }).then(result => { 
                
                this.shipmentRecord = result; 
                this.isShipmentFound = true;
                this.shipmentRecordId = result.Id;

                if (this.shipmentRecord != null) {
                    
                    if (this.barcodeScanner.isAvailable()) {
                        
                        //this.barcodeScanner.resumeCapture().then((scannedBarcode) => {
                this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => {

                            this.secureBagsID = scannedBarcode.value; 
                            if (this.secureBagsID != '' ) { 
                                this.tagbagWithShipment(this.secureBagsID, this.shipmentRecord.Id); 
                            }
                            
                        }).catch((error) => { 
                            this.barcodeScanner.endCapture();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Information",
                                    message: "Failed to scan barcode, try again.",
                                    variant: "warning"
                                })
                            );
                            
                            this.isBagIdManual = true;
                            this.bagManual = '';
                            
                            
                        }).finally(() => { 
                            this.barcodeScanner.endCapture();
                            
                        });

                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Information",
                                message: "Scanner not available or turned off.",
                                variant: "information"
                            })
                        );
                        this.isBagIdManual = true;
                        this.bagManual = ''
                    }
                }
                
            }).catch(error => {
                let errormessage ='';
                if (error) {
                     errormessage = 'Unknown error';
                    if (Array.isArray(error.body)) {
                        errormessage = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        errormessage = error.body.message;
                    }

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Information",
                            message: "Shipping note number not found, or "+ errormessage,
                            variant: "information"
                        })
                    );

                    this.shipmentCreationflage = false;
                    this.isShipmentPage = true; 
                    this.isShippingNumberManual = true;
                    this.isBagPage = false; 
                } 
                
            });  

        } else {
            
            if (this.shipmentRecord != null) {
                
                if (this.barcodeScanner.isAvailable()) {
                    
                    //this.barcodeScanner.resumeCapture().then((scannedBarcode) => {
                this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => {


                        this.secureBagsID = scannedBarcode.value;
                        
                        if (this.secureBagsID != '') {
                            this.tagbagWithShipment(this.secureBagsID, this.shipmentRecord.Id);  
                        }
                        
                    }).catch((erorr) => {
                        this.barcodeScanner.endCapture();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Information",
                                message: "Failed to scan barcode, try again.",
                                
                                variant: "information"
                            })
                        ); 
                        this.isBagIdManual = true;
                        this.bagManual = '';
                            
                    }).finally(() => { 
                        this.barcodeScanner.endCapture();
                    });
                } 
            }
        } 
        
       // this.beginScanning();
    }
    
    fileuploaddone(event) {
        
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';

        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
    }
    
    processScannedBarcode(barcode) {
         this.secureBags.push(barcode); 
    }
    
    shippingNotePhotoUploadFinished(event) {
        this.fileuploaddone(event);
        this.sploadShippingNotePhoto++;

    }

    uploadInvoicePhotoUploadFinished(event) {
        this.fileuploaddone(event);
        this.sploadInvoicePhoto++;

    }
    
    uploadSecureBagPhotoUploadFinished(event) {
        this.fileuploaddone(event);
        this.sploadSecureBagPhoto++;

    }
    
    endProcess(event) { 

        if (this.shipmentRecord != null) {
            
            createTrackingRecord({
                shipmentTrackingRecord: SHIPMENT_TRACKING,
                shipmentId : this.shipmentRecord.Id,
                secureBaglist: this.secureBags

            }).then(result => {
               
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "success ",
                        message: "Process Ending..",
                        variant: "success"
                    })
                );
                
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "warning",
                        message: "warning :- Tracking record not created. ",
                        variant: "warning"
                    })
                ); 
            });
        }
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.pickupid,
                objectApiName: 'Pickup__c', 
                actionName: 'view'
            },
        });
        
        this.barCodeData = '';  
        this.secureBags=[];
        this.currentSecureBags = '';
        this.shipmentRecord;
        this.secureBagRecord;
        this.shipmentCreationflage = true;
        this.numberofbags = 0;
        this.scanButton = false;
        this.secureBagsID = ''; 
        this.sploadShippingNotePhoto = 0;
        this.sploadInvoicePhoto = 0;
        this.sploadSecureBagPhoto = 0;
        this.shippingNoteNumberManual = ''; 
        this.isShipmentPage = true; 
        this.isBagPage = false;
        this.bagManual = '';
        this.isBagIdManual = false; 
        SHIPMENT.Destination_Pincode__c = null;
        SHIPMENT.Consignee_Name_TMS__c = null;
        SHIPMENT.Destination_Address_Name__c = null;
        SHIPMENT.Customer_Product_Category__c = null;
        SHIPMENT.Product_Description__c = null;
        SHIPMENT.Number_of_Packages__c = null;
        eval("$A.get('e.force:refreshView').fire();");
    } 
}