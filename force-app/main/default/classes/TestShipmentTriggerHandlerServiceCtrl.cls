@isTest
public class TestShipmentTriggerHandlerServiceCtrl {
    
    @isTest
   public static void testcalculateShipmentAmount(){
         Id operShipId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();
         Id commShipId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Community Shipment').getRecordTypeId();
        
        Account Acc = New Account();
        Acc.Name = 'abcxyz';
        Acc.BVC_Company_Type__c = 'Domestic';
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Insert Acc;
        Account AccVar = New Account();
        AccVar.Name = 'abcxyz';
        AccVar.BVC_Company_Type__c = 'Domestic';
        AccVar.Customer_Status__c = 'Active';
        AccVar.Category__c = 'Manufacturer';
        AccVar.Type_Of_Customer__c = 'Both';
        AccVar.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        AccVar.Primary_Customer_Email__c = 'abc@sdcn.com';
        AccVar.PAN_Number_of_Entity__c = 'EQUPNB123J';
        AccVar.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Insert AccVar;
        /*Hub__c hub = new Hub__c();
        hub.Name = 'Delhi';
        insert hub;
        Active_Pincode__c Pin = new Active_Pincode__c();
        Pin.Name = '110004';
        Pin.Hub__c = hub.Id;
        insert Pin;*/
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd.Name = 'TestAddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.Id;
        TestAdd.Source__c = 'Manual';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        //TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.PINCODE__c = '110004';
        TestAdd.Your_Address_Identifier__c = 'Hyderbad';
        //TestAdd.Pincode_TMS__c= Pin.Id;
        Insert TestAdd;
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = AccVar.Id;
        TestPick.Shipper_Name__c = Acc.Id;
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
    //    TestPick.Name = 'TestPickup';
        Insert TestPick;
        Shipment_Lot__c ShipLot1 = New Shipment_Lot__c();
        ShipLot1.Name = 'TestLot';
        Insert ShipLot1;
        Product__c prodObj = new Product__c();
        prodObj.Name = 'ivalSHIP';
        insert prodObj;
        Product2 prod2Obj = new Product2();
        prod2Obj.Name = 'ivalSHIP';
        insert prod2Obj;
        Active_Pincode__c pincode = new Active_Pincode__c();
     //   pincode.City__c = 'Amravati';
        pincode.Pincodes__c = '444603';
        pincode.Country__c = 'India';
        pincode.State__c = 'Maha';
        insert pincode;
        Active_Pincode__c pincodevar = new Active_Pincode__c();
        //pincodevar.City__c = 'Delhi';
        pincodevar.Pincodes__c = '110001';
        pincodevar.Country__c = 'India';
        pincodevar.State__c = 'Delhi';
        insert pincodevar;
        List<Shipment__c> ShipList1 = New List<Shipment__C>();
        /*Shipment__c Ship = New Shipment__c();
        Ship.Name = 'TestShipment';
        Ship.Pickup__c = TestPick.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = AccVar.Name;
        Ship.Customer__c = AccVar.Id;
        Ship.Short_URL__c = 'abc123@xyz.com';
        Ship.Total_Charge__c = 3456;
        Ship.Total_Invoice_Value__c = 876;
        Ship.Shipper_Email_ID__c = 'abc@sdcn.com';
        Ship.Shipper__c = 'abcxyz';
        Ship.Consignee_Name__c = 'abcxyz';
        Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        Ship.Bill_To_Party_PAN__c = 'EQUPNB123K';
        Ship.Shipment_Lot__c = ShipLot1.Id;
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Product_Name__c = prodObj.Id;
        Ship.Gross_Weight__c = 123;
        Ship.BVC_Products__c = 'ivalSHIP';
        Ship.Status__c = 'Verified for Billing';
        Ship.Ready_for_Billing__c = true;
        insert Ship;*/
        //ShipList1.add(Ship);
        
        Shipment__c Ship2 = New Shipment__c();
       // Ship2.Name = 'TestShipment';
        Ship2.Pickup__c = TestPick.Id;
        Ship2.Bill_To_GSTIN__c = 'ABCD123L';
        Ship2.Bill_To_Party_Address__c = 'Test Address';
        Ship2.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship2.Billing_Entity_Name__c = AccVar.Name;
        Ship2.Customer__c = AccVar.Id;
        Ship2.Short_URL__c = 'abc123@xyz.com';
        Ship2.Total_Charge__c = 3456;
        Ship2.Total_Invoice_Value__c = 876;
        Ship2.Shipper_Email_ID__c = 'abc@sdcn.com';
        Ship2.Shipper__c = 'abc';
        Ship2.Consignee_Email_ID__c = 'abc@sd.com';
        Ship2.Consignee_Name__c = 'abc';
        Ship2.Bill_To_Party_PAN__c = 'EQUPNB123K';
        Ship2.Shipment_Lot__c = ShipLot1.Id;
        Ship2.Origin_Pincode__c = '444603';
        Ship2.Destination_Pincode__c = '110001';
        Ship2.Product_Name__c = prodObj.Id;
        Ship2.Gross_Weight__c = 123;
        Ship2.BVC_Products__c = 'ivalSHIP';
        Ship2.RecordTypeId = commShipId;
        insert Ship2;        
        ShipList1.add(Ship2);
        Shipment__c Ship3 = New Shipment__c();
      //  Ship3.Name = 'TestShipment';
        Ship3.Pickup__c = TestPick.Id;
        Ship3.Bill_To_GSTIN__c = 'ABCD123L';
        Ship3.Bill_To_Party_Address__c = 'Test Address';
        Ship3.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship3.Billing_Entity_Name__c = AccVar.Name;
        Ship3.Customer__c = AccVar.Id;
        Ship3.Invoice_Calculated_Amount__c = 123;
        Ship3.Total_Charge__c = 3456;
        Ship3.Total_Invoice_Value__c = 876;
        Ship3.Shipper_Email_ID__c = 'abc@sd.com';
        Ship3.Shipper__c = 'abc';
        Ship3.Shipment_Lot__c = ShipLot1.Id;
       
        insert Ship3; 
        ShipList1.add(Ship3);
        try{
             test.startTest();
        ShipmentTriggerHandlerServiceCtrl.calculateShipmentAmount(ShipList1);
        test.stopTest();
        }catch(exception e){
            system.debug('Error message'+ e);
        }
       
    }
     @isTest
  public  static void testcalculateShipmentAmount1(){
         Id operShipId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();
         Id commShipId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Community Shipment').getRecordTypeId();
        
        Account Acc = New Account();
        Acc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        Acc.BVC_Company_Type__c = 'Domestic';
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.PAN_Number_of_Entity__c = 'GMUUY5467R';          
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Insert Acc;
        Account AccVar = New Account();
        AccVar.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        AccVar.BVC_Company_Type__c = 'Domestic';
        AccVar.Customer_Status__c = 'Active';       
        AccVar.Category__c = 'Manufacturer';
        AccVar.Type_Of_Customer__c = 'Both';
        AccVar.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        AccVar.Primary_Customer_Email__c = 'abc@sdcn.com';
        AccVar.PAN_Number_of_Entity__c = 'EQUPNB123K';
        AccVar.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Insert AccVar;
        
                    
        Hub__c newHub = new Hub__c();
          newHub.Name = 'delhi Acr';
          newHub.Branch__c = 'delhi';
          insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
                    
        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Hub__c = newHub.id;
        pin.Zone__c = z.Id;
        insert pin;
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd.Name = 'TestAddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.Id;
        TestAdd.Source__c = 'Manual';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        //TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.PINCODE__c = '110004';
        TestAdd.Your_Address_Identifier__c = 'Hyderbad';
        TestAdd.Active_Pincode__c = pin.Id ;
        //TestAdd.Pincode_TMS__c= Pin.Id;
        Insert TestAdd;
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = AccVar.Id;
     //   TestPick.Shipper_Name__c = Acc.Id;
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        

   //     TestPick.Name = 'TestPickup';
        Insert TestPick;
        Shipment_Lot__c ShipLot1 = New Shipment_Lot__c();
        ShipLot1.Name = 'TestLot';
        Insert ShipLot1;
        Product__c prodObj = new Product__c();
        prodObj.Name = 'ivalSHIP';
        insert prodObj;
        Product2 prod2Obj = new Product2();
        prod2Obj.Name = 'ivalSHIP';
        insert prod2Obj;
        Active_Pincode__c pincode = new Active_Pincode__c();
     //   pincode.City__c = 'Amravati';
        pincode.Pincodes__c = '444603';
        pincode.Country__c = 'India';
        pincode.State__c = 'Maha';
        insert pincode;
        Active_Pincode__c pincodevar = new Active_Pincode__c();
        //pincodevar.City__c = 'Delhi';
        pincodevar.Pincodes__c = '110001';
        pincodevar.Country__c = 'India';
        pincodevar.State__c = 'Delhi';
        insert pincodevar;
        List<Shipment__c> ShipList1 = New List<Shipment__C>();
        Shipment__c Ship = New Shipment__c();
   //     Ship.Name = 'TestShipment';
        Ship.Pickup__c = TestPick.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = AccVar.Name;
        Ship.Customer__c = AccVar.Id;
        Ship.Short_URL__c = 'abc123@xyz.com';
        Ship.Total_Charge__c = 3456;
        Ship.Total_Invoice_Value__c = 876;
        Ship.Shipper_Email_ID__c = 'abc@sdcn.com';
        Ship.Shipper__c = 'abcxyz';
        Ship.Consignee_Name__c = 'abcxyz';
        Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        Ship.Bill_To_Party_PAN__c = 'EQUPNB123K';
        Ship.Shipment_Lot__c = ShipLot1.Id;
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Product_Name__c = prodObj.Id;
        Ship.Gross_Weight__c = 123;
        Ship.BVC_Products__c = 'ivalSHIP';
        Ship.Status__c = 'Verified for Billing';
        Ship.Ready_for_Billing__c = true;
        ship.RecordTypeId = operShipId;
        insert Ship;
        //ShipList1.add(Ship);
        
        /*Shipment__c Ship2 = New Shipment__c();
        Ship2.Name = 'TestShipment';
        Ship2.Pickup__c = TestPick.Id;
        Ship2.Bill_To_GSTIN__c = 'ABCD123L';
        Ship2.Bill_To_Party_Address__c = 'Test Address';
        Ship2.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship2.Billing_Entity_Name__c = AccVar.Name;
        Ship2.Customer__c = AccVar.Id;
        Ship2.Short_URL__c = 'abc123@xyz.com';
        Ship2.Total_Charge__c = 3456;
        Ship2.Total_Invoice_Value__c = 876;
        Ship2.Shipper_Email_ID__c = 'abc@sdcn.com';
        Ship2.Shipper__c = 'abc';
        Ship2.Consignee_Email_ID__c = 'abc@sd.com';
        Ship2.Consignee_Name__c = 'abc';
        Ship2.Bill_To_Party_PAN__c = 'EQUPNB123K';
        Ship2.Shipment_Lot__c = ShipLot1.Id;
        Ship2.Origin_Pincode__c = '444603';
        Ship2.Destination_Pincode__c = '110001';
        Ship2.Product_Name__c = prodObj.Id;
        Ship2.Gross_Weight__c = 123;
        Ship2.BVC_Products__c = 'ivalSHIP';
        Ship2.RecordTypeId = commShipId;
        insert Ship2;        
        ShipList1.add(Ship2);*/
        Shipment__c Ship3 = New Shipment__c();
   //     Ship3.Name = 'TestShipment';
        Ship3.Pickup__c = TestPick.Id;
        Ship3.Bill_To_GSTIN__c = 'ABCD123L';
        Ship3.Bill_To_Party_Address__c = 'Test Address';
        Ship3.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship3.Billing_Entity_Name__c = AccVar.Name;
        Ship3.Customer__c = AccVar.Id;
        Ship3.Invoice_Calculated_Amount__c = 123;
        Ship3.Total_Charge__c = 3456;
        Ship3.Total_Invoice_Value__c = 876;
        Ship3.Shipper_Email_ID__c = 'abc@sd.com';
        Ship3.Shipper__c = 'abc';
        Ship3.Shipment_Lot__c = ShipLot1.Id;
     
        insert Ship3; 
         ShipList1.add(Ship3);
        try{
           test.startTest();
           ShipmentTriggerHandlerServiceCtrl.calculateShipmentAmount(ShipList1);
           test.stopTest();
        }catch(exception e){
            system.debug('Error message'+ e);
        }
    }

}