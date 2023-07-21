trigger ShipmentLotTrigger on Shipment_Lot__c (after update,after insert,before update, before insert) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
       
        ShipmentLotTriggerHandler.updateShipmentCheckbox(Trigger.New);
    }

}