public with sharing class ShipmentBulkVerificationHndlr {
    @AuraEnabled (cacheable=true)
    public static List<SBQQ__Quote__c> retrieveShips(DateTime shipmentFrom,DateTime shipmentTo ,String bvcservice , string customerName){
        system.debug(shipmentFrom);
        system.debug(shipmentTo);
        system.debug(bvcservice);
        system.debug(customerName);
        List<Shipment__c> ListShipments = new List<Shipment__c>();
        if(customerName==null || customerName==''){
            if(bvcservice=='BATH'){ListShipments = [SELECT Id,Name,Customer__c,Customer__r.Name,Customer__r.Billing_Frequency__c,Customer__r.Invoice_Batch__c,CreatedDate FROM Shipment__c where Customer__r.BATH_Contract__c!=null And Customer_Product_Category__c=:bvcservice And Verified_for_Billing__c=false And CreatedDate>=:shipmentFrom And CreatedDate<=:shipmentTo Limit 800]; 
            }else{
               ListShipments = [SELECT Id,Name,Customer__c,Customer__r.Name,Customer__r.Billing_Frequency__c,Customer__r.Invoice_Batch__c,CreatedDate FROM Shipment__c where Customer__r.eSHIP_Contract__c!=null And Customer_Product_Category__c=:bvcservice And Verified_for_Billing__c=false And CreatedDate>=:shipmentFrom And CreatedDate<=:shipmentTo Limit 800]; 
            }
        }else{
            if(bvcservice=='BATH'){ListShipments = [SELECT Id,Name,Customer__c,Customer__r.Name,Customer__r.Billing_Frequency__c,Customer__r.Invoice_Batch__c,CreatedDate FROM Shipment__c where Customer__r.BATH_Contract__c!=null And Customer_Product_Category__c=:bvcservice And Verified_for_Billing__c=false And CreatedDate>=:shipmentFrom And Customer__r.Name=:customerName And CreatedDate<=:shipmentTo Limit 800]; 
            }else{
                ListShipments = [SELECT Id,Name,Customer__c,Customer__r.Name,Customer__r.Billing_Frequency__c,Customer__r.Invoice_Batch__c,CreatedDate FROM Shipment__c where Customer__r.eSHIP_Contract__c!=null And Customer_Product_Category__c=:bvcservice And Verified_for_Billing__c=false And CreatedDate>=:shipmentFrom And Customer__r.Name=:customerName And CreatedDate<=:shipmentTo Limit 800]; 
            }
        }
        set<Id> ShipIds = new set<Id>();
         for(Shipment__c ship:ListShipments){
            ShipIds.add(ship.Id);
        }
        List<SBQQ__Quote__c> quoteList =[select id,Shipment__c,Shipment__r.Name,SBQQ__NetAmount__c,SBQQ__Account__c,SBQQ__Account__r.Name,SBQQ__Account__r.Billing_Frequency__c,SBQQ__Account__r.Invoice_Batch__c,Shipment__r.CreatedDate from SBQQ__Quote__c where Shipment__c In :ShipIds];
        system.debug(ListShipments);
        return quoteList;
    }
    @AuraEnabled(cacheable=true)
    public static void VerifyForShips(string ShipsIds){
        system.debug(':::::::::::ShipsIds:::::::::'+ShipsIds);
        List<Id> ids=ShipsIds.split(',');
        Database.executeBatch(new ShipOrderCreatnBathEshipBatch(ids), 1);   
    }
    
    public void sendMail(String message_Data){
        String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = : userName limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{activeUser.Email});
        mail.setSubject('Shipment Bulk Verification');
        mail.setPlainTextBody(message_Data);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});        
    }
    
}