public class ShipmentLotTriggerHandler {
    
    public static void updateShipmentCheckbox(List<Shipment_Lot__c>shipLotList){
        List<Shipment_Lot__c> shipmentLotList=[select Id, name, (SELECT Id,Name,Short_URL__c,Invoiced_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,Total_Invoice_Value__c,Customer__c FROM Shipments__r) 
                                               from Shipment_Lot__c 
                                               where Amount_Calculated_For_All_Shipment__c=false];
        for(Shipment_Lot__c shipLotObj : shipmentLotList){
            for(Shipment__c shipObj : shipLotObj.Shipments__r){
                if(shipObj.Short_URL__c == null){
                    
                }
            }
        }
   
    }

}