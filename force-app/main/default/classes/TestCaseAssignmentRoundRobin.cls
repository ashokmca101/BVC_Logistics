@isTest
public class TestCaseAssignmentRoundRobin {
    Static TestMethod Void CaseRoundRobinTest(){
        /*List<Group> QueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'ServiceRep_Queue_For_Email_To_Case' LIMIT 1];
        List<GroupMember> QueueMember = [Select UserOrGroupId,Id From GroupMember where GroupId =:QueueId LIMIT 1];
        Id OwnerId = QueueMember.UserOrGroupId;*/
        Test.StartTest();
        Account Acc = New Account();
        Acc.Name = 'Ayush';
        Acc.Primary_Customer_Email__c = 'abx@adn.com';
        Insert Acc;
        List<Case> CaseList = New List<Case>();
        Case A = New Case();
        A.AccountId = Acc.Id;
        A.Origin = 'Email';
        A.Status = 'New';
        A.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Domestic Tickets').getRecordTypeId();
        CaseList.add(A);
        Case B = New Case();
        B.AccountId = Acc.Id;
        B.Origin = 'Phone';
        B.Status = 'New';
        B.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Tickets Mumbai').getRecordTypeId();
        CaseList.add(B);
        Case C = New Case();
        C.AccountId = Acc.Id;
        C.Origin = 'Email';
        C.Status = 'New';
        C.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Tickets Seepz').getRecordTypeId();
        CaseList.add(C);
        Case D = New Case();
        D.AccountId = Acc.Id;
        D.Origin = 'Email';
        D.Status = 'New';
        D.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Tickets Surat').getRecordTypeId();
        CaseList.add(D);
        // Damco Team
        Case E = New Case();
        E.AccountId = Acc.Id;
        E.Origin = 'Email';
        E.Status = 'New';        
        E.Subject = 'KYC';        
        E.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Domestic Tickets').getRecordTypeId();
        CaseList.add(E);
        Insert CaseList;
        List<Id> CaseIds = New List<Id>();
        for(Case Ticket : CaseList){
            CaseIds.add(Ticket.Id);
        }
        // Updated by Damco Team
        CaseAssignmentRoundRobin.assignTicketRoundRobin(CaseIds);
        Test.stopTest();
    }
}