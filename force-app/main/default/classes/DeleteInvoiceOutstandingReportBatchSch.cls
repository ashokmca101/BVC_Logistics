global class DeleteInvoiceOutstandingReportBatchSch implements Schedulable {
   global void execute(SchedulableContext SC) {
      DeleteInvoiceOutstandingReportBatch batch = new DeleteInvoiceOutstandingReportBatch(); 
      Database.executeBatch(batch, 200);
   }
}