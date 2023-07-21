trigger InvoiceLineTrigger on blng__InvoiceLine__c (after insert,after update, before insert) {
    if(trigger.isInsert && trigger.isBefore){
        system.debug('Inv Line before Insert : ');
       InvoiceLineTriggerHandler.updateManualInvoiceBillingDetails(trigger.new); 
    }
    if(trigger.isInsert && trigger.isAfter){
        InvoiceLineTriggerHandler.populateInvoiceProductField(trigger.new);
        InvoiceLineTriggerHandler.updateOrderProductFields(trigger.new);
    }
    
    if((trigger.isInsert || trigger.isUpdate )&& trigger.isAfter){
        InvoiceLineTriggerHandler.rollupInvoiceCharges(trigger.new, trigger.oldMap);
    }
    
}