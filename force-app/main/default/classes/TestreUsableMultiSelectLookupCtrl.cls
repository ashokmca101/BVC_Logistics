@isTest
public class TestreUsableMultiSelectLookupCtrl {
    Static TestMethod void ReUsableMultiSelectMethod(){
        Test.startTest();
        Account A1 = New Account();
        A1.Name = 'Ayush Test';
        Insert A1;
        Account A2 = New Account();
        A2.Name = 'Excluded Account';
        Insert A2;
        List<Account> ExcludeItemList = New List<Account>();
        ExcludeItemList.add(A2);
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('Ayush', 'Account', ExcludeItemList);
        Test.stopTest();
    }
}