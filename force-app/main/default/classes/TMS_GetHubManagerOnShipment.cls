/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TMS_GetHubManagerOnShipment {
    @InvocableMethod
    public static void getHubManager(List<Shipment__c>shipmentlist){
        //System.debug('==== getHubManager ===: ');
        List<Shipment__c>updatedShipment = new List<Shipment__c>();
        
        //System.debug('==== shipmentlist ===: '+shipmentlist);

        Set<Id> orginhubId = new Set<Id>();
        Set<Id> destinationhubId = new Set<Id>();

        Map<Id,Id> originHubIdVsFSE = new Map<Id,Id>();
        Map<Id,Id> destinationHubIdVsFSE = new Map<Id,Id>();
        if(shipmentlist.size()>0){
            for(Shipment__c shp:shipmentlist){
                if(shp.Origin_Hub__c != null && shp.Destination_Hub__c != null){
                    orginhubId.add(shp.Origin_Hub__c);
                    destinationhubId.add(shp.Destination_Hub__c);
                }
            }
             
            for(FSE_Sales__c fse:[Select Id, name, Sales_Person__c, Hub__c FROM FSE_Sales__c WHERE Hub__c IN :orginhubId AND Type__c = 'Manager']){
                if(!originHubIdVsFSE.containsKey(fse.Hub__c)){
                    originHubIdVsFSE.put(fse.Hub__c, fse.Sales_Person__c);
                }
            }
            //System.debug('==== originHubIdVsFSE ==='+originHubIdVsFSE);
            
            for(FSE_Sales__c fs:[Select Id, name, Sales_Person__c, Hub__c FROM FSE_Sales__c WHERE Hub__c IN :destinationhubId AND Type__c = 'Manager']){
                if(!destinationHubIdVsFSE.containsKey(fs.Hub__c)){
                    destinationHubIdVsFSE.put(fs.Hub__c, fs.Sales_Person__c);
                }
            }
            
            //System.debug('==== destinationhubId ==='+destinationhubId);
            
            for(Shipment__c sh:shipmentlist){
                if(sh.Origin_Hub__c != null && sh.Destination_Hub__c != null){
                    Shipment__c tempSh = new Shipment__c();
                    tempSh.Id = sh.Id;
                    tempSh.Origin_Hub_Manager__c = originHubIdVsFSE.get(sh.Origin_Hub__c);
                    tempSh.Destination_Hub_Manager__c = destinationHubIdVsFSE.get(sh.Destination_Hub__c);
                    //System.debug('==== Origin Hub Manager ====== '+ sh.Origin_Hub_Manager__c);
                    //System.debug('==== Destination Hub Manager ====== '+ sh.Destination_Hub_Manager__c);
                    updatedShipment.add(tempSh);
                }  
            }
            //System.debug('==== updatedShipment ==='+updatedShipment);
            if(updatedShipment.size() > 0){ 
                update updatedShipment;
            }
        }
    } 
}