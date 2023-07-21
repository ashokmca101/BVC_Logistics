@isTest
public class TMS_UpdateShipment_ShippingNoteNo_Test {
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        //FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,u.id,'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        //Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Shipping Label','EZ000333','Available',false);
        //SP_Bag.Digital__c = true;
        //insert SP_Bag;
        Digital_Shipping_Label__c spl = new Digital_Shipping_Label__c();
        spl.Name = '1193839';
        spl.Status__c = 'Available';
		insert spl;
        
        test.startTest();
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, true);
        TMS_UpdateShipment_ShippingNoteNo.updateShippingNoteNo(new List<Shipment__c>{Ship1});
        test.stopTest();
    }
}