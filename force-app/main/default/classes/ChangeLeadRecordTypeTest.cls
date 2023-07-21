@isTest
public class ChangeLeadRecordTypeTest {
    Static TestMethod Void ChangeLeadRecordTypeTestMethod(){
        Product2 LeadProduct = New Product2();
        LeadProduct.Name = 'Domestic Valuables';
        LeadProduct.Product_Level_1__c = 'Domestic Valuables';
        LeadProduct.Product_Level_2__c = 'LuxeSHIP';
        LeadProduct.Product_Category__c = 'Domestic Valuables';
        LeadProduct.IsActive = TRUE;
        LeadProduct.Family = 'valship';
        Insert LeadProduct;
        List<Id> LeadIdList = New List<Id>();
        Lead L1 = New Lead();
        L1.LastName = 'Test1';
        L1.Status = 'New';
        L1.Product__c = 'Domestic Valuables';
        L1.Company = 'TestCompany';
        L1.Email = 'abc@ab.com';
        L1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Minimum Fields').getRecordTypeId();
        Insert L1;
        LeadIdList.add(L1.Id);
        Lead L2 = New Lead();
        L2.LastName = 'Test2';
        L2.Status = 'New';
        L2.Product__c = 'Domestic Valuables';
        L2.Company = 'TestCompany2';
        L2.Email = 'abc2@ab.com';
        L2.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Minimum Fields').getRecordTypeId();
        Insert L2;
        LeadIdList.add(L2.Id);
        Test.startTest();
        ChangeLeadRecordType.ChangeLeadRecordTypeMethod(LeadIdList);
        Test.stopTest();
    }
}