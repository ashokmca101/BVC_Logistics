/* Method to Community_DisplayCustomerLogoController & Community_CustomerLogoUploadController.
Added By: PWC
Added on: 05-Mar-2021
*/
@isTest (SeeAllData = false) 
public class TestCommunity_DisplayCustomerLogoContrlr {
    static testMethod void displayCustomerLogo() {
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
            
            ContentVersion contentVersion = new ContentVersion(
                    Title = 'Company_Logo',
                    PathOnClient = 'Company_Logo.png',
                    VersionData = Blob.valueOf('Company_Logo'),
                    IsMajorVersion = true
                );
            insert contentVersion; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
            system.debug('===contentVersion '+contentVersion_2.Id);
            List<ContentDocument> documents = [SELECT Id, Title, Filetype,LatestPublishedVersionId FROM ContentDocument];
            system.debug('===documents '+documents);
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = ac.id;
            cdl.ContentDocumentId = contentVersion_2.contentdocumentid;
            cdl.shareType = 'V';
            cdl.visibility='AllUsers';
            insert cdl;
            system.debug('cdl==='+cdl.Id);
        }
        
       test.startTest();
        System.runAs(newUser){
             Community_DisplayCustomerLogoController.fetchLogoURl();
             System.assert(newUser.id!=null);
        }
      
        test.stopTest();
        
       
        
    }
}