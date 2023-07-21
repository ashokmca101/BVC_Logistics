trigger CreditNoteTrigger on blng__CreditNote__c (before insert, before update, after insert, after update) {

   // GST Based serial Number calculation
    if(Trigger.isBefore && Trigger.isInsert ){
        CreditNoteTriggerHandler.updateEmailRecepients(trigger.new);
        //CreditNoteTriggerHandler.gstSerialNumberUpdate(trigger.new);
        CreditNoteTriggerHandler.ValidateCreditAmountInsert(trigger.new);
        CreditNoteTriggerHandler.updateRecordType(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate ){
        CreditNoteTriggerHandler.ValidateCreditAmount(trigger.new,trigger.oldMap);
        CreditNoteTriggerHandler.gstSerialNumberUpdate(trigger.new);
        CreditNoteTriggerHandler.amountsInWordConversion(trigger.new,trigger.oldMap);
    }
    //CPQ_ConnectController controller = new CPQ_ConnectController();
    if(Trigger.isAfter && Trigger.isInsert){ 
        
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        
       CreditNoteTriggerHandler.callEYTaxCal(trigger.new,trigger.oldMap);
       CreditNoteTriggerHandler.generateDocument(trigger.new,trigger.oldMap);
    }

}