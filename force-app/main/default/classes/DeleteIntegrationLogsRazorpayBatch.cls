global class DeleteIntegrationLogsRazorpayBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Integration_Log__c WHERE Integration_Server__c = 'Razorpay' AND CreatedDate < LAST_N_DAYS : 60
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Integration_Log__c> logs) {
        try {
            delete logs;
        } catch (Exception e) {
            System.debug(e);
        }
    }
	    
    global void finish(Database.BatchableContext bc) {
    }
}