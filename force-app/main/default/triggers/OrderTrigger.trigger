trigger OrderTrigger on Order (after update, before delete, after insert) {
    
    
    if(trigger.isUpdate && trigger.isAfter){
        Map<Id,Order> orderMap = new  Map<Id,Order>();
        utilClass.flowSequence++;
        system.debug('flowSequence : Order After Update Trigger'+utilClass.flowSequence);
        // if(!UtilClass.triggerLoop ){
        for(Order  o : trigger.newMap.values()){
            Order oldO = trigger.oldMap.get(o.Id);
            system.debug('Old status : '+oldO.Status+'Status: '+o.Status);
            if(o.Status == 'Activated' && oldO.Status != o.Status && o.BVC_Service__c!='BATH' && o.BVC_Service__c!='eSHIP'){
                UtilClass.triggerLoop = true;
                orderMap.put(o.Id,o);
            }
            if(o.Shipment_Status_Static__c=='ACR Consumed'&& o.BVC_Service__c!='BATH' && o.BVC_Service__c!='eSHIP'){
           OrderTriggerHandler.createReverseOrder(Trigger.oldMap,Trigger.newMap); 
        }
        }
        if(orderMap.size() >0){
            OrderTriggerHandler.orderProcesser(orderMap);
        }
        
        
    } 
    if(trigger.isBefore && trigger.isDelete){
       OrderTriggerHandler.cannotDeleteOrder(Trigger.old);
    }

}