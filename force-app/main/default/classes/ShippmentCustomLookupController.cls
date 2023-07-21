public with sharing class ShippmentCustomLookupController {
   
    // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName , String recType) {    
        List < sObject > sObjList = new List < sObject > ();
        string sText = '%' + searchKey + '%';
        string sWildCardText =  recType;
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sText And Customer__c =:sWildCardText order by Name ASC' ;
        
    system.debug('sQuery--->'+sQuery);
    for (sObject obj: database.query(sQuery)) {
        sObjList.add(obj);
    }
    System.debug('sObjList---'+sObjList);
    return sObjList;
}
}