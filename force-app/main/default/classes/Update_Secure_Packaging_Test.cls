@isTest(seeAllData=False)
public class Update_Secure_Packaging_Test {
    
    @isTest
    public static void updateRelatedSecurePackaging_Test()
    {
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
        Insert TestPick;
        
        List<Shipment__c> ShipList = New List<Shipment__c>();
        Shipment__c Ship = New Shipment__c();
        Ship.Pickup__c = TestPick.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123LR';
        Ship.Bill_To_Party_Address__c = 'Test Addresss';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234MW';
        Ship.Billing_Entity_Name__c = Acc.Name;
        Ship.Customer__c = Acc.Id;
        Ship.Short_URL__c = 'abc123@xyz.com';
        Ship.Invoice_Calculated_Amount__c = 12367;
        Ship.Total_Charge__c = 34566;
        Ship.Total_Invoice_Value__c = 8769;
        Ship.Shipping_Note_Number__c = '@xyz';
        ShipList.add(Ship);
		Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','@xyz','Available',true);        
        Test.startTest();
         Update_Secure_Packaging.updateRelatedSecurePackaging(ShipList);
        Test.stopTest();   
    }
}