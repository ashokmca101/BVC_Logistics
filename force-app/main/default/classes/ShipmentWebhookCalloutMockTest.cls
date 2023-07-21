@isTest
public class ShipmentWebhookCalloutMockTest 
{
    @isTest
	static void ShipmentMockTest()
    {
        Test.setMock(HttpCalloutMock.class, new ShipmentWebHookCalloutMock());
      //  String jsoncontent ='Id":"123456","Name":"Name"}';
        
              
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        
       user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];
              
        Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '94746367837';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
  //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';      
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
     //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '9877287843';
        insert shippingAcc;
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
                 
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
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
       
        Insert TestAdd;
       
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
             newexhibition.Name = 'New OFC opening';
             newexhibition.COA_Exhibition_Code__c = 'OFC-21';
             insert newexhibition ;
                        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
              newLot.name = 'New Shipment Lot';
              insert newLot;                               
            
        Pickup__c TestPick = New Pickup__c();
            TestPick.Pickup_Date__c = System.Today();
            TestPick.Customer__c = Acc.Id;        
            TestPick.Origin_Address_Name__c = TestAdd.Id;
            TestPick.Destination_Address_Name__c = TestAdd.Id;
         //   TestPick.Name = 'TestPickup';
           Insert TestPick; 
        
       Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
             newpickup.Delivery_Route_Number__c = 'RTNO-45';
             newpickup.Hub__c = newhub.id;
   //        newpickup.Delivery_Route_Assigned_To__c = u.id;
             insert newpickup;

        
           Shipment__c ship = new Shipment__c();          
           ship.Invoice_Calculated_Amount__c = 29000;
           Ship.Total_Charge__c = 3456;
           ship.Customer__c = Acc.id; 
           ship.Insurance_By__c = 'BVC';
     //    ship.Shipper_Name_TMS__c = shippingAcc.Name;
    //     ship.Consignee_Name_TMS__c = shippingAcc.name;
     //    ship.Origin_Address_Name__c = testAdd.name;
           ship.Destination_Address_Name__c = TestAdd.Id;
           ship.Net_Weight__c = 12;
           ship.Net_Weight_UOM_TMS__c = 'gram';
           ship.Shipment_Value__c = 21;
           ship.Pickup__c = TestPick.id;
           Ship.Total_Invoice_Value__c = 876;
           ship.Billing_Account__c = acc.Id;
           Ship.Bill_To_GSTIN__c = 'ABCD123L';
           Ship.Bill_To_Party_Address__c = 'Test Address';
           Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
           Ship.Billing_Entity_Name__c = Acc.Name;
           ship.AddressBook__c = TestAdd.Id;
           ship.Delivery_Route_Assigned_To__c = u.id;                                                
           ship.Origin_Hub__c= newHub.Id;  
           ship.Status__c = 'billed';   
           Ship.Shipper__c = 'abcxyz';
           ship.Tracking_Status__c = 'Delivered';          
         
           Ship.Origin_Pincode__c = '444603';
           Ship.Destination_Pincode__c = '110001';
           Ship.Consignee_Name__c = 'abcxyz';
       //  ship.Shipment_Lot__c = newLot.id;
           ship.Gross_Weight__c = 12.2;
           ship.Shipment_Stage__c = 'BVC weighment done';
           Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
           ship.Delivery_Route_Number__c = newpickup.Id;
           ship.Customer_Product_Category__c = 'ValSHIP';
           ship.Origin_Type__c = 'Online';
           ship.Destination_Type__c = 'Online';
           ship.Product_Description__c = 'Product_Category__c';
           ship.BVC_Product_Name__c = 'valSHIP within city';
           ship.BVC_Product_Name__c = 'valSHIP Surface C2C';
           ship.BVC_Product_Name__c = 'valSHIP Express C2C';
           ship.IsExhibition__c = true;
           ship.Status__c = 'pending billing';
           ship.Exhibition__c = newexhibition.id;
           ship.Exhibition_Movement_Type__c= 'Inward';
           ship.Exhibition_Name__c = 'newExhibition';
           ship.Shipment_Created_Through__c = 'Mobile App';                     
           ship.Product_Code__c = '';         
           newShipmentlist.add(ship);                  
           insert newShipmentlist;
        String jsoncontent = ShipmentWebHook.jsonContent(newShipmentlist);
        ShipmentWebHook.sendRequest(jsoncontent);          
    }
}