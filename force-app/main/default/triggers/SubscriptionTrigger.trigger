trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert) {
    
    if(trigger.isAfter && trigger.isInsert){
        
        Set<Id> contractIds = new Set<Id>();
        for(SBQQ__Subscription__c subs : trigger.new){
            contractIds.add(subs.SBQQ__Contract__c);
        }
        if(!contractIds.isEmpty()){
            SubscriptionTriggerHandler.updateContract(contractIds);
        }
        
    }

}