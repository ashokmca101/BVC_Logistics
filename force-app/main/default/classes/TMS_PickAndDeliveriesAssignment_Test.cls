@isTest
public class TMS_PickAndDeliveriesAssignment_Test {
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,UserInfo.getUserId(),'FSE',true,false);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Pickup__c pick = BVCL_TestDataFactory.CreatePickup(BillingAcc.id,ShipperAcc.id,ShipperAddress.id,false);
        
        Pickup_Delivery_Route__c pdr = new Pickup_Delivery_Route__c();
        pdr.RecordTypeId = Schema.SObjectType.Pickup_Delivery_Route__c.getRecordTypeInfosByName().get('Pickup').getRecordTypeId();
        pdr.Name = 'pd1';
        pdr.Pickup_Route_Assigned_By__c = UserInfo.getUserId();
        pdr.Pickup_Route_Assigned_To__c = UserInfo.getUserId();
        pdr.Pickup_Route_Time_Slot_1__c = system.now().Time();
        pdr.Pickup_Route_Time_Slot_2__c = system.now().Time();
        pdr.Pickup_Route_Time_Slot_3__c = system.now().Time();
        pdr.Pickup_Route_Time_Slot_From_1__c = system.now().addHours(1).Time();
        pdr.Pickup_Route_Time_Slot_From_2__c = system.now().addHours(2).Time();
        pdr.Pickup_Route_Time_Slot_From_3__c = system.now().addHours(5).Time();
        pdr.Pickup_Route_Time_Slot_To_1__c = system.now().addHours(2).Time();
        pdr.Pickup_Route_Time_Slot_To_2__c = system.now().addHours(4).Time();
        pdr.Pickup_Route_Time_Slot_To_3__c = system.now().addHours(6).Time();
        pdr.Hub__c = DelhiHub.id;
        insert pdr;
        
        Route_Assignment__c ra = new Route_Assignment__c();
        ra.Round_Robin__c = 1;
        ra.Pickup_Delivery_Route__c = pdr.id;
        ra.Route_Assigned_To__c = UserInfo.getUserId();
        ra.Route_Assigned_By__c = UserInfo.getUserId();
        insert ra;
        pick.Pickup_Route_Number__c = pdr.Id;
        insert pick;
        test.startTest();
        TMS_PickAndDeliveriesAssignment.pickupAssignment(new List<Pickup__c> {pick});
        pick.Pickup_Route_Number__c = null;
        pick.BVC_Origin_Hub__c = DelhiHub.id;
        update pick;
        
        fse.Round_Robin__c = 1;
        fse.Pickup_Route__c = pdr.id;
        fse.Hub__c = DelhiHub.id;
        insert fse;
        TMS_PickAndDeliveriesAssignment.pickupAssignment(new List<Pickup__c> {pick});
        test.stopTest();
    }
}