trigger updateBillingAccount on Shipment__c (before insert, before update) {
    //system.debug('Trigger called');
    Set<Id>accountIds=new Set<Id>();
    List<Shipment__c> ShipmentWithBillingAccountList = new List<Shipment__c>();
    for(Shipment__c shp:trigger.new){
        if(shp.Customer__c!=null){
            accountIds.add(shp.Customer__c);
        }
        if(shp.Billing_Account__c !=null){
            ShipmentWithBillingAccountList.add(shp);
        }           
    }
    
    Profile [] profileList = [SELECT Id, Name, UserType, UserLicense.Name FROM Profile WHERE Id=:userinfo.getProfileId() AND UserLicense.Name like 'Customer Community Plus%' LIMIT 1];
    
    Boolean showError = profileList.size() > 0 ? false: true;
    
    
    Map<Id,Account>mapOfIdVsAccount=new Map<Id,Account>([SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:accountIds]);
    for(Shipment__c sh:trigger.new){
        if(sh.Customer__c !=null && (trigger.isInsert || sh.Customer__c != trigger.oldmap.get(sh.id).Customer__c)){
            if(mapOfIdVsAccount.containsKey(sh.Customer__c)){
                //system.debug('>>'+mapOfIdVsAccount.get(sh.Customer__c));
                //system.debug('>>'+mapOfIdVsAccount.get(sh.Customer__c)+' :'+mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size());
                if(mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size()==0){
                    sh.Billing_Account__c=mapOfIdVsAccount.get(sh.Customer__c).id;
                    sh.Billing_Address__c=mapOfIdVsAccount.get(sh.Customer__c).Primary_Address__r.id;
                }
                if(mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size()==1){
                    for(Account cust:mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts){
                        sh.Billing_Account__c=cust.id;
                        sh.Billing_Address__c=cust.Primary_Address__r.id;
                    }
                }
                if(mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size()>1 &&(sh.Billing_Account__c==null || sh.Billing_Address__c==null)){
                    if(showError ){ // to bypass mobile and Community
                        if(sh.Shipment_Created_Through__c != 'Mobile App'){
                            trigger.new[0].addError('Please select a Billing Account');
                        }
                        
                    }
                    
                } 
            }
        }
        
    } 
    if(ShipmentWithBillingAccountList !=null && ShipmentWithBillingAccountList.size()>0){
        //system.debug('calling handler');
        updateBillingAccount_handler.updatePrimaryAddress(ShipmentWithBillingAccountList);
    }
    
    /* if(Trigger.isBefore){
if( Trigger.isInsert){
TMS_PickAndDeliveriesAssignment.shipmentAssignment(Trigger.new);
}
}*/ 
}