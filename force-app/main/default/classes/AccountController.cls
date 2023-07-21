public class AccountController {
    //this is test code used for testing LWC component createACRReport
   @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name,Email__c FROM Account];
    }
}