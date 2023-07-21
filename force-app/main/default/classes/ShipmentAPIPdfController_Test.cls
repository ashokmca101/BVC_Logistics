@isTest
public class ShipmentAPIPdfController_Test {

    @isTest
    public static void ShipmentAPIPdfController(){
          
     Account BillingAcc = BVCL_TestDataFactory.createCustomer('Billing Customer23','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('Shipper Account BVCL','Shipping',true);
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
        Ship1.Net_Weight__c = 8000;
        Ship1.Shipment_Value__c = 10000;
        Ship1.Billing_Address__c = ShipperAddress.Id;
        Ship1.Number_of_Packages__c = 1;
        ship1.Shipment_Type__c = 'Prepaid';   
        ship1.Insurance_By_BVC__c = 'test';
        ship1.Customer_Product_Category__c = 'ValSHIP';
        insert Ship1;
        
        test.startTest();   
        //ApexPages.currentPage().getParameters().put('id',Ship1.Id); 
         ApexPages.currentPage().getParameters().put('type','post');
        ApexPages.currentPage().getParameters().put('list','Ship1.Id');
        ShipmentAPIPdfController pdfcontroller = new ShipmentAPIPdfController();
        test.stopTest();
    }
    @isTest
       public static void ShipmentAPIPdfController2(){
          
     Account BillingAcc = BVCL_TestDataFactory.createCustomer('Billing Customer23','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('Shipper Account BVCL','Shipping',true);
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
        Ship1.Net_Weight__c = 8000;
        Ship1.Shipment_Value__c = 10000;
        Ship1.Billing_Address__c = ShipperAddress.Id;
        Ship1.Number_of_Packages__c = 1;
        ship1.Shipment_Type__c = 'Collect';   
        ship1.Insurance_By_BVC__c = 'test';
        ship1.Customer_Product_Category__c = 'ValSHIP';
        insert Ship1;
        List<Shipment__c> shipList = new List<Shipment__c>();
          shipList.add(Ship1); 
           List<Secure_Packaging__c> labelList = new List<Secure_Packaging__c>();
           labelList.add(Label);
        test.startTest();   
        //ApexPages.currentPage().getParameters().put('id',Ship1.Id); 
        ApexPages.currentPage().getParameters().put('type','pre');
        ApexPages.currentPage().getParameters().put('list','Label.Id');   
        ShipmentAPIPdfController pdfcontroller = new ShipmentAPIPdfController();
        //pdfcontroller.SelectedLabelList(Label);
        //ShipmentAPIPdfController.shipmentList(shipList);
        test.stopTest();
    }
    
       @isTest
       public static void ShipmentAPIPdfController3(){
          
     Account BillingAcc = BVCL_TestDataFactory.createCustomer('Billing Customer23','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('Shipper Account BVCL','Shipping',true);
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
        Ship1.Net_Weight__c = 8000;
        Ship1.Shipment_Value__c = 10000;
        Ship1.Billing_Address__c = ShipperAddress.Id;
        Ship1.Number_of_Packages__c = 1;
        ship1.Shipment_Type__c = 'Collect';   
        ship1.Insurance_By_BVC__c = 'test';
        ship1.Customer_Product_Category__c = 'ValSHIP';
        insert Ship1;
        List<Shipment__c> shipList = new List<Shipment__c>();
          shipList.add(Ship1); 
           List<Secure_Packaging__c> labelList = new List<Secure_Packaging__c>();
           labelList.add(Label);
        test.startTest();   
        ApexPages.currentPage().getParameters().put('id',Ship1.Id); 
        //ApexPages.currentPage().getParameters().put('type','pre');
        //ApexPages.currentPage().getParameters().put('list','Label.Id');   
        ShipmentAPIPdfController pdfcontroller = new ShipmentAPIPdfController();
        //pdfcontroller.SelectedLabelList(Label);
        //ShipmentAPIPdfController.shipmentList(shipList);
        test.stopTest();
    }
}