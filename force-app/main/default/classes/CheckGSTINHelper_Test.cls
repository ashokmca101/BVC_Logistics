@isTest
public class CheckGSTINHelper_Test {
    @testSetup static void setup() {
        // Create common test account
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.GST_Registered__c = TRUE;
        insert testAccts;
        
        AddressBook__c addObj = new AddressBook__c();
        addObj.Name = 'Add 1';
        addObj.Customer__c = testAccts.Id;
        addObj.Is_Billing_Address__c = TRUE;
        addObj.Is_Primary__c = TRUE;
        addObj.PAN_Number_of_Entity__c = 'AAACT5131A';
        addObj.GSTIN__c = 'AAACT5131A12345';
        addObj.Source__c = 'Manual';
        addObj.TRADE_NAME__c ='ABC';
        insert addObj;
  
    }
    
    @isTest
    static void testCheckGstin(){
        List<AddressBook__c> addList = [SELECT Id,Customer__c,PAN_Number_of_Entity__c,GSTIN__c,Source__c FROM AddressBook__c where name='Add 1'];
        CheckGSTINHelper.CheckGstin(addList);
    }

}