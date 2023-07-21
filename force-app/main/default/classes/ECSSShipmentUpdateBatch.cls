public class ECSSShipmentUpdateBatch implements Database.Batchable<sObject>,Database.stateful{
    Set<Id> ids = new Set<Id>();
    public ECSSShipmentUpdateBatch(Set<Id> ids){
        this.ids = ids;
    }
    String query = 'SELECT Id,Name,Order__c,Shipment__c FROM External_Contract_Shipment__c WHERE Id IN :ids ORDER BY Name';
    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext bc , List<External_Contract_Shipment__c> ecShipments){
        List<Shipment__c> ships = new List<Shipment__c>();
        List<Order> orders = new List<Order>();
        if(ecShipments.size() > 0 && ecShipments != null){
            for(External_Contract_Shipment__c ecs : ecShipments){
                Shipment__c ship = new Shipment__c(Id = ecs.Shipment__c,Status__c = 'Billed');
                ships.add(ship);
                Order o = new Order(Id = ecs.Order__c,Shipment_Status_Static__c = 'Billed');
                orders.add(o);
            }
            Database.SaveResult[] lsr = Database.update(ships,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('Shipment with Id :'+result.getId()+' Successfully Updated');
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Ship fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            
            Database.SaveResult[] lsrs = Database.update(orders,false);
            for(Database.SaveResult result : lsrs){
                if(result.isSuccess()){
                    system.debug('Orders with Id :'+result.getId()+' Successfully Updated');
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}