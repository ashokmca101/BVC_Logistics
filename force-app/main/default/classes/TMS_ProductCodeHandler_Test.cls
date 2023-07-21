@isTest
public class TMS_ProductCodeHandler_Test {
    public static testmethod void productNameTest(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Delhi',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        ship1.Customer_Product_Category__c = 'ValSHIP';
        insert Ship1; 
        test.startTest();
        AddressBook__c ShipperAddress2 = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Gurgaon',true);
        
        Origin_Destination__c od =new Origin_Destination__c(name='Delhi-Gurgaon',OriginCity__c='Delhi',DestinationCity__c='Gurgaon',Mode_Of_Service__c='Door-to-Airport');
        insert od;
        
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress2.id, false);
        ship2.Customer_Product_Category__c = 'ValSHIP';
        insert Ship2;
        test.stopTest();
    }
}