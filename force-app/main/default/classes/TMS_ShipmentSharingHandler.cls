public class TMS_ShipmentSharingHandler {
    //This method returns a Map of user IDs grouped by their city. It queries for users with a specific profile and city.
    public static Map<String,List<String>> UserBranches(){
        Map<String,List<String>> UserBranchMap = new Map<String,List<String>>();
        for(User u:[select id, City FROM User WHERE Profile.Name = 'Operations Office Executive' AND City !=null LIMIT 50000]){
        //for(User u:[select id, City FROM User WHERE (Profile.Name = 'Operations Office Executive' OR Profile.Name = 'System Administrator') AND City !=null LIMIT 50000]){
            string userCity = u.City.toUpperCase();
            if(UserBranchMap.containsKey(userCity)){
                UserBranchMap.get(userCity).add(u.id);
            }else{
                UserBranchMap.put(userCity, new List<String>{u.id});
            }
        }
        return UserBranchMap;
    }
    
    /*This method takes a list of Shipment__c records, and shares them with users based on the origin hub's branch city.
	* It retrieves the relevant users from the `UserBranches()` method.
	*/
    public static void ShareShipmentRecords(List<Shipment__c> ShipList){
        
        Map<String,List<String>> UserBranchMap = new Map<String,List<String>>();
        UserBranchMap = TMS_ShipmentSharingHandler.UserBranches();
        
        Map<String,List<String>> OriginCityShipMap = new Map<String,List<String>>();        
        Map<id,Hub__c> HubMap = new Map<id,Hub__c>([select id, Branch__c From Hub__c LIMIT 50000]);
        
        for(Shipment__c Ship: ShipList){
            if(Ship.Origin_Hub__c !=null && HubMap.containsKey(Ship.Origin_Hub__c)){
                String OriginHubBranch = HubMap.get(Ship.Origin_Hub__c).Branch__c.toUpperCase();
                if(OriginCityShipMap.containsKey(OriginHubBranch)){
                    OriginCityShipMap.get(OriginHubBranch).add(Ship.Id);
                }else{
                    OriginCityShipMap.put(OriginHubBranch, new List<String>{Ship.Id});
                }
            }
        }
        //Sharing code
        List<Shipment__share> ShipToShareList = new List<Shipment__share>();
        ///share records to origin hub employees
        for(String OriginBranch:OriginCityShipMap.keySet()){
            List<String> ShipmentsInBranch = OriginCityShipMap.get(OriginBranch);
            if(UserBranchMap!=null && UserBranchMap.containsKey(OriginBranch)){
                List<String> UsersInBranch = UserBranchMap.get(OriginBranch);
                //system.debug('UsersInBranch>>'+UsersInBranch.size());
                for(String u: UsersInBranch){
                    for(String s:ShipmentsInBranch){
                        Shipment__share share = new Shipment__share();
                        share.ParentId = s;
                        share.AccessLevel = 'Edit';
                        share.UserOrGroupId = u;
                        share.RowCause=Schema.Shipment__share.RowCause.Manual;
                        //system.debug('Las: '+share);
                        ShipToShareList.add(share);
                    }
                }
            }
        }
        //origin hub share ended
        //Insert Sharing
        if(ShipToShareList != null && ShipToShareList.size()>0){
            system.debug('ShipToShareList: '+ShipToShareList.size());
            database.insert(ShipToShareList,false);
        }
    }
    
    //This method deletes manual share records for a given list of shipment record IDs.
    public static void DeleteShareRecords(List<String> ShipIdList){
        system.debug('<==> 11.ShipIdList :'+ShipIdList);
        Delete [select id FROM Shipment__share WHERE RowCause ='Manual' AND ParentId=:ShipIdList];
        system.debug('deleted');
    }
    
    //This method deletes manual share records for a given map of shipment record IDs to user IDs.
    public static void deleteSharingForEscorters(Map<id,id> deleteMap){
        if(deleteMap !=null){
            List<Shipment__share> ShipShareToDeleteList = new List<Shipment__share>();
            for(Shipment__share sh:[select id,UserOrGroupId,ParentId FROM Shipment__share WHERE RowCause ='Manual' AND ParentId=:deleteMap.keyset()]){
                if(sh.UserOrGroupId == deleteMap.get(sh.ParentId)){
                    system.debug('11.deleted ShipShareToDeleteList:'+ShipShareToDeleteList);
                    ShipShareToDeleteList.add(sh);
                }
            }
            if(ShipShareToDeleteList !=null && ShipShareToDeleteList.size()>0){
                Database.DeleteResult[] lsr = Database.Delete(ShipShareToDeleteList,false);
            }
        }
    }
    
    //This method shares shipment records with users based on a map of shipment record IDs to user IDs.
    public static void SharingForEscorters(Map<id,id> shareMap){
        List<Shipment__share> ShipmentToShareList = new List<Shipment__share>();
        for(id RecId : shareMap.keyset()){
            Shipment__share share = new Shipment__share();
            share.ParentId = RecId;
            share.AccessLevel = 'Edit';
            share.UserOrGroupId = shareMap.get(RecId);
            share.RowCause=Schema.Shipment__share.RowCause.Manual;
            ShipmentToShareList.add(share);
        }
        if(ShipmentToShareList !=null && ShipmentToShareList.size()>0){
            database.insert(ShipmentToShareList,false);
        }
    }
    
    //This method shares shipment records with transit hub employees based on the transit hub's branch city.
	//It retrieves the relevant users from the `UserBranches()` method.    
    public static void ShipmentShareToTransitExecutives(Map<String,List<String>> TransitCityShip_Map){
        System.debug('for checking in share class '+TransitCityShip_Map);
        try{
            Map<String,List<String>> UserBranchMap = TMS_ShipmentSharingHandler.UserBranches();
            //Sharing code
            List<Shipment__share> ShipToShareList = new List<Shipment__share>();
            System.debug('11. Inside ShipmentShareToTransitExecutives');
            ///share records to transit hub employees
            for(String TransitBranch:TransitCityShip_Map.keySet()){
                System.debug('11. Inside TransitBranch'+TransitBranch);
                System.debug('11. Inside UserBranchMap'+UserBranchMap);
                List<String> ShipmentsInBranch = TransitCityShip_Map.get(TransitBranch);
                if(UserBranchMap!=null && UserBranchMap.containsKey(TransitBranch)){
                    List<String> UsersInBranch = UserBranchMap.get(TransitBranch);
                    system.debug('UsersInBranch>>'+UsersInBranch.size());
                    for(String u: UsersInBranch){
                        for(String s:ShipmentsInBranch){
                            Shipment__share share = new Shipment__share();
                            share.ParentId = s;
                            share.AccessLevel = 'Edit';
                            share.UserOrGroupId = u;
                            share.RowCause=Schema.Shipment__share.RowCause.Manual;
                            ShipToShareList.add(share);
                        }
                    }
                }
            }
            System.debug('for checking ShipToShareList : '+ShipToShareList);
            if(ShipToShareList != null && ShipToShareList.size()>0){
                system.debug('for checking ShipToShareList: '+ShipToShareList.size());
                database.insert(ShipToShareList,false);
            }
        }Catch(exception e){
            system.debug('line: '+e.getLineNumber()+ ' msg: '+e.getMessage());
        }
    }
    
    //Change ownership of escorter's owned shipments---starts---
    @InvocableMethod
    public static void changeOwner(List<Shipment__c> ShipList){
        Map<id,User> Escorters = new Map<id,User>([select id,ProfileId FROM User WHERE Profile.Name = 'Operations Field Executive' LIMIT 50000]);
        for(Shipment__c ship: ShipList){
            if(Escorters.containsKey(ship.OwnerId)){
                System.debug('11.ship.OwnerId :'+ship.OwnerId);
                ship.OwnerId = Label.Shipment_s_Default_Owner;
            }
        }
        try{
            database.update(ShipList, false);
        }catch(exception e){
            //system.debug('Line: '+e.getLineNumber()+' err: '+e.getMessage());
        }
    }
    //Change ownership of escorter's owned shipments---ends---
}