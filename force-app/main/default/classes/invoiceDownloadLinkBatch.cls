global class invoiceDownloadLinkBatch implements Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC){
       string query = 'select id,name,Invoice_Public_Link__c from blng__Invoice__c';
       return Database.getQueryLocator(query);
   	}
   global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope){
       
        for(blng__Invoice__c s:scope){
       	//	s.Status = 'Activated';
       }
  }
    
   global void finish(Database.BatchableContext BC){
       
   }

}