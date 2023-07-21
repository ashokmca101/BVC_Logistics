trigger ST_ShipmentTrigger on Shipment__c (after update, after insert) {
   if(Trigger.isAfter){
       if(Trigger.isInsert){
           List<Shipment__c> shipmentList = new List<Shipment__c>();
           for(Shipment__c ship: Trigger.new){
               if(ship.Shipping_Note_Number__c != null){
                 shipmentList.add(ship);  
               }
           }
         Update_Secure_Packaging.updateRelatedSecurePackaging(shipmentList);  
       }
       if(Trigger.isUpdate){
          
        // Added By standav
        Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>();
        for(Shipment__c ship : trigger.new){
            if(ship.Status__c == 'Verified For Billing' && trigger.oldmap.get(ship.Id).Status__c == 'Pending Billing' )
            {
                shipMap.put(ship.Id,ship);
            } 
        }
        if(shipMap.size() > 0){
            OrderCreateShipment.validateAndCreateOrder(shipMap);  
        }
           
       } 
    }
}