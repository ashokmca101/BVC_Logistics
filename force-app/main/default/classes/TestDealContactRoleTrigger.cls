@isTest
public class TestDealContactRoleTrigger {
    
    static testMethod void DealContactRoleTest(){
		User TestUser = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        Account Acc1 = New Account ();
        Acc1.Name = 'Ayush';
        Insert Acc1;
        Account Acc2 = New Account();
        Acc2.Name = 'Ayush2';
        Insert Acc2;
        Opportunity Opp = New Opportunity();
        Opp.OwnerId = TestUser.Id;
        Opp.Name = 'TestOpp';
        Opp.CloseDate = Date.newInstance(2021, 05, 05);
      	Opp.AccountId = Acc1.Id;
        Opp.StageName = 'BVC Opportunity';
        Opp.Amount = 1000000;
        Insert Opp;
        Contact Con1 = New Contact();
        Con1.LastName = 'AyushCon1';
        Con1.AccountId = Acc1.Id;
        Con1.Email = 'test@gmail.com';
        Con1.Title = 'Test';
        Con1.FirstName = 'User';
        Insert Con1;
        Contact Con2 = New Contact();
        Con2.LastName = 'AyushCon2';
        Con2.AccountId = Acc2.Id;
        Con2.Email = 'testver1@gmail.com';
        Insert Con2;
        OpportunityContactRole A = New OpportunityContactRole();
        A.OpportunityId = Opp.Id;
        A.ContactId = Con1.Id;
		A.Role = 'Authorised Signatory';
        
        OpportunityContactRole B = New OpportunityContactRole();
        B.OpportunityId = Opp.Id;
        B.ContactId = Con2.Id;
        B.Role = 'Authorised Signatory';
       
        Insert A;
        
        Try{
            Insert B;
        }
        Catch(Exception e){
            System.assert(e.getMessage().contains('Only a single people on a deal can be an Authorised Signatory'));
        }
        Test.stopTest();
    }
}