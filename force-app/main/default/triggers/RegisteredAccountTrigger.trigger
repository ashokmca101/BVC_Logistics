trigger RegisteredAccountTrigger on Registered_Account__c (after insert,before insert) {
    if(trigger.isInsert && trigger.isBefore){
        for(Registered_Account__c ra:trigger.new){
            ra.Customer_Id__c = ra.Customer__c;
        }
    }
    List<Address_Status__mdt> addstatus=[Select id,AddressTriggerStatus__c,RegAccountTriggerStatus__c from Address_Status__mdt limit 1];
    if(addstatus.size()>=1 && addstatus[0].RegAccountTriggerStatus__c==True && addstatus[0].RegAccountTriggerStatus__c!=null){
        system.debug('AddressTrigger Before Return');
        return;
    }
    system.debug('AddressTrigger After Return');
    
    if(Trigger.isAfter && Trigger.isInsert){
        RegisteredAcc_TriggerHandlerServiceCtrl.createBVCPickupAddressMapping(Trigger.new);
        RegisteredAcc_TriggerHandlerServiceCtrl.createPICKUPADDRESSMAPPING(Trigger.new);
    }
    
}