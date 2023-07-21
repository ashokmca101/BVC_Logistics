@isTest
public class Address_TriggerHandlerServiceCtrl_Test {
    Static TestMethod Void RegisteredAcc_TriggerHandlerServiceCtrlTest(){
        Test.startTest();
        Account testAccts1 = New Account();
        testAccts1.Name = 'TestAccount1';
        testAccts1.BVC_Company_Type__c = 'Domestic';
        testAccts1.Customer_Status__c = 'Active';
        testAccts1.Category__c = 'Manufacturer';
        testAccts1.Type_Of_Customer__c = 'Both';
        testAccts1.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        insert testAccts1;
        Account testAccts2 = New Account();
        testAccts2.Name = 'TestAccount2';
        testAccts2.BVC_Company_Type__c = 'Domestic';
        testAccts2.Customer_Status__c = 'Active';
        testAccts2.Category__c = 'Manufacturer';
        testAccts2.Type_Of_Customer__c = 'Both';
        testAccts2.BVC_Legal_Entity__c = 'B.V. Chinai & Co. (India) Private Limited';
        insert testAccts2;
        List<Registered_Account__c> RegAccList1 = New List<Registered_Account__c>();
        List<Registered_Account__c> RegAccList2 = New List<Registered_Account__c>();
        Registered_Account__c RegAcc1 = New Registered_Account__c();
        //RegAcc1.Name = 'TestRegAccount1';
        RegAcc1.AWS_Sync_Status__c = 'Pending';
        RegAcc1.BVC_Legal_Entity__c = 'B.V. Chinai & Co. (India) Private Limited';
        RegAcc1.BVC_Software_Id__c = 'MERCURY - A1';
        RegAcc1.Customer__c = testAccts1.Id;
        Insert RegAcc1;   
        Registered_Account__c RegAcc2 = New Registered_Account__c();
        //RegAcc2.Name = 'TestRegAccount2';
        RegAcc2.AWS_Sync_Status__c = 'Pending';
        RegAcc2.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        RegAcc2.BVC_Software_Id__c = 'MERCURY - A1';
        RegAcc2.Customer__c = testAccts2.Id;
        Insert RegAcc2;
        Id BillingId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id ShippingId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();        
        List<AddressBook__c> AddressList = New List<AddressBook__c>();
        AddressBook__c ab=new AddressBook__c();
            ab.name='demo';
            ab.ADDRESS1__c='Address1';
            ab.ADDRESS2__c='Address2';
            ab.CITY__c='city';
            ab.COUNTRY__c='India';
            ab.Customer__c=testAccts1.id;
            ab.PINCODE__c='854105';
            ab.District__c='district';
            ab.TRADE_NAME__c=testAccts1.name;
            //ab.GSTIN__c='UNREGISTERRED12';
            ab.Is_Billing_Address__c=true;
        	ab.RecordTypeId = BillingId;
        	ab.GSTIN__c = '';
        insert ab;
        AddressList.add(ab);
        AddressBook__c ab1=new AddressBook__c();
            ab1.name='demo';
            ab1.ADDRESS1__c='Address1';
            ab1.ADDRESS2__c='Address2';
            ab1.CITY__c='city';
            ab1.COUNTRY__c='India';
            ab1.Customer__c=testAccts2.id;
            ab1.PINCODE__c='854105';
            ab1.District__c='district';
            ab1.TRADE_NAME__c=testAccts2.name;
            ab1.GSTIN__c='';
        	ab1.RecordTypeId = ShippingId;
            ab1.Is_Billing_Address__c=false;
        insert ab1;
        AddressList.add(ab1);
        Address_TriggerHandlerServiceCtrl.updateBillingAddressCheckBox(AddressList);
        Address_TriggerHandlerServiceCtrl.createPICKUPADDRESSMAPPING(AddressList);
        Address_TriggerHandlerServiceCtrl.addressPickupMappingCreation(AddressList);
        Test.stopTest();
    }
}