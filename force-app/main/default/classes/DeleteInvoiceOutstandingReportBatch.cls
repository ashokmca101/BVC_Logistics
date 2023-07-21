Global class DeleteInvoiceOutstandingReportBatch Implements Database.Batchable<sObject>{
	
    Public Database.QueryLocator Start(Database.BatchableContext BC){
        Date TodayDate = Date.today();
        String QueryVar = 'SELECT Id, Name FROM Invoice_Outstanding_Report__c WHERE CreatedDate <= :TodayDate';
        Return	Database.getQueryLocator(QueryVar);
    }
    
    Public Void Execute(Database.BatchableContext BC, List<Invoice_Outstanding_Report__c> RecordList){
        System.Debug('List to be deleted' + RecordList);
        Delete RecordList;
    }
    
    Global Void Finish(Database.BatchableContext BC){
        
    }
}