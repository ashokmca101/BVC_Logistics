public class CRM_KYCDocumentsUpload {
    
    @AuraEnabled 
    public static Account fetchAccountDetails(String accId){
        Account accountDetails; 
        accountDetails = [Select Id, KARZAA_Company_Type__c, Type, 
                          Customer_Type__c,BVC_Company_Type__c, Documents_Uploaded__c, Form_Of_Organization__c 
                          FROM Account WHERE Id = :accId];
        system.debug('accountDetails::'+accountDetails);
        String userId = UserInfo.getUserId();
        UserRecordAccess editAccessCheck=[SELECT RecordId, HasEditAccess ,HasReadAccess  FROM UserRecordAccess 
            WHERE UserId = :userId AND RecordId =:accId];
        system.debug('editAccessCheck.HasEditAccess::'+editAccessCheck.HasEditAccess);
        if(editAccessCheck.HasEditAccess == false)
        {
           system.debug('editAccessCheck.HasEditAccess::'+editAccessCheck.HasEditAccess);
        }
        return accountDetails;
    }
    
    
    
    @AuraEnabled
    public static String saveAccountDocumentDetails(Account acct,String doctitle,String docid){
        string returnString = '';
        Account acc = acct;
        List<ContentDocument> toUpdateCD = new List<ContentDocument>();
        for(ContentDocument doc : [select Id, Title from ContentDocument where Id = :docid]) {
            doc.Title =doctitle;
            toUpdateCD.add(doc);
            system.debug('updated title='+toUpdateCD);
        }
        try {
            //insert contDoc;
            update toUpdateCD;
            update acc;
            returnString = 'Success';
        } catch (Exception e) {
            returnString = e.getMessage();
        }
        
        return returnString;
    }
    
    @AuraEnabled 
    public static void saveIECToApexClass(String inputIEC , String accId){
        Boolean alreadyPresentValue = false;
        Account acc = [Select Id, BVC_Company_Type__c
                       FROM Account WHERE Id = :accId];
        Set<String> bvcCompTypeVal = new Set<String>(acc.BVC_Company_Type__c.split(';'));
        
        for (String str : bvcCompTypeVal) {
            
            if (str == 'International') {
                system.debug('Already has International.');
                alreadyPresentValue = true;
            }
        }
        if(alreadyPresentValue == false)
        {
            if(inputIEC != null)
            {
                Account accObj = new Account();
                accObj.Id = accId;
                accObj.IEC_Manual_Input__c = inputIEC;
                accObj.BVC_Company_Type__c =acc.BVC_Company_Type__c +';'+ 'International';
                update accObj;
            }
        }
        
    }
    @AuraEnabled 
    public static void saveADCodeToApexClass(String inputADCode , String accId){
        Boolean alreadyPresentValue = false;
        Account acc = [Select Id, BVC_Company_Type__c
                       FROM Account WHERE Id = :accId];
        Set<String> bvcCompTypeVal = new Set<String>(acc.BVC_Company_Type__c.split(';'));
        
        for (String str : bvcCompTypeVal) {
            
            if (str == 'CB Customer') {
                system.debug('Already has CB Customer.');
                alreadyPresentValue = true;
            }
        }
        If(alreadyPresentValue == false)
        {
            if(inputADCode != null)
            {
                Account accObj = new Account();
                accObj.Id = accId;
                accObj.AD_Code_Manual_Input__c = inputADCode;
                accObj.BVC_Company_Type__c = acc.BVC_Company_Type__c +';'+ 'CB Customer';
                update accObj;
            } 
        }
        
        
    }
    
    
    
}