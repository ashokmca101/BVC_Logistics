@isTest
public class ChangeAccountRecordTypeTest {
    Static TestMethod void ChangeAccountRecordTypeTestMethod(){
        List<Id> AccList = New List<Id>();
        Account Acc1 = New Account();
        Acc1.Name = 'TestAccount1';
        Acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Quick Billing').getRecordTypeId();
        Insert Acc1;
        AccList.Add(Acc1.Id);
        Account Acc2 = New Account();
        Acc2.Name = 'TestAccount2';
        Acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Quick Shipping').getRecordTypeId();
        Insert Acc2;
        AccList.add(Acc2.Id);
        Test.startTest();
        ChangeAccountRecordType.ChangeAccountRecordTypeMethod(AccList);
        Test.stopTest();
    }
}