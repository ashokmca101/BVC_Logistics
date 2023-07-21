import { LightningElement, api, track } from 'lwc';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities'; 
import SHIPMENT from '@salesforce/schema/Shipment__c'; 
import shipmentRecordGet from "@salesforce/apex/TMS_AddSecureBagOnShipment.shipmentRecordGet"; 
import createSecureBagRecords from "@salesforce/apex/TMS_AddSecureBagOnShipment.createSecureBagRecords";
import updateshipmentAndPickup from "@salesforce/apex/TMS_AddSecureBagOnShipment.updateshipmentAndPickup";
import { NavigationMixin } from 'lightning/navigation'; 
import SHIPMENT_TRACKING from '@salesforce/schema/Shipment_Tracking__c';

 
export default class TmsAddSecureBagOnShipment  extends NavigationMixin(LightningElement) {
    
    @api recordId;
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
    @track completeButton = true;
    @track secureBagsID = ''; 
    @track sploadShippingNotePhoto = 0;
    @track sploadInvoicePhoto = 0;
    @track sploadSecureBagPhoto = 0;
    @track isShippingNumberManual = false;

    @track shippingNoteNumberManual = ''; 
    @track isShipmentPage = true;

    @track isBagPage = false;
    @track bagManual = '';
    @track isBagIdManual = true;

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
    

    handleNumberofPackagesChange(event) { 
        SHIPMENT.Number_of_Packages__c = event.target.value;
        this.numberofbags = event.target.value; 
    }

    checkshipmentRecord( dataRecordId ) { 
        shipmentRecordGet({ 
            shipmentRecordId: dataRecordId  
        }).then(result => {
            if (result) {
                this.isShipmentFound = true;
                this.shipmentCreationflage = false;
                this.shipmentRecord = result;
                this.shipmentRecordId = result.Id;
                this.numberofbags = this.shipmentRecord.Number_of_Packages__c;
                this.barCodeData =  result.Shipping_Note_Number__c;
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

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Information ",
                    message: "Please scan a valid secure bag.",
                    variant: "information"
                })
            );
            this.isBagIdManual = true;
            this.bagManual = '';
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
        this.checkshipmentRecord(this.recordId);
                 
    }
    
    handleSecureBagsManualChange(event) {
        
        this.bagManual = event.target.value; 
        let pid = this.pickupid;
        
        if(this.bagManual != '' && this.bagManual != null) { 
            this.secureBagsID = this.bagManual;
            this.tagbagWithShipment(this.bagManual, this.shipmentRecord.Id);
            
        } 
    }
    

    addSecureBags(event) {

        this.isShipmentPage = false;
        this.isBagPage = true; 
        if (this.shipmentRecord != null) {
            
            if (this.barcodeScanner.isAvailable()) {
                
                //this.barcodeScanner.resumeCapture().then((scannedBarcode) => {
                this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => {

                    this.secureBagsID = scannedBarcode.value;
                    
                    if (this.secureBagsID != '') {
                        this.tagbagWithShipment(this.secureBagsID, this.shipmentRecord.Id); 
                        
                    }
                }).catch((error) => {
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Information",
                            message: "Scanner not available or turned off.", 
                            variant: "information"
                        })
                    );
                    this.barcodeScanner.endCapture();
                    this.isBagIdManual = true;
                    this.bagManual = '';
                        
                }).finally(() => { 
                    this.barcodeScanner.endCapture();
                });
            } 
        } 
    }
    /*
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
    */
    
    processScannedBarcode(barcode) {
         this.secureBags.push(barcode); 
    }
    
   /* shippingNotePhotoUploadFinished(event) {
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

    }*/
    
    endProcess(event) { 
        updateshipmentAndPickup({
            shipmentId: this.recordId,
            numberofPackage : SHIPMENT.Number_of_Packages__c 
        }).then(result=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Completed !',
                    variant: 'success',
                }),
            ); 
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.pickupid,
                    objectApiName: 'Shipment__c',
                    recordId: this.recordId, 
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
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: '!',
                    variant: 'error',
                }),
            );

        });

        
       
    } 
}