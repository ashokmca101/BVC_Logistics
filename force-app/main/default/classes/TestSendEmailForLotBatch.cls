@isTest
public class TestSendEmailForLotBatch {
	Static TestMethod Void EmailForLotBatchMethod(){
        Account Acc = New Account();
        Acc.Name = 'TestAccount';
        Acc.BVC_Company_Type__c = 'Domestic';
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Insert Acc;
        Contact Con = new Contact ();
        Con.LastName = 'TestContact';
        Con.Email = 'abc@asln.com';
        Con.AccountId = Acc.Id;
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
        
        
        List<Shipment_Lot__c> ShipLotList = New List<Shipment_Lot__c>();
        For(integer i = 0; i<200; i++){
            Shipment_Lot__c ShipLot = New Shipment_Lot__c();
            ShipLot.Name = 'Test'+i;
            ShipLot.Amount_Calculated_For_All_Shipment__c = TRUE;
            ShipLotList.add(ShipLot);
        }
        Insert ShipLotList;
        Shipment__c Ship = New Shipment__c();
        Ship.Name = 'TestShipment';
        Ship.Pickup__c = TestPick.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = Acc.Name;
        Ship.Customer__c = Acc.Id;
        Ship.Shipment_Lot__c = ShipLotList[1].Id;
        Insert Ship;
        Test.startTest();
        SendEmailForLotBatch obj = new SendEmailForLotBatch();
        Database.executeBatch(obj);
        Test.StopTest();
    }
}