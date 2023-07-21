@isTest
public class ChangeContactRecordTypeTest {
    Static TestMethod void ChangeContactRecordTypeTestMethod(){
        List<Id> ContactIdList = New List<Id>();
        Contact Con1 = New Contact();
        Con1.LastName = 'Test1';
        Con1.Email = 'abc123@ac.com';
        Con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Quick Contact Creation').getRecordTypeId();
        Insert Con1;
        ContactIdList.add(Con1.Id);
        Contact Con2 = New Contact();
        Con2.LastName = 'Test2';
        Con2.Email = 'abc23@ac.com';
        Con2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Quick Contact Creation').getRecordTypeId();
        Insert Con2;
        ContactIdList.add(Con2.Id);
        Test.startTest();
        ChangeContactRecordType.ChangeContactRecordTypeMethod(ContactIdList);
        Test.stopTest();
    }
}