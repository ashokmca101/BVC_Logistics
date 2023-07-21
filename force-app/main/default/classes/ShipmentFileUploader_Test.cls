@isTest
public class ShipmentFileUploader_Test {
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('TIRUPATI DIAMONDS','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('KRYSTAL HALLMARK CENTRE','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c BillAddress = BVCL_TestDataFactory.CreateAddress('Billing',BillingAcc.id,'Line 1',DelhiPin.id,'Cityyy',false);
        BillAddress.TRADE_NAME__c = 'TIRUPATI DIAMONDS';
        insert BillAddress;
        
        Blob fileblob = blob.valueOf('Customer(Name),Billing Account(Name),Billing Address(Id),Shipper Account(Name),Origin Address Name(Id),Consignee Account(Name),Destination Address Name(Id),Shipment Date,Shipping Note Number,Shipment Value (INR),Net Weight (KG),Gross Weight (KG),Insuarance By\nTIRUPATI DIAMONDS,TIRUPATI DIMONDS,'+BillAddress.id+',KRYSTAL HALLMARK CENTRE,'+ShipperAddress.id+',KRYSTAL HALLMARK CENTRE,'+ShipperAddress.id+','+system.today()+',AA556699,2500000,0.485,0.85,SHIPPER');
        ShipmentFileUploader ship = new ShipmentFileUploader();
        ship.contentFile = fileblob;
        ship.ReadFile();
        ship.getuploadedShipments();
        
    }
    public static testmethod void test2(){
        Blob fileblob2 = blob.valueOf('Customer(Name),Billing Account(Name),Billing Address(Id),Shipper Account(Name),Origin Address Name(Id),Consignee Account(Name),Destination Address Name(Id),Shipment Date,Shipping Note Number,Shipment Value (INR),Net Weight (KG),Gross Weight (KG),Insuarance By\nTIRUPATI DIAMONDS,TIRUPATI ,BillAddress.id,KRYSTAL HALLMARK,ShipperAddress.id,KRYSTAL HALLMARK CENTRE,ShipperAddress.id,2022-11-11,AA556699,2500000,0.485,0.85,SHIPPER');
        ShipmentFileUploader ship2 = new ShipmentFileUploader();
        ship2.contentFile = fileblob2;
        ship2.ReadFile();
    }
}