/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TMS_DeliveryListView { //3he7f4j57k
     
    @AuraEnabled(cacheable=true)
    public static List<Delivery__c> viewAllDelivery(){
        List<Delivery__c> deliveryList = new List<Delivery__c>();
        try {

            deliveryList =[ 
                    SELECT Id,Name, Customer_Name__c, Shipment__c, Number_of_Secure_Bag__c, Shipping_Note_Number__c, Status__c 
                    FROM Delivery__c 
                    WHERE LastModifiedDate = TODAY AND  OwnerId =: UserInfo.getUserId () AND 
                    Status__c = 'Created'];
             

            return deliveryList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void  updateDelivery(List<Delivery__c> deliveryList){
        System.debug('==== deliveryList ===='+deliveryList);
       try {
            if(deliveryList.size() > 0){
                for(Delivery__c delivery : deliveryList ){
                    delivery.Status__c = 'Accepted';
                }
            }   

            Update deliveryList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}