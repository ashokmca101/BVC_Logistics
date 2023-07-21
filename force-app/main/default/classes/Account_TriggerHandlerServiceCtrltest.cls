@istest
public class Account_TriggerHandlerServiceCtrltest {

    @istest
    Public static void testd(){
        String BillingRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.Email__c = 'test@gmail.com';
        testAccts.Mobile__c = '9999999999';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.First_Name__c = 'Test';
        testAccts.Last_Name__c ='1'; 
        testAccts.Name_As_Per_PAN_Manual_Input__c = 'test' ;
        testAccts.RecordTypeId = BillingRecType;
            insert testAccts;
    
        
         Account accountDetails = [Select Id,PAN_Number_of_Entity__c
                          FROM Account WHERE PAN_Number_of_Entity__c='AAACT5131A'];
        system.debug('accountDetails:::'+accountDetails);
        
         Test.startTest();
         //UtilityForTestCallOuts.panVerificationAPICall(accountDetails.Id,accountDetails.PAN_Number_of_Entity__c);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForPANVerif());
        KYCPanVerificationAPI.PanAPIRequest obbj = new KYCPanVerificationAPI.PanAPIRequest();
        
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForPANVerif mock = new MockHttpResponseGeneratorForPANVerif();
        HttpResponse res = mock.respond(req);
         KYCPanVerificationAPI.verifyPanAPI(accountDetails.Id,accountDetails.PAN_Number_of_Entity__c);
        Account_TriggerHandlerServiceCtrl.dotest();
        Account_TriggerHandlerServiceCtrl.dotest2();
        Account_TriggerHandlerServiceCtrl.dotest3();
         Test.stopTest();
    }
     @isTest
    static void testStichProfileAPI(){
        String BillingRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.Email__c = 'test@gmail.com';
        testAccts.Mobile__c = '9999999999';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.First_Name__c = 'Test';
        testAccts.Last_Name__c ='1'; 
        testAccts.Name_As_Per_PAN_Manual_Input__c = 'test' ;
        testAccts.RecordTypeId = BillingRecType;
            insert testAccts;
        Account accObj = [SELECT Id,PAN_Number_of_Entity__c FROM Account WHERE PAN_Number_of_Entity__c='AAACT5131A'];
   
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
        KYCPanVerificationAPI.getStichProfileAPI(accObj.Id , accObj.PAN_Number_of_Entity__c);
        Test.stopTest();
    }
    
    @isTest
    static void testFinancialSummaryAPI(){
        String BillingRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.Email__c = 'test@gmail.com';
        testAccts.Mobile__c = '9999999999';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.First_Name__c = 'Test';
        testAccts.Last_Name__c ='1'; 
        testAccts.Name_As_Per_PAN_Manual_Input__c = 'test' ;
        testAccts.RecordTypeId = BillingRecType;
            insert testAccts;
        Account accObj = [SELECT Id,Entity_Id__c FROM Account WHERE PAN_Number_of_Entity__c='AAACT5131A'];
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
        KYCPanVerificationAPI.financialSummaryAPI(accObj.Id , accObj.Entity_Id__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void testDoCreditRatingAPICallout(){
        String BillingRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.Email__c = 'test@gmail.com';
        testAccts.Mobile__c = '9999999999';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.First_Name__c = 'Test';
        testAccts.Last_Name__c ='1'; 
        testAccts.Name_As_Per_PAN_Manual_Input__c = 'test' ;
        testAccts.RecordTypeId = BillingRecType;
            insert testAccts;
        Account accObj = [SELECT Id,PAN_Number_of_Entity__c FROM Account WHERE PAN_Number_of_Entity__c='AAACT5131A'];
        
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
        KYCPanVerificationAPI.creditRatingAPI(accObj.Id , accObj.PAN_Number_of_Entity__c);
        Test.stopTest();
        
        
    }
}