/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-24-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TMS_UpdateShipment_ShippingNoteNo { 
    
    @invocableMethod
    public static void updateShippingNoteNo ( List<Shipment__c> shipmentList) {

        List<Shipment__c> shipmentToUpdate = new List<Shipment__c>();
        List<Digital_Shipping_Label__c> securePackagingList = new List<Digital_Shipping_Label__c>();
        Map<Digital_Shipping_Label__c,Shipment__c> mapOfSecurePack = new Map<Digital_Shipping_Label__c,Shipment__c>();
        /*Set<Id> hubIdSet = new Set<Id> ();

        for(Shipment__c shipmentRecord :  shipmentList){
            hubIdSet.Add(shipmentRecord.Origin_Hub__c);
        } 

        System.debug('====== hubIdSet =========== '+hubIdSet);*/

        Digital_Shipping_Label__c [] securePackaging = [
            SELECT Id, Name, Status__c,Status_Identifier__c FROM Digital_Shipping_Label__c WHERE Status__c = 'Available'
            ORDER BY Status_Identifier__c ASC  LIMIT 1000
            //AND Allocated_To_Hub__c IN: hubIdSet
        ]; 

        System.debug('===================  securePackaging ========'+securePackaging.size());


        if(securePackaging.size() > 0 && shipmentList.size() <= securePackaging.size() ) { 
            for(Integer i = 0; i < shipmentList.size(); i++) {
                mapOfSecurePack.put(securePackaging[i],shipmentList[i] );
            }
            for(Digital_Shipping_Label__c sp1 : mapOfSecurePack.keyset()) {
                if(mapOfSecurePack.containsKey(sp1)) {

                    Shipment__c tempShipment = new Shipment__c();
                    tempShipment.Id = mapOfSecurePack.get(sp1).Id;
                    tempShipment.Shipping_Note_Number__c = sp1.Name;
                    shipmentToUpdate.add(tempShipment);
                    
                    Digital_Shipping_Label__c tempsbag = new Digital_Shipping_Label__c();
                    tempsbag.Id = sp1.Id;
                    tempsbag.Status__c = 'Consumed';
                    tempsbag.Shipment__c = tempShipment.Id;
                    securePackagingList.add(tempsbag);
                }
                
            }
        }
        
        if(shipmentToUpdate.size()>0 && securePackagingList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(shipmentToUpdate, false);
            system.debug('-------myupdate----'+saveResultList);
            Database.SaveResult[] saveResultList1 = Database.update(securePackagingList, false);
            system.debug('-------myupdate1----'+saveResultList1);
        }
    }
}