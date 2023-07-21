trigger updateURlonShipmentUsingCDL on ContentDocumentLink (after insert) 
{
    List<String> cdIds = new list<String>();
    List<String> shipIds = new list<String>();
    
    for(ContentDocumentLink cdl : trigger.new)
    {
        cdIds.add(cdl.ContentDocumentId);
        shipIds.add(cdl.LinkedEntityId);
    }
    
    List<ContentVersion> cvList = [select Id, ContentDocumentId, VersionDataUrl from ContentVersion  where ContentDocumentId IN :cdIds];
    
    List<Shipment__c> shipList = [Select Id,POD_Link__c from Shipment__c where Id IN : shipIds];
    
    
    
}