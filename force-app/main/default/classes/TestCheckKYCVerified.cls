/* Method to check KYC is Verified.
   Added By: PWC
   Added on: 24-Feb-2021
*/
@isTest (SeeAllData = false) 
public class TestCheckKYCVerified {
	static testMethod void createnewlead() {
        Test.startTest();
        
        Id p = [select id from profile where name='Custom Customer Community Plus Login User'].id;
       
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        con.Email = 'test@gmail.com';
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='testcc@noemail.com');
       
        insert user;
        system.runAs(user) {
            Id accid=CheckKYCVerified.navigate_to_AccountId();
        }
          
      Boolean KYC_STatus=CheckKYCVerified.check_If_KYC_Is_Verified();
      
      Test.stopTest();
   }
}