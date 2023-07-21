@isTest
public class TestCRM_KYCDocumentsUpload {
    
     @testSetup static void setup() {
        // Create common test account
        Account testAccts = new Account();
         testAccts.name='Test1';
         testAccts.KARZAA_Company_Type__c = 'Private';
         testAccts.Type = '';
         //testAccts.Customer_Type__c = 'Prospect';
         testAccts.BVC_Company_Type__c = 'Domestic';
         testAccts.Documents_Uploaded__c = 'Passport';
         testAccts.Form_Of_Organization__c = 'Company';
        insert testAccts;
         
         
    }
    
    @isTest
    static void testFetchAccountDetails(){ 
        String accName='Test1';
        Account accountDetails = [Select Id,KARZAA_Company_Type__c, Type, 
                          		  Customer_Type__c,BVC_Company_Type__c, Documents_Uploaded__c, Form_Of_Organization__c
                                  FROM Account WHERE name=:accName];
        system.assertEquals(true, accountDetails.Id != null); 
        CRM_KYCDocumentsUpload.fetchAccountDetails(accountDetails.Id);
    }
    @isTest
    static void testsaveAccountDocumentDetails(){
        Account accountDetails = [Select Id FROM Account WHERE name='Test1'];
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        
        String doctitle = 'PAN Card';
        CRM_KYCDocumentsUpload.saveAccountDocumentDetails(accountDetails ,doctitle , cv.Id );
    }   
    
    
    @isTest
    static void testSaveIECToApex(){
        
        Account accountDetails = [Select Id,BVC_Company_Type__c FROM Account WHERE name='Test1'];
        accountDetails.Export_House__c = 'Star Trading House';
        accountDetails.IEC_Manual_Input__c = '1234';
        accountDetails.Category__c = 'Manufacturer';
        accountDetails.Customer_Type__c ='GOVERNMENT';
        update accountDetails;
        String inputIEC = '1234';
        CRM_KYCDocumentsUpload.saveIECToApexClass(inputIEC,accountDetails.Id);
        if(inputIEC != null)
            {
                Account accObj = new Account();
                accObj.Id = accountDetails.Id;
                accObj.IEC_Manual_Input__c = inputIEC;
                accObj.BVC_Company_Type__c =accountDetails.BVC_Company_Type__c +';'+ 'International';
                accObj.Export_House__c = 'Star Trading House';
                accObj.IEC_Manual_Input__c = '1234';
                accObj.Category__c = 'Manufacturer';
                accObj.Customer_Type__c ='GOVERNMENT';
                update accObj;
            }
        CRM_KYCDocumentsUpload.saveIECToApexClass(inputIEC,accountDetails.Id);
    }
    
    @isTest
    static void testSaveADCodeToApex(){
        
        Account accountDetails = [Select Id,BVC_Company_Type__c FROM Account WHERE name='Test1'];
        accountDetails.Export_House__c = 'Star Trading House';
        accountDetails.IEC_Manual_Input__c = '1234';
        accountDetails.Category__c = 'Manufacturer';
        accountDetails.Customer_Type__c ='GOVERNMENT';
        update accountDetails;
        String inputADCode = '1234';
        CRM_KYCDocumentsUpload.saveADCodeToApexClass(inputADCode,accountDetails.Id);
        if(inputADCode != null)
            {
                Account accObj = new Account();
                accObj.Id = accountDetails.Id;
                accObj.AD_Code_Manual_Input__c = inputADCode;
                accObj.BVC_Company_Type__c =accountDetails.BVC_Company_Type__c +';'+ 'CB Customer';
                accObj.Export_House__c = 'Star Trading House';
                accObj.IEC_Manual_Input__c = '1234';
                accObj.Category__c = 'Manufacturer';
                accObj.Customer_Type__c ='GOVERNMENT';
                update accObj;
            }
        CRM_KYCDocumentsUpload.saveADCodeToApexClass(inputADCode,accountDetails.Id);
    }

}