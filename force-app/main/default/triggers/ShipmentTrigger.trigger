trigger ShipmentTrigger on Shipment__c (after update,after insert,before update, before insert,before delete) {
    
   
    
    if(Trigger.isAfter && Trigger.isInsert){
        ShipmentTriggerHandlerServiceCtrl.calculateShipmentAmount(trigger.New);
        if(trigger.New[0].Invoice_Calculated_Amount__c != null){
            system.enqueueJob(new Community_RazorpayQueueableCrtInv(trigger.New));
        }  
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        //ShipmentTriggerHandlerServiceCtrl.calculateShipmentAmount(trigger.New);
        if(trigger.New[0].Invoice_Calculated_Amount__c != trigger.Old[0].Invoice_Calculated_Amount__c){
            system.enqueueJob(new Community_RazorpayQueueableCrtInv(trigger.New));
        }
        
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        if(trigger.New[0].Invoice_Calculated_Amount__c != null && trigger.New[0].Short_URL__c == null){
            system.enqueueJob(new Community_RazorpayQueueableCrtInv(trigger.New));
        }
        if(trigger.New[0].Customer_Product_Category__c!='BATH' && trigger.New[0].Customer_Product_Category__c!='eSHIP'){
              ShipmentTriggerHandler.updateShipmentLotCheckbox(Trigger.New);
        }
      
        // Added By standav
        Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>();
       /* for(Shipment__c ship : trigger.new){
            if((ship.Status__c == 'Verified For Billing' && ship.Status__c <> trigger.oldmap.get(ship.Id).Status__c && ship.Ready_for_Billing__c)
               ||(ship.Ready_for_Billing__c &&ship.Status__c == 'Verified For Billing'&&ship.Ready_for_Billing__c <> trigger.oldmap.get(ship.Id).Ready_for_Billing__c)
               ||(ship.Ready_for_Rebilling__c &&ship.Status__c == 'Verified For Billing'&&ship.Ready_for_Rebilling__c <> trigger.oldmap.get(ship.Id).Ready_for_Rebilling__c)
               ||(ship.Status__c == 'Verified For Billing' && ship.Status__c <> trigger.oldmap.get(ship.Id).Status__c && ship.Ready_for_Rebilling__c))
            {
                shipMap.put(ship.Id,ship);
            } 
        }
        system.debug('Shipment AFter Update Trigger:::'+shipMap.values());
        if(shipMap.size() > 0){
            OrderCreateShipment.validateAndCreateOrder(shipMap);  
        }*/
        
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        user currentUser= Utility.getUserDetails();
        if(currentUser.ContactId !=null){
            //ShipmentTriggerHandler.UpdateShipmentShipper(Trigger.New);
            //ShipmentTriggerHandler.UpdateShipmentConsignee(Trigger.New);
            //ShipmentTriggerHandler.updateShipmentBillTo(Trigger.New);
        }
        
        ShipmentTriggerHandler.setPayer(Trigger.New);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        ShipmentTriggerHandler.setPayer(Trigger.New);
    }
    if(Trigger.isbefore && Trigger.isDelete){
        ShipmentTriggerHandler.cannotDeleteShipment(trigger.old);
        }
   
}