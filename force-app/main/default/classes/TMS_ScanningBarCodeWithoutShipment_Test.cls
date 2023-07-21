@isTest
public class TMS_ScanningBarCodeWithoutShipment_Test {
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Pickup__c Pickup = BVCL_TestDataFactory.CreatePickup(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, true);
        Shipment__c Ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship.Pickup__c = Pickup.id;
        Ship.Shipping_Note_Number__c = 'EZ00000005';
        insert Ship;
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label',Ship.Shipping_Note_Number__c,'Available',true);
        Secure_Packaging__c Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','AB98898','Available',true);
        Test.startTest();
        TMS_ScanningBarCodeWithoutShipment.shipmentRecordGet(Ship.Shipping_Note_Number__c, Pickup.id);
        
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        TMS_ScanningBarCodeWithoutShipment.createShipmentRecord(Ship2, Pickup.id, Ship.Shipping_Note_Number__c);
        
        TMS_ScanningBarCodeWithoutShipment.createSecureBagRecords(Bag.name, Ship.id);
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Scan_Time__c = system.now();
        
        Secure_Bag__c sb = new Secure_Bag__c();
        sb.Shipment__c = Ship.id;
        sb.Secure_Bag__c = Bag.id;
        insert sb;
        TMS_ScanningBarCodeWithoutShipment.createTrackingRecord(st, Ship.id, new List<Secure_Bag__c>{sb});
        TMS_ScanningBarCodeWithoutShipment.SecureBagWrapper wrap = new TMS_ScanningBarCodeWithoutShipment.SecureBagWrapper();
        wrap.bagId = sb.id;
        wrap.secureBag = sb;
        Test.stopTest();
    }
}