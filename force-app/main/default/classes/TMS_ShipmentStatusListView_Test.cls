/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TMS_ShipmentStatusListView_Test {

    @isTest
    public static void TMS_ShipmentStatusListView(){
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
         
        insert Ship1; 
        
        List<Shipment__c> shipmentList = new List<Shipment__c>();
        shipmentList.add(Ship1);
        
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        insert bag1;
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
       
             String account = '';
            String billingAccount= '';
            String bvcBranch= '';
            String bvcProduct= '';
            String exhibitionName= '';
            Date shipmentDateTo= null;
            Date shipmentDateFrom= null;
            String readyforRebilling= 'Yes'; 
            String readyforbilling= '';
        Test.startTest();            
            TMS_ShipmentStatusListView.shipmentFilterList(shipmentList);
            TMS_ShipmentStatusListView.searchShipment(BillingAcc.Id, BillingAcc.Id, DelhiHub.Id, bvcProduct,Ship1.Exhibition_Name__c,system.today(), system.today().addDays(-1), readyforbilling, readyforbilling);
            TMS_ShipmentStatusListView.saveDraftValues(shipmentList);
            TMS_ShipmentStatusListView.createSOQLWhere(BillingAcc.Id, BillingAcc.Id, DelhiHub.Id, bvcProduct,Ship1.Exhibition_Name__c,system.today(), system.today().addDays(-1), readyforbilling, readyforbilling);
        Test.stopTest();
    }
}