public class ClearInvalidIntegrationLogBatch implements Database.Batchable<SObject>{
    Integer daysToExpiry = Integer.valueOf(Label.Integration_Log_Days_to_Expiry);
    String query = 'SELECT Id,Invoice__c,Integration_Server__c FROM Integration_Log__c WHERE CreatedDate <= LAST_N_DAYS:'+daysToExpiry;    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope){
        Database.delete(scope,false);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }

}