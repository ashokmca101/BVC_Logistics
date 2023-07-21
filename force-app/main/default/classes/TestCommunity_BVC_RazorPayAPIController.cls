@isTest
public class TestCommunity_BVC_RazorPayAPIController {

    @isTest
    static void testRazorPay(){
       Account a=new Account();
        a.name='Test Account';
        insert a;
         Contact con = new Contact();
         //con.Name = 'Contact 1';
         con.Email = 'Contact@gmail.com';
         con.MobilePhone = '1234567890';
         con.Phone = '1234567890';
         con.AccountId = a.Id;
         con.LastName = 'AAAA';
         insert con;
          AddressBook__c ab=new AddressBook__c();
            ab.name='demo';
            ab.ADDRESS1__c='Address1';
            ab.ADDRESS2__c='Address2';
            ab.CITY__c='city';
            ab.COUNTRY__c='India';
            ab.Customer__c=a.id;
            ab.PINCODE__c='110055';
            ab.District__c='district';
            ab.TRADE_NAME__c=a.name;
            ab.GSTIN__c='';
            
        insert ab;
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
        List<Id> lstShip = new List<Id>();
        Shipment__c shipObj = new Shipment__c();
        shipObj.Customer__c = a.Id;
            shipObj.Name = 'Shipment 1';
            shipObj.AddressBook__c = ab.Id;
            shipObj.Pickup__c =p.Id;
         shipObj.Bill_To_Party_Address__c = 'ABC';
         shipObj.Bill_To_Party_PAN__c = 'ABC';
         shipObj.Billing_Entity_Name__c = 'ABC';
         shipObj.Bill_to_1__c = 'Shipper';
         shipObj.Bill_To_GSTIN__c = 'ABC';
        insert shipObj;
        lstShip.add(shipObj.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForPayLink());
        
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForPayLink mock = new MockHttpResponseGeneratorForPayLink();
        HttpResponse res = mock.respond(req);
        
        Community_BVC_RazorPayAPIController.authurl(lstShip);
        Test.stopTest();
        
    }

}