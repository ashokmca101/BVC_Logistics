@isTest
public class TMS_AddSecureBagOnShipment_Test {
    public static testmethod void test1(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        test.startTest();
        TMS_AddSecureBagOnShipment.shipmentRecordGet(Ship1.id);
        TMS_AddSecureBagOnShipment.createSecureBagRecords(SP_Bag.name, Ship1.id);
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        insert bag1;
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        TMS_AddSecureBagOnShipment.createTrackingRecord(st, Ship1.id, new List<Secure_Bag__c>{bag1});
        TMS_AddSecureBagOnShipment.updateshipmentAndPickup(Ship1.id);
        test.stopTest();
    }
}