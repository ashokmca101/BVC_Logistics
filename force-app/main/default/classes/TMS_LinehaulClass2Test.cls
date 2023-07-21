@isTest
public class TMS_LinehaulClass2Test 
{
    @isTest
    public static void testMethod1() 
    {      
        
        Test.startTest();
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
                Date tod = system.today();
                Integer d = tod.day();
                Integer mo = tod.month();
                Integer yr = tod.year();                
        DateTime nt = DateTime.newInstance(yr, mo, d);    
        TMS_LinehaulClass2.SavePickup(a.id,a1.id,ab.Id,'sample1',nt,true);
        TMS_LinehaulClass2.SavePickup(a.id,a1.id,ab.Id,'sample1',null,true);
        test.stopTest();         
    }
}