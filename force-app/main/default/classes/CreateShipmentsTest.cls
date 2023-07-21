@istest
public class CreateShipmentsTest {
   
    @istest
    public static void  CreateapiSucess() {
        test.startTest();
        Id billingAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id shipAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Account testAccts = new Account();
        testAccts.Name='Shipping Tesst'; 
        testAccts.First_Name__c = 'Te';
        testAccts.Last_Name__c ='shipping';    
        testAccts.Email__c = 'test@gmail.com';
        testAccts.Mobile__c = '9999999999';
        testAccts.PAN_Number_of_Entity__c = 'AADCM9043R';
        testAccts.KARZAA_KYC_Verified__c = false;
        testAccts.Stitch_Profile_API_Status__c = false ;
        testAccts.Credit_Rating_API_Status__c = false;
        testAccts.Financial_Summary_API_Status__c = false;
        testAccts.Entity_Id__c = 'L74999TZ1984PLC001456';
        testAccts.AWS_SYNC_Status__c = 'Pending';
        testAccts.RecordTypeId = shipAcc;
        insert testAccts;
         

        Account testAccts1 = new Account();
        testAccts1.Name='Billing Tesst'; 
        testAccts1.First_Name__c = 'Te';
        testAccts1.Last_Name__c ='Billing';    
        testAccts1.Email__c = 'testa@gmail.com';
        testAccts1.Mobile__c = '9999999994';
        testAccts1.PAN_Number_of_Entity__c = 'AADCM9043R';
        testAccts1.KARZAA_KYC_Verified__c = false;
        testAccts1.Stitch_Profile_API_Status__c = false ;
        testAccts1.Credit_Rating_API_Status__c = false;
        testAccts1.Financial_Summary_API_Status__c = false;
        testAccts1.Entity_Id__c = 'L74999TZ1984PLC001456';
        testAccts1.AWS_SYNC_Status__c = 'Pending';
        testAccts1.RecordTypeId = billingAcc;
        insert testAccts1; 
        
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        //req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/CreateShipment/'+testAccts.Id;
        req.requestURI = 'https://bvc2--damctmsdev.my.salesforce.com/services/apexrest/CreateShipment/'+testAccts1.Id;
        req.httpMethod = 'POST';
        //String str = '[{"ShipmentDate": "2022-06-14", "BVC_Service": "ValSHIP", "Origin_Address_Pincode": "110055", "Origin_Address_Line1": "C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE", "Origin_Address_City": "Delhi", "Destination_Address_Pincode": "110055", "Destination_Address_Line1": "C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE", "Destination_Address_City": "Delhi", "Origin_Address_Person": "", "Origin_Address_Name": "110055,C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE, ,Delhi", "Destination_Address_Name": "110055,C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE, ,Delhi", "Shipper_PAN": "AADCM9043R", "Consignee_PAN": "ARUPA9695D", "Billing_Entity_Name": "BVCL DELHI", "Product_Description": "Diamond Jewellery", "Net_Weight": "12.00", "Net_Weight_UOM": "Gram", "Gross_Weight": "12.00", "Gross_Weight_UOM": "Gram", "Number_of_Packages": "1", "COD": false, "COD_Value": "0", "COD_Currency": "", "COD_Paid_Via": "", "Insurance": "BVC", "Shipment_Value_Currency": "INR", "Billing_Address": "110055,C/O VD JEWELS,MT-245,1ST FLOOR,STOTTE, BANK STREET,KAROL BAGH,Delhi", "Billing_Account": "Malabar Gold Pvt Ltd AADCM9043R - Billing AADCM9043R AADCM9043R AADCM9043P AADCM9043R", "Your_Address_Identifier_Destination": "for destination bulk fnjf4", "Your_Address_Identifier_Origin": "for origin bulk fjeifjf" },{ "ShipmentDate": "2022-06-14", "BVC_Service": "ValSHIP", "Origin_Address_Pincode": "110055", "Origin_Address_Line1": "C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE", "Origin_Address_City": "Delhi", "Destination_Address_Pincode": "110055", "Destination_Address_Line1": "C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE", "Destination_Address_City": "Delhi", "Origin_Address_Person": "", "Origin_Address_Name": "110055,C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE, ,Delhi", "Destination_Address_Name": "110055,C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE, ,Delhi", "Shipper_PAN": "AADCM9043R", "Consignee_PAN": "ARUPA9695D", "Billing_Entity_Name": "BVCL DELHI", "Product_Description": "Diamond Jewellery", "Net_Weight": "12.00", "Net_Weight_UOM": "Gram", "Gross_Weight": "12.00", "Gross_Weight_UOM": "Gram", "Number_of_Packages": "1", "COD": false, "COD_Value": "0", "COD_Currency": "", "COD_Paid_Via": "", "Insurance": "BVC", "Shipment_Value_Currency": "INR", "Billing_Address": "110055,C/O VD JEWELS,MT-245,1ST FLOOR,STOTTE, BANK STREET,KAROL BAGH,Delhi", "Billing_Account": "Malabar Gold Pvt Ltd AADCM9043R - Billing AADCM9043R AADCM9043R AADCM9043P AADCM9043R", "Your_Address_Identifier_Destination": "for destination bulk fenfef", "Your_Address_Identifier_Origin": "for origin bulknfefnfn"}]';
        //String str = '[{ "ShipmentDate": "2022-06-16", "BVC_Service": "ValSHIP", "Origin_Address_Pincode": "560078", "Origin_Address_Line1": "C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE", "Origin_Address_City": "Bangalore", "Destination_Address_Pincode": "500038", "Destination_Address_Line1": "C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE", "Destination_Address_City": "Hyderabad", "Origin_Address_Person": "", "Origin_Address_Name": "560078,C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE, ,Bangalore", "Destination_Address_Name": "500038,C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE, ,Hyderabad", "Shipper_PAN": "AAMCP2216Q", "Consignee_PAN": "ABAFA5201A", "Billing_Entity_Name": "BVCL KARNATAKA", "Product_Description": "Diamond Jewellery", "Net_Weight": "12.00", "Net_Weight_UOM": "Gram", "Gross_Weight": "12.00", "Gross_Weight_UOM": "Gram", "Number_of_Packages": "1", "Shipment_Value":"10000", "COD": false, "COD_Value": "0", "COD_Currency": "", "COD_Paid_Via": "", "Insurance": "BVC", "Shipment_Value_Currency": "INR", "Shipper_Name":"PURPLE JEWELS PVT LTD - Shipping AAMCP2216Q", "Consignee_Name":"ACPL PRODUCTS AND JEWELLERY LLP - Shipping ABAFA5201A", "Billing_Address": "560078,NO 68 , PRATHIBA INDUSTRIAL ESTATE, KANAKPURA ROAD,Bangalore", "Billing_Account": "PURPLE JEWELS PRIVATE LIMITED - Billing AAMCP2216Q", "Your_Address_Identifier_Destination": "PURP8", "Your_Address_Identifier_Origin": "ACPL8" }]';
        String str = '[{ "ShipmentDate": "2022-06-14", "BVC_Service": "ValSHIP", "Origin_Address_Pincode": "110055", "Origin_Address_Line1": "C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE", "Origin_Address_Line2": "TT", "Origin_Address_City": "Delhi", "Destination_Address_Pincode": "110055", "Destination_Address_Line1": "C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE", "Destination_Address_Line2": "TD", "Destination_Address_City": "Delhi", "Origin_Address_Person": "", "Origin_Address_Name": "110055,C/O VD JEWELS,MT-100,1ST FLOOR,STOTTE,TT,Delhi", "Destination_Address_Name": "110055,C/O VD JEWELS,MT-101,1ST FLOOR,STOTTE,TD,Delhi", "Shipper_PAN": "AADCM9043R", "Consignee_PAN": "ARUPA9695D", "Shipper_Name":"MALABAR GOLD PVT LTD - Shipping AADCM9043R", "Consignee_Name":"Krishna - Shipping ARUPA9695D - Shipping ARUPA9695D", "Billing_Entity_Name": "BVCL DELHI", "Product_Description": "Diamond Jewellery", "Net_Weight": "12.00", "Net_Weight_UOM": "Gram", "Gross_Weight": "12.00", "Gross_Weight_UOM": "Gram", "Number_of_Packages": "1", "Shipment_Value":"10000", "COD": false, "COD_Value": "0", "COD_Currency": "", "COD_Paid_Via": "", "Insurance": "BVC", "Shipment_Value_Currency": "INR", "Billing_Address": "110055,C/O VD JEWELS,MT-245,1ST FLOOR,STOTTE, BANK STREET,KAROL BAGH,Delhi", "Billing_Account": "Malabar Gold Pvt Ltd AADCM9043R - Billing AADCM9043R AADCM9043R AADCM9043P AADCM9043R", "Your_Address_Identifier_Destination": "for destination bulk11", "Your_Address_Identifier_Origin": "for origin 011" }]';
        req.requestBody= Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res;
        system.debug('str'+str);
        CreateShipments.Createshipmentinfo();
        test.stopTest();
    }
    
    
    @istest
    public static void  CreateapiError2() {
        test.startTest();
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
        insert testAccts;         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/CreateShipment/'+testAccts.Id;
        req.httpMethod = 'POST';
        String str = '[{"ShipmentDate":"2022-03-29","BVC_Service":"GoldSHIP"}]';
        req.requestBody= Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res;
        
       CreateShipments.Createshipmentinfo();
        test.stopTest();
    }
    
    @istest
    public static void  CreateapiError() {
        test.startTest();
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/CreateShipment/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
       CreateShipments.Createshipmentinfo();
        test.stopTest();
    }
}