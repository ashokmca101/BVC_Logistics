@isTest
public class DeleteInvoiceOutstandingReportBatchTest {
    Static TestMethod Void DeleteInvoiceOutstandingReportBatchTestMethod(){
         Account Acc = New Account();
        Acc.Name = 'TestAccount';
        Acc.BVC_Company_Type__c = 'Domestic';
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Insert Acc;
        List<Invoice_Outstanding_Report__c> IORList = New List<Invoice_Outstanding_Report__c>();
        Invoice_Outstanding_Report__c IORObject = New Invoice_Outstanding_Report__C();
        IORObject.Name = 'Test Report';
        IORObject.Customer__c = Acc.Id;
        IORList.add(IORObject);
        Insert IORList; 
        
        Test.startTest();
        DeleteInvoiceOutstandingReportBatch obj = New DeleteInvoiceOutstandingReportBatch();
        Database.QueryLocator ql = obj.start(null);
		obj.execute(null,IORList);
		obj.Finish(null);
        Test.stopTest();
    }
}