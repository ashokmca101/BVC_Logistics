public class Case_TriggerHandlerCtrl {

    public static void setManuallyTransferred(List<Case> newCaseList,map<Id,Case> mpOldCase){
        List<Group> ManagerGroup = [SELECT Id FROM Group WHERE DeveloperName = 'Ticket_Managers'];
        List<GroupMember> ManagerList = [Select UserOrGroupId,Id From GroupMember where GroupId =:ManagerGroup];
        Set<Id> ManagersIdSet = New Set<Id>();
        For(GroupMember Manager : ManagerList){
            ManagersIdSet.add(Manager.UserorGroupId);
        }
        System.debug('Manager id set' + ManagersIdSet);
        System.debug('Current User Id' + UserInfo.getUserId());
        Id CurrentUserId = UserInfo.getUserId();
        for(Case newCase:newCaseList){
            if(newCase.OwnerId !=mpOldCase.get(newCase.Id).OwnerId 
               && (ManagersIdSet.Contains(CurrentUserId))  ){
                newCase.Manual_Ticket_Assignment__c = true;
            }
        }
    }
}