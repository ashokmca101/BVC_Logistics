@isTest
public class TestStichProfileAPIResponseClass {
     @testSetup static void setup() {
        // Create common test account
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        insert testAccts;
    }
    @isTest
    static void testUpdateResponseMethod(){
        Account accObj = [SELECT id,PAN_Number_of_Entity__c FROM Account WHERE Name like '%Test1%'];
        StaticResource sr = [SELECT Id, Name , Body FROM StaticResource where name='StitchProfileResponse' LIMIT 1];
		//String body = sr.Body.toString();
        String getResponse = sr.Body.toString(); 
        Id accountId = accObj.Id; 
        String pan_number = accObj.PAN_Number_of_Entity__c;
        StichProfileAPIResponseClass.updateResponseMethod(getResponse, accountId, pan_number);
    }
}