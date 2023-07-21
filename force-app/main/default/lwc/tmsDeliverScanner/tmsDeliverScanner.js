/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-14-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
import { LightningElement,api,track } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import secureBagGet from "@salesforce/apex/TMS_DeliverScanner.secureBagGet";
import insertUpdateRecord from "@salesforce/apex/TMS_DeliverScanner.insertUpdateRecord";
import SHIPMENT_TRACKING from '@salesforce/schema/Shipment_Tracking__c';
import { NavigationMixin } from 'lightning/navigation';
import allSecureBagGet from "@salesforce/apex/TMS_DeliverScanner.allSecureBagGet";

export default class TmsDeliverScanner extends NavigationMixin(LightningElement) {
    @api recordId;
    @track barcodeScanner;
    @track scanningOptions;
    @track shipmentView = true;
    @track sacnButtonLabel = 'Scan Secure Bags';
    @track currentSecureBags = '';
    @track secureBagsID = '';
    @track latitude;
    @track longitude;    
    @track secureBagsManualId = '';
    @track isBagIdManual = false;
    @track isLoading  = false; 
    @track erorrmessage = 'Unknown erorr'; 
    @track sploadShippingNotePhoto = 0;
    @track sploadInvoicePhoto = 0;
    @track sploadSecureBagPhoto = 0;
    @track idUploadView = false;
    @track shipmentRecordId;
    @track idSignatureView = false;
    @track numberofSSN = 0;
    @track ssnValidation = '';
    @track isfirstBagScan = true; 
    @track scanButton = false;
    connectedCallback() { 

        this.isLoading = true;
        this.beginScanning();
        this.countBags = ''
         
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => { 
                SHIPMENT_TRACKING.Geocode__Latitude__s = position.coords.latitude;
                SHIPMENT_TRACKING.Geocode__Longitude__s = position.coords.longitude; 
            });
        }
       // alert(this.recordId);
        this.buttonComete = true; 
        this.isLoading = false;
    }

    errorCallback(error, stack) {
        // Dev use
        console.log("===== Error =====",error);
        console.log("===== stack =====",stack);
    }

    getAndUpdateBag(barcodeValue) { 

        this.isLoading = true;  
        secureBagGet({ 
            secureBagId: barcodeValue,
            addressID : this.recordId
        }).then(result => { 

            this.isLoading = true;
            
            this.currentSecureBags = result;
            this.shipmentRecordId = result.Shipment__c; 
            if(this.isfirstBagScan){
                this.ssnValidation = result.Shipment__r.Shipping_Note_Number__c;
                allSecureBagGet({ 
                    addressID : this.recordId
                }).then(result=>{
                    this.numberofSSN = result
                }).catch(error => {
                    this.numberofSSN = 0;
                });
                 
                this.isfirstBagScan = false;
            } 
            
            var secureId = typeof this.currentSecureBags === undefined ? '' : this.currentSecureBags.Secure_Bag__r.Name; 

            if (this.currentSecureBags != null) {

                insertUpdateRecord({
                    shipmentTrackingrecord: SHIPMENT_TRACKING,
                    secureBagRecord: this.currentSecureBags,
                    shippingNoteNumber : this.ssnValidation
                }).then(result => { 

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "Scanning completed for : "+secureId+".",
                            variant: "success"
                        })
                    ); 
                    this.sacnButtonLabel = 'Scan More';
                   // this.isBagIdManual = false; 
                    this.isLoading  = false; 
                    this.numberofSSN = this.numberofSSN - 1;
                    if(this.numberofSSN <= 0){
                        this.scanButton = true;
                    }
                }).catch(erorr => { 

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
                    
                    this.isBagIdManual = true;
                    this.secureBagsManualId = '';
                    
                }); 
            }
            this.secureBagsManualId = ''; 
            this.sacnButtonLabel = 'Scan More'; 
            this.isLoading  = false;

        }).catch(erorr => {  
            if (erorr) { 
                if (Array.isArray(erorr.body)) {
                    this.erorrmessage = erorr.body.map(e => e.message).join(', ');
                } else if (typeof erorr.body.message === 'string') {
                    this.erorrmessage = erorr.body.message;
                } 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Information",
                        message: this.erorrmessage,
                        variant: "Information"
                    })
                );
                
            } 

            this.isBagIdManual = true;
            this.secureBagsManualId = ''; 
            this.isLoading = false;

        });
    }
    
     

    handleSecureBagsManualChange(event) { 
        this.isLoading = true;
        this.secureBagsManualId = event.target.value; 
        
        if (this.secureBagsManualId != '' && this.secureBagsManualId != null) {
            this.secureBagsID = this.secureBagsManualId;
            this.getAndUpdateBag(this.secureBagsManualId);
        }
 
        this.isLoading  = false;
    } 

    beginScanning() {  

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

        this.secureBagScanning();
        
     
    }
    
    secureBagScanning() { 
 
        if (this.barcodeScanner.isAvailable()) { 

            this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => { 
                this.secureBagsID = scannedBarcode.value;
                
                if (this.secureBagsID != '' && this.secureBagsID != null) {
                    this.getAndUpdateBag(this.secureBagsID); 
                } 
            
            }).catch((erorr) => { 
                if (erorr) {  
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Information ",
                            message: "Secure bag record not found. Requesting you to re-scan or enter manually.",
                            variant: "information"
                        })
                    );
                } 
                this.barcodeScanner.endCapture();
                this.isBagIdManual = true;
                this.secureBagsManualId = ''; 
                this.isLoading  = false;

            }).finally(() => { 
                this.barcodeScanner.endCapture();
                this.isLoading  = false; 
            });
            
        } else { 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Information",
                    message: "Scanner not available or turned off.",
                    variant: "information"
                })
            ); 
           // this.isBagIdManual = true;
            this.isLoading  = false;
        } 
    }

    uploadDocument(event){
        this.idUploadView = true;
        this.shipmentView = false;
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

    addSignature(event){
        this.idSignatureView = true;
        this.shipmentView = false;
        this.idUploadView = false; 
    } 
}