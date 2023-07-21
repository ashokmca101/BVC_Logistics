public class SendEmailForShipmentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
   
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String queryVar = 'SELECT Id,Name,Short_URL__c,Invoiced_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,Total_Invoice_Value__c,Customer__c,Shipment_Lot__c FROM Shipment__c  where Shipment_Lot__c = null AND Short_URL__c != null AND Invoiced_Amount__c =0.00';
        
        return Database.getQueryLocator(queryVar);
    }
    public void execute(Database.BatchableContext bc,List<Shipment__c> shipmentList){
       
         MAP<String,List<String>> customerToEmailsMap = new MAP<String,List<String>>();
        Set<Id> customerIds = new  Set<Id>();
        
        for(Shipment__c shipObj : shipmentList){
            customerIds.add(shipObj.Customer__c);
        }
        
        
        List<Contact> contactList =[SELECT Id,Name,Email,BVC_Finance_Contact__c,Phone,MobilePhone,AccountId FROM Contact WHERE AccountId in : customerIds AND Email != null ];
       
        for(Contact con : contactList){
            customerToEmailsMap.put(con.AccountId,new List<String>{con.Email}); 
        }   
        system.debug('mapEmailShip:::'+customerToEmailsMap);
        
        EmailToContactAboutShipment.sendEmailForShipment(shipmentList,customerToEmailsMap);    
                
           
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}