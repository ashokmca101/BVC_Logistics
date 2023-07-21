@isTest
public class TestCommunity_InvoicesTableController {
    static testMethod void InvoicesTableControllerMethod(){
        Id p = [select id from profile where name='Custom Customer Community Plus Login User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId =ac.Id);
        con.MobilePhone = '1231231231';
        con.Email ='ajinkya@gmail.com';
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='testcc@noemail.com',PAN_Number_of_Entity__c='cupek54610',Name_As_Per_Pan_Manual_Input__c='abc',Firstname='Testing');
        insert user;
        //user u=[select id from user where id='0051m000001YVbMAAW'];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Company_Logo',
            PathOnClient = 'Company_Logo.png',
            VersionData = Blob.valueOf('Company_Logo'),
            IsMajorVersion = true
        );
        blng__Invoice__c TestInvoice = New blng__Invoice__c();
        TestInvoice.blng__Account__c = ac.Id;
        TestInvoice.blng__InvoiceDate__c = System.Today()+1;
        Insert TestInvoice;
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, Filetype FROM ContentDocument];
        system.debug('==='+documents);
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ac.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.visibility='AllUsers';
        cdl.LinkedEntityId = TestInvoice.Id;
        insert cdl;
        
        
        Test.startTest();
        Community_InvoicesTableController.getInvoices(System.today(),System.today()+2);
        Test.stopTest();
    }
}