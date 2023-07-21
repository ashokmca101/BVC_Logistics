public with sharing class AccountDataController {
    public AccountDataController() {
        
    }
    @AuraEnabled (cacheable=true)
        public static List<Shipment__c> fetchShipments(){
            return [ SELECT Id, Name, Shipping_Note_Number__c, Shipment_Date__c, Destination_Address_Line1__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name, Delivery_Route_Assigned_To__c,
            Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,Number_of_Packages__c,Delivery_Route_Assigned_To__r.Name, Destination_Address_City__c FROM Shipment__c WHERE 
            Shipping_Note_Number__c != null AND Tracking_Status__c='Destination Hub' LIMIT 10000];       
    }
    @AuraEnabled (cacheable=true)
        public static List<Shipment__c> searchShipments(String searcchKey){
            return [SELECT Id, Name, Shipping_Note_Number__c, Shipment_Date__c, Destination_Address_Line1__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name, Delivery_Route_Assigned_To__c,
            Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,Number_of_Packages__c,Delivery_Route_Assigned_To__r.Name, Destination_Address_City__c FROM Shipment__c WHERE Shipping_Note_Number__c != null AND Shipping_Note_Number__c =: searcchKey AND Tracking_Status__c='Destination Hub'];
        }
        @AuraEnabled
        public static List<Shipment__c> updateShipments(List<Shipment__c> shipdata, String searcchKey){
            System.debug('shipdata--'+shipdata);
            System.debug('searcchKey---'+searcchKey);
            List<Shipment__c> shipdatalist = new List<Shipment__c>();
            if(searcchKey != null){
                for(Shipment__c s:shipdata){
                    s.Delivery_Route_Assigned_To__c = searcchKey;
                    shipdatalist.add(s);
                }                
            }
            update shipdatalist;
            return shipdatalist; 

        }    
}