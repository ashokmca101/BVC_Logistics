public class TMS_PickupSharingHandler {
    
    public static void SharePickupRecords(List<Pickup__c> PickList){
        Map<String,List<String>> UserBranchMap = new Map<String,List<String>>();
        for(User u:[select id, City FROM User WHERE Profile.Name = 'Operations Office Executive' AND City !=null LIMIT 50000]){
            string userCity = u.City.toUpperCase();
            if(UserBranchMap.containsKey(userCity)){
                UserBranchMap.get(userCity).add(u.id);
            }else{
                UserBranchMap.put(userCity, new List<String>{u.id});
            }
        }
        Map<String,List<String>> ShipperCityPickupMap = new Map<String,List<String>>();
        Map<id,Hub__c> HubMap = new Map<id,Hub__c>([select id, Branch__c From Hub__c LIMIT 50000]);
        for(Pickup__c pick:PickList){
            if(HubMap.containsKey(pick.BVC_Origin_Hub__c)){
                String PickHubBranch = HubMap.get(pick.BVC_Origin_Hub__c).Branch__c.toUpperCase();
                if(ShipperCityPickupMap.containsKey(PickHubBranch)){
                    ShipperCityPickupMap.get(PickHubBranch).add(pick.Id);
                }else{
                    ShipperCityPickupMap.put(PickHubBranch, new List<String>{pick.Id});
                }
            }
        }
        //Sharing code
        List<Pickup__share> PickupToShareList = new List<Pickup__share>();
        ///share records to origin hub employees
        for(String OriginBranch:ShipperCityPickupMap.keySet()){
            List<String> PickupsInBranch = ShipperCityPickupMap.get(OriginBranch);
            if(UserBranchMap!=null && UserBranchMap.containsKey(OriginBranch)){
                List<String> UsersInBranch = UserBranchMap.get(OriginBranch);
                //system.debug("UsersInBranch>>"+UsersInBranch.size());
                for(String u: UsersInBranch){
                    for(String p:PickupsInBranch){
                        Pickup__share share = new Pickup__share();
                        share.ParentId = p;
                        share.AccessLevel = 'Edit';
                        share.UserOrGroupId = u;
                        share.RowCause=Schema.Pickup__share.RowCause.Manual;
                        PickupToShareList.add(share);
                    }
                }
            }
        }
        //origin hub share ended
        //Insert Sharing
        if(PickupToShareList != null && PickupToShareList.size()>0){
            //system.debug('PickupToShareList: '+PickupToShareList.size());
            database.insert(PickupToShareList,false);
        }
    }
    
	public static void DeleteShareRecords(List<String> PickupIdList){
        Delete [select id FROM Pickup__share WHERE RowCause ='Manual' AND ParentId=:PickupIdList];
        //system.debug('deleted');
    }
    
    public static void deleteSharingForEscorters(Map<id,id> deleteMap){
        if(deleteMap !=null){
            List<Pickup__share> PickupToDeleteList = new List<Pickup__share>();
            for(Pickup__share sh:[select id,UserOrGroupId,ParentId FROM Pickup__share WHERE RowCause ='Manual' AND ParentId=:deleteMap.keyset()]){
                if(sh.UserOrGroupId == deleteMap.get(sh.ParentId)){
                    PickupToDeleteList.add(sh);
                }
            }
            if(PickupToDeleteList !=null && PickupToDeleteList.size()>0){
                Database.DeleteResult[] lsr = Database.Delete(PickupToDeleteList,false);
                system.debug('err: '+lsr);
            }
        }
    }
    
    public static void SharingForEscorters(Map<id,id> shareMap){
        List<Pickup__share> PickupToShareList = new List<Pickup__share>();
        for(id RecId : shareMap.keyset()){
            Pickup__share share = new Pickup__share();
            share.ParentId = RecId;
            share.AccessLevel = 'Edit';
            share.UserOrGroupId = shareMap.get(RecId);
            share.RowCause=Schema.Pickup__share.RowCause.Manual;
            PickupToShareList.add(share);
        }
        if(PickupToShareList !=null && PickupToShareList.size()>0){
            Database.SaveResult[] lsr = Database.Insert(PickupToShareList,false);
            system.debug('err: '+lsr);
        }
    }
    
    @InvocableMethod
    public static void deleteSharingForEscortersOnPickupComplete(List<Pickup__c> deleteShareList){
        Map<id,id> deleteMap = new Map<id,id>();
        for(Pickup__c pick:deleteShareList){
            deleteMap.put(pick.id,pick.Pickup_Assigned_To__c);
        }
        if(deleteMap !=null){
            List<Pickup__share> PickupToDeleteList = new List<Pickup__share>();
            for(Pickup__share sh:[select id,UserOrGroupId,ParentId FROM Pickup__share WHERE RowCause ='Manual' AND ParentId=:deleteMap.keyset()]){
                if(sh.UserOrGroupId == deleteMap.get(sh.ParentId)){
                    PickupToDeleteList.add(sh);
                }
            }
            if(PickupToDeleteList !=null && PickupToDeleteList.size()>0){
                Database.DeleteResult[] lsr = Database.Delete(PickupToDeleteList,false);
            }
        }
    }
}