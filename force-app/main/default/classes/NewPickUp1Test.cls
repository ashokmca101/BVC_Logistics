@isTest
public class NewPickUp1Test 
{
	@testSetup
    static void testSetup(){
        Id userId=UserInfo.getUserId();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Account a=new Account();
        a.name='Test Billing Customer Account';
        a.RecordTypeId = devRecordTypeId;
        a.PAN_Number_of_Entity__c  ='1234556778';
        a.BVC_Company_Type__c='Domestic';
        a.Customer_Status__c ='Active';
        a.Type_Of_Customer__c='Customer';
        a.Category__c='Manufacturer';
        a.ST_Pricing_Type__c = 'Non ACR';
        a.BVC_Legal_Entity__c='B.V. Chinai & Co. (India) Private Limited';
        insert a;

        Account a1=new Account();
        a1.name='Test Shipping Customer Account';
        a1.RecordTypeId = devRecordTypeId1;
        a1.PAN_Number_of_Entity__c  ='1234566778';
        a1.BVC_Company_Type__c='Domestic';
        a1.Customer_Status__c ='Active';
        a1.Type_Of_Customer__c='Customer';
        a1.Category__c='Manufacturer';
        a1.BVC_Legal_Entity__c='B.V. Chinai & Co. (India) Private Limited';        
        insert a1;

        Id devRecordTypeId5 = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        
        List<AddressBook__c> addresslist=new list<AddressBook__c>();
        AddressBook__c ab=new AddressBook__c();
            ab.name='1-7-12,Sanfranciisco, washigton,United States of America';
            ab.ADDRESS1__c='Address1';
            ab.ADDRESS2__c='Address2';
            ab.CITY__c='city';
            ab.COUNTRY__c='India';
            ab.Customer__c=a1.id;
            ab.PINCODE__c='854105';
            ab.District__c='district';
            ab.TRADE_NAME__c=a.name;
            ab.GSTIN__c='';
        ab.recordtypeId=devRecordTypeId5;
            
        insert ab;
        AddressBook__c ab1=new AddressBook__c();
            ab1.name='1-7-132,Sanfranciisco, washigton,United States of America';
            ab1.ADDRESS1__c='Address5';
            ab1.ADDRESS2__c='Address6';
            ab1.CITY__c='city';
            ab1.COUNTRY__c='India';
            ab1.Customer__c=a1.id;
            ab1.PINCODE__c='854106';
            ab1.District__c='district';
            ab1.TRADE_NAME__c=a.name;
            ab1.GSTIN__c=''; 
        ab1.recordtypeId=devRecordTypeId5;
        insert ab1;
        
        Pickup__c p=new Pickup__c();
        p.Contact_Person_Name__c='cp';
        p.Contact_Person_Number__c=1234567890;
        p.Destination__c='test';
        p.Insurance_By__c='test';
        p.Net_Weight__c=35;
        p.Net_Weight_UOM__c='45';
        p.No_Of_Parcels__c=9;
        p.Pickup_Date__c=date.today();
        p.Pickup_Time__c=system.now();
        p.Product_Type__c='ad';
        p.TypeOfPickup__c='demo';
        p.Pickup_Address__c=ab.Id;
        p.Customer__c=a.id;
        String dt='2017-01-10T14:53:55.000+0000';
        insert p;        
    }
    @isTest
    public static void testMethod1() 
    {         
        Test.startTest();  
        PageReference pageRef = new PageReference('/apex/NewPickupVF?core.apexpages.request.devconsole=1');
        Pickup__c p = [select Id from Pickup__c limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        Test.setCurrentPage(pageRef);
        NewPickUp1 tc = new NewPickUp1(sc);
        Account ak = [select Id,Name from Account where RecordType.Name=:'Shipping' limit 1];
        Account ak1 = [select Id,Name from Account where RecordType.Name=:'Billing' limit 1];
        AddressBook__c ab5 = [select Id,Name from AddressBook__c where PINCODE__c=:'854106'  limit 1];
        tc.selectedCustomer = ak1.Name;
        tc.checkCustomer();
        tc.selectedShipAc = ak.Name;
        tc.selectedShipAdd = ab5.Name;
        tc.CustomerId ='';        
        // tc.
        tc.checkShipAc();
        tc.Cancel();
        tc.selectedCustomer = ak1.Name;
        tc.selectedShipAc = ak.Name;
        tc.selectedShipAdd = ab5.Name;
        tc.savenNew();
        PageReference pageRef2 = new PageReference('/apex/NewPickupVF?core.apexpages.request.devconsole=1');
        PageReference pageRefx = Page.NewPickupVF;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(p);
        NewPickUp1 tc1 = new NewPickUp1(sc1);
        tc1.selectedCustomer ='Test Billing Customer Account';
        //tc1.checkCustomer();
        tc1.selectedShipAc = '';        
        tc1.selectedShipAdd='';
        tc1.CustomerId='';
        tc1.s_date = System.today();
       // tc1.checkCustomer();
        tc1.checkShipAc();
        tc1.Cancel();
        tc1.savenNew();
        Test.setCurrentPage(pageRef2);
        test.stopTest();                
    }
    @isTest
    public static void testMethod2() 
    {    
        test.startTest();
        Pickup__c p = [select Id from Pickup__c limit 1];
        PageReference pageRef2 = new PageReference('/apex/NewPickupVF?core.apexpages.request.devconsole=1');
        PageReference pageRefx = Page.NewPickupVF;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(p);
        NewPickUp1 tc1 = new NewPickUp1(sc1);
        tc1.selectedCustomer ='';
        tc1.selectedShipAc = '';        
        tc1.selectedShipAdd='';
        tc1.CustomerId='';
        tc1.s_date = System.today();
        tc1.checkCustomer();
        tc1.checkShipAc();
        tc1.Cancel();
        tc1.savenNew();
        Test.setCurrentPage(pageRef2);
        test.stopTest();                
        
    }
    
}