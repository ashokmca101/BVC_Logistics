trigger CreditNoteLineTrigger on blng__CreditNoteLine__c (before insert,before update) {
    if(trigger.isInsert && trigger.isBefore){
        CreditNoteLineTriggerHandler.validateChargeHeadAmount(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        CreditNoteLineTriggerHandler.validateChargeHeadAmount(trigger.new);
    }
}