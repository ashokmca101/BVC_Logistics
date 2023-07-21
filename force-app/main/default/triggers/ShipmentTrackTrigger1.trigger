trigger ShipmentTrackTrigger1 on Shipment_Tracking__c (after insert,after update,after delete) 
{
    
    List<Shipment_Tracking__c> stList = new List<Shipment_Tracking__c>();
    if(trigger.isInsert && trigger.isAfter)
    {
       //Map<Id,Shipment_Tracking__c> oldrec = trigger.OldMap;
        for(Shipment_Tracking__c st : trigger.new)
        {
            if(st.Shipping_Note_No__c!=null){stList.add(st);}            
           // stList.add(st);
        }
    } // Location__c
    
    if(trigger.isUpdate && trigger.isAfter)
    {
       Map<Id,Shipment_Tracking__c> oldMap = trigger.OldMap;
        for(Shipment_Tracking__c st : trigger.new)
        {
            System.debug('11.Shipping_Note_No__c :'+st.Shipping_Note_No__c);
            Shipment_Tracking__c oldRec = oldMap.get(st.Id);
            if(oldRec.Location__c!=st.Location__c)
            {                
                stList.add(st);
            }            
        }
    }    
    
    
    if(stList.size()>0)
    {
     
       String jsoncontent = ShipmentTrackingWebHook.jsonContent(stList);
       ShipmentTrackingWebHook.sendRequest(jsoncontent);
    }

}