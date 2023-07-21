public class ShipmentShare 
{
    public static void ShareShipment(List<Shipment_Tracking__c> STList)
    {
        System.debug('ShipmentShare Started');
        List<Id> ListIds = new List<Id>();
        for(Shipment_Tracking__c st:STList)
        {
            ListIds.add(st.Shipment__c);
            System.debug('11.st.Shipment_Tracking__c :'+st.Shipment__c);
        }
        Id userId =UserInfo.getUserId();
        System.debug('11.userId :'+userId);
        List<Shipment__Share> NewSHList = new List<Shipment__Share>();
        if(ListIds.size()>0)
        {
            for(Id ShipId : ListIds)
            {
                System.debug('11.x :'+ShipId);
                Shipment__Share ss = new Shipment__Share();
                List<Shipment__Share> sshare = [select UserOrGroupId from Shipment__Share where UserOrGroupId=:userId and ParentId =: ShipId];
                System.debug('11.sshare :'+sshare);
                if(sshare.size()==0)
                {
                    System.debug('11.Creating :');
                    Shipment__Share newSh = new Shipment__Share(); 
                    newSh.UserOrGroupId=userId;
                    newSh.AccessLevel='Edit';
                    newSh.ParentId=ShipId;
                    newSh.RowCause='Manual';
                    NewSHList.add(newSh);
                    System.debug('11.Created Rec :'+newSh);
                }
            }
            System.debug('11.NewSHList :'+NewSHList);
        }
        if(NewSHList.size()>0)
        {
            insert NewSHList;
        }
        
    }
/*
    public static void ShareShipment(List<Secure_Bag__c> SBList)
    {
        System.debug('ShipmentShare Started');
        List<Id> ListIds = new List<Id>();
        for(Secure_Bag__c sb:SBList)
        {
            ListIds.add(sb.Shipment__c);
            System.debug('11.sb.Shipment__c :'+sb.Shipment__c);
        }
        Id userId =UserInfo.getUserId();
        System.debug('11.userId :'+userId);
        List<Shipment__Share> NewSHList = new List<Shipment__Share>();
        if(ListIds.size()>0)
        {
            for(Id x : ListIds)
            {
                System.debug('11.x :'+x);
                Shipment__Share ss = new Shipment__Share();
                List<Shipment__Share> sshare = [select UserOrGroupId from Shipment__Share where UserOrGroupId=:userId and ParentId =: x];
                System.debug('11.sshare :'+sshare);
                if(sshare.size()==0)
                {
                    System.debug('11.Creating :');
                    Shipment__Share newSh = new Shipment__Share(); 
                    newSh.UserOrGroupId='';
                    newSh.AccessLevel='Edit';
                    newSh.ParentId=x;
                    newSh.RowCause='Manual';
                    NewSHList.add(newSh);
                    System.debug('11.Created Rec :'+newSh);
                }
            }
            System.debug('11.NewSHList :'+NewSHList);
        }
        if(NewSHList.size()>0)
        {
            insert NewSHList;
        }
        
    }
    */
}