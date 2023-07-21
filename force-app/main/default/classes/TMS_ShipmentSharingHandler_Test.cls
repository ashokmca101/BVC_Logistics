@isTest
public class TMS_ShipmentSharingHandler_Test {
    @isTest public static void shareTest1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        test.startTest();
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Origin_Hub__c = DelhiHub.id;
        Ship1.Destination_Hub__c = DelhiHub.id;
        insert Ship1;
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        insert bag1;
        bag1.Current_Origin_City__c = 'Delhi';
        bag1.Finalised_Linehaul_Number__c = '12345';
        bag1.Flight_Schedule__c = 'null';
        bag1.Linehaul_Type__c  = 'Outbound';
        bag1.Next_Destination__c = 'Delhi';
        update bag1;
        test.stopTest();
    }
    @isTest public static void shareTest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Operations Field Executive'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u;
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Hub__c MumbaiHub = BVCL_TestDataFactory.CreateHub('Mumbai', true, 'MUMBAI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        Active_Pincode__c MumbaiPin = BVCL_TestDataFactory.CreatePincode('110035', MumbaiHub.id, 'Mumbai', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        AddressBook__c ShipperAddress2 = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',MumbaiPin.id,'Cityyy',true);
        
        test.startTest();
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress2.id, false);
        Ship2.Delivery_Route_Assigned_To__c = UserInfo.getUserId();
        Ship2.OwnerId = u.id;
        insert Ship2;
        Ship2.Delivery_Route_Assigned_To__c = u.id;
        //Ship2.OwnerId = u.id;
        update Ship2;
        TMS_ShipmentSharingHandler.changeOwner(new List<Shipment__c> {Ship2});
        test.stopTest();
        
    }
}