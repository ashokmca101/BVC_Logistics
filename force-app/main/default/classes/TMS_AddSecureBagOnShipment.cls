/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class TMS_AddSecureBagOnShipment {
     
    @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shipmentRecordId){
        try { 

            //System.debug('=============shippingNoteNumber: ' + shipmentRecordId);
            Shipment__c  shipmentRecord = new Shipment__c();

            Shipment__c [] tempDate = [
                SELECT ID, Name, Origin_Pincode__c,Number_of_Packages__c,Destination_Pincode__c,Customer_Product_Category__c,Shipping_Note_Number__c  
                FROM Shipment__c  
                WHERE Id =: shipmentRecordId
                LIMIT 1];

            //System.debug('=============tempDate: ' + tempDate);

            return tempDate.size() > 0 ? tempDate[0] : null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    @AuraEnabled
    public static Secure_Bag__c createSecureBagRecords(String bagId , String shipmentID ) {

        //System.debug('=============== bagId ======= : '+bagId);
        //System.debug('=============== secureBag ======= : '+shipmentID);
        try { 
            Secure_Bag__c secureBag = new Secure_Bag__c();

            Secure_Packaging__c securePackaging = [
                SELECT Id, Name, Shipment__c,Status__c, RecordType.Name  
                FROM Secure_Packaging__c 
                WHERE Name =: bagId AND RecordType.Name ='Secure Bag' LIMIT 1
            ];

            if(securePackaging != null && securePackaging.Status__c == 'Available' ){ 
                if(shipmentID != null && shipmentID != ''  && shipmentID != 'null'){
                    secureBag.Shipment__c = shipmentID;
                    secureBag.Current_Scan_Loction__c = 'Picked Up';
                    secureBag.Current_Scan_Date_and_Time__c =DateTime.now();
                    secureBag.Secure_Bag__c =  securePackaging.Id; 
    
                } 

                if(secureBag != null){
                    Database.insert(secureBag); 
                    securePackaging.Status__c = 'Consumed'; 
                    securePackaging.Shipment__c = shipmentID; 
                    Database.update(securePackaging); 
                }

            } else{
                throw new AuraHandledException('Secure Bag is tagged with another shipmment.');
            } 

            return secureBag;

        } catch (Exception e) {
            //System.debug('line: '+e.getLineNumber()+' err: '+e);
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    @AuraEnabled
    public static void createTrackingRecord(Shipment_Tracking__c shipmentTrackingRecord , String shipmentId , List<Secure_Bag__c> secureBaglist){
        try {

            System.debug('=========secureBaglist=========='+secureBaglist);
            if(shipmentTrackingRecord != null){  
                shipmentTrackingRecord.Shipment__c = shipmentId != null ? shipmentId : '';
                shipmentTrackingRecord.Scan_Time__c = DateTime.now(); 
                shipmentTrackingRecord.Location__c = 'Picked Up'; 
                Database.insert(shipmentTrackingrecord); 

                if(shipmentTrackingrecord.Id != null ){
                    for(Secure_Bag__c secureBag : secureBaglist){
                        secureBag.Tracking__c = shipmentTrackingrecord.Id;
                    }

                    Database.update(secureBaglist);
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static void updateshipmentAndPickup( String shipmentId  ){
       // try {

            //System.debug('=========shipmentId=========='+shipmentId);
            if(shipmentId != null && shipmentId != ''){  
                Shipment__c shipmentRecord = new Shipment__c();
                shipmentRecord.Id = shipmentId;
                shipmentRecord.Tracking_Status__c = 'Picked Up';
                Database.update(shipmentRecord);
                
                Pickup__c [] pickupRecord  = [SELECT Id, Shipment__c , Pickup_Status__c FROM Pickup__c WHERE Shipment__c =: shipmentId LIMIT 1];

                if(pickupRecord.size() > 0){
                    Pickup__c pickup = new Pickup__c();
                    pickup.Id = pickupRecord[0].Id;
                    pickup.Pickup_Status__c = 'Completed';
                    Database.update(pickup);
                }
            }
            
    //    } catch (Exception e) {
    //        throw new AuraHandledException(e.getMessage());
    //    }
    }

    
    public class SecureBagWrapper{

        @AuraEnabled
        public String bagId{get;set;} 

        @AuraEnabled
        public Secure_Bag__c secureBag {get;set;}
        
        
    }
}