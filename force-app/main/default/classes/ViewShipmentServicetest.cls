@isTest
public with sharing class ViewShipmentServicetest {
    
    @istest
    public static void  GetServiceAPi() {
        test.startTest();   
        Id operationRecrodTypeId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();

        Account testAccts = new Account();
        testAccts.Name='Te Tesst'; 
        testAccts.First_Name__c = 'Te';
        testAccts.Last_Name__c ='Tesst';    
        testAccts.Email__c = 'test@gmail.com';
        testAccts.Mobile__c = '9999999999';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.KARZAA_KYC_Verified__c = false;
        testAccts.Stitch_Profile_API_Status__c = false ;
        testAccts.Credit_Rating_API_Status__c = false;
        testAccts.Financial_Summary_API_Status__c = false;
        testAccts.Entity_Id__c = 'L74999TZ1984PLC001456';
        testAccts.AWS_SYNC_Status__c = 'Pending';
        testAccts.Customer_Status__c = 'Active';
        testAccts.KYC_Indicator_for_Domestic_Flag__c = true;
        insert testAccts; 
                Id shipAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();

        Account testAccts2 = new Account();
        testAccts2.Name='Consignee Tesst'; 
        testAccts2.First_Name__c = 'Te';
        testAccts2.Last_Name__c ='Consignee';    
        testAccts2.Email__c = 'testc@gmail.com';
        testAccts2.Mobile__c = '9999999998';
        testAccts2.PAN_Number_of_Entity__c = 'ARUPA9695D';
        testAccts2.KARZAA_KYC_Verified__c = false;
        testAccts2.Stitch_Profile_API_Status__c = false ;
        testAccts2.Credit_Rating_API_Status__c = false;
        testAccts2.Financial_Summary_API_Status__c = false;
        testAccts2.Entity_Id__c = 'L74999TZ1984PLC001456';
        testAccts2.AWS_SYNC_Status__c = 'Pending';
        testAccts2.RecordTypeId = shipAcc;
        insert testAccts2;
        
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        
       
        
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',false);
        ShipperAddress.Is_Active__c = true;
        ShipperAddress.ADDRESS1__c = '(HSR) - 29, SIPCOT INDUSTRIAL COMPLEX.,';
        ShipperAddress.CITY__c = 'New Delhi';
        ShipperAddress.STATE__c = 'Delhi';
        ShipperAddress.COUNTRY__c = 'India';
        insert ShipperAddress;
        
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = testAccts.Id;
        TestPick.Shipper_Name__c = ShipperAcc.Id;
        TestPick.Origin_Address_Name__c = ShipperAddress.Id;
        TestPick.Destination_Address_Name__c = ShipperAddress.Id;
        //TestPick.Name = 'TestPickup';
        Insert TestPick;

     
         Product__c prodObj = new Product__c();
        prodObj.Name = 'ivalSHIP';
        insert prodObj;
        
          Shipment__c Ship = New Shipment__c();
        //Ship.Name = 'TestShipment';
        Ship.Pickup__c = TestPick.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = testAccts.Name;
        Ship.Customer__c = testAccts.Id;
        Ship.Short_URL__c = 'abc123@xyz.com';
        Ship.Invoice_Calculated_Amount__c = 123;
        Ship.Total_Charge__c = 3456;
        Ship.Total_Invoice_Value__c = 876;
        Ship.Shipper_Email_ID__c = 'abc@sdcn.com';
        Ship.Shipper__c = 'abcxyz';
        Ship.Consignee_Name__c = 'abcxyz';
        Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        Ship.Bill_To_Party_PAN__c = 'EQUPNB123K';
        //Ship.Shipment_Lot__c = ShipLot1.Id;
        //Ship.Origin_Pincode__c = '444603';
        ///Ship.Destination_Pincode__c = '110001';
        Ship.Product_Name__c = prodObj.Id;
        Ship.Gross_Weight__c = 123;
        //Ship.BVC_Products__c ='GoldSHIP Express C2C';
        Ship.Bill_to_1__c = 'Shipper';
        Ship.RecordTypeId = operationRecrodTypeId;
        Ship.Shipment_Date__c = System.today();
        Ship.Customer__c = testAccts.Id;
        Ship.Shipper_PAN__c = 'Dcw3r3';
        Ship.Consignee_PAN__c = 'SFR323';
        Ship.Shipping_Note_Number__c = 'BM55345';
        Ship.Status__c = 'Billed';
        Ship.E_Invoice_Number__c = '2223';
        Ship.Shipment_Date__c = System.Today() ;
        Ship.Product_Description__c = 'trest';
        Ship.Net_Weight__c = 6 ;
        Ship.Net_Weight_UOM__c = '6ks';
        Ship.Gross_Weight__c = 8 ;
        Ship.Gross_Weight_UOM__c = '8kg' ;
        Ship.Number_of_Packages__c = 9 ;
        Ship.Insurance_By_BVC__c = 'test';
        Ship.Billing_Account__c = testAccts.Id;
        Ship.Shipper_Name_TMS__c = ShipperAcc.Id;
        Ship.Consignee_Name_TMS__c = testAccts2.Id;
        Ship.Origin_Address_Name__c = ShipperAddress.Id;
        Ship.Destination_Address_Name__c = ShipperAddress.Id;
        Ship.Insurance_By__c = 'BVC';
        Ship.Gross_Weight_UOM_TMS__c = 'KG';
        insert Ship;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/ViewShipment/' ;
        req.addParameter('Shipping_Number',Ship.Shipping_Note_Number__c);
        req.addParameter('Reference_Number',testAccts.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        ViewShipmentService.GetviewShipment();
        test.stopTest();
    }
     @istest
    public static void  GetServiceAPierror() {
        test.startTest();
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/ViewShipment/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        ViewShipmentService.GetviewShipment();
        test.stopTest();
    }
    @istest
    public static void  GetServiceAPierror2() {
        test.startTest();
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/ViewShipment/';
         req.addParameter('Shipping_Number','');
        req.addParameter('Reference_Number','test');

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        ViewShipmentService.GetviewShipment();
        test.stopTest();
    }
}