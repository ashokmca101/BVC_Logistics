trigger ShipmentTrigger1 on Shipment__c (after insert,after update) 
{
    
    List<Shipment__c> stList = new List<Shipment__c>(); // Tracking_Status__c
    if(trigger.isInsert && trigger.isAfter)
    {
        for(Shipment__c st : trigger.new)
        {
            if(st.Shipping_Note_Number__c!=null){stList.add(st);}            
        }
    }

    if(trigger.isUpdate && trigger.isAfter)
    {
        Map<Id,Shipment__c> oldMap = trigger.OldMap;
        for(Shipment__c st : trigger.new)
        {
            Shipment__c oldRec = oldMap.get(st.Id);
            if(st.LastModifiedDate!=oldRec.LastModifiedDate || st.Shipment_Created_Date_Time__c!=oldRec.Shipment_Created_Date_Time__c )
            //if(st.Tracking_Status__c!=oldRec.Tracking_Status__c)
            {
                stList.add(st);
            }            
        }
    }    
    if(stList.size()>0)
    {        
        String jsoncontent = ShipmentWebHook.jsonContent(stList);
        ShipmentWebHook.sendRequest(jsoncontent);
    }
}