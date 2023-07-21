public with sharing class BVC_LedgerTableController {

    @AuraEnabled(cacheable=true)
    public static List<Ledger__c> getLedgers(date startdate, date endDate){ //date startdate, date endDate
        List<Ledger__c> ledgerList = new List<Ledger__c>();

        Integer startMonth = startdate.Month();
        Integer startYear = startdate.Year();
        Integer endMonth = endDate.Month();
        Integer endYear = endDate.Year();

        ledgerList = [SELECT Accounting_Date__c,Account_Number__c,Amount__c,Applied_Invoice_Number__c,Bill_No__c,
        Bill_To_Site_Number__c,BVC_Branch__c,BVC_Company_ID__c,BVC_Master_ID__c,BVC_Site_ID__c,CreatedById,
        CreatedDate,Credit_INR__c,Credit__c,CurrencyIsoCode,Currency_Code__c,Customer__c,Customer__r.Name,Debit_INR__c,Debit__c,
        Due_Date__c,Exchange_Rate__c,Id,Invoice_Number__c,IsDeleted,LastModifiedById,LastModifiedDate,
        Legal_Entity__c,Name,Original_Doc_No__c,PAN__c,Particular__c,Site_Name__c,Site_Number__c,SystemModstamp,
        Tax__c,Trade_Name__c,Transaction_Date__c,Vch_Type__c FROM Ledger__c WHERE (CALENDAR_YEAR(Accounting_Date__c)>=:startYear AND CALENDAR_MONTH(Accounting_Date__c)>=:startMonth AND 
        CALENDAR_YEAR(Accounting_Date__c)<=:endYear AND CALENDAR_MONTH(Accounting_Date__c)<=:endMonth AND Vch_Type__c!='Opening Balance' AND Vch_Type__c!='Closing Balance') OR (
        (CALENDAR_YEAR(Accounting_Date__c)=:startYear AND CALENDAR_MONTH(Accounting_Date__c)=:startMonth AND Vch_Type__c='Opening Balance') OR
        (CALENDAR_YEAR(Accounting_Date__c)=:endYear AND CALENDAR_MONTH(Accounting_Date__c)=:endMonth AND Vch_Type__c='Closing Balance')) ORDER BY Accounting_Date__c];

        system.debug(ledgerList);

        return ledgerList;
    }
}