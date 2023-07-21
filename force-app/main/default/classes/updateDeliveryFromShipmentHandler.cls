public class updateDeliveryFromShipmentHandler {
    public static void DeliveryFromShipment(List<Shipment__c> ships)
    {
        List<Delivery__c> deliveryList = new List<Delivery__c>();
        Set<Id> shipId = new Set<Id>();
        for(Shipment__c ship : ships)
        {
            if(ship.Tracking_Status__c == 'Destination Hub')
            {
                shipId.add(ship.Id);
            }
        }
        
        List<Delivery__c> delList = [Select Id,Status__c,Shipment__c from Delivery__c where Shipment__c =:shipId];
        if(delList.Size()> 0)
        {
            Delivery__c delivery = new Delivery__c();
            delivery.Shipment__c = delList[0].Shipment__c;
            delivery.Status__c = 'Created';
            delivery.Id = delList[0].id;
            deliveryList.add(delivery);
        }
        if(deliveryList.size() > 0)
        {
            update deliveryList;
        }
    }
}