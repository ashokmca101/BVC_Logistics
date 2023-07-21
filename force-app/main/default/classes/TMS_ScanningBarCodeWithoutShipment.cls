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
public without sharing class TMS_ScanningBarCodeWithoutShipment {
    
    @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shippingNoteNumber, String pickupID){
        try {
            
            //System.debug('=============pickupID: ' + pickupID);
            //System.debug('=============shippingNoteNumber: ' + shippingNoteNumber);
            Shipment__c  shipmentRecord = new Shipment__c();
            
            Shipment__c [] tempDate = [
                
                SELECT ID, Name, Origin_Pincode__c,Number_of_Packages__c,Destination_Pincode__c,Customer_Product_Category__c,Shipping_Note_Number__c  
                FROM Shipment__c  
                WHERE Shipping_Note_Number__c =: shippingNoteNumber AND 
                Pickup__c =: pickupID  
                WITH SECURITY_ENFORCED LIMIT 1];
            
            //System.debug('=============tempDate: ' + tempDate);
            
            return tempDate.size() > 0 ? tempDate[0] : null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Shipment__c createShipmentRecord(Shipment__c shipmentRecord , String   pickupId, String sNoteNumber  ){
         try {
        
        //System.debug('======createShipmentRecord======'+shipmentRecord);   
        //System.debug('======pickupId======'+pickupId); 
        //System.debug('======pickupId======'+sNoteNumber);
        //System.debug('dest: '+shipmentRecord.Destination_Address_Name__c);
        
        Pickup__c [] pickupRecord = [SELECT Customer__c, Shipper_Address__c, Shipper_Name__c 
                                     FROM Pickup__c 
                                     WHERE Id =:pickupId 
                                     WITH SECURITY_ENFORCED
                                    ];
        
        // Secure_Packaging__c
        
        Secure_Packaging__c securePackagingRecord = [ 
            SELECT Id, Name, Shipment__c,Status__c, RecordType.Name   
            FROM Secure_Packaging__c 
            WHERE Name =: sNoteNumber LIMIT 1
            
        ];
        
        if(securePackagingRecord != null){
            
            if(securePackagingRecord.RecordType.Name == 'Shipping Label' && securePackagingRecord.Status__c == 'Available'){
                if(shipmentRecord != null && pickupRecord != null){ 
                    shipmentRecord.Customer__c=  pickupRecord[0].Customer__c;
                    shipmentRecord.Pickup__c = pickupRecord[0].Id;
                    shipmentRecord.Shipping_Note_Number__c = sNoteNumber;
                    shipmentRecord.Origin_Address_Name__c = pickupRecord[0].Shipper_Address__c;
                    shipmentRecord.Shipper_Name_TMS__c = pickupRecord[0].Shipper_Name__c;
                    shipmentRecord.Shipment_Created_Through__c = 'Mobile App';
                    
                    Database.insert(shipmentRecord); 
                    
                    securePackagingRecord.Status__c = 'Consumed';
                    securePackagingRecord.Shipment__c = shipmentRecord.Id;
                    if(shipmentRecord.Id != null){
                        Database.Update(securePackagingRecord);
                    } 
                }
            }else{
                throw new AuraHandledException('shipping label is tagged with another pickup request.');
            } 
        } 
        
        
        //System.debug('======shipmentRecord======'+shipmentRecord);
        return shipmentRecord; 
        
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
            //System.debug('=============== Exception ======= : '+e);
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    @AuraEnabled
    public static void createTrackingRecord(Shipment_Tracking__c shipmentTrackingRecord , String shipmentId , List<Secure_Bag__c> secureBaglist){
        try {
            
            //System.debug('=========secureBaglist=========='+secureBaglist);
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
    
    
    public class SecureBagWrapper{
        
        @AuraEnabled
        public String bagId{get;set;} 
        
        @AuraEnabled
        public Secure_Bag__c secureBag {get;set;}
        
        
    }
}