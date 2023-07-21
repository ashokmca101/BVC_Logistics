@isTest
public class TestCommunity_KYC_SettingsController {

    @testSetup static void setup() {
        
        // Create common test account
        Account testAcctsVar = new Account();
         testAcctsVar.name='Test2';
         testAcctsVar.KARZAA_Company_Type__c = 'Private';
         testAcctsVar.Type = '';
         testAcctsVar.Customer_Status__c = 'Active';
         testAcctsVar.Category__c = 'Manufacturer';
         testAcctsVar.Type_Of_Customer__c = 'Consignee';
         testAcctsVar.BVC_Legal_Entity__c = 'B.V.C. Trade Private Limited';
         testAcctsVar.BVC_Company_Type__c = 'Domestic';
         testAcctsVar.Documents_Uploaded__c = 'Passport';
        testAcctsVar.Form_Of_Organization__c = 'Company';
        testAcctsVar.IEC_Manual_Input__c = '12345';
        //testAcctsVar.BVC_Company_Type__c = 'International';
        testAcctsVar.Export_House__c = 'Export house For BVCI';
        testAcctsVar.Customer_Type__c = 'PRIVATE';
        insert testAcctsVar;
        
        Account testAccts = new Account();
         testAccts.name='Test1';
         testAccts.KARZAA_Company_Type__c = 'Private';
         testAccts.Type = '';
         testAccts.Customer_Status__c = 'Active';
         testAccts.Category__c = 'Manufacturer';
         testAccts.Type_Of_Customer__c = 'Consignee';
         testAccts.BVC_Legal_Entity__c = 'B.V.C. Trade Private Limited';
         testAccts.BVC_Company_Type__c = 'Domestic';
         testAccts.Documents_Uploaded__c = 'Passport';
         testAccts.Form_Of_Organization__c = 'Company';
        insert testAccts;

        Contact conObj = new Contact();
        conObj.lastname = 'test2';
        conObj.AccountId = testAccts.Id;
        conObj.MobilePhone = '1234567890';
        conObj.Email = 'test@gmail.com';
        insert conObj;
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusernew@testorg.com');
       
        insert userObj;
        
        Contact con = new Contact();
        con.lastname = 'test';
        con.AccountId = testAccts.Id; 
        con.ownerid = userObj.id;
        con.MobilePhone = '1267567890';
        con.Email = 'test123@gmail.com';
        insert con;
    }
    
    @isTest
    static void testFetchLoggedInUser(){ 
         
        Community_KYC_SettingsController.fetchLoggedInUser();
    }
    
    @isTest
    static void testFetchAccountDetails(){ 
        
        
            Id profileId = [select id from profile where name='Custom Customer Community Plus Login User'].id;
            
            Account accObj = new Account(name ='GrazittiNew') ;
            insert accObj; 
            
            Contact conObj = new Contact(LastName ='testConNew',AccountId =accObj.Id);
        	conObj.MobilePhone = '1234567899';
        	conObj.Email = 'test123@gmail.com';
            insert conObj;  
            
            User user = new User(alias = 'test1234', email='test1234@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing12', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                                 ContactId = conObj.Id,
                                 timezonesidkey='America/Los_Angeles', username='testccd@noemail.com',PAN_Number_of_Entity__c='cupek54611',Name_As_Per_Pan_Manual_Input__c='abcd',Firstname='Testing1');
            insert user;
        
            //user u=[select id from user where id='0051m000001YVbMAAW'];
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Company_Logo',
                PathOnClient = 'Company_Logo.png',
                VersionData = Blob.valueOf('Company_Logo'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, Filetype FROM ContentDocument];
            system.debug('==='+documents);
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = accObj.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            cdl.visibility='AllUsers';
            insert cdl;
        	system.debug('cdl==='+cdl);
        Test.startTest();
            system.runAs(user) {
                Community_KYC_SettingsController.fetchAccountDetails();
                //String test=Community_DisplayCustomerLogoController.fetchLogoURl();
            }
        Community_KYC_SettingsController.saveAccountDocumentDetails(accObj, 'Test Doc', cdl.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetPicklistvalues(){ 
        Community_KYC_SettingsController.getPicklistvalues('Account','Customer_Type__c' );
    }
    
    @isTest
    static void testGetCurrentUserAccountId(){ 
        Community_KYC_SettingsController.getCurrentUserAccountId();
    }
    
    @isTest
    static void testSaveIECToApexClass(){ 
        String IEC = '1234';
        Account accObj =[SELECT Id FROM Account WHERE name ='Test1'];
        String accId = accObj.Id;
        Community_KYC_SettingsController.saveIECToApexClass(IEC,accId);
        Community_KYC_SettingsController.saveIECToApexClass(IEC,accId);
    }
    
    @isTest
    static void testSaveADCodeToApexClass(){ 
        String inputADCode = '1234';
        Account accObj =[SELECT Id FROM Account WHERE name ='Test2'];
        String accId = accObj.Id;
        Community_KYC_SettingsController.saveADCodeToApexClass(inputADCode,accId);
        Community_KYC_SettingsController.saveADCodeToApexClass(inputADCode,accId);
    }
    
   /* @isTest
    static void testSaveAccountDocumentDetails(){
        Account errAcc = new Account();
        Community_KYC_SettingsController.saveAccountDocumentDetails(errAcc);
        Account accObj =[SELECT Id FROM Account WHERE name ='Test1'];
        Community_KYC_SettingsController.saveAccountDocumentDetails(accObj);
    }*/
    
    @isTest
    static void testFetchKYCDocs(){ 
        Account accObj =[SELECT Id FROM Account WHERE name ='Test1'];
        KYC_Document__c kycObj = new KYC_Document__c();
        kycObj.Customer__c = accObj.Id;
        kycObj.Type_Of_Document__c = 'Passport';
        insert kycObj;
        Community_KYC_SettingsController.fetchKYCDocs(accObj);
    }
    
     @isTest
    static void testSaveAccountDetails(){ 
        Community_KYC_SettingsController.ContactWrapper testWrapperError = new Community_KYC_SettingsController.ContactWrapper();
        Community_KYC_SettingsController.saveAccountDetails(testWrapperError);
        
        Account accObj =[SELECT Id FROM Account WHERE name ='Test1'];
        Contact conObj =[SELECT Id FROM Contact WHERE name ='test'];
        Community_KYC_SettingsController.ContactWrapper testWrapper = new Community_KYC_SettingsController.ContactWrapper();
        testWrapper.acc = accObj;
        testWrapper.con = conObj;
        
        Community_KYC_SettingsController.saveAccountDetails(testWrapper);
    }
    
}