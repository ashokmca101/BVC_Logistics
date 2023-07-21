@isTest
public class TestBVC_SSO {
 @testSetup
    static void setupTestData(){
        test.startTest();
        Community community_Obj = new Community();
        //  Insert community_Obj; 
        test.stopTest();
    }
    static testMethod void test_UserData_UseCase1(){
        List<Network> community_Obj  =  [SELECT id, name from network Limit 1];
        System.assertEquals(true,community_Obj.size()>0);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String randomString = String.valueOf(System.currentTimeMillis());
        String uniqueName = 'xyz@newtest.666555444.com';
        User usr = new User(LastName = 'Test',
                            FirstName='k',
                            Alias = 'P',
                            Email = 'cat@newtest.com',
                            Username = 'xyz@newtest.666555444.com',//randomString + 'testUserJSW@test.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           ) ;
        insert usr;
        BVC_SSO obj01 = new BVC_SSO();
        Auth.UserData dataX= new Auth.UserData('goodidentifier', 'firstName', 'lastName', 'fullName', 'xyz@newtest.666555444.com', 
                                               null, uniqueName, 'en', 'provider', null, null);
        obj01.createUser(community_Obj[0].Id,dataX);
    }
    static testMethod void test_UserData_UseCase2(){
        List<network> community_Obj  =  [SELECT id from network];
        System.assertEquals(true,community_Obj.size()>0);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String randomString = String.valueOf(System.currentTimeMillis());
        String uniqueName = 'xyz@newtest.666555444.com';
        User usr = new User(LastName = 'Test',
                            FirstName='k',
                            Alias = 'P',
                            Email = 'subbuforcloud@gmail.com',
                            Username = 'testUserJSW@test.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           ) ;
        insert usr;
        BVC_SSO obj01 = new BVC_SSO();
        Auth.UserData dataX= new Auth.UserData('goodidentifier', 'firstName', 'lastName', 'fullName', 'testUserJSW@test.com', 
                                               null, uniqueName, 'en', 'provider', null, null);
        obj01.updateUser(usr.Id,community_Obj[0].Id,dataX);
    }
}