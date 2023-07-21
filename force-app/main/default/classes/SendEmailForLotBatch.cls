public class SendEmailForLotBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
   
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String varPaid ='Paid';
        String queryVar = 'select Id, name,Amount_Calculated_For_All_Shipment__c, (SELECT Id,Name,Short_URL__c,Invoiced_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,Total_Invoice_Value__c,Customer__c,Shipment_Payment_Status__c FROM Shipments__r WHERE Shipment_Payment_Status__c!=:varPaid) from Shipment_Lot__c where Amount_Calculated_For_All_Shipment__c=true';
        
        return Database.getQueryLocator(queryVar);
    }
    public void execute(Database.BatchableContext bc,List<Shipment_Lot__c> shipmentLotList){
       
         MAP<String,List<String>> customerToEmailsMap = new MAP<String,List<String>>();
        Set<Id> customerIds = new  Set<Id>();
         for(Shipment_Lot__c shipLotObj : shipmentLotList){
            for(Shipment__c shipObj : shipLotObj.Shipments__r){
                customerIds.add(shipObj.Customer__c);
            }
        }
        
        List<Contact> contactList =[SELECT Id,Name,Email,BVC_Finance_Contact__c,Phone,MobilePhone,AccountId FROM Contact WHERE AccountId in : customerIds AND Email != null AND BVC_Finance_Contact__c = true];
       
        for(Contact con : contactList){
            customerToEmailsMap.put(con.AccountId,new List<String>{con.Email}); 
        }   
        system.debug('mapEmailShip:::'+customerToEmailsMap);
        
        EmailToContactAboutShipment.sendEmailTest1(shipmentLotList,customerToEmailsMap);    
                
           
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}