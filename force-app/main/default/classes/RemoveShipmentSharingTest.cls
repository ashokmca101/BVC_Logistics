@isTest
public class RemoveShipmentSharingTest 
{
    @isTest public static void shareTest1()
    {
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
        Active_Pincode__c MumbaiPin = BVCL_TestDataFactory.CreatePincode('110066', MumbaiHub.id, 'Mumbai', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        AddressBook__c ShipperAddress2 = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',MumbaiPin.id,'Cityyy',true);
        test.startTest();
       // Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress2.id, false);
        Shipment__c sh = new Shipment__c();
        sh.Customer__c = BillingAcc.id;
        sh.Shipper_Name_TMS__c = ShipperAcc.id;
        sh.Origin_Address_Name__c = ShipperAddress.id;
        sh.Consignee_Name_TMS__c = ShipperAcc.id;
        sh.Destination_Address_Name__c =ShipperAddress2.id;
        //sh.Tracking_Status__c = 'Out for Delivery';
        sh.Tracking_Status__c = 'Created';                
        sh.Delivery_Route_Assigned_To__c = UserInfo.getUserId();
        sh.OwnerId = u.id;
       // sh.OwnerId = UserInfo.getUserId();
        insert sh;
        List<ID> ids = new List<ID>();
        ids.add(sh.Id);
        RemoveShipmentSharing.RemoveSharing(ids);
        test.stopTest();
    }
}