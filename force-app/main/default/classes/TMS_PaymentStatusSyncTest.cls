/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public  class TMS_PaymentStatusSyncTest {
    @isTest
    static void testPaymentCreation(){
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
        ship1.Product_Code__c = 'VAL-EX-C2C';
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000; 
        insert Ship1;
        
        //ship1.Verified_for_Billing__c = true;
        //Update ship1;
        
        Order orderRecord = new Order();
        orderRecord.AccountId = BillingAcc.id;
        OrderRecord.Status = 'Draft'; 
        OrderRecord.Shipment__c = ship1.Id;
        OrderRecord.EffectiveDate = System.today();
        Insert OrderRecord; 
        
        Ship1.Order__c = OrderRecord.Id;
        Update Ship1;
        
        blng__Invoice__c invoiceRecord = new blng__Invoice__c();
        invoiceRecord.blng__Account__c =  BillingAcc.Id;
        invoiceRecord.blng__Order__c =     OrderRecord.Id;  
        InvoiceRecord.Razorpay_Id__c = 'plink_JGScM65gXV98AO';
        InvoiceRecord.blng__InvoiceStatus__c = 'Posted';
        InvoiceRecord.Short_URL__c = 'https://rzp.io/i/7AJtJMg';
        
        Insert InvoiceRecord;
        
        
        Test.startTest();
         List<Shipment__c>ShipList = new List<Shipment__c>();
        ShipList.add(ship1);
        TMS_PaymentStatusSync.SyncPayment(ShipList);
        Test.stopTest();
        
    }
    
}