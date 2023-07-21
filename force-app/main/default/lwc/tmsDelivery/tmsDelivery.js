import { LightningElement, api, track, wire } from 'lwc';
import allSecureBagGet from "@salesforce/apex/TMS_DeliveryController.allSecureBagGet"; 
import insertUpdateRecord from "@salesforce/apex/TMS_DeliveryController.insertUpdateRecord"; 
import SHIPMENT_TRACKING from '@salesforce/schema/Shipment_Tracking__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import signaturePadURL from '@salesforce/resourceUrl/signature_pad';
import saveSign from '@salesforce/apex/TSM_SignatureHelper.saveSign'; 
import getshipmetID from '@salesforce/apex/TSM_SignatureHelper.getshipmetID';
import DELIVERY from '@salesforce/schema/Delivery__c';


const columns = [
    { label: 'Shipping Note Number', fieldName: 'Shipping_Note_Number__c', type: 'text' },
    { label: 'Bag', fieldName: 'Secure_Packaging_Identifier__c', type: 'text' } 
];

 

export default class TmsDelivery extends NavigationMixin(LightningElement){ 

    @track columns = columns;
    @api recordId;
    @track bagRecord;
    @track selectedbag;
    @track trackingInsert;
    @track shipmentView = true;
    @track idSignatureView = false;
    @track isLoading = false;
    @track erorrmessage = '';
	@track trackinglist;
	
	@api trackinglist;
    sigPadInitialized = false;
    canvasWidth = 400;
    canvasHeight = 200;
    @track shipmentRecord;
    @track consigneeName = '';
    @track addressId = '';
    @track isLoad = false;
    @track shipmentId;
    @track tempRecord =[];
	@track deliveryId;
    @track SBID;
	
	handleConsigneeNameChange(event) {
        DELIVERY.Consignee_Name__c = event.target.value; 
    }

    handleConsigneeDesignationChange(event) {
        DELIVERY.Consignee_Designation__c = event.target.value;
    }
	
	
	@wire (getshipmetID,{recId: '$recordId'})
	wiredshipmentId({data, error}){ 
		if(data) {
            //this.shipmentId = data;

            this.shipmentId  = data.Shipment__r.Id;
            this.deliveryId = data.Id;
			this.error = undefined;
		}else {
            console.log('you are in error')
			this.data = undefined;
			this.error = error;
		}
	}	

    connectedCallback(){

        this.isLoading = true;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => { 
                SHIPMENT_TRACKING.Geocode__Latitude__s = position.coords.latitude;
                SHIPMENT_TRACKING.Geocode__Longitude__s = position.coords.longitude; 
            });
        }

        allSecureBagGet({
            deliveryId : this.recordId
        }).then(result=>{
						console.log('record Id :',this.recordId);
            this.bagRecord =   result;
            console.log('11.SecureBag :',result);
            for(let key in result)
            {
                console.log('VAL :'+result[key]);
            }
            console.log('11.SecureBag :',result[0].Id);
            this.SBID = result[0].Id;
            this.isLoading = false;

        }).catch(error=>{
            if (error) { 
                if (Array.isArray(error.body)) {
                    this.erorrmessage = erorr.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.erorrmessage = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Alert",
                        message: "Alert : "+this.erorrmessage+".",
                        variant: "warning"
                    })
                ); 
            }

            this.isLoading = false;
        }).finally(()=>{
            this.isLoading = false;
            this.idSignatureView = false;
        });
    }

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedbag =selectedRows;
       console.log("Selected Record ",this.selectedbag);
    }

    fileDetails(event){ 
        this.isLoading = true;
        
        this.idSignatureView = true;
        this.shipmentView = false;
        this.isLoading = false;
        this.callingAnotherMethod();

    }
	
	
	
	callingAnotherMethod(){
		this.isLoad = true;
        if (this.sigPadInitialized) {
            return;
        }
        this.sigPadInitialized = true;

        Promise.all([
            loadScript(this, signaturePadURL)
        ])
            .then(() => {
                this.initialize();
            })
            .catch(erorr => { 
                if (erorr) { 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: "Alert : Unknown Error. (while reload Check Setting)",
                            variant: "warning"
                        })
                    ); 

                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: { 
                            objectApiName: 'Delivery__c', 
                            actionName: 'list'
                        },
                        state: {
                            filterName: '00B5g00000WYOHcEAP'
                        },
                    });
                }
            }).finally(()=>{
                this.isLoad = false;
            });

	}
	
	    initialize() {
        const canvas = this.template.querySelector('canvas.signature-pad');
        this.signaturePad = new window.SignaturePad(canvas);
    }
    
	
	handleClick() {

        this.isLoad = true;


        let tempRecord = [];         

        this.selectedbag.forEach((item, index) => {
            tempRecord.push(item);
          });

         
        console.log("Selected A Record ",tempRecord);

        console.log('Hi you are in handle click');
        insertUpdateRecord({
            trackingRecord : SHIPMENT_TRACKING,
            secureBagList : tempRecord
            
        }).then(recordData =>{
            console.log("Selected B Record ",tempRecord);
            this.trackingInsert = recordData; 
						console.log("Selected C Record ",JSON.stringify(recordData));
                        console.log("Selected D Record ",this.trackingInsert);
            this.dispatchEvent(
                this.callingSaveSignMethod()
                /* new ShowToastEvent({
                    title: "Success",
                    message: "Scanning completed.",
                    variant: "success"
                }) */
            );  
            
			
			
        }).catch(erorr=>{
            console.log("Selectederorr ",erorr);
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
            this.isLoading = false;
            this.idSignatureView = false;
            this.shipmentView = true;

        }).finally(()=>{
            this.isLoading = false;
            
        });


        
            

        
    }


    callingSaveSignMethod(){
        var convertedDataURI = this.signaturePad.toDataURL().replace(/^data:image\/(png|jpg);base64,/, "");
         
        saveSign({
            strSignElement: convertedDataURI,
            recId : this.recordId,
            deliveryData : DELIVERY,
            trackingList: this.trackingInsert
        }) .then(result => { 
             console.log('Save Sign is working.');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Scanning Completed & File created with Signature',
                    variant: 'success',
                }),
            );

            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: { 
                    objectApiName: 'Delivery__c', 
                    actionName: 'list'
                },
                state: {
                    filterName: '00B5g00000WYOHcEAP'
                },
            });

            eval("$A.get('e.force:refreshView').fire();");

        }).catch(erorr => { 
            console.log("----- Error ------",erorr );
            if (erorr) { 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Alert : Record Saved Completed and Unknown Error. (while reload component)",
                        variant: "warning"
                    })
                );
                
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: { 
                        objectApiName: 'Delivery__c', 
                        actionName: 'list'
                    },
                    state: {
                        filterName: '00B5g00000WYOHcEAP'
                    },
                });
            }
        }).finally(()=>{
            this.isLoad = false;
            this.shipmentRecord;
            this.consigneeName = '';
            this.addressId = '';
        });  
        

    }


 	
	fileuploaddone(event) {
        
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        console.log('FILE UPLOADED');

        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';  
            console.log('FILE UPLOADED Name :'+uploadedFiles[i].name);          
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        ); 

    }
	
	
}