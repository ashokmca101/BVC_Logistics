@isTest
public class TMS_PickupHandlerTest {
    @isTest public static void TestupdatePickUp(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Operations Field Executive'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Pickup_Delivery_Route__c pd= new Pickup_Delivery_Route__c(Name='TestPickup',Pickup_Route_Assigned_To__c=u.Id
                                                                  ,Hub__c=DelhiHub.Id);
        insert pd; 
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        //ShipperAddress.Pickup_Route_Number__c=pd.Id;
        update ShipperAddress; 
        Pickup__c pick = BVCL_TestDataFactory.CreatePickup(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, false);
        pick.BVC_Origin_Hub__c = DelhiHub.id;
        pick.Pickup_Assigned_To__c = UserInfo.getUserId();
        insert pick;
        pick.Pickup_Assigned_To__c = u.id;
        update pick;  
      
     //  TMS_PickupHandler.getPickupRouteNumber(pd.Id);
     //  TMS_PickupHandler.getPickupRouteAssignedTo(pick.Pickup_Assigned_To__c);
           
    }
 
}