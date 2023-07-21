@isTest
public class TestRetriggerKYCController {
    @testSetup static void setup() {
        // Create common test account
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.KARZAA_KYC_Verified__c = true;
        testAccts.Stitch_Profile_API_Status__c = false ;
        testAccts.Credit_Rating_API_Status__c = false;
        testAccts.Financial_Summary_API_Status__c = false;
        testAccts.Entity_Id__c = '123444';
        insert testAccts;
    }
    
    @isTest
    static void testReInitiateKYC(){
        Test.startTest();
        List<Account> objAcc = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,
                           		 Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c,
                                 Financial_Summary_API_Status__c,Entity_Id__c    
                           		 FROM Account WHERE name='Test1'];
      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForPANVerif());
        
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForPANVerif mock = new MockHttpResponseGeneratorForPANVerif();
        HttpResponse res = mock.respond(req);
        RetriggerKYCController.reInitiateKYC(objAcc);
        Account testAccts = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c 
                           		 FROM Account WHERE name='Test1'];
        testAccts.KARZAA_KYC_Verified__c = false;
        update testAccts;
        List<Account> objAccAfterUpdate = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,
                           		 			Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c,
                                 			Financial_Summary_API_Status__c,Entity_Id__c    
                           		 			FROM Account WHERE name='Test1'];
        RetriggerKYCController.reInitiateKYC(objAccAfterUpdate);
        Account testAcctsStitch = [SELECT Id,PAN_Number_of_Entity__c,Stitch_Profile_API_Status__c,KARZAA_KYC_Verified__c 
                           		 FROM Account WHERE name='Test1'];
        testAcctsStitch.Stitch_Profile_API_Status__c = true;
        testAcctsStitch.KARZAA_KYC_Verified__c = true;
        update testAcctsStitch;
        List<Account> objAccAfterUpdateStitch = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,
                           		 			Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c,
                                 			Financial_Summary_API_Status__c,Entity_Id__c    
                           		 			FROM Account WHERE name='Test1'];
        RetriggerKYCController.reInitiateKYC(objAccAfterUpdateStitch);
        Test.stopTest();
    }
    @isTest
    static void testReInitiateKYCFianan(){
        Test.startTest();
        Account testAcctsStitch = [SELECT Id,PAN_Number_of_Entity__c,Stitch_Profile_API_Status__c,KARZAA_KYC_Verified__c 
                           		 FROM Account WHERE name='Test1'];
        testAcctsStitch.Stitch_Profile_API_Status__c = true;
        testAcctsStitch.KARZAA_KYC_Verified__c = true;
        testAcctsStitch.Credit_Rating_API_Status__c = true;
        update testAcctsStitch;
        List<Account> objAccAfterUpdateStitch = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,
                           		 			Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c,
                                 			Financial_Summary_API_Status__c,Entity_Id__c    
                           		 			FROM Account WHERE name='Test1'];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForFinan());
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForFinan mock = new MockHttpResponseGeneratorForFinan();
        HttpResponse res = mock.respond(req);
        
        RetriggerKYCController.reInitiateKYC(objAccAfterUpdateStitch);
        Test.stopTest();
    }
    @isTest
    static void testReInitiateKYCCreditRating(){
        Test.startTest();
        Account testAcctsStitch = [SELECT Id,PAN_Number_of_Entity__c,Stitch_Profile_API_Status__c,KARZAA_KYC_Verified__c,
                                  Financial_Summary_API_Status__c
                           		 FROM Account WHERE name='Test1'];
        testAcctsStitch.Financial_Summary_API_Status__c = true;
        testAcctsStitch.Stitch_Profile_API_Status__c = true;
        testAcctsStitch.KARZAA_KYC_Verified__c = true;
        update testAcctsStitch;
        List<Account> objAccAfterUpdateStitch = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,
                           		 			Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c,
                                 			Financial_Summary_API_Status__c,Entity_Id__c    
                           		 			FROM Account WHERE name='Test1'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForCredit());
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForCredit mock = new MockHttpResponseGeneratorForCredit();
        HttpResponse res = mock.respond(req);
        
        RetriggerKYCController.reInitiateKYC(objAccAfterUpdateStitch);
        Test.stopTest();
    }
    @isTest
    static void testReInitiateKYCVerifyPAn(){
        Test.startTest();
        Account testAcctsStitch = [SELECT Id,PAN_Number_of_Entity__c,Stitch_Profile_API_Status__c,KARZAA_KYC_Verified__c,
                                  Financial_Summary_API_Status__c
                           		 FROM Account WHERE name='Test1'];
        testAcctsStitch.Financial_Summary_API_Status__c = true;
        testAcctsStitch.Stitch_Profile_API_Status__c = true;
        testAcctsStitch.KARZAA_KYC_Verified__c = false;
        update testAcctsStitch;
        List<Account> objAccAfterUpdateStitch = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,
                           		 			Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c,
                                 			Financial_Summary_API_Status__c,Entity_Id__c    
                           		 			FROM Account WHERE name='Test1'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForPANVerif());
        
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForPANVerif mock = new MockHttpResponseGeneratorForPANVerif();
        HttpResponse res = mock.respond(req);
        
        RetriggerKYCController.reInitiateKYC(objAccAfterUpdateStitch);
        Test.stopTest();
    }
}