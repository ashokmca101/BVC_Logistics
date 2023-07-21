trigger AddressTrigger on AddressBook__c (after insert,after update) {
    List<Address_Status__mdt> addstatus=[Select id,AddressTriggerStatus__c,RegAccountTriggerStatus__c from Address_Status__mdt limit 1];
    if(addstatus.size()>=1 && addstatus[0].AddressTriggerStatus__c==True && addstatus[0].AddressTriggerStatus__c!=null){
        system.debug('AddressTrigger Before Return');
        return;
    }
    system.debug('AddressTrigger After Return');
    if(Trigger.isAfter && Trigger.isInsert){
        //List<AddressBook__c> newAddress =   Trigger.new;
        Address_TriggerHandlerServiceCtrl a=new Address_TriggerHandlerServiceCtrl();
        if(!Test.isRunningTest()){
            Address_TriggerHandlerServiceCtrl.updateBillingAddressCheckBox(Trigger.new);
        }
        Address_TriggerHandlerServiceCtrl.addressPickupMappingCreation(Trigger.new);
        Address_TriggerHandlerServiceCtrl.createPICKUPADDRESSMAPPING(Trigger.new);
        //Address_TriggerHandlerServiceCtrl.makeAllOtherAddressAsNonBilling(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        
        Address_TriggerHandlerServiceCtrl a=new Address_TriggerHandlerServiceCtrl();
         //List<AddressBook__c> newAddress =   Trigger.new;
        if(!Test.isRunningTest()){
            Address_TriggerHandlerServiceCtrl.updateBillingAddressCheckBox(Trigger.new);
        }
        //Address_TriggerHandlerServiceCtrl.makeAllOtherAddressAsNonBilling(Trigger.old);
        //Here we use the account id, to get the older version of record.
        //Account oldAccount = Trigger.oldMap.get(acc.ID);
        
        
        
    }
}