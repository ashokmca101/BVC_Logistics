trigger Bvc_Botform_Trigger on rsplus__Bot_Form__c (before update,after update,after insert) {
   
    //if(trigger.isAfter && (trigger.isupdate || trigger.isInsert))
    // BVC_botFormTriggerHandler.relatedsetup(trigger.new);
    if(trigger.isAfter && trigger.isupdate){
     BVC_botFormTriggerHandler.NewaddressSetup(trigger.new);
    BVC_botFormTriggerHandler.relatedsetup(trigger.new);
    }
 }