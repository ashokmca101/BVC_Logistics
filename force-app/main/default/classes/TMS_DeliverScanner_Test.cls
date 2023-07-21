/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TMS_DeliverScanner_Test {
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label', 'YYY7777', 'Available', true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipping_Note_Number__c = 'EB78464734';
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        insert Ship1;
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        insert bag1;
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        test.startTest();
        TMS_DeliverScanner.secureBagGet(SP_Bag.name, ShipperAddress.id);
        Secure_Bag__c QueryBag = [select id,Shipment__c,Secure_Bag__c,Shipment__r.Shipping_Note_Number__c FROM Secure_Bag__c
                                 WHERE id=:bag1.id LIMIT 1];
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        //st.Shipment__c = Ship1.id;
        st.Hub__c = DelhiHub.id;
        st.Airport__c = DelhiAir.id;
        
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        //system.debug('SNN'+QueryBag.Shipment__r.Shipping_Note_Number__c);
        TMS_DeliverScanner.insertUpdateRecord(st, QueryBag, Ship1.Shipping_Note_Number__c);
        TMS_DeliverScanner.SecureBag cls = new TMS_DeliverScanner.SecureBag();
        cls.secureBagRecord = QueryBag;
        cls.numberofBag = 1;
        cls.bagCount = 1;

        TMS_DeliverScanner.allSecureBagGet(ShipperAddress.Id);
        test.stopTest();
    }

 
}