/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-11-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TMS_DeliverScanner {

    @AuraEnabled
    public static Integer allSecureBagGet(String addressID){
        try { 
           // // System.debug('============= addressID ====== '+addressID);
            Secure_Bag__c [] secureBag = [
                SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c,Shipment__r.Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Shipping_Note_Number__c, Cargo_Type__c, Current_Destination_City__c, Destination_Hub__c, Secure_Bag__r.Name 
                FROM Secure_Bag__c 
                WHERE Shipment__r.Destination_Address_Name__c =: addressID AND Shipment__r.Tracking_Status__c = 'Out for Delivery'
                ]; 
             
            
            return secureBag.size() > 0 ?secureBag.size() : 0 ; 
            
        } catch (Exception e) { 
            throw new AuraHandledException('\n - '+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Secure_Bag__c secureBagGet(String secureBagId, String addressID){
        try { 
           // // System.debug('============= addressID ====== '+addressID);
            Secure_Bag__c secureBag = [
                SELECT Id, Name , Shipment__c,Shipment__r.Number_of_Packages__c,Shipment__r.Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Shipping_Note_Number__c, Cargo_Type__c, Current_Destination_City__c, Destination_Hub__c, Secure_Bag__r.Name 
                FROM Secure_Bag__c 
                WHERE Secure_Bag__r.Name =: secureBagId
                LIMIT 1 ]; 
            
           // // System.debug('============= addressID ====== '+addressID);
           // // System.debug('============= secureBag ====== '+secureBag);
            if(secureBag != null ){
                if(secureBag.Shipment__r.Destination_Address_Name__c != addressID){
                    throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');
                }
            }else{
                throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');
            }

            return secureBag; 
            
        } catch (Exception e) {
           // // System.debug('err: '+e.getLineNumber()+e.getMessage());
            throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');
        }
    } 
    
    @AuraEnabled
    public static void insertUpdateRecord(Shipment_Tracking__c shipmentTrackingrecord, Secure_Bag__c secureBagRecord, String shippingNoteNumber){
        
        try {
            //// System.debug('1: '+secureBagRecord.Shipment__r.Shipping_Note_Number__c + ' 2: '+shippingNoteNumber);
          //  if(secureBagRecord.Shipment__r.Shipping_Note_Number__c == shippingNoteNumber){
                if(secureBagRecord != null && shipmentTrackingrecord != null){
                    
                    Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();
                    shipmentTrackingrecord.Shipment__c = secureBagRecord.Shipment__c; 
                    shipmentTrackingrecord.Scan_Time__c = DateTime.now(); 
                    shipmentTrackingrecord.Location__c = 'Delivered';
                    Database.insert( shipmentTrackingrecord); 
                }
                
                if(secureBagRecord != null ){ 
                    Secure_Bag__c tempbag = new Secure_Bag__c ();
                    tempbag.Id = secureBagRecord.Id;
                    tempbag.Current_Scan_Loction__c = shipmentTrackingrecord.Location__c; 
                    tempbag.Current_Scan_Hub__c =shipmentTrackingrecord.Hub__c;
                    tempbag.Current_Scan_Date_and_Time__c = DateTime.now();
                    tempbag.Tracking__c = shipmentTrackingrecord.Id;
                    tempbag.Current_Scan_Airport__c = shipmentTrackingrecord.Airport__c;
                     
                    Database.update(tempbag);  
                }else{
                    throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');
                } 
          /*  }else{
                
                throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');
            } */
        } catch (Exception e) {
           // // System.debug('line: '+e.getLineNumber()+' msg:'+e.getMessage());
           throw new AuraHandledException( '\n - '+ e.getMessage());
        }
    }
    
    @TestVisible class SecureBag{
        
        @AuraEnabled
        public Secure_Bag__c secureBagRecord {get;set;}
        
        @AuraEnabled
        public Integer numberofBag {get;set;} 
        
        @AuraEnabled
        public Integer bagCount {get;set;} 
    }
    
}