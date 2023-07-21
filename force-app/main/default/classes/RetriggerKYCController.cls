public class RetriggerKYCController {
    
	@InvocableMethod(label='Re Initiate KYC' description='')
    public static void reInitiateKYC(List<Account> lstAcc) {
        Account objAcc = [SELECT Id,PAN_Number_of_Entity__c,KARZAA_KYC_Verified__c,Stitch_Profile_API_Status__c, Credit_Rating_API_Status__c   FROM Account WHERE Id=:lstAcc[0].Id];
        Id accId = lstAcc[0].Id;
        system.debug('accountId::'+lstAcc[0].Id);
        String PanNumberOfEntity = String.valueOf(objAcc.PAN_Number_of_Entity__c);
        system.debug('PanNumberOfEntity::'+PanNumberOfEntity);
        //KYCPanVerificationAPI.verifyPanAPI(accId,PanNumberOfEntity);
        if(objAcc.KARZAA_KYC_Verified__c == false)
        {
            RetriggerKYCController.verifyPan(accId,PanNumberOfEntity);
        }
        if(objAcc.KARZAA_KYC_Verified__c == true)
        {
            
            if(objAcc.Stitch_Profile_API_Status__c == false)
            {
                RetriggerKYCController.stichProfile(accId,PanNumberOfEntity);
            }
            
            Account objAccFinSum = [SELECT Financial_Summary_API_Status__c,Entity_Id__c   FROM Account WHERE Id=:lstAcc[0].Id];
            if(objAccFinSum.Entity_Id__c != null && objAccFinSum.Financial_Summary_API_Status__c == false)
            {
                RetriggerKYCController.financialSummary(accId,objAccFinSum.Entity_Id__c);
            }
            if(objAcc.Credit_Rating_API_Status__c  == false)
            {
                RetriggerKYCController.creditRating(accId,PanNumberOfEntity);
            }
        }
        
    }
    @future(callout=true)
    public static void verifyPan(Id accId,String PanNumberOfEntity){
        KYCPanVerificationAPI.verifyPanAPI(accId,PanNumberOfEntity);
    }
    @future(callout=true)
    public static void stichProfile(Id accId,String PanNumberOfEntity){
        KYCPanVerificationAPI.getStichProfileAPI(accId,PanNumberOfEntity);
    }
    @future(callout=true)
    public static void financialSummary(Id accId,String entityId){
        KYCPanVerificationAPI.financialSummaryAPI(accId,entityId);
    }
    @future(callout=true)
    public static void creditRating(Id accId,String PanNumberOfEntity){
        KYCPanVerificationAPI.creditRatingAPI(accId,PanNumberOfEntity);
    }

    
    /*@AuraEnabled
    public static void reInitiateKYC(String accountId) {
        Account objAcc = [SELECT Id,PAN_Number_of_Entity__c FROM Account WHERE Id=:accountId];
        Id accId = accountId;
        system.debug('accountId::'+accountId);
        String PanNumberOfEntity = String.valueOf(objAcc.PAN_Number_of_Entity__c);
        system.debug('PanNumberOfEntity::'+PanNumberOfEntity);
        //KYCPanVerificationAPI.verifyPanAPI(accId,PanNumberOfEntity);
        RetriggerKYCController.verifyPan(accId,PanNumberOfEntity);
    }*/
}