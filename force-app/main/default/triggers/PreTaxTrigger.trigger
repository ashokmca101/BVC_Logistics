trigger PreTaxTrigger on BVC_CB_PreTaxBill__c (after update) {
    List<Id> preTaxList = new List<Id>();
    for(BVC_CB_PreTaxBill__c preTax:Trigger.New){
        if(preTax.BVC_CB_PretaxDetails_Inserted__c && !Trigger.OldMap.get(preTax.Id).BVC_CB_PretaxDetails_Inserted__c){ 
        	preTaxList.add(preTax.Id);	
        }   
    }
    if(!preTaxList.isEmpty()){
    	PreTaxTriggerHandler.createOrderFromPreTax(preTaxList); 
    }

}