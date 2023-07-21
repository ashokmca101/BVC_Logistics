trigger ShipmentTrackingTrigger on Shipment_Tracking__c (before Insert,after Insert) 
{
    /*
    if(trigger.isInsert && trigger.isBefore)
    {
        List<Shipment_Tracking__c> stList = new List<Shipment_Tracking__c>();
        for(Shipment_Tracking__c st : trigger.new)
        {
           stList.add(st);
        }
        if(stList.size()>0)
        {
            ShipmentShare.ShareShipment(stList);
        }
    }
    */
    /*
    if(trigger.isInsert && trigger.isBefore)
    {
        Integer temp = 0;        
             for(Shipment_Tracking__c st:trigger.new)
             {
                 temp=0;
                 Shipment__c sh = [select id,Pickup__c from Shipment__c where Id=:st.Shipment__c limit 1];
                 Pickup__c pk = [select Id,Pickup_Status__c,Name from Pickup__c where Id=:sh.Pickup__c limit 1];
                 if(st.Location__c=='Created' || st.Location__c=='Out for Pickup' || st.Location__c=='Picked Up')
                 {
                    temp = 1; 
                 }
                 if(pk.Pickup_Status__c!='Completed' && temp==0)
                 {
                    st.addError('Complete the Pickup '+pk.Name+' Then Proceeds');                   
                 }
             }
    }

    if(trigger.isInsert && trigger.isAfter)
    {
        String test;
        for(Shipment_Tracking__c st:trigger.new)
        {
            test = st.Location__c;
        }
    }
*/
}