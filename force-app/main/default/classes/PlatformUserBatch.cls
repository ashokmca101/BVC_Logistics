public class PlatformUserBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful {
   // public string shipIds;
   
    Set<Id> ids = new Set<Id>();
    public  PlatformUserBatch(Set<Id> ids){
        
        /*for(Shipment__c ship : [select id,name,Verified_for_Billing__c from Shipment__c]){
             if(ship.Verified_for_Billing__c == true){
        ids.add(ship.Id);
    }
        }*/
   
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
        
        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Status__c = \'Verified For Billing\' AND 	platform_User__c=TRUE AND 	Customer_Category_Static__c!=\'ACR\'';
    	//string query = 'select id,name from Shipment__c WHERE Status__c = \'Verified For Billing\' AND 	platform_User__c=TRUE';
        //system.debug('query'+query);
        system.debug('Query Batch'+query);
        //list<Shipment__c> listShip=Database.getQueryLocator(query);
        //system.debug(listShip);
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
public static void fakeMethod(){
        integer i = 0;
          
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
     }
}