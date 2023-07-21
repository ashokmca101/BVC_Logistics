trigger updateDeliveryFromShipment on Shipment__c (After update) {
    if(Trigger.isAfter && Trigger.isUpdate)
    {
       // updateDeliveryFromShipmentHandler.DeliveryFromShipment(Trigger.new);
    }
}