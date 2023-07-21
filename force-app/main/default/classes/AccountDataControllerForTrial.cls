public with sharing class AccountDataControllerForTrial {
    @AuraEnabled (cacheable=true)
    public static List<Account> fetchContacts(){
        return [SELECT Name, Email__c
                FROM Account
                LIMIT 2000];
    }

}