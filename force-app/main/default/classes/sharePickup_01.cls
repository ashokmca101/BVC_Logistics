public class sharePickup_01 {
  @InvocableMethod(label='getPickups' description='Returns the list of account')
  public static void getAccount(List<Id> pkid) {
      PickupShareBatch pb = new PickupShareBatch();
      Database.executeBatch(pb,200);
      /*
     Pickup__c pkRec = [select Id from Pickup__c where Id=: pkId[0]];
     List<Pickup__Share> psList = [select Id,ParentId,UserOrGroupId from Pickup__Share where ParentId=:pkRec.Id];
      Integer count=0;
      Group VPG = [select Id from Group where Name=:'VIZAG HUB'];
      List<GroupMember> VGM = [select Id,UserOrGroupId from GroupMember where GroupId=:VPG.Id];
      List<Pickup__Share> newBulkShare = new List<Pickup__Share>();
      for(GroupMember gm: VGM)
      {
          count=0;
          for(Pickup__Share ps: psList)
          {
              if(gm.UserOrGroupId == ps.UserOrGroupId)
              {
                count=count+1;  
              }
          }   
          if(count==0)
          {
            Pickup__Share newPS = new Pickup__Share();  
            newPS.UserOrGroupId = gm.UserOrGroupId;
            newPS.ParentId = pkRec.Id;
            newPS.AccessLevel = 'Edit';
            newPS.RowCause = 'Manual';
            newBulkShare.add(newPS);
          }
      }
      if(newBulkShare.size()>0)
      {
          insert newBulkShare;
      }
*/
      
  }
}