trigger QuoteTrigger on SBQQ__Quote__c (after update,after insert,before update,before delete) {
    
    
    if(Trigger.isbefore && Trigger.isUpdate){
        for(SBQQ__Quote__c q : trigger.new){
            if(q.Base_Quote__c == true && trigger.oldMap.get(q.Id).Base_Quote__c == true){
                q.addError('Base Quote Cannot be edited');
            }
            
            
        }
        QuoteTriggerHandler.lockQuoteAfterQuoteSent(trigger.newMap,trigger.oldMap);
    }
    
    
    if(Trigger.isAfter && Trigger.isUpdate ){
        system.debug('After Update:::');
        QuoteTriggerHandler.submitForApproval(trigger.newMap,trigger.oldMap);
        if(UtilClass.quoteFirstTime){
            UpdateNonACRTemplate.deleteNonACRTemplate(Trigger.new,Trigger.oldMap);
        }
        
        UpdateNonACRTemplate.afterInsert(Trigger.new,Trigger.oldMap);
        QuoteTriggerHandler.UpdateQuoteLineExhibitionLookup(trigger.new,trigger.oldMap);
    }
    if(Trigger.isbefore &&  Trigger.isDelete){
        Id profileId=userinfo.getProfileId();
        for(SBQQ__Quote__c q : trigger.old){
            if(q.Base_Quote__c == true ){
                q.addError('Base Quote Cannot be Deleted');
            }
        }
    }
    
}