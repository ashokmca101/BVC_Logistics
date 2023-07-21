@isTest(seeAllData=false)
public class tms_VehicleVaultHandler_Test
{
    static testMethod void vehicleVault() 
    {
        List<Secure_Bag__c> bagList = new List<Secure_Bag__c>();
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
         
        BVC_Vault_Master__c vlt = new BVC_Vault_Master__c();
        vlt.name = 'Test Vault';
        insert vlt;
        
        Transport__c vhl = new Transport__c();
        vhl.Name = 'Test vehicle';
        insert vhl;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.Hub__c = hub.id;
        st.BVC_Vehicle__c = vhl.Id;
        st.Vaults__c = vlt.Id;
        st.Scan_Time__c = system.now();
        insert st;
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Current_Scan_Hub__c = hub.id;
        bag1.Tracking__c = st.Id;
        insert bag1;
        bagList.add(bag1);
        
       Test.startTest();
        tms_VehicleVaultHandler.updateSecureBagLocation(bagList);
        Test.stopTest();
    }
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
        //TM_ShipmentTrackerController.updateNormalBag(st, BagList);
        Test.stopTest();
}
}