trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update) {

    if(trigger.isBefore && trigger.isInsert){
        QuoteLineTriggerHandler.UpdateQuoteLineChargeFields(trigger.new);
        QuoteLineTriggerHandler.quoteLineMaxDiscount(trigger.new,null);
    }

    if(trigger.isBefore && trigger.isUpdate)
    {
        if(!UtilClass.qliRecursionCheck){
            QuoteLineTriggerHandler.quoteLineMaxDiscount(trigger.new,trigger.oldMap);
        }
        
    }
    
}