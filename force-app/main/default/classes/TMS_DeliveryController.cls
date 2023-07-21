/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TMS_DeliveryController {

    @AuraEnabled
    public static List<Secure_Bag__c> allSecureBagGet(String deliveryId){
        String currentUserId = UserInfo.getUserId();
        Set<Id> ShipmentId = new Set<Id>();
        List<Secure_Bag__c> secureBagList  = new List<Secure_Bag__c>();

        try {

            Delivery__c [] deliveryArray = [
                SELECT Id, Shipment__c, Status__c, OwnerId, Address__c 
                FROM Delivery__c
                WHERE ID =: deliveryId AND
                    OwnerId =: currentUserId 
            ];

            if(deliveryArray.size() > 0){
                for(Delivery__c delivery : [
                    SELECT Id, Shipment__c, Status__c, OwnerId, Address__c 
                    FROM Delivery__c
                    WHERE Address__c =: deliveryArray[0].Address__c AND
                        Status__c = 'Accepted' AND 
                        OwnerId =: currentUserId
                ]){
                    ShipmentId.add(delivery.Shipment__c);
                }
            }else{
                throw new AuraHandledException('\n - No Record Found');
            } 
             
            if(ShipmentId.size() > 0){
                secureBagList = [
                    SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                    FROM Secure_Bag__c 
                    WHERE Current_Scan_Loction__c != 'Delivered' AND
                    Shipment__c IN: ShipmentId
                ]; 

            }         
                System.debug('secure bag status : '+secureBagList);
                return secureBagList.size() > 0 ? secureBagList : null ;  
 
            
        } catch (Exception e) { 
            throw new AuraHandledException('\n - No Record Found');
        }
    } 

    @AuraEnabled 
    public static List<Shipment_Tracking__c> insertUpdateRecord(Shipment_Tracking__c trackingRecord, List<Secure_Bag__c> secureBagList ){
        try {
            System.debug('=====secureBagList====='+secureBagList);
            System.debug('=====trackingRecord====='+trackingRecord);
            Set<Id> shipmentId = new Set<Id>();
            Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>(); 
            Map<Id,Shipment_Tracking__c> shipmnetTrackingMap = new Map<Id,Shipment_Tracking__c>();
            Map<Id,Secure_Bag__c> updateSecureBag = new Map<Id,Secure_Bag__c>();

            
          
            if(secureBagList.size() > 0){
                for(Secure_Bag__c bag : secureBagList){
                    shipmentId.add(bag.Shipment__c);              
                }

                System.debug('shipmentId : '+shipmentId);
                if(shipmentId.size() > 0){
                    shipmentMap = new Map <Id, Shipment__c>([ 
                        SELECT Id,Origin_Hub__c,Destination_Hub__c,Destination_Hub__r.Airport__c,Origin_Hub__r.Airport__c 
                        FROM Shipment__c WHERE Id IN:shipmentId 
                    ]); 
                } 
                
                System.debug('shipmentMap @@ '+shipmentMap.values());
 
                if(!shipmentMap.isEmpty()){
                    for(Shipment__c  ship : shipmentMap.values()){                        
                        Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();                        
                        shipmentTracking = trackingRecord.clone(false,false,false,false);
                        shipmentTracking.Shipment__c = null; 
                        shipmentTracking.Scan_Time__c = DateTime.now();
                        ShipmentTracking.Location__c = 'Delivered'; 
                        shipmentTracking.Shipment__c =  ship.Id ;
                        shipmnetTrackingMap.put(shipmentTracking.Shipment__c,shipmentTracking); 
                        
                    }
 					
                    System.debug('shipmnetTrackingMap.valus ###'+shipmnetTrackingMap.values());
                    if(!shipmnetTrackingMap.isEmpty()){ 
                                            System.debug('shipmnetTrackingMap.valus %%%%'+shipmnetTrackingMap.values());
                        //Insert shipmnetTrackingMap.values();
                        
                        for(Secure_Bag__c secureBag :  secureBagList){
                            Secure_Bag__c bag = new Secure_Bag__c();
                            bag.id = secureBag.Id;
                            
                            if(shipmnetTrackingMap.containsKey(secureBag.Shipment__c)){
                                bag.Current_Scan_Loction__c =  shipmnetTrackingMap.get(secureBag.Shipment__c).Location__c;
                                bag.Tracking__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Id; 
                                bag.Current_Scan_Date_and_Time__c = DateTime.now(); 
                                bag.Scanning_Status__c = 'Scanned';
                            }
                            updateSecureBag.put(bag.Id,bag); 
                        }  
                    }
                }
            }
            System.debug('updateSecureBag.values() $%$%'+updateSecureBag.values());
            if(updateSecureBag.values().size() > 0 ){ 
                System.debug('updateSecureBag.values() '+updateSecureBag.values());
                Update updateSecureBag.values();
            }
			System.debug('Final value retuning : '+shipmnetTrackingMap.values());
            return shipmnetTrackingMap.values();
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}