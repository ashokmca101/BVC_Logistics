public class EY_TaxIntegrationQueueable implements Queueable,Database.AllowsCallouts{
    List <blng__Invoice__c> invoices2Tax= new List<blng__Invoice__c>();
    
    public EY_TaxIntegrationQueueable (List<blng__Invoice__c> invList )
    {
        invoices2Tax = invList ;
    }
    public void execute(QueueableContext qc){
        List<Id> invIds = new List<Id>();
        List<Id> razorpayInvoiceIds = new List<Id>();
        
        for(blng__Invoice__c inv : invoices2Tax){
            invIds.add(inv.Id);           
        }
        
        if(invIds.size() >0){
            razorpayInvoiceIds.addAll(QueryUtility.invoiceQuery(invIds));
        }
        
        system.debug('Invoice List 4 razor pay >>>'+razorpayInvoiceIds);
        if(razorpayInvoiceIds.size() > 0 && !Test.isRunningTest()){
            system.enqueueJob(new RazorpayQueueable(razorpayInvoiceIds));
            
        }
        
}
}