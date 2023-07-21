trigger tms_VehicleVault on Secure_Bag__c (before update ) {
    if(Trigger.isUpdate){
        tms_VehicleVaultHandler.updateSecureBagLocation(trigger.new);
    }
}