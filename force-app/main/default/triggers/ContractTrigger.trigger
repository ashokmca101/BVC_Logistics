trigger ContractTrigger on Contract (before insert,after update, after insert, before update ) {
    
    if(trigger.isBefore && trigger.isInsert){
        //To populate invoice number in contract
        ContractTriggerHandler.populateinvoice(Trigger.New); 
        
    }
    
    if(trigger.isBefore && trigger.isUpdate  ){
    
         
        for(Contract c : trigger.new){
            if(c.Business_Type__c=='ACR' && c.Invoice__c==null){
               ContractTriggerHandler.populateinvoice(Trigger.New); 
            }
            Contract oldValue = trigger.oldMap.get(c.Id);
            if(c.EndDate <> oldValue.EndDate){
                c.Original_Contract_End_Date__c = oldValue.EndDate;
            } 
        }        
    }
    
    if(trigger.isAfter && trigger.isUpdate ){
        system.debug('===AfterUpdate called from Contract Trigger');
        system.debug('===isFirstTime'+UtilClass.isFirstTime);
        ContractTriggerHandler.createPriceTables(trigger.newMap,trigger.oldMap);
        ContractTriggerHandler.sendContractExpiryEmail(Trigger.New,trigger.OldMap);
        ContractTriggerHandler.resetEmailTriggerACRAdjustment(trigger.newMap,trigger.oldMap);
        if(UtilClass.isFirstTime){
            ContractTriggerHandler.deactivateExistingPriceTable(trigger.newMap,trigger.oldMap);
        }
     
       
        if(trigger.new[0].BVC_Service__c=='BATH' || trigger.new[0].BVC_Service__c=='eSHIP'){
           if((trigger.new[0].Consumed_Amount__c>=trigger.new[0].Consumed_Amount_85__c && trigger.new[0].Greater_That_85_consumed_Amount__c!=trigger.old[0].Greater_That_85_consumed_Amount__c)|| trigger.new[0].Consumed_Amount__c>=trigger.new[0].Consumed_Amount_98__c) {
            SendContractAnnaxureEmail.sendConsumptionDetails(trigger.new);
          }
        }
  
        
         if(trigger.new[0].BVC_Service__c=='BATH' || trigger.new[0].BVC_Service__c=='eSHIP'){
            if(trigger.new[0].Consumed_Amount__c>=trigger.new[0].Consumed_Amount_85__c && trigger.new[0].Greater_That_85_consumed_Amount__c!=trigger.old[0].Greater_That_85_consumed_Amount__c){
                SendContractAnnaxureEmail.contractRenewal(trigger.new);
        	}
         }
        
    }   
    
}