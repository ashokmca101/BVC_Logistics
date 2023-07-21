public class SubscriptionTriggerHandler {
    
    @future
    public static void updateContract(Set<Id> contractIds){
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        List<Contract> contractToBeUpdated = new List<Contract>();
        Contract  cont;
        
        for(SBQQ__Subscription__c subs : [SELECT Id, ST_Package_Type__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__NetAmount__c,SBQQ__Contract__r.StartDate, 
                                          SBQQ__Contract__r.BVC_Entity__c, SBQQ__Contract__r.BVC_Billing_Entity__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Billing_Entity__c,
                                          SBQQ__Contract__r.BVC_Branch__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Branch__c,ST_Exhibition__c,
                                          SBQQ__Contract__r.Contract_Signed_Date__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.Contract_Signed_Date__c,
                                          SBQQ__Contract__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Business_Type__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Entity__c
                                          FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c=:contractIds AND SBQQ__Contract__r.Status != 'Expired' ])
        {
            String packageType;
            //cont = new Contract();
            if(subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Business_Type__c == 'ACR')
            {
                if(!String.isBlank(subs.ST_Package_Type__c) && !contractMap.containsKey(subs.SBQQ__Contract__c))
                {
                    cont = new Contract(Id=subs.SBQQ__Contract__c,Business_Type__c = 'ACR',
                                        Contracted_ACR_Package__c =subs.ST_Package_Type__c,
                                        BVC_Entity__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Entity__c,
                                        BVC_Billing_Entity__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Billing_Entity__c,
                                        BVC_Branch__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Branch__c,
                                        Contract_Signed_Date__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Contract_Signed_Date__c,
                                        Contract_Amount__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__NetAmount__c);
                    
                    contractMap.put(subs.SBQQ__Contract__c, cont);
                }
            }
            else if(subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Business_Type__c == 'Non ACR' || subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Business_Type__c == 'Exhibition'){
                if(!contractMap.containsKey(subs.SBQQ__Contract__c) && subs.SBQQ__Contract__r.StartDate <= Date.today()){
                    cont = new Contract(Id=subs.SBQQ__Contract__c,Business_Type__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Business_Type__c,
                                        BVC_Entity__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Entity__c,
                                        BVC_Billing_Entity__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Billing_Entity__c,
                                        BVC_Branch__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Branch__c,
                                        Contract_Signed_Date__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Contract_Signed_Date__c,
                                        Status = 'Activated',Exhibition__c = subs.ST_Exhibition__c);                    
                    contractMap.put(subs.SBQQ__Contract__c, cont);
                }
                else if(!contractMap.containsKey(subs.SBQQ__Contract__c) && subs.SBQQ__Contract__r.StartDate > Date.today()){
                    cont = new Contract(Id=subs.SBQQ__Contract__c,
                                        BVC_Entity__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Entity__c,
                                        BVC_Billing_Entity__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Billing_Entity__c,
                                        BVC_Branch__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.BVC_Branch__c,
                                        Contract_Signed_Date__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Contract_Signed_Date__c,
                                        Business_Type__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Business_Type__c,
                                        Exhibition__c = subs.ST_Exhibition__c);                    
                    contractMap.put(subs.SBQQ__Contract__c, cont);                    
                }
            }
            
        }
        
        if(!contractMap.isEmpty()){
            system.debug('Contract Business Type:::'+contractMap);
            update contractMap.values();
        }
    }
    
}