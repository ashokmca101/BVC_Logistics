@isTest
public class TestAccount_TriggerHandlerServiceCtrl {
     @testSetup static void setup() {
        // Create common test account
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.KARZAA_KYC_Verified__c = false;
        testAccts.Stitch_Profile_API_Status__c = false ;
        testAccts.Credit_Rating_API_Status__c = false;
        testAccts.Financial_Summary_API_Status__c = false;
        testAccts.Entity_Id__c = 'L74999TZ1984PLC001456';
         /*testAccts.BVC_Company_Type__c = 'International';
         testAccts.Category__c = 'Manufacturer';
         testAccts.Type_Of_Customer__c = 'Consignee';
         testAccts.BVC_Legal_Entity__c = 'B.V. Chinai & Co. (India) Private Limited';
         testAccts.Customer_Type__c = 'Government';
         testAccts.Export_House__c = 'Star Trading House';
         testAccts.IEC__c = '1234';
         testAccts.IEC_Manual_Input__c = '1234';*/
         testAccts.AWS_SYNC_Status__c = 'Pending';
        insert testAccts;
         
    }
    
    
    @isTest
    static void testVerifyPan(){
        System.debug('****'+[SELECT Id,name,PAN_Number_of_Entity__c FROM Account]);
        Account accObj = [SELECT Id,PAN_Number_of_Entity__c FROM Account WHERE name like '%Test1%'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForPANVerif());
        
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForPANVerif mock = new MockHttpResponseGeneratorForPANVerif();
        HttpResponse res = mock.respond(req);
        
        
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.debug('actualValue:::'+res.getBody());
        String expectedValue = '{"result":{"name":"TITAN COMPANY LIMITED"},"request_id":"e11160f6-02a8-40a6-9ccf-040cbee70c29","status-code":"101"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        
        Account_TriggerHandlerServiceCtrl.verifyPan(accObj.Id , accObj.PAN_Number_of_Entity__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void testStichProfileAPI(){
        Account accObj = [SELECT Id,PAN_Number_of_Entity__c FROM Account WHERE  name like '%Test1%'];
   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForStitch());
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForStitch mock = new MockHttpResponseGeneratorForStitch();
        HttpResponse res = mock.respond(req);
        
        
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.debug('actualValue:::'+res.getBody());
        System.assertEquals(200, res.getStatusCode());
        Account_TriggerHandlerServiceCtrl.stichProfileAPI(accObj.Id , accObj.PAN_Number_of_Entity__c);
        Test.stopTest();
    }
    
    @isTest
    static void testFinancialSummaryAPI(){
        Account accObj = [SELECT Id,Entity_Id__c FROM Account WHERE  name like '%Test1%'];
        //String entityId = 'L74999TZ1984PLC001456';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForFinan());
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForFinan mock = new MockHttpResponseGeneratorForFinan();
        HttpResponse res = mock.respond(req);
        
        
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.debug('actualValue:::'+res.getBody());
        System.assertEquals(200, res.getStatusCode());
        Account_TriggerHandlerServiceCtrl.doFinancialSummaryAPICallout(accObj.Id , accObj.Entity_Id__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void testDoCreditRatingAPICallout(){
        Account accObj = [SELECT Id,PAN_Number_of_Entity__c FROM Account WHERE  name like '%Test1%'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForCredit());
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForCredit mock = new MockHttpResponseGeneratorForCredit();
        HttpResponse res = mock.respond(req);
        
        
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.debug('actualValue:::'+res.getBody());
        System.assertEquals(200, res.getStatusCode());
        Account_TriggerHandlerServiceCtrl.doCreditRatingAPICallout(accObj.Id , accObj.PAN_Number_of_Entity__c);
        Test.stopTest();
        
        
    }
    @isTest
    static void testsetAWSStatus(){
        Account testAccts =[SELECT Id,Name,KARZAA_KYC_Verified__c from Account where  name like '%Test1%'];
        map<Id,Account> mpOldAccounts = new map<Id,Account>();
        mpOldAccounts.put(testAccts.Id, testAccts);
        testAccts.BVC_Company_Type__c = 'International';
         testAccts.Category__c = 'Manufacturer';
         testAccts.Type_Of_Customer__c = 'Consignee';
         testAccts.BVC_Legal_Entity__c = 'B.V. Chinai & Co. (India) Private Limited';
         testAccts.Customer_Type__c = 'Government';
         testAccts.Export_House__c = 'Star Trading House';
         testAccts.IEC__c = '1234';
         testAccts.IEC_Manual_Input__c = '1234';
         testAccts.Form_Of_Organization__c = 'Company';
         testAccts.Legacy_Record__c = false;
        testAccts.Name_As_Per_PAN_Manual_Input__c = 'Titan';
        update testAccts;
        List<Account> accountList = new List<Account>();
        accountList.add(testAccts);
        Account_TriggerHandlerServiceCtrl.setAWSStatus(accountList, mpOldAccounts);
        testAccts.PAN_Number_of_Entity__c = 'AARFG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARHG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARJG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARGG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARPG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARAG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARTG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARBG4053G';
        update testAccts;
        testAccts.PAN_Number_of_Entity__c = 'AARLG4053G';
        update testAccts;
        //Account_TriggerHandlerServiceCtrl.setBeforeValues(accountList);
    }
   @isTest
    static void testAccountsharingWithSecondaryOwner(){
        Id p = [select id from profile where name='Custom Customer Community Plus Login User'].id;
        
        Account ac = new Account(name ='GrazittiABC') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testConABC',AccountId =ac.Id);
        con.MobilePhone = '1234567812';
        con.Email = 'testABC@gmail.com';
        insert con;  
        
        User userA = new User(alias = 'testABC', email='test123ABC@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingA', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='testABC@noemail.com',PAN_Number_of_Entity__c='cupek54645',Name_As_Per_Pan_Manual_Input__c='abcAB',Firstname='TestingA');
        insert userA;
        
        Test.startTest();
        Account testAccts =[SELECT Id,Name,IsCustomerPortal,Secondary_Service_Owner__c from Account where Id=:ac.Id];
        system.debug('testAccts::'+testAccts);
        //stAccts.OwnerId = objUser.Id;
        //string ids=UserInfo.getUserId();
        //ac.OwnerId = userA.Id;
        Account acObj = new Account(Id =ac.Id) ;
        acObj.Sales_Secondary_Owner__c = userA.Id;
        acObj.IsCustomerPortal = true;
        update acObj;
        system.debug('IsCustomerPortal::'+ac.IsCustomerPortal);
        List<Account> accountList = new List<Account>();
        accountList.add(acObj);
        system.runAs(userA) {
            Account_TriggerHandlerServiceCtrl.AccountsharingWithSecondaryOwner(accountList);
            //system.debug('test::'+test);
        }
        Test.stopTest();        
    }
}