@isTest
public class Case_TriggerHandlerCtrlTest {
    Static TestMethod Void CaseTriggerHandlerCtrlTestMethod(){
        List<User> TestUserList = [SELECT Name, Id FROM User LIMIT 2];
        Case TestTicket = New Case();
        TestTicket.Origin = 'Email';
        TestTicket.Status = 'New';
        TestTicket.OwnerId = TestUserList[0].Id;
        Insert TestTicket;
        User TestUser = New User();
        TestUser = [SELECT Name, Id FROM User Where Name = 'BVC Admin' limit 1];
        System.runAs(TestUser){
        	Test.StartTest();
        	TestTicket.OwnerId = TestUserList[1].Id;
        	Update TestTicket;
        	Test.stopTest();
        }     
    }
}