public without Sharing class Community_KYC_SettingsController {
    
    public static User fetchLoggedInUser(){
        Id userId = UserInfo.getUserId();
        return [SELECT IsActive, Id, Name, ContactId FROM User WHERE Id = :userId];
    }
    
    @AuraEnabled 
    public static ContactWrapper fetchAccountDetails(){
        User currentUser = fetchLoggedInUser();
        Account accountDetails; 
        Contact currentContact;
        If(currentUser!=null){
            currentContact = [SELECT Id, AccountId, Name,Phone,Email,MobilePhone,Account.PAN_Number_of_Entity__c, Account.Name_As_Per_PAN_Manual_Input__c, Account.KARZAA_Name_As_Per_PAN__c,
            Account.BillingAddress, Account.KARZAA_GSTIN__c, Account.KARZAA_SEZ_Status__c, Account.IEC__c, Account.AD_Code__c, Account.Owner.Profile.Name FROM Contact WHERE Id = :currentUser.ContactId];
            if(CurrentContact!=null){
                accountDetails = [Select Id, Name, PAN_Number_of_Entity__c, Name_As_Per_PAN_Manual_Input__c, KARZAA_Name_As_Per_PAN__c,BVC_Legal_Entity__c,GSTIN__c,Trade_Name__c,
                BillingAddress,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,KARZAA_GSTIN__c,KARZAA_SEZ_Status__c,IEC__c,AD_Code__c,AD_Code_Manual_Input__c,IEC_Manual_Input__c, Owner.Profile.Name, KARZAA_Company_Type__c, Type, 
                BVCSoftwareID__c, Customer_Type__c, Documents_Uploaded__c, Form_Of_Organization__c,BVC_Company_Type__c , KYC_Indicator_For_CB_Customer__c ,KYC_Indicator_for_Domestic__c ,KYC_Indicator_For_International__c  FROM Account WHERE Id = :currentContact.AccountId Limit 1];
            }
        }
        Community_KYC_SettingsController.ContactWrapper wrapper = new Community_KYC_SettingsController.ContactWrapper();
        wrapper.acc = accountDetails;
        wrapper.con = currentContact;
        system.debug(wrapper);
        return wrapper;
    }

    @AuraEnabled
    public static string saveAccountDetails(ContactWrapper wrapper){
        string returnString = '';
        Account acc = wrapper.acc;
        Contact con = wrapper.con;
        try {
           update acc; 
           update con;
           returnString = 'Success';
        } catch (Exception e) {
            returnString = e.getMessage();
        }

        return returnString;
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
    public static List<String> fetchKYCDocs(Account acc){
        List<String> existingDocs = new List<String>();
        for(KYC_Document__c KYCDoc : [SELECT Id,Name,Customer__c,Type_Of_Document__c FROM KYC_Document__c WHERE Customer__c =: acc.id]){
            existingDocs.add(KYCDoc.Type_Of_Document__c);
        }
        if(existingDocs==null){
            existingDocs.add('NONE');
        }        
        return existingDocs;
    }

    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname){
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
               
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        system.debug('List: ' + optionlist);
        return optionlist;
    }
    
    public static string getCurrentUserAccountId(){
        User currentusr= [Select id,Name,Contact.Accountid From User Where Id =:Userinfo.getUserId()];
        return currentusr.Contact.Accountid;
    }
    
    @AuraEnabled 
    public static void saveIECToApexClass(String inputIEC, String accId){
        /*String accId = Community_KYC_SettingsController.getCurrentUserAccountId();
        if(inputIEC != null)
        {
            Account accObj = new Account();
            accObj.Id = accId;
            accObj.IEC_Manual_Input__c = inputIEC;
            update accObj;
        }*/
        
        
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
                accObj.Export_House__c = 'Export house For BVCI';
                accObj.Customer_Type__c = 'PRIVATE';
                update accObj;
            }
        }
        if(alreadyPresentValue)
        {
            if(inputIEC != null)
            {
                Account accObj = new Account();
                accObj.Id = accId;
                accObj.IEC_Manual_Input__c = inputIEC;
                update accObj;
            }
        }
    }
    
    @AuraEnabled 
    public static void saveADCodeToApexClass(String inputADCode, String accId){
        /*String accId = Community_KYC_SettingsController.getCurrentUserAccountId();
        if(inputADCode != null)
        {
            Account accObj = new Account();
            accObj.Id = accId;
            accObj.AD_Code_Manual_Input__c = inputADCode;
            update accObj;
        }*/
        
        Boolean alreadyPresentValue = false;
        Account acc = [Select Id, BVC_Company_Type__c,IEC_Manual_Input__c
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
                if(acc.IEC_Manual_Input__c == null || acc.IEC_Manual_Input__c == ''){
                    accObj.IEC_Manual_Input__c = '0';
                }
                accObj.BVC_Company_Type__c = acc.BVC_Company_Type__c +';'+ 'CB Customer';
                update accObj;
            } 
        }
        If(alreadyPresentValue)
        {
            if(inputADCode != null)
            {
                Account accObj = new Account();
                accObj.Id = accId;
                accObj.AD_Code_Manual_Input__c = inputADCode;
                if(acc.IEC_Manual_Input__c == null || acc.IEC_Manual_Input__c == ''){
                    accObj.IEC_Manual_Input__c = '0';
                }
                update accObj;
            } 
        }
        
    }
    

    public class ContactWrapper {
        @AuraEnabled public Contact con {get;set;}
        @AuraEnabled public Account acc {get;set;}
        
    }
}