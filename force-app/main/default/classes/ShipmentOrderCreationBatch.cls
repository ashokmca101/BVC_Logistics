public class ShipmentOrderCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful {
    Set<Id> ids = new Set<Id>();
    public ShipmentOrderCreationBatch(Set<Id> ids){
        System.debug('Shipment Ids '+ids);
        this.ids = ids;
    }
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            //if(fieldDescribe.isAccessible()) {
            fieldNames.add(fieldName);
            //}
        }
        
        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Status__c = \'Verified For Billing\' AND Id IN :ids ORDER BY Name';
        system.debug('query'+query);
        system.debug('Query Batch'+query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext bc , List<Shipment__c> ships){
        System.debug('>>> execute start at ' + DateTime.now().format('yyyy/MM/dd hh:mm:ss'));
        if(ships.size() > 0 && ships != null){
            Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>(ships);
            OrderCreateShipment.createOrderShipment(shipMap); 
        }
        System.debug('>>> execute end at ' + DateTime.now().format('yyyy/MM/dd hh:mm:ss'));
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}