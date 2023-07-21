public class PickupShareBatch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        DateTime myDateTime = DateTime.newInstance(2023, 01, 01, 12, 6, 13);
        String query ='select Id from Pickup__c where createddate >=: myDateTime';
        //List<Pickup__c> pkl = [select Id from Pickup__c where createddate >=: myDateTime];
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Pickup__c> pickupsList)
    {
        List<Pickup__Share> newBulkShare = new List<Pickup__Share>();
        for(Pickup__c pk:pickupsList )
        {
            List<Pickup__Share> psList = [select Id,ParentId,UserOrGroupId from Pickup__Share where ParentId=:pk.Id];
            Integer count=0;
            Group VPG = [select Id from Group where Name=:'VIZAG HUB'];
            List<GroupMember> VGM = [select Id,UserOrGroupId from GroupMember where GroupId=:VPG.Id];
            
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
                    newPS.ParentId = pk.Id;
                    newPS.AccessLevel = 'Edit';
                    newPS.RowCause = 'Manual';
                    newBulkShare.add(newPS);
                }
            }
        }
        if(newBulkShare.size()>0)
        {
            insert newBulkShare;
        }       
    }
    
    public void finish(Database.BatchableContext BC)
    {
    }
}