@isTest
public class Community_InvoiceOutstandingCtrlTest {
    static testMethod void testInvoiceOutstanding() {
        Profile adminProfile = [Select id from Profile where Name='System Administrator'];
        UserRole nonPortalRole = [Select PortalType, PortalAccountId From UserRole where PortalType !='CustomerPortal' limit 1];
        User adminUser = new User(alias = 'testABC', email='test123ABC@noemail.com',UserRoleId = nonPortalRole.Id,
                             emailencodingkey='UTF-8', lastname='TestingA', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = adminProfile.id, country='United States',IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='testABC@noemail.com',PAN_Number_of_Entity__c='iupek54645',Name_As_Per_Pan_Manual_Input__c='abcAB',Firstname='TestingA');
        insert adminUser;
         Id p = [select id from profile where name='Custom Customer Community Plus Login User'].id;
          UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
         User newUser ;
    
        System.runAs(adminUser){
            Account ac = new Account(name ='GrazittiABC',PAN_Number_of_Entity__c='jupek54645') ;
            insert ac; 
            
            Contact con = new Contact(LastName ='testConABC',AccountId =ac.Id);
            con.MobilePhone = '1234567812';
            con.Email = 'testABC@gmail.com';
            insert con; 
            
            newUser = new User(
            //UserRoleId = ur.Id,
            profileId = p,
            username = 'newUser@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            firstName='GrazittiABC',
            lastname='lastname',
            contactId = con.id,
                PAN_Number_of_Entity__c='jupek54645',Name_As_Per_Pan_Manual_Input__c='abcAB'
            );
            insert newUser; 
            Invoice_Outstanding_Report__c outstandingReport = new Invoice_Outstanding_Report__c();
           outstandingReport.Name= 'Test';
           outstandingReport.Trade_Name__c= 'Test';
           outstandingReport.Shipping_Number__c='123';
           outstandingReport.Document_Type__c='Invoice';
           outstandingReport.Document_Number__c='MH18BOMM021825';
           outstandingReport.Document_Date__c=System.today();
           outstandingReport.Amount_Due__c=1234;
           outstandingReport.Due_date__c = System.today();
           outstandingReport.Original_Amount__c= 12345;
           outstandingReport.Customer__c=ac.id;
           insert outstandingReport;
            
           
        }
        
       test.startTest(); 
       System.runAs(newUser){
           Community_InvoiceOutstandingCtrl.getData(System.today(), System.today());
       }
      
        test.stopTest();
    }
}