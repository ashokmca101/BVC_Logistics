@IsTest(SeeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {

 /* Verifies that IsValidPassword method with various password combinations. */
 @IsTest
 static void testIsValidPassword() {
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
  System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
 }

 @IsTest
 static void testSiteAsContainerEnabled() {
  System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
 }

 /* Verifies the selfRegistration method flow with various invalid inputs */
 @IsTest
 static void testSelfRegistration() {
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);
  System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'),paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
  System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '',paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
  System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '',paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
  System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '',paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
 }


 /* Verifies the selfRegistration flow for valid inputs */
 @IsTest
 static void testSelfRegisterWithProperCredentials() {
  Map < String, String > paramsMap = initializeParams();
  System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
 }

 /* Verifies SelfRegistration flow with an accounId that is created within the test */
 @IsTest
 static void testSelfRegisterWithCreatedAccount() {
  Account acc = new Account(name = 'test acc');
  insert acc;
  List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
  System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
  String accountId = accounts[0].Id;
  Map < String, String > paramsMap = initializeParams();
  System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
 }

 @IsTest
 static void testGetNullExtraFields() {
  System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null));
 }

 @IsTest
 static void testGetNonEmptyExtraFields() {
  System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
 }

 /* Verifies validation of extraFields within the Self Registration flow */
 @IsTest
 static void testGetExtraFieldsInSelfRegistration() {
  List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
  Map < String, String > paramsMap = initializeParams();
  Map < String, Object > fieldMap = new Map < String, Object > ();
  fieldMap.put('description', 'new field');
  fieldMap.put('fieldPath', 'dummyPath');
  fieldlist.add(fieldMap);
  String extraFields = JSON.serialize(fieldlist);
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('mobilephone'),paramsMap.get('nameasperpan'),paramsMap.get('panofentity'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
 }

 @IsTest
 static void LightningSelfRegisterControllerInstantiation() {
  LightningSelfRegisterController controller = new LightningSelfRegisterController();
  System.assertNotEquals(controller, null);
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > ();
  String firstName = 'test';
  String lastName = 'User';
  String email = 'testUser@salesforce.com';
  String mobilephone = '1234567890';
  String nameasperpan = 'Test User';
  String panofentity = 'ABCDE1234A';
  String password = 'testuser123';
  String confirmPasswordCorrect = 'testuser123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';
  paramsMap.put('firstName', firstName);
  paramsMap.put('lastName', lastName);
  paramsMap.put('email', email);
     paramsMap.put('mobilephone', mobilephone);
     paramsMap.put('nameasperpan', nameasperpan);
     paramsMap.put('panofentity', panofentity);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  return paramsMap;
 }
     static testMethod void validateCustomer() {
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
            
            
        }
        
       test.startTest();
        System.runAs(newUser){
             LightningSelfRegisterController.validateNewCustomer('testABC@gmail.com');
             //System.assert(newUser.id!=null);
        }
      
        test.stopTest();
        
       
        
    }

}