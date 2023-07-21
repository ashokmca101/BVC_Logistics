@isTest(seeAllData=false)
public class updateDeliveryFromShipmentHandlerTest {

    static testmethod void DeliveryShipmentTest()
    {
        List<Shipment__c> shipmentList = new List<Shipment__c>();
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c sh = new Shipment__c();
        sh.Customer__c = BillingAcc.id;
        sh.Shipper_Name_TMS__c = shipperAcc.id;
        sh.Origin_Address_Name__c = null;
        sh.Consignee_Name_TMS__c = ShipperAcc.id;
        sh.Destination_Address_Name__c =null;
        sh.Tracking_Status__c = 'Destination Hub';
        insert sh;
        shipmentList.add(sh);
        Delivery__c delivery = new Delivery__c();
        delivery.Status__c = '';
        delivery.Shipment__c = sh.Id;
        insert delivery;
        
        Test.startTest();
        updateDeliveryFromShipmentHandler.DeliveryFromShipment(shipmentList);
        Test.stopTest();
    }
}