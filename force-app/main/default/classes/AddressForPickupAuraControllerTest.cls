@isTest (SeeAllData = false)
public class AddressForPickupAuraControllerTest {
    static testMethod void testMethod1() {
      Id userId=UserInfo.getUserId();
        Test.startTest();
        Account a=new Account();
        a.name='Test Account';
        insert a;
        List<AddressBook__c> addresslist=new list<AddressBook__c>();
        AddressBook__c ab=new AddressBook__c();
            ab.name='demo';
            ab.ADDRESS1__c='Address1';
            ab.ADDRESS2__c='Address2';
            ab.CITY__c='city';
            ab.COUNTRY__c='India';
            ab.Customer__c=a.id;
            ab.PINCODE__c='854105';
            ab.District__c='district';
            ab.TRADE_NAME__c=a.name;
            ab.GSTIN__c='';
            
        insert ab;
        AddressBook__c ab1=new AddressBook__c();
            ab1.name='demo';
            ab1.ADDRESS1__c='Address1';
            ab1.ADDRESS2__c='Address2';
            ab1.CITY__c='city';
            ab1.COUNTRY__c='India';
            ab1.Customer__c=a.id;
            ab1.PINCODE__c='854105';
            ab1.District__c='district';
            ab1.TRADE_NAME__c=a.name;
            ab1.GSTIN__c='';
            
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
        List<String> selectedAddressId=new List<String>();
        selectedAddressId.add(ab.id);
        List<String> selectedAddressId1=new List<String>();
        selectedAddressId1.add(ab.id);
        selectedAddressId1.add(ab1.id);
        List<String> pickupmap=new List<String>();
        pickupmap.add(p.Contact_Person_Name__c);
        pickupmap.add(String.valueof(p.Contact_Person_Number__c));
        pickupmap.add(p.Destination__c);
        pickupmap.add(p.Insurance_By__c);
        pickupmap.add(String.valueof(p.Net_Weight__c));
        pickupmap.add(p.Net_Weight_UOM__c);
        pickupmap.add(String.valueof(p.No_Of_Parcels__c));
        pickupmap.add(String.valueof(p.Pickup_Date__c));
        pickupmap.add(dt);
        pickupmap.add(p.Product_Type__c);
        pickupmap.add(p.TypeOfPickup__c);
        pickupmap.add(p.Pickup_Address__c);
        pickupmap.add(p.Customer__c);
        
        AddressForPickupAuraController.getAddressList();
        AddressForPickupAuraController.insertPickupData1(selectedAddressId,a.id);
        AddressForPickupAuraController.insertPickupData1(selectedAddressId1,a.id);
        Test.stopTest();  
    }

}