public class ConsolidatedRazorpayGeneratorBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    List<Id> invoiceIds= new List<Id>();
     string query = 'Select id from blng__invoice__c where id in:invoiceIds';
    
    public ConsolidatedRazorpayGeneratorBatch(List<Id> invIds){
        this.invoiceIds = invIds;
    }
   
    public Database.QueryLocator Start(Database.BatchableContext ctx){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext ctx, List<blng__Invoice__C> rpayInvoices){
        system.debug('Invoice Ids for RazorPay Batch>>>'+invoiceIds);
        List<Id> listIds= new List<Id>();
        for(blng__invoice__c inv : rpayInvoices){
            listIds.add(inv.Id);
        }
        CPQ_ConnectController.authurl(listIds);
    }
    
    public void finish(Database.BatchableContext ctx ){
        system.debug('Successfully Completed Razorpay Integration for Consolidated Invoices');
    }
}