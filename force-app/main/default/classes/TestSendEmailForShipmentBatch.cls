@isTest
public class TestSendEmailForShipmentBatch {
    Static TestMethod Void SendEmailForShipmentBatchMethod(){
        Account Acc = New Account();
        Acc.Name = 'TestAccount';
        Acc.BVC_Company_Type__c = 'Domestic';
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Insert Acc;
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.Name = 'TestAddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.Id;
        TestAdd.Source__c = 'Manual';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.PINCODE__c = '123456';
        Insert TestAdd;
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;
        TestPick.Shipper_Name__c = Acc.Id;
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.Name = 'TestPickup';
        Insert TestPick;
        Shipment_Lot__c ShipLot = New Shipment_Lot__c();
        ShipLot.Name = 'Test';
        ShipLot.Amount_Calculated_For_All_Shipment__c = TRUE;
        Insert ShipLot;
        List<Shipment__c> ShipList = New List<Shipment__c>();
        For(integer i = 0; i<20; i++){
            Shipment__c Ship = New Shipment__c();
            Ship.Name = 'TestShipment'+i;
        	Ship.Pickup__c = TestPick.Id;
        	Ship.Bill_To_GSTIN__c = 'ABCD123L'+i;
        	Ship.Bill_To_Party_Address__c = 'Test Address'+i;
        	Ship.Bill_To_Party_PAN__c = 'ABCD1234M'+i;
        	Ship.Billing_Entity_Name__c = Acc.Name;
        	Ship.Customer__c = Acc.Id;
            Ship.Short_URL__c = 'abc123@xyz.com';
            Ship.Invoice_Calculated_Amount__c = 123+i;
            Ship.Total_Charge__c = 3456+i;
            Ship.Total_Invoice_Value__c = 876+i;
            ShipList.add(Ship);
        }
        Insert ShipList;
        Test.startTest();
        SendEmailForShipmentBatch obj = new SendEmailForShipmentBatch();
        Database.executeBatch(obj);
        Test.StopTest();
    }
}