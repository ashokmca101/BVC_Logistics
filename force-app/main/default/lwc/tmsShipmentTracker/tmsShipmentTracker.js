/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-14-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version 
**/
import { LightningElement,wire,track } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import SHIPMENT_TRACKING from '@salesforce/schema/Shipment_Tracking__c'; 
import { NavigationMixin } from 'lightning/navigation';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id';
import {getRecord} from 'lightning/uiRecordApi'; //Operations Field Executive
import EXECUTIVE_PROFILE_NAME from '@salesforce/label/c.ExecutiveProfileName';

// Get Secure bag and Seal Id.
import bagBySealId from "@salesforce/apex/TM_ShipmentTrackerController.bagBySealId";
import bagBySecureBagId from "@salesforce/apex/TM_ShipmentTrackerController.bagBySecureBagId";
import scanningInProgress from "@salesforce/apex/TM_ShipmentTrackerController.scanningInProgress";
import updateSecureBag from "@salesforce/apex/TM_ShipmentTrackerController.updateSecureBag";
import updateNormalBag from "@salesforce/apex/TM_ShipmentTrackerController.updateNormalBag";
import LoggedInUserHub from "@salesforce/apex/TM_ShipmentTrackerController.LoggedInUserHub";
import upadateScanBagsWithNoseal from "@salesforce/apex/TM_ShipmentTrackerController.upadateScanBagsWithNoseal";


const bagSet = new Set(); 

const columns = [
    
    { label: 'Secure Bag', fieldName: 'Name' }
    
];

/*const columns = [
    { label: 'Shipping Note Number', fieldName: 'Shipping_Note_Number__c' },
    { label: 'Secure Bag', fieldName: 'Secure_Bag__r.Name' },
    { label: 'Cargo Type', fieldName: 'Cargo_Type__c' },
    { label: 'Destination Hub', fieldName: 'Destination_Hub__c' }
];*/


export default class TmsShipmentTracker extends NavigationMixin(LightningElement) {
    
    @track barcodeScanner; 
    @track scanningOptions; 
    @track currentSecureBags;  
    @track isLocation = false;
    @track ishub = false;
    @track isAirport = false; 
    @track isVehicle = false;
    @track isLoading  = false;  
    @track updateSucessBag = [];
    @track updateMisroutedBag = []; 
    @track bagInformation ='';
    @track sealID = '';
    @track sealManualId = ''; 
    @track secureBagID = '';
    @track secureBagManualId = ''; 
    @track isSealIdManual = false;
    @track mainView = true;
    @track sealView = false;
    @track bagView = false;
    @track erorrmessage = 'Unknown erorr';
    @track bagCount = 0;
    @track exitButton = true;
    @track isCountMismatch = false;
    @track normalBagButton = false;
    @track bagLockStatus = '';
    @track isHubUser = false;
    @track options = [];
    @track isSealButtonDisable = false;
    @track isVaultId;
    @track isVehicleId;
    @track scanbag = true;
    @track columns = columns;
    @track bagArray =[];
    @track sealArray =[];
    @track totalBagLength;
    @track value = '';
    @track selectedBags;
    @track checkedBags = [];
    @track unique=[];
    @track consigneeName = '';
    @track UnseletedCheckIds = [];
    @track selectedBagRecord = '';
    @track selectedBagRecord1 = '';
    @track defaultAllBagRecords = [];
    @track tmpUnselectedSecureBagIds = [];
    @track tempArray = [];
    @track enableUnlockSealCompleteButton = true;
    
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ;  
        } else if (data) { 
            let profileName = data.fields.Profile.value.fields.Name.value; 
            if(profileName === EXECUTIVE_PROFILE_NAME){
                this.options = [
                    { label: '-- Select --', value: '' },
                    { label: 'Port', value: 'Port' } 
                ];
            }  else{
                this.options =  [
                    { label: '-- Select --', value: '' },
                    { label: 'Hub', value: 'Hub' },
                    { label: 'Port', value: 'Port' },
                    { label: 'Vehicle', value: 'Vehicle'},
                    { label: 'Vault', value: 'Vault'} 
                ];
            }        
        }
    } 

    connectedCallback() {

        this.isLoading = true;
        this.beginScanning(); 
         
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => { 
                SHIPMENT_TRACKING.Geocode__Latitude__s = position.coords.latitude;
                SHIPMENT_TRACKING.Geocode__Longitude__s = position.coords.longitude; 
            });
        } 

        this.buttonComete = true; 
        LoggedInUserHub().then(result=>{
            if(result == null){
                this.isHubUser = true;
                this.mainView = false;
                this.sealView = false;
                this.bagView = false;
                this.isCountMismatch = false;
            } 
        }).catch(error=>{
            if (error) {  
                this.isHubUser = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "WARNING ",
                        message: "You don't have the level of access required to complete this action. Please contact your administrator for help.",
                        variant: "warning"
                    })
                );
            } 
        }).finally(()=> {
            this.isLoading = false;
        });
        
    }

    /* checkAll() {
        var checkboxes = document.getElementsByName('selectedRecord');
        var checkAllCheckbox = document.getElementById('checkAll');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checkAllCheckbox.checked;
        }
    } */

    selectedCheckboxes(event){
        var checkValue = event.target.checked;
        console.log('Check box value ',checkValue);
        //console.log('Check box value defaultAllBagRecords ',this.defaultAllBagRecords);
        
        if(checkValue === true){
            this.selectedBagRecord = event.target.value;
            console.log('Selected Ids ',this.selectedBagRecord);
           
    
        }else {
            this.UnseletedCheckIds.push(event.target.value);
            
            /* this.tmpUnselectedSecureBagIds = this.UnseletedCheckIds;
            console.log('Unselected check Ids Array ',this.tmpUnselectedSecureBagIds); */
            this.tempArray.push(this.defaultAllBagRecords.filter(value => value.Secure_Bag__r.Id === event.target.value));
            //this.tmpUnselectedSecureBagIds = tempArray;
            console.log('checking unselected bags ',this.tempArray);    
        
        }

           
       
    }

    fetchSealBagByID(barcodeValue){
        this.isLoading = true;
        this.mainView = false;
        this.bagView = false;
        this.isHubUser = false;
        bagBySealId({
            bagId : barcodeValue
        }).then(data=>{ 
            this.bagInformation = JSON.parse(JSON.stringify(data));

            this.sealArray.push(this.bagInformation);
            //this.totalBagLength = this.sealArray.length;
            
            console.log('Scan Seal Record ',this.sealArray);
            if(this.bagInformation){
                if(this.bagInformation.typeOfBag ==="Seal-Bag"){
                    this.sealView = true;
                    this.bagCount = this.bagInformation.numberOfBag; 
                }else{
                    this.sealView = false;
                    this.isSealIdManual = true; 
                } 

                scanningInProgress({
                    bagData : this.bagInformation
                }).then(data=>{
                    if(data){ 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "Scanning completed.",
                                variant: "success"
                            })
                        );
                    }  
                }).catch(error =>{
                    if (error) { 
                        if (Array.isArray(error.body)) {
                            this.erorrmessage = error.body.map(e => e.message).join(', ');
                        } else if (typeof error.body.message === 'string') {
                            this.erorrmessage = error.body.message;
                        } 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Information",
                                message: this.erorrmessage,
                                variant: "Information"
                            })
                        );                        
                    }
                    this.mainView = true;
                    this.sealView = false;
                    this.bagView = false;
                    this.isSealIdManual = false; 
                    this.bagInformation = '';
                    this.bagCount = '';
                    
                }).finally(()=>{
                    
                    this.isLoading = false;
                    console.log('Spinner stop or not ',this.isLoading);
                });  
            }

        }).catch(error =>{
            if (error) { 
                if (Array.isArray(error.body)) {
                    this.erorrmessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.erorrmessage = error.body.message;
                } 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Information",
                        message: "You have entered invalid Seal Id",
                        variant: "Information"
                    })
                ); 
            }
            this.mainView = true;
            this.sealView = false;
            this.bagView = false;
            this.isSealIdManual = false;
            this.bagCount = '';
            
            this.bagInformation = '';
        }).finally(()=>{
            this.isLoading = false;
        });
    }
    
    fetchSecureBagByID(barcodeValue, bagData, bagType){ 
        this.isLoading = true;
        let bagmap = new Map(Object.entries(bagData)); 
        
        if(bagmap.has(barcodeValue)){
            this.currentSecureBags = bagmap.get(barcodeValue);

            // Check if Consignee_Name_TMS__r data is not available
            if (this.currentSecureBags.Shipment__r && this.currentSecureBags.Shipment__r.Consignee_Name_TMS__r) {
                this.currentSecureBags.consigneeName = this.currentSecureBags.Shipment__r.Consignee_Name_TMS__r.Name;
            } else {
                this.currentSecureBags.consigneeName = "";
            }


            if(this.bagArray.length > 0){
                    const tmpArray = this.bagArray.filter(value => value.Secure_Bag__r.Id === this.currentSecureBags.Secure_Bag__r.Id);
                    if(tmpArray.length > 0){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Alert: ",
                                message: "Secure Bag is already exist",
                                variant: "warning"
                            })
                        );
                        //alert("Secure Bag is already exist");
                    } else {
                        this.bagArray.push(this.currentSecureBags);
                        for(let i=0;i<this.bagArray.length;i++){
                            this.bagArray[i].checkId = "true";
                        }
                        this.checkedBags.push(this.currentSecureBags.Secure_Bag__r.Id);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: " Scanning complete.",
                                variant: "success"
                            })
                        ); 
                       
                    }
                } else {
                    this.bagArray.push(this.currentSecureBags);
                    for(let i=0;i<this.bagArray.length;i++){
                        this.bagArray[i].checkId = "true";
                    }
                   console.log('0casdadasdasd ',JSON.stringify(this.bagArray));
                   this.checkedBags.push(this.currentSecureBags.Secure_Bag__r.Id);
                  
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: " Scanning complete.",
                            variant: "success"
                        })
                    ); 
                }
                
                this.totalBagLength = this.bagArray.length;
                

               //this.bagArray.push(bagmap.get(barcodeValue));
            this.updateSucessBag.push(bagmap.get(barcodeValue));
            //this.defaultAllBagRecords = this.updateSucessBag;
            console.log('for checking updateSucessBag ',this.updateSucessBag);
            console.log('for checking updateSucessBag.size() ',this.updateSucessBag.length);
            
            if(this.bagCount == 0 || this.bagCount <0){
                this.bagCount = 0;
            }else{
                if(! bagSet.has(barcodeValue)){
                    this.bagCount--;
                }
            }
            bagSet.add(barcodeValue);
            this.isLoading = false;

        }else{ 
            console.log('for checking SHIPMENT_TRACKING : ',SHIPMENT_TRACKING);
         bagBySecureBagId({
                bagId : barcodeValue,
                trackingrecord : SHIPMENT_TRACKING,
                bagMode : bagType
            }).then(data=>{

                let result;
                if(data.shipmentRecordMap){ 
                    result = new Map(Object.entries(data.shipmentRecordMap));
                }                 
                
                this.currentSecureBags = result.get(barcodeValue);             
                //console.log('eeee for checking ',JSON.stringify(result.get(barcodeValue)));
                
                // Check if Consignee_Name_TMS__r data is not available
                if (this.currentSecureBags.Shipment__r && this.currentSecureBags.Shipment__r.Consignee_Name_TMS__r) {
                    this.currentSecureBags.consigneeName = this.currentSecureBags.Shipment__r.Consignee_Name_TMS__r.Name;
                } else {
                    this.currentSecureBags.consigneeName = "";
                }
                
                if(this.bagArray.length > 0){
                    const tmpArray = this.bagArray.filter(value => value.Secure_Bag__r.Id === this.currentSecureBags.Secure_Bag__r.Id);
                    if(tmpArray.length > 0){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Alert: ",
                                message: "Secure Bag is already exist",
                                variant: "warning"
                            })
                        );
                        //alert("Secure Bag is already exist");
                    } else {


                        if(bagType == 'Misrouted'){

                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Alert",
                                    message: "This Bag is not associated with this seal.",
                                    variant: "warning"
                                })
                            );
                            /* this.exitButton = false;
                            this.isSecureIdManual = true;
                            this.bagView = true;
                            this.sealView = false; 
                            this.mainView = false;
                            this.sealManualId = false; */ 
                        }else{
    
                            this.bagArray.push(this.currentSecureBags);
                            for(let i=0;i<this.bagArray.length;i++){
                                this.bagArray[i].checkId = "true";
                            }
                            
                            console.log('for checking bag array after 17. ',this.bagArray)
                        
                            
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: " Scanning complete.....",
                                variant: "success"
                            })
                        );
                        
                        }





                        /*this.bagArray.push(this.currentSecureBags);

                        for(let i=0;i<this.bagArray.length;i++){
                            this.bagArray[i].checkId = "true";
                        }
                        
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: " Scanning complete.",
                                variant: "success"
                            })
                        ); */
                       
                    }
                } else {

                    if(bagType == 'Misrouted'){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Alert",
                                message: "This Bag is not associated with this seal.",
                                variant: "warning"
                            })
                        );
                       /*  this.exitButton = false;
                        this.isSecureIdManual = true;
                        this.bagView = true;
                        this.sealView = false; 
                        this.mainView = false;
                        this.sealManualId = false;  */
                    }else{

                        this.bagArray.push(this.currentSecureBags);
                        for(let i=0;i<this.bagArray.length;i++){
                            this.bagArray[i].checkId = "true";
                        }
                        
                        console.log('for checking bag array after 17. ',this.bagArray)
                    
                        
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: " Scanning complete.....",
                            variant: "success"
                        })
                    );
                    
                    }

                    /*this.bagArray.push(this.currentSecureBags);

                    for(let i=0;i<this.bagArray.length;i++){
                        this.bagArray[i].checkId = "true";
                    }
                   console.log('0casdadasdasd ',JSON.stringify(this.bagArray));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: " Scanning completeddd.",
                            variant: "success"
                        })
                    ); */
                    this.isLoading = false;
                }
                
                this.totalBagLength = this.bagArray.length;
                console.log('currentSecureBags Data ',JSON.stringify(this.currentSecureBags));
                this.updateMisroutedBag.push(result.get(barcodeValue));
                //this.updateSucessBag.push(result.get(barcodeValue));
                console.log('for checking SHIPMENT_TRACKING befor upadateScanBagsWithNoseal ',SHIPMENT_TRACKING);
                if(bagType == 'Misrouted'){
                upadateScanBagsWithNoseal({     
                    trackingRecord : SHIPMENT_TRACKING,          
                    secureBagList : this.updateMisroutedBag
                });
                }


                console.log('updateMisroutedBag kjhkjhkjhskdfjhkjdhf ',this.updateMisroutedBag);
                this.defaultAllBagRecords = this.updateMisroutedBag;
                //console.log('Data selected for scanning complete ',this.defaultAllBagRecords);

                //this.updateMisroutedBag.push(this.currentSecureBags); 
                

                /*if(bagType == 'Misrouted'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Alert",
                            message: " : Missrouted Bag.",
                            variant: "warning"
                        })
                    );
                }*/
                /*
                this.exitButton = false;
                this.isSecureIdManual = true;
                this.bagView = true;
                this.sealView = false; 
                this.mainView = false;
                this.sealManualId = false; */
            }).catch(error =>{ 
                if (error) { 
                    if (Array.isArray(error.body)) {
                        this.erorrmessage = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.erorrmessage = error.body.message;
                    }  

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Alert: ",
                            message: this.erorrmessage,
                            variant: "warning"
                        })
                    );
                } 
            }).finally(()=>{
                this.isLoading = false;
            });
        } 
        

    }
    
    
    
    handleLocationChange(event) { 
        
        this.isLoading = true;

        if (event.target.value == 'Hub') { 
            this.ishub = false;
            this.isAirport = false;
            this.isVehicle = false;
            this.isVault = false;
            SHIPMENT_TRACKING.Hub__c = '';
            SHIPMENT_TRACKING.Location__c = event.target.value
            this.isLocation = true; 
            this.scanbag = true;
            this.enableUnlockSealCompleteButton = true;
            console.log('for checking SHIPMENT_TRACKING at start ',SHIPMENT_TRACKING);

        } else if (event.target.value == 'Port') {
            this.ishub = false;
            this.isVehicle = false;
            this.isVault = false;
            SHIPMENT_TRACKING.Airport__c = '';
            SHIPMENT_TRACKING.Location__c = event.target.value
            this.isAirport = true;
            this.isLocation = true; 
            this.scanbag = false;
            this.enableUnlockSealCompleteButton = false;

        } else if (event.target.value == 'Vehicle')
        {
            this.ishub = false;
            this.isAirport = false;
            this.isVault = false;
            SHIPMENT_TRACKING.BVC_Vehicle__c = '';
            SHIPMENT_TRACKING.Location__c = event.target.value
            this.isVehicle = true;
            this.isLocation = true;
            this.scanbag = true;
            this.enableUnlockSealCompleteButton = true;

        } else if (event.target.value =='Vault')
        {  this.ishub = false;
            this.isAirport = false; 
            this.isVehicle = false;
            SHIPMENT_TRACKING.Vaults__c= '';
            SHIPMENT_TRACKING.Location__c = event.target.value
            this.isVault = true;
            this.isLocation = true;
            this.scanbag = true;
            this.enableUnlockSealCompleteButton = true;
        }
         else { 
            this.ishub = false; 
            this.isAirport = false; 
            this.isVehicle = false;
            this.isVault = false;
            this.isLocation = false;
            SHIPMENT_TRACKING.Hub__c = ''; 
            SHIPMENT_TRACKING.Airport__c = '';
            SHIPMENT_TRACKING.BVC_Vehicle__c = '';
            SHIPMENT_TRACKING.Vaults__c = '';
            //SHIPMENT_TRACKING.Location__c = event.target.value;
            SHIPMENT_TRACKING.Location__c = 'Tansit Hub';
            this.scanbag = true;
            console.log('for checking SHIPMENT_TRACKING at start ',SHIPMENT_TRACKING);

        }

        if (event.target.value == 'Out for Delivery') {
            this.isSealButtonDisable = true;
        }else{
            this.isSealButtonDisable = false;
        }

        // Disable Spinner
        this.isLoading  = false;
    }

    handleHubChange(event) {        
        SHIPMENT_TRACKING.Hub__c = event.target.value; 
    }

    handleAirportChange(event) {
        SHIPMENT_TRACKING.Airport__c = event.target.value;
    
    }
    handleVehicleChange(event){
        SHIPMENT_TRACKING.BVC_Vehicle__c = event.target.value;
        //this.isVehicleId = event.target.value;
        
    }
    handleVaultChange(event) {        
        SHIPMENT_TRACKING.Vaults__c	= event.target.value; 
        //this.isVaultId = event.target.value;
       // console.log('record::'+this.isVaultId);
    }

    handleSealIDManualChange(event) { 
        this.sealManualId = event.target.value; 
        this.sealManualId = this.sealManualId.trim();
        if (this.sealManualId != '' && this.sealManualId != null) {
            this.sealID = this.sealManualId;  
            this.fetchSealBagByID(this.sealManualId);
          
        }  
    } 

    handleSecureManualChange(event){ 
        this.secureBagManualId = event.target.value; 
        this.secureBagManualId = this.secureBagManualId.trim();
        if (this.secureBagManualId != '' && this.secureBagManualId != null) {
            this.secureBagID = this.secureBagManualId;
            if(this.bagInformation.shipmentRecordMap && this.normalBagButton === false){ 
                this.fetchSecureBagByID(this.secureBagManualId,this.bagInformation.shipmentRecordMap,'Misrouted');
            } 

            if(this.normalBagButton === true){ 
                this.fetchSecureBagByID(this.secureBagManualId,'','bag');
            } 
        } 
        //this.secureBagManualId = '';
        this.handleResetForSecureBag(event)
    }



    handleResetForSecureBag(event)
    {
        event.target.value = '';
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
     
    }
    
    sealIDScanning() {
        this.isLoading  = true; 
        this.mainView = false;
        this.sealView = true; 
        this.bagView = false;
        this.isHubUser = false;
        this.isCountMismatch = false;

        if (this.barcodeScanner.isAvailable()) { 

            this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => { 
                this.sealID = scannedBarcode.value;
                this.isSealIdManual = false;
                this.isSecureIdManual = false; 
                if (this.sealID != '' && this.sealID != null) {
                    this.fetchSealBagByID(this.sealID); 
                }
                
            }).catch((erorr) => {
                //console.log("===== sealIDScanning Error ====",erorr); 
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
                this.sealManualId = '';
                this.sealView = true; 
                this.isSealIdManual = true;
                this.isSecureIdManual = false; 

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
             
            this.isSealIdManual = true;
            this.isSecureIdManual = false;
            this.sealView = true;           
        } 
        this.isLoading  = false;
    }

    unlocksealId() { 
        this.bagLockStatus = 'Unlock';
        this.isLoading  = true;
        this.normalBagButton = false;
        this.isSecureIdManual = true;
        this.bagView = true;
        this.sealView = false; 
        this.mainView = false;
        this.sealManualId = false;
        this.isCountMismatch = false; 
        this.isHubUser = false;

        if (this.barcodeScanner.isAvailable()) { 

            this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => { 
                this.secureBagID = scannedBarcode.value; 
                this.isSealIdManual = false;
                this.isSecureIdManual = false;
                if (this.secureBagID != '' && this.secureBagID != null) {
                    if(this.bagInformation.shipmentRecordMap){ 
                        this.fetchSecureBagByID(this.secureBagID, this.bagInformation.shipmentRecordMap,'Misrouted'); 
                    }
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
                this.isSealIdManual = false;
                this.isSecureIdManual = true;
                this.bagView = true;
                this.sealView = false; 
                this.mainView = false;
                this.sealManualId = false;  
                this.normalBagButton = false;

            }).finally(() => { 
                this.barcodeScanner.endCapture();               
                this.normalBagButton = false; 
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
            this.isSealIdManual = false;
            this.isSecureIdManual = true;
            this.bagView = true;
            this.sealView = false; 
            this.mainView = false;
            this.sealManualId = false;            
            this.normalBagButton = false;
            this.isLoading  = false; 
        } 
    }

    bagScanning() {  
        this.isLoading = true;
        this.normalBagButton = true;
        this.isSecureIdManual = true;
        this.bagView = true;
        this.sealView = false; 
        this.mainView = false;
        this.isCountMismatch = false;
        
        if (this.barcodeScanner.isAvailable()) {
            
            this.barcodeScanner.beginCapture(this.scanningOptions).then((scannedBarcode) => { 
                this.secureBagID = scannedBarcode.value; 
                this.isSealIdManual = false;
                this.isSecureIdManual = false; 
                if (this.secureBagID != '' && this.secureBagID != null) { 
                    this.fetchSecureBagByID(this.secureBagID, '','bag'); 
                } 
                
            }).catch((erorr) => {  
                if (erorr) {  
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Information ",
                            message: "Secure bag record not found. Requesting you to re-scan or enter manually."+JSON.stringify(erorr),
                            variant: "information"
                        })
                    );
                } 
                this.barcodeScanner.endCapture(); 
                this.bagView = true;
                this.sealView = false; 
                this.mainView = false;
                this.sealManualId = false;  
                this.isSealIdManual = false;
                this.isSecureIdManual = true;

            }).finally(() => { 
                this.barcodeScanner.endCapture();               
                this.normalBagButton = true;
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
            this.isSecureIdManual = true;
            this.normalBagButton = true;
            this.isSealIdManual = false; 
            this.bagView = true;
            this.sealView = false; 
            this.mainView = false;
            this.sealManualId = false; 
            this.isLoading  = false;
        } 
        
    }
    
    scanningCompleted() { 

        LoggedInUserHub().then(result=>{
            console.log(`hub iwerwerd hydrabad Scanning Complete ${result}`);
            this.hubId = result;
            
        }).catch(error=>{
            console.log(`error occure ${error}`);
        });


        this.isLoading = true;
        if(this.bagCount != 0 &&  this.bagLockStatus != ''){
            this.isCountMismatch = true;
            this.isSecureIdManual = false;
            this.bagView = false;
            this.sealView = false; 
            this.mainView = false;
            this.sealManualId = false;            
            this.bagCount = this.bagInformation.numberOfBag - this.bagCount;
            this.isLoading = false;
        }else{ 
            updateSecureBag({
                trackingRecord : SHIPMENT_TRACKING,
                secureBagList : this.updateSucessBag.length > 0 ? this.updateSucessBag : Object.values(this.bagInformation.shipmentRecordMap) ,
                shipmetWrapData : this.bagInformation,
                lockStatus : this.bagLockStatus
            }).then(data=>{ 

                let misRoutArray =[];
          // this.misRoutArray =[];
            let routArray = [];
            console.log(`for checking hub id after debug ${this.hubId}`);
            let tmpHubId = this.hubId;
            for(let i=0 ;i<this.bagArray.length;i++){
                let obj = new Object(this.bagArray [i]);
                console.log(`id chekcing now ${obj.Shipment__r.Destination_Hub__c}`);
                //console.log('for checking obj.Seal_Id__r.Name ',obj.Seal_Id__r.Name);
                //console.log('for checking obj.Seal_Id__r.Name ',obj.Seal_Id__r.Name);
                if((tmpHubId === obj.Shipment__r.Destination_Hub__c) || (tmpHubId === obj.Shipment__r.Origin_Hub__c)){
                    routArray.push(obj.Secure_Packaging_Identifier__c);
                }else{
                    misRoutArray.push(obj.Secure_Packaging_Identifier__c);
                }
                
            }
            console.log(`for check me misrouted check value ${misRoutArray}`);
            console.log(`for check me routed check value new ${routArray}`);
            if(routArray.length>0){
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: 'Scanning Completed for Bags '+routArray,
                    variant: "success"
                })
            );   
            }
            
            if(misRoutArray.length>0){
                    this.dispatchEvent(
                new ShowToastEvent({
                    title: "Alert",
                    message: 'Misrouted Bags : '+ misRoutArray +' Scanned',
                    variant: "Warning"
                })
            ); 
            }
        
            this.bagLockStatus ='';  
            }).catch(error=>{ 
                if (error) { 
                    if (Array.isArray(error.body)) {
                        this.erorrmessage = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.erorrmessage = error.body.message;
                    } 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Information",
                            message: this.erorrmessage,
                            variant: "Information"
                        })
                    );
                    
                }   

            }).finally(() => { 
                this.isCountMismatch = false;
                this.isSecureIdManual = false;
                this.bagView = false;
                this.sealView = false; 
                this.mainView = true;
                this.sealManualId = false;
                this.bagCount = '';
                this.bagInformation = '';
                this.bagInformation ='';
                this.sealID = '';
                this.sealManualId = '';
                this.secureBagID = '';
                this.secureBagManualId = '';
                this.currentSecureBags = '';
                this.totalBagLength = '';
                this.updateSucessBag = [];
                this.normalBagButton = false;
                this.isHubUser = false;
                this.isLoading = false;
                this.isSealButtonDisable = false;
                this.bagArray = [];
                this.sealArray = [];
                
                window.location.reload();
            });
        } 
    } 

    cancelProcess(){
        this.isCountMismatch = false;
        this.isSecureIdManual = true;
        this.bagView = true;
        this.sealView = false; 
        this.mainView = false;
        this.sealManualId = false; 
        this.normalBagButton = false;
        this.updateSucessBag = [];
        this.isHubUser = false;
    }

    updateBag(){
        
        LoggedInUserHub().then(result=>{
            console.log(`hub id updateBag ${result}`);
            this.hubId = result;
            
        }).catch(error=>{
            console.log(`error occure ${error}`);
        });

        this.isLoading = true;
        console.log('for checking SHIPMENT_TRACKING : ',SHIPMENT_TRACKING);

        updateSecureBag({
            trackingRecord : SHIPMENT_TRACKING,
            secureBagList : this.updateSucessBag.length > 0 ? this.updateSucessBag : Object.values(this.bagInformation.shipmentRecordMap) , 
            shipmetWrapData : this.bagInformation,
            lockStatus : this.bagLockStatus
        }).then(data=>{ 
           

            let misRoutArray =[];
       //this.misRoutArray =[];
            let routArray = [];
            console.log(`for checking hub id after debug ${this.hubId}`);
            let tmpHubId = this.hubId;
            for(let i=0 ;i<this.updateSucessBag.length;i++){
                let obj = new Object(this.updateSucessBag[i]);
                console.log(`id chekcing now ${obj.Shipment__r.Destination_Hub__c}`);
                
                if((tmpHubId === obj.Shipment__r.Destination_Hub__c) || (tmpHubId === obj.Shipment__r.Origin_Hub__c)){
                    routArray.push(obj.Secure_Packaging_Identifier__c);
                }else{
                    misRoutArray.push(obj.Secure_Packaging_Identifier__c);
                }
                
            }
            console.log(`for check me misrouted check value ${misRoutArray}`);
            console.log(`for check me routed check value new ${routArray}`);
            if(routArray.length>0){
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: 'Scanning Completed for Bags '+routArray,
                    variant: "success"
                })
            );   
            }
            
            if(misRoutArray.length>0){
                    this.dispatchEvent(
                new ShowToastEvent({
                    title: "Alert",
                    message: 'Misrouted Bags : '+misRoutArray+' Scanned',
                    variant: "Warning"
                })
            ); 
            }
              
        }).catch(error=>{ 
            if (error) { 
                if (Array.isArray(error.body)) {
                    this.erorrmessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.erorrmessage = error.body.message;
                } 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Information",
                        message: this.erorrmessage,
                        variant: "Information"
                    })
                );
                
            } 
        }).finally(() => { 
            this.isCountMismatch = false;
            this.isSecureIdManual = false;
            this.bagView = false;
            this.sealView = false; 
            this.mainView = true;
            this.sealManualId = false;
            this.bagCount = 0;
            this.bagInformation = '';
            this.bagInformation ='';
            this.sealID = '';
            this.sealManualId = '';
            this.secureBagID = '';
            this.secureBagManualId = '';
            this.currentSecureBags = '';
            this.normalBagButton = false;
            this.isHubUser = false;
            this.updateSucessBag = [];
            this.isLoading = false;

            window.location.reload();
        }); 
        
    }



    scanningEnd() { 

        /* //obj1 => !arr2.some(obj2 => obj1.id === obj2.id)
        const finalBagsToScan = this.updateMisroutedBag.filter(entries => !(this.tempArray.includes(entries.Secure_Bag__r.Id)));

        //const finalBagsToScan = this.updateMisroutedBag.filter(entries => !this.tempArray.some(entries1 => entries.Secure_Bag__r.Id === entries1.Secure_Bag__r.Id));
        console.log('finalBagsToScan data ',finalBagsToScan); */

        LoggedInUserHub().then(result=>{
            console.log(`hub id updateNormalBag ${result}`);
            this.hubId = result;
            
        }).catch(error=>{
            console.log(`error occure ${error}`);
        });
        
        console.log('this.updateMisroutedBag === >',this.updateMisroutedBag);
        this.isLoading = true;
        if(this.bagCount != 0){
            this.isCountMismatch = true;
            this.isSecureIdManual = false;
            this.bagView = false;
            this.sealView = false; 
            this.mainView = false;
            this.sealManualId = false;
            this.bagCount = this.bagInformation.numberOfBag - this.bagCount;
            this.isLoading = false;
        }else{
            console.log(`@@@trackimg record data is ${JSON.stringify(SHIPMENT_TRACKING)}`);
            console.log(`@@@ secure bag list  ${JSON.stringify(this.updateMisroutedBag)}`);
            updateNormalBag({
                trackingRecord : SHIPMENT_TRACKING,
                secureBagList : this.updateMisroutedBag
                
                //isVaults : this.isVaultId,
                //isVehicles : this.isVehicleId
            }).then(data=>{ 
                console.log('data dsbhjdbsfj',data);

                this.misRoutArray =[];
            let routArray = [];
            console.log(`for checking hub id after debug ${this.hubId}`);
            let tmpHubId = this.hubId;
            for(let i=0 ;i<this.updateMisroutedBag.length;i++){
                let obj = new Object(this.updateMisroutedBag[i]);
                console.log(`id chekcing now ${obj.Shipment__r.Destination_Hub__c}`);
                console.log(`id chekcing now ${obj.Shipment__r.Origin_Hub__c}`);
                
                if((tmpHubId === obj.Shipment__r.Destination_Hub__c) || (tmpHubId === obj.Shipment__r.Origin_Hub__c)){
                    routArray.push(obj.Secure_Packaging_Identifier__c);
                }else{
                    this.misRoutArray.push(obj.Secure_Packaging_Identifier__c);
                }
                
            }
            console.log(`for check me misrouted check value ${this.misRoutArray}`);
            console.log(`for check me misrouted check value new ${routArray}`);
            if(routArray.length>0){
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: 'Scanning Completed for Bags'+routArray,
                    variant: "success"
                })
            );   
            }
            
            if(this.misRoutArray.length>0){
                    this.dispatchEvent(
                new ShowToastEvent({
                    title: "Alert",
                    message: 'Misrouted Bags '+this.misRoutArray+' Scanned',
                    variant: "Warning"
                })
            ); 
            }
                
            }).catch(error=>{ 
                if (error) { 
                    if (Array.isArray(error.body)) {
                        this.erorrmessage = error.body.map(e => e.message).join(', ');
                        console.log('Error Message 1 ===> ',this.erorrmessage);
                    } else if (typeof error.body.message === 'string') {
                        this.erorrmessage = error.body.message;
                        console.log('Error Message 2 ===> ',this.erorrmessage);
                    } 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Information",
                            message: this.erorrmessage,
                            variant: "Information"
                        })
                    );
                    
                }  

            }).finally(() => { 
                this.isCountMismatch = false;
                this.isSecureIdManual = false;
                this.bagView = false;
                this.sealView = false; 
                this.mainView = true;
                this.sealManualId = false;
                this.bagCount = 0;
                this.bagInformation = '';
                this.bagInformation ='';
                this.sealID = '';
                this.sealManualId = '';
                this.secureBagID = '';
                this.secureBagManualId = '';
                this.currentSecureBags = '';
                this.normalBagButton = false;
                this.updateSucessBag = [];
                this.isHubUser = false;
                this.isLoading = false;
                this.isSealButtonDisable = false;
                this.bagArray =[];
                this.totalBagLength = '';
                this.sealArray = [];

                window.location.reload();
            });
        } 
    } 
    
}