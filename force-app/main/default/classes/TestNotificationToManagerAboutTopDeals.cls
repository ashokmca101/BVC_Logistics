@isTest
public class TestNotificationToManagerAboutTopDeals {
    Static TestMethod void NotificationToManager(){
        Test.startTest();
        User TestUser = [ SELECT Phone, Id FROM User WHERE Id = : UserInfo.getUserId() ];
        Account Acc = New Account();
        Acc.Name = 'Ayush';
        Insert Acc;
        List<Opportunity> TopDealList = New List<Opportunity>();
        Opportunity Opp1 = New Opportunity();
        Opp1.OwnerId = TestUser.Id;
        Opp1.Name = 'TopDeal1';
        Opp1.CloseDate = Date.newInstance(2021, 05, 05);
      	Opp1.AccountId = Acc.Id;
        Opp1.StageName = 'BVC Opportunity';
        Opp1.Amount = 1100000;
        TopDealList.Add(Opp1);
        Opportunity Opp2 = New Opportunity();
        Opp2.OwnerId = TestUser.Id;
        Opp2.Name = 'TopDeal2';
        Opp2.CloseDate = Date.newInstance(2021, 05, 05);
      	Opp2.AccountId = Acc.Id;
        Opp2.StageName = 'BVC Opportunity';
        Opp2.Amount = 200000;
        TopDealList.Add(Opp2);
        Insert TopDealList;
        List<Id> TopDealListId = New List<Id>();
        For (Opportunity Opp : TopDealList){
            TopDealListId.add(Opp.Id);
        }
    	NotificationToManagerAboutTopDeals.SendNotificationToManager(TopDealListId);
        Test.stopTest();
    }
    
}