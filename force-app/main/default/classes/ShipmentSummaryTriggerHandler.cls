public class ShipmentSummaryTriggerHandler {
    
    public static void updateShipmentStatus(Set<Id> shipSummaryIds){
        
        system.debug('===shipSummaryIds : '+shipSummaryIds.size()+ ' ===shipSummaryIds : '+shipSummaryIds);
        Set<Id> ecsIds = new Set<Id>();
        for(External_Contract_Shipment__c cs : [select Id,Order__c,Name,Shipment__c FROM External_Contract_Shipment__c where Shipment_Summary__c =: shipSummaryIds ORDER BY Name])
        {
            ecsIds.add(cs.Id);
        }
        system.debug('===ecsIds : '+ecsIds.size());
        List<Shipment__c> shipmentToBeUpdated = new List<Shipment__c>();
        Shipment__c ship;
        if(!ecsIds.isEmpty())
        {
            Database.executeBatch(new ECSSShipmentUpdateBatch(ecsIds), 100);
            
        }
    }
    
}