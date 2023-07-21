public class Community_InvoicesTableController {

   @AuraEnabled(cacheable=true)
   public static List<InvoiceWrapper> getInvoices(date startDate, date endDate){
        List<InvoiceWrapper> invoiceWrapperList = new List<InvoiceWrapper>();
        
        Map<Id,Id> invoiceIdtoContentDocIdMap = new Map<Id,Id>();
        Map<Id,ContentVersion> invoiceIdtoCVMap = new Map<Id,ContentVersion>();

        Map<Id,blng__Invoice__c> invoiceMap = new Map<Id,blng__Invoice__c>();

        string domain = 'bvc2--bvcdev.lightning.force.com';
            
        for(blng__Invoice__c inv: [SELECT Id,blng__InvoiceDate__c,blng__LastPaymentRunId__c,
        blng__PaymentRunId__c,blng__UniqueId__c,Name,SystemModstamp 
        FROM blng__Invoice__c WHERE blng__InvoiceDate__c >= :startDate AND blng__InvoiceDate__c <= :endDate ]){
            invoiceMap.put(inv.Id, inv);
        }
		//List<ContentDocumentLink> toUpdateCDL = new List<ContentDocumentLink>();//
        for(ContentDocumentLink conDocLink: [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :invoiceMap.keyset()]){
            invoiceIdtoContentDocIdMap.put(conDocLink.LinkedEntityId, conDocLink.ContentDocumentId);
            //conDocLink.Visibility = 'AllUsers';//
            //toUpdateCDL.add(conDocLink);//
        }
        //update toUpdateCDL;//
        for(blng__Invoice__c invoiceItem: invoiceMap.values()){
            InvoiceWrapper invWrapper = new InvoiceWrapper();
            invWrapper.invoice = invoiceItem;
            invWrapper.invoiceDate = invoiceMap.get(invoiceItem.Id).blng__InvoiceDate__c;
            invWrapper.invoiceName = invoiceMap.get(invoiceItem.Id).Name;
            invWrapper.invoiceId = invoiceMap.get(invoiceItem.Id).Id;
            invWrapper.docLink = domain + '/sfc/servlet.shepherd/document/download/'+ invoiceIdtoContentDocIdMap.get(invoiceItem.Id) +'?operationContext=S1';
            invoiceWrapperList.add(invWrapper);
        }

        return invoiceWrapperList;
   }

   public class InvoiceWrapper{
    @AuraEnabled public string docLink{get; set;}
    @AuraEnabled public blng__Invoice__c invoice{get; set;}
    @AuraEnabled public String invoiceName{get; set;}
    @AuraEnabled public Id invoiceId{get; set;}
    @AuraEnabled public Date invoiceDate{get; set;}
   }

}