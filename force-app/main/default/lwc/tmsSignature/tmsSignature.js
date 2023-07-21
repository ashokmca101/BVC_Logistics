import { LightningElement,api,track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import signaturePadURL from '@salesforce/resourceUrl/signature_pad';
import saveSign from '@salesforce/apex/TSM_SignatureHelper.saveSign'; 
import getshipmetID from '@salesforce/apex/TSM_SignatureHelper.getshipmetID';

import DELIVERY from '@salesforce/schema/Delivery__c';
import { NavigationMixin } from 'lightning/navigation'; 

export default class TmsSignature extends NavigationMixin(LightningElement) {
    @api recordid;
    @api trackinglist;
    sigPadInitialized = false;
    canvasWidth = 400;
    canvasHeight = 200;
    @track shipmentRecord;
    @track consigneeName = '';
    @track addressId = '';
    @track isLoad = false;
    @track shipmentId;
    @track deliveryId;

    handleConsigneeNameChange(event) {
        DELIVERY.Consignee_Name__c = event.target.value; 
    }

    handleConsigneeDesignationChange(event) {
        DELIVERY.Consignee_Designation__c = event.target.value;
    }

    @wire (getshipmetID,{recId: '$recordid'})
	wiredshipmentId({data, error}){ 
		if(data) {
			//this.shipmentId = data;
            this.shipmentId  = data.Shipment__r.Id;
            this.deliveryId = data.Id;
            console.log('Delivery Id :'+this.deliveryId);
			this.error = undefined;
		}else {
			this.accounts =undefined;
			this.error = error;
		}
	}

    connectedCallback() {
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
        
        var convertedDataURI = this.signaturePad.toDataURL().replace(/^data:image\/(png|jpg);base64,/, "");
         
        saveSign({
            strSignElement: convertedDataURI,
            recId : this.recordid,
            deliveryData : DELIVERY,
            trackingList: this.trackinglist
        }) .then(result => { 
             
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'File created with Signature',
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
        console.log('11.<==> uploadedFiles :'+uploadedFiles);

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
}