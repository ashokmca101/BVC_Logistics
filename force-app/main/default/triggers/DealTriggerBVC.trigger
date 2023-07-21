trigger DealTriggerBVC on Opportunity (before insert,After insert,after update) {
    
    if(Trigger.isAfter && Trigger.isInsert){   
       DealTriggerBVCHelper.insertPeopleRole(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert){
       for(Opportunity Opp:Trigger.new){
           if(Opp.BVC_Product__c==null){
               DealTriggerBVCHelper.updateProductFd(trigger.new);   
           }
       }
            OpportunityDuplicateValidator.checkForDuplicates(Trigger.new);
            OpportunityValidationClass.validateOpportunity(Trigger.new, Trigger.oldMap);
    }
 
}