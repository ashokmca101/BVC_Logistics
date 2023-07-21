@isTest(SeeAllData=false)
public class ShipmentsTriggerTest {
    
    public static testMethod void ShipmentsTriggerTestMethod(){
        List<Shipment__c> newShipList= new List<shipment__c>();
        List<Shipment__c> oldShipList = new List<Shipment__c>();
       shipment__c newShip = new Shipment__c();
         newShip.Bill_to_1__c = 'shipper';
          newShipList.add(newShip);
        test.startTest();
           insert newShipList;
       
         newShip=[select id,Bill_to_1__c,Invoice_Calculated_Amount__c from shipment__c where id=:newShip.id];
         newShip.Bill_to_1__c = 'consignee';
         newShip.Invoice_Calculated_Amount__c = 43;
            oldShipList.add(newShip);

            update oldShipList;
        
        newship=[select id,Bill_to_1__c from shipment__c where Bill_to_1__c ='consignee'];
        delete newship;
        
        newship=[select id,Bill_to_1__c from shipment__c where Bill_to_1__c ='consignee' ALL ROWS];
        undelete newship;
        test.stopTest();
               
        
    }
	    

}