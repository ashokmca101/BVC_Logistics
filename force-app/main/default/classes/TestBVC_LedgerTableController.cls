@isTest
public class TestBVC_LedgerTableController {
    Static TestMethod Void LedgetTableControllerMethod(){
        Test.startTest();
        Account Cust = New Account();
        Cust.Name = 'Test Customer';
        Insert Cust;
        Ledger__c L1 = New Ledger__c ();
        L1.Name = 'Test Ledger';
        L1.Customer__c = Cust.Id;
        L1.Legal_Entity__c = 'BVC Logistics Private Limited';
        L1.PAN__c = 'EQUPB1234L';
        L1.Vch_Type__c = 'Total';
        L1.Accounting_Date__c = system.today();
        Insert L1;
        BVC_LedgerTableController.getLedgers(system.today(), system.today());
    }
}