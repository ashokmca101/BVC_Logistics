global class ExpireContractBatch implements Database.Batchable<sObject>, Schedulable {
    
    public static final String contractStatus = 'Activated';
    public static final String contractQuery = 'Select Id,SBQQ__Order__c,SBQQ__RenewalForecast__c,AccountId,Business_Type__c,Status,StartDate,EndDate from Contract where Status =: contractStatus';
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(contractQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> contList) {
        List<Contract> contractToBeUpdated = new List<Contract>();
        date currentDate = date.today();
        for(Contract cont : contList){
            if(cont.Status <> 'Expired' && cont.EndDate < currentDate){
                cont.Status = 'Expired';
                contractToBeUpdated.add(cont);
            }     
            if(cont.Status <> 'Expired' && cont.SBQQ__RenewalForecast__c == false && cont.EndDate <= currentDate + 30){
                cont.SBQQ__RenewalForecast__c = true;
                contractToBeUpdated.add(cont);
            }  
        }
        
        if(!contractToBeUpdated.isEmpty()){
            update contractToBeUpdated;
        }
    }

    
    global void finish(Database.BatchableContext BC) {
        //Nothing to add for now
    }
    
    
   global void execute(SchedulableContext sc) {
        ExpireContractBatch batch = new ExpireContractBatch();
        database.executebatch(batch);
    }        
}