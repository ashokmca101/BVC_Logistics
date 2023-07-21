/* Method to check KYC is Verified on current user.
   Added By: PWC
   Added on: 24-Feb-2021
*/
public class CheckKYCVerified {
    @auraEnabled
    Public static Boolean check_If_KYC_Is_Verified () {
       User CurrentUserInfo=[Select Id,Is_KYC_Verified__c,Contact.AccountId,Contact.Account.KARZAA_KYC_Verified__c,profile.Name from user where id=:UserInfo.getUserId() Limit 1];
       Boolean KYC_Verified=CurrentUserInfo.Contact.Account.KARZAA_KYC_Verified__c;
        If(CurrentUserInfo.profile.Name=='System Administrator') {
           KYC_Verified=true; 
        }
       return KYC_Verified;
    }
    @auraEnabled
    Public static Id navigate_to_AccountId () {
       User CurrentUserInfo=[Select Id,Is_KYC_Verified__c,Contact.AccountId from user where id=:UserInfo.getUserId() Limit 1];
       Id accid=CurrentUserInfo.Contact.AccountId;
       return accid;
    }

}