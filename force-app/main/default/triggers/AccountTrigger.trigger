trigger AccountTrigger on Account (after insert,after update,before update,before insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        Account newAccount =   Trigger.new[0];
        String BillingRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        String QuickBillingRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Quick Billing').getRecordTypeId();
        //system.debug('>> '+Trigger.new[0].RecordTypeId);
        if(newAccount.RecordTypeId==BillingRecType || newAccount.RecordTypeId==QuickBillingRecType){
            //system.debug('Pan verification '+newAccount.RecordTypeId);
            if(!Test.isRunningTest()){
                Account_TriggerHandlerServiceCtrl.verifyPan(newAccount.Id,newAccount.PAN_Number_of_Entity__c);
            }
        }
        
        Account_TriggerHandlerServiceCtrl.AccountsharingWithSecondaryOwner(Trigger.new);
    }
     if(Trigger.isBefore &&  Trigger.isUpdate){
       Account_TriggerHandlerServiceCtrl.setBeforeValues(Trigger.new);
       Account_TriggerHandlerServiceCtrl.setAWSStatus(Trigger.new,trigger.OldMap);
    }
   
    if(Trigger.isAfter && Trigger.isUpdate){
        /*for (Account acc: Trigger.new) {*/
        Account_TriggerHandlerServiceCtrl.AccountsharingWithSecondaryOwner(Trigger.new);
        Account acc =   Trigger.new[0];
        //Here we use the account id, to get the older version of record.
        Account oldAccount = Trigger.oldMap.get(acc.ID);
        
        //once we get the older version, we can get any field's value from older version to compare.
        if((acc.KYC_Status__c  != oldAccount.KYC_Status__c) && (acc.KYC_Status__c == 'API Verified' ) &&( !Test.isRunningTest())) {
            system.debug('old status::'+oldAccount.KYC_Status__c);
            System.enqueueJob(new CRM_QueuableFinancialSummaryAPI(acc.Id,acc.Entity_Id__c,acc.PAN_Number_of_Entity__c));
            system.debug('new status::'+acc.KYC_Status__c);
            system.debug('status value changed.');
            
        }
        //Account_TriggerHandlerServiceCtrl.createPublicLinkForACR(Trigger.new);
    }
}