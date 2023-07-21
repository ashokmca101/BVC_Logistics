@isTest
private without sharing class updateBillingAccount_Test {
    static testMethod void validateBillingAccount(){
        
        Active_Pincode__c ac=new Active_Pincode__c();
        ac.Name='110001';
        ac.City__c='Delhi';
        ac.Country__c='India';
        ac.State__c='Delhi';
        insert ac;

        Account acc0=new Account();
        acc0.Name='Account without Child';
        acc0.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        insert acc0;

        AddressBook__c address0=new AddressBook__c();
        address0.Name='Delhi Test0';
        address0.Pincode_TMS__c=ac.id;
        address0.Customer__c=acc0.id;
        insert address0;
        acc0.Primary_Address__c=address0.id;
        update acc0;
        
        Shipment__c shp0=new Shipment__c();
        
        shp0.Name='Test 1';
        shp0.Insurance_By__c='BVC';
        shp0.Customer__c=acc0.id;
        insert shp0;

        Account acc=new Account();
        acc.Name='Parent 1';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        insert acc;
        Account acc1=new Account();
        acc1.Name='Child 1';
        acc1.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        acc1.ParentId=acc.id;
        insert acc1;

        AddressBook__c address=new AddressBook__c();
        address.Name='Delhi Test';
        address.Pincode_TMS__c=ac.id;
        address.Customer__c=acc.id;
        insert address;
        acc.Primary_Address__c=address.id;
        update acc;
        
        Shipment__c shp=new Shipment__c();
        
        shp.Name='Test 1';
        shp.Insurance_By__c='BVC';
        shp.Customer__c=acc.id;
        shp.Billing_Account__c=acc1.id;
        insert shp;

        Account acc2=new Account();
        acc2.Name='Parent 2';
        acc2.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        insert acc2;
        Account acc3=new Account();
        acc3.Name='Child 2';
        acc3.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        acc3.ParentId=acc2.id;
        insert acc3;

        AddressBook__c address1=new AddressBook__c();
        address1.Name='Delhi Test 1';
        address1.Pincode_TMS__c=ac.id;
        address1.Customer__c=acc2.id;
        insert address1;
        acc2.Primary_Address__c=address1.id;
        update acc;
        
        Shipment__c shp1=new Shipment__c();
        
        shp1.Name='Test 2';
        shp1.Insurance_By__c='Consignee';
        shp1.Customer__c=acc2.id;
        insert shp1;
    }
}