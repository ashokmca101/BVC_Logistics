public class ConsolidateTaxCalBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public List<Id> razorpayInvoiceIds = new List<Id>();
    String query = 'SELECT Id,Name,Razorpay_Id__c,Short_URL__c,'
        +' blng__Account__c FROM blng__Invoice__c WHERE Razorpay_Id__c = null '
        +' AND  Short_URL__c = null AND blng__InvoiceStatus__c = \'Draft\'' 
        +' AND (blng__TaxAmount__c = 0 OR  blng__TaxAmount__c = null) AND blng__InvoiceRunCreatedBy__c != null '
        +' AND blng__Order__c = null ';
   
    public Database.QueryLocator Start(Database.BatchableContext bc){
     	system.debug('Print Query:'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<blng__Invoice__c> scope){
        system.debug('Scope+++'+scope);
        List<Id> invIds = new List<Id>();
        
        
        for(blng__Invoice__c inv : scope){
            invIds.add(inv.Id);           
        }
        
        if(invIds.size() >0){
            razorpayInvoiceIds.addAll(QueryUtility.invoiceQuery(invIds));
        }
        
        system.debug('Invoice List 4 razor pay >>>'+razorpayInvoiceIds);
        
            
    }
    public void finish(Database.BatchableContext bc){
        system.debug('Finish Ids'+razorpayInvoiceIds);
        if(razorpayInvoiceIds.size() >0){
            ConsolidatedRazorpayGeneratorBatch rpaybatch = new ConsolidatedRazorpayGeneratorBatch(razorpayInvoiceIds);
             Id batchProcessId = Database.executeBatch(rpaybatch);
        }
      
    }
}