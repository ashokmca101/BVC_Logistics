public without sharing class Community_InvoiceOutstandingCtrl {
    
    @AuraEnabled(cacheable=true)
    public static  List<Invoice_Outstanding_Report__c>  getData(date startdate, date endDate){
        system.debug('method inoked');
        List<Invoice_Outstanding_Report__c> invoiceList = new List<Invoice_Outstanding_Report__c>();

        Integer startMonth = startdate.Month();
        Integer startYear = startdate.Year();
        Integer endMonth = endDate.Month();
        Integer endYear = endDate.Year();
        
        invoiceList = [Select id ,Name,Trade_Name__c,Shipping_Number__c,Document_Type__c,
                       Document_Number__c,Document_Date__c,Amount_Due__c,Due_date__c,Original_Amount__c,Customer__c
                       from Invoice_Outstanding_Report__c where Customer__c =: Utility.getCommunityUserAccountId() and 
                        Document_Date__c >= :startDate AND Document_Date__c <= :endDate ] ;
        return invoiceList;
    }
}