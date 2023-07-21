global class ContractActivationBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Map<Id, blng__Invoice__c> paidInvoiceMap = new Map<Id, blng__Invoice__c>();
    public static final String contractStatus = 'Draft';
    public static final String contractQuery = 'Select Id,SBQQ__Order__c,AccountId,Business_Type__c,Status,StartDate from Contract where StartDate <= Today and Status =: contractStatus';
    
    global ContractActivationBatch(){
        System.debug('===ContractActivationBatch');
        Set<Id> accountIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        
        
        for(Contract con : [select Id, SBQQ__Order__c, AccountId, Business_Type__c from Contract where StartDate <= today and Status = 'Draft'])
        {
            accountIds.add(con.AccountId);
            orderIds.add(con.SBQQ__Order__c);            
        }
        
        System.debug('===accountIds : '+accountIds);
        System.debug('===orderIds : '+orderIds);
        
        for(blng__Invoice__c inv : [select Id,blng__PaymentStatus__c, blng__InvoiceStatus__c,blng__Order__c,blng__Account__c 
                                    from blng__Invoice__c where blng__Order__c = : orderIds and blng__Account__c = : accountIds])
        {
            if(inv.blng__PaymentStatus__c == 'Paid' && inv.blng__InvoiceStatus__c == 'Posted'){
                paidInvoiceMap.put(inv.blng__Order__c , inv);
            }
        }
        System.debug('===paidInvoiceMap : '+paidInvoiceMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('===start');
        return Database.getQueryLocator(contractQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> contList) {
        System.debug('===execute');
        System.debug('===Execute contList : '+contList.size());
        List<Contract> contractToBeUpdated = new List<Contract>();
        
        for(Contract cont : contList){
            if(cont.Business_Type__c == 'ACR' && cont.Status == 'Draft'){
                if(paidInvoiceMap.containsKey(cont.SBQQ__Order__c)){
                    cont.Status = 'Activated';
                    contractToBeUpdated.add(cont);
                }
            }
            else if((cont.Business_Type__c == 'Non ACR' || cont.Business_Type__c == 'Exhibition')  && cont.Status == 'Draft'){
                cont.Status = 'Activated';
                contractToBeUpdated.add(cont);
            }
        }
        
        try{
            system.debug('===contractToBeUpdated : '+contractToBeUpdated.size());
            if(!contractToBeUpdated.isEmpty()){
                update contractToBeUpdated;
            }
        }
        catch(Exception ex){
            System.debug('Exception occurred : '+ex.getMessage()+' Error at Line number : '+ex.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //Nothing to add for now
    }
    
    
    global void execute(SchedulableContext sc) {
        ContractActivationBatch batch = new ContractActivationBatch();
        database.executebatch(batch);
    }     
}