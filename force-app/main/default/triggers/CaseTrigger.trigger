trigger CaseTrigger on Case (before update,before insert) {
    if(Trigger.isBefore && Trigger.isUpdate)  {
        Case_TriggerHandlerCtrl.setManuallyTransferred(trigger.new,trigger.OldMap);
    }
}