public class RemoveShipmentSharing {
    @InvocableMethod(label='RemoveShipmentSharing')
    public static void RemoveSharing(List<ID> ids)
    {
        System.debug('RemoveSharing ids :'+ids);
        Shipment__c ship = [select Id,Delivery_Route_Assigned_To__c from Shipment__c where Id=:ids[0]];
        List<Shipment__share> ShareList = [select Id,ParentId,UserOrGroupId from Shipment__share where ParentId=:ship.Id];
        System.debug('RemoveSharing ShareList :'+ShareList);
        List<ID> userIds = new List<ID>();
        List<ID> DelUIds = new List<ID>();
        if(ShareList.size()>0)
        {
            for(Shipment__share sh :ShareList)
            {
                userIds.add(sh.UserOrGroupId);
            }
            
            List<User> ESList = [select Id, Name from User where Id IN :userIds AND Profile.Name = 'Operations Field Executive'];
            for(User u:ESList)
            {
                DelUIds.add(u.Id);
            }
            if(DelUIds.size()>0)
            {
                // if(ship.Delivery_Route_Assigned_To__c)
                System.debug('Deleted Sahring Rec DelUIds :'+DelUIds);
                System.debug('Deleted Sahring Rec DelUIds :'+ship.Delivery_Route_Assigned_To__c);               
                List<Shipment__share> DelShareList = [select Id,ParentId,UserOrGroupId from Shipment__share where ParentId =: ship.Id AND UserOrGroupId IN : DelUIds];
                System.debug('Deleted Sahring Rec :'+DelShareList);
                Database.DeleteResult[] lsr = Database.Delete(DelShareList,false);
                System.debug('lsr :'+lsr);
                if(ship.Delivery_Route_Assigned_To__c !=null)
                {
                    System.debug('not null');
                    Shipment__share share = new Shipment__share();
                    share.ParentId = ship.Id;
                    share.AccessLevel = 'Edit';
                    share.UserOrGroupId = ship.Delivery_Route_Assigned_To__c;
                    share.RowCause=Schema.Shipment__share.RowCause.Manual;
                   // Database.DeleteResult[] lsr1 = Database.Insert(share,false);
                    insert share;
                    System.debug('share'+share);
                }                
                // delete DelShareList;
            }
        }
    }

}