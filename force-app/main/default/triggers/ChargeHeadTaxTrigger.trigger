trigger ChargeHeadTaxTrigger on Charge_Head_Tax__c (after insert,before insert) {
    if(trigger.isBefore && trigger.isInsert){
      ChargeHeadTaxTriggerHandler.chargeHeadCode(trigger.new);  
    }
    if(trigger.isAfter && trigger.isInsert){
        ChargeHeadTaxTriggerHandler.invoiceTaxCalculator(trigger.new);
    }
}