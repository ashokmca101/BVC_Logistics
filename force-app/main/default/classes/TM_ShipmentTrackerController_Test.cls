/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TM_ShipmentTrackerController_Test {
    @isTest

    public static void Test1(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Current_Scan_Hub__c = hub.id;
        //bag1.Current_Scan_Airport__c = Airport.id;
        insert bag1;
        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag1);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        TM_ShipmentTrackerController.bagBySealId(Seal.name);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        TM_ShipmentTrackerController.scanningInProgress(wr);
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.Hub__c = hub.id; 
        st.Scan_Time__c = system.now();
        //insert st;
        Test.startTest();
        TM_ShipmentTrackerController.bagBySecureBagId(SP_Bag.name,st,'');
        TM_ShipmentTrackerController.bagBySecureBagId(SP_Bag.name,st,'Misrouted');
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock');
        TM_ShipmentTrackerController.updateNormalBag(st, BagList);
        Test.stopTest();
    }

    @isTest    
    public static void Test2(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;

        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);

        //Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created'; 
        insert bag1;

        Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag.id;
        bag2.Seal_Id__c = Seal.id;
        bag2.Current_Scan_Loction__c = 'Created'; 
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag2;

        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag2);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.hub__c= hub.id;  
 
        Test.startTest();
        TM_ShipmentTrackerController.secureBagGet(SP_Bag.name);
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock');
        BagList = new List<Secure_Bag__c>();
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock');
        Test.stopTest();
    }

    @isTest    
    public static void Test3(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
 
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        insert bag1;

        Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag.id;
        bag2.Seal_Id__c = Seal.id;
        bag2.Current_Scan_Loction__c = 'Created'; 
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag2;

        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag2);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id; 
        st.Location__c = 'Out for Delivery';

        Test.startTest();
        TM_ShipmentTrackerController.secureBagGet(SP_Bag.name);
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock');
        BagList = new List<Secure_Bag__c>();
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock');
        TM_ShipmentTrackerController.LoggedInUserHub();
        Test.stopTest();
    }



}