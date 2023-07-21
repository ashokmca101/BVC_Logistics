@isTest
public class TestBVC_LeadTriggerHandler {
   Static TestMethod Void LeadTriggerHandlerMethod(){
        Test.startTest();
        Product2 Prd1 = New Product2();
        Prd1.Name = 'Domestic Valuables';
        prd1.IsActive = true;
        Insert Prd1;
       	Product2 Prd2 = New Product2();
        Prd2.Name = 'International Valuables';
        prd2.IsActive = true;
        Insert Prd2;
        List<Lead> LeadList = New List<Lead>();
        Lead L1 = New Lead();
        L1.LastName = 'ABC';
        L1.MobilePhone = '1248761234';
        L1.Email = 'asdk@aj.com';
        L1.Status = 'New';
        L1.Company = 'woefih';
        L1.Product__c = 'Domestic Valuables;International Valuables';
        L1.LeadSource = 'Direct database upload by admin';
        LeadList.Add(L1);
        Lead L2 = New Lead();
        L2.LastName = 'XYZ';
        L2.MobilePhone = '3248761234';
        L2.Email = 'adk@aj.com';
        L2.Status = 'New';
        L2.Company = 'wofih';
        L2.Product__c = 'Domestic Valuables';
        L2.LeadSource = 'Facebook';
       	Lead L3 = New Lead();
        L3.LastName = 'KLM';
        L3.MobilePhone = '3243761234';
        L3.Email = 'adk@aj.com';
        L3.Status = 'New';
        L3.Company = 'wofihad';
        L3.Product__c = 'International Valuables';
        L3.LeadSource = 'Twitter';
        LeadList.Add(L3);
        Insert LeadList;
        BVC_LeadTriggerHandler LeadTriggerHandlerObj = New BVC_LeadTriggerHandler();
        LeadTriggerHandlerObj.convertLeadToOpps(LeadList);
        Test.stopTest();
    }
}