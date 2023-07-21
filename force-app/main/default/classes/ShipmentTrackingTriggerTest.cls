@isTest
public class ShipmentTrackingTriggerTest {
    Public static testMethod void ShipmentTrackingTestMethod(){                
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> UpdateShipmentlist = new List<shipment__c>();        
        user user1= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];              
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

     

        AddressBook__c TestShipAdd = New AddressBook__c();
        TestShipAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestShipAdd.Name = 'TestShipAddress';
        TestShipAdd.GSTIN__c = '';
        TestShipAdd.TRADE_NAME__c = shippingAcc.Name;
        TestShipAdd.Customer__c = shippingAcc.id;
        TestShipAdd.Source__c = 'Manual';
        TestShipAdd.Your_Address_Identifier__c = 'billing';
        TestShipAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestShipAdd.ADDRESS1__c = 'ABC Street';
        TestShipAdd.CITY__c = 'Test City';
        TestShipAdd.STATE__c = 'Test State';
        TestShipAdd.COUNTRY__c = 'Test Country';
        TestShipAdd.Active_Pincode__c = pin.Id ;
       
        Insert TestShipAdd;
        
     
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
            TestPick.Pickup_Status__c='Completed';
 			insert TestPick;
        
       Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
             newpickup.Delivery_Route_Number__c = 'RTNO-45';
             newpickup.Hub__c = newhub.id;

             insert newpickup;

			Shipment__c ship1 = new Shipment__c();           
        	ship1.Customer_Product_Category__c = 'GoldSHIP';
        	ship1.Customer__c = Acc.id;
        	ship1.Shipper_Name_TMS__c =shippingAcc.Id;
        	ship1.Origin_Address_Name__c=TestShipAdd.Id;
			ship1.Net_Weight__c = 12;        
        	ship1.Net_Weight_UOM_TMS__c='Gram';
        	ship1.Shipment_Value__c=12;
        	ship1.Insurance_By__c='BVC';
        	ship1.Pickup__c= TestPick.Id;
           ship1.CreatedById = user1.Id;
        	insert ship1;

        //
        Secure_Bag__c SB = new Secure_Bag__c();
        SB.Shipment__c = ship1.Id;
        SB.Current_Scan_Loction__c='Created';
        insert SB;
        //
        Test.startTest();
        Shipment_Tracking__c sht = new Shipment_Tracking__c();
        sht.Shipment__c=ship1.Id;        
        sht.Scan_Time__c = Date.newInstance(2022, 06, 09);
        sht.Location__c='Created';
        insert sht; 
        
        List<Shipment_Tracking__c> ids = new List<Shipment_Tracking__c>();
        ids.add(sht);
       // UpdatePickupUsingSB.getAccountNames(ids);
        ShipmentShare.ShareShipment(ids);
        Test.stopTest();
        
    }
}