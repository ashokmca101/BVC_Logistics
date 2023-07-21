@isTest(SeeAllData=false)
public class TestLeadRoundRobin {
    Static TestMethod void LeadTest(){
        Test.startTest();
        User TestUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        List<User> SalesRep = [SELECT Id FROM User LIMIT 2];
        system.debug('Sales rep query'+SalesRep);
        Active_Pincode__c Pincode1 = New Active_Pincode__c();
        Pincode1.OwnerId = UserInfo.getUserId();
        Pincode1.Pincodes__c = '123123';
        Pincode1.Country__c = 'India';
        Pincode1.District__c = 'Test District 1';
        Pincode1.State__c = 'Test State 1';
        Insert Pincode1;
        system.debug('Pincode 1 inserted'+Pincode1);
        Active_Pincode__c Pincode2 = New Active_Pincode__c();
        Pincode2.OwnerId = UserInfo.getUserId();
        Pincode2.Pincodes__c = '321321';
        Pincode2.Country__c = 'India';
        Pincode2.District__c = 'Test District 2';
        Pincode2.State__c = 'Test State 2';
        Insert Pincode2;
        system.debug('Pincode2  inserted'+Pincode2);
        Active_Area_Sales_Rep__c ActiveAreaSalesRep1 = New Active_Area_Sales_Rep__c();
        ActiveAreaSalesRep1.Name = 'Active Area Sales Rep 1';
        ActiveAreaSalesRep1.Active_Pincode__c = Pincode1.Id;
        //ActiveAreaSalesRep1.Id = UserInfo.getUserId();
        ActiveAreaSalesRep1.Sales_Rep__c = SalesRep[0].Id;
        Insert ActiveAreaSalesRep1;
        system.debug('ActiveAreaSalesRep1  inserted'+ActiveAreaSalesRep1);
        Active_Area_Sales_Rep__c ActiveAreaSalesRep2 = New Active_Area_Sales_Rep__c();
        ActiveAreaSalesRep2.Name = 'Active Area Sales Rep 2';
        ActiveAreaSalesRep2.Active_Pincode__c = Pincode1.Id;
        //ActiveAreaSalesRep2.OwnerId = UserInfo.getUserId();
        ActiveAreaSalesRep2.Sales_Rep__c = SalesRep[1].Id;
        Insert ActiveAreaSalesRep2;
        system.debug('ActiveAreaSalesRep2  inserted'+ActiveAreaSalesRep2);
        Active_Area_Sales_Rep__c ActiveAreaSalesRep3 = New Active_Area_Sales_Rep__c();
        ActiveAreaSalesRep3.Name = 'Active Area Sales Rep 3';
        ActiveAreaSalesRep3.Active_Pincode__c = Pincode2.Id;
        //ActiveAreaSalesRep3.OwnerId = UserInfo.getUserId();
        ActiveAreaSalesRep3.Sales_Rep__c = SalesRep[0].Id;
        Insert ActiveAreaSalesRep3;
        Product2 LeadProduct = New Product2();
        LeadProduct.Name = 'Domestic Valuables';
        LeadProduct.Product_Level_1__c = 'Domestic Valuables';
        LeadProduct.Product_Level_2__c = 'LuxeSHIP';
        LeadProduct.Product_Category__c = 'Domestic Valuables';
        LeadProduct.IsActive = TRUE;
        LeadProduct.Family = 'valship';
        Insert LeadProduct;
        List<Lead> LeadList = New List<Lead>();
        Lead L1 = New Lead();
        //L1.OwnerId = TestUser.Id;
        L1.LastName = 'ABC';
        L1.MobilePhone = '1248761234';
        L1.Email = 'asdk@aj.com';
        L1.Status = 'New';
        L1.Company = 'woefih';
        L1.Product__c = 'Domestic Valuables';
        L1.LeadSource = 'Direct database upload by admin';
        LeadList.Add(L1);
        
        Lead L2 = New Lead();
        //L2.OwnerId = TestUser.Id;
        L2.LastName = 'XYZ';
        L2.MobilePhone = '1248766412';
        L2.Email = 'asdasdk@aj.com';
        L2.Status = 'New';
        L2.Company = 'woefasdih';
        L2.Product__c = 'Domestic Valuables';
        L2.LeadSource = 'Direct database upload by admin';
        L2.PostalCode = '123123';
        LeadList.Add(L2);
        
        Lead L3 = New Lead();
        //L3.OwnerId = TestUser.Id;
        L3.LastName = 'XYZRT';
        L3.MobilePhone = '1234487664';
        L3.Email = 'asdak@aj.com';
        L3.Status = 'New';
        L3.Company = 'wosdih';
        L3.Product__c = 'Domestic Valuables';
        L3.LeadSource = 'Direct database upload by admin';
        L3.PostalCode = '321321';
        LeadList.Add(L3);
        
        Insert LeadList;
        L1.OwnerId = TestUser.Id;
        Update L1;
        System.debug('Lead Insert' + LeadList);
        System.debug('Lead 3 Owner' + L1.Owner.FirstName);
        Set<Id> TicketIdSet = New Set<Id>();
        For(Lead L : LeadList){
            TicketIdSet.add(L.Id);
        }
        LeadRoundRobin.assignTicketRoundRobin(TicketIdSet);
        Test.stopTest();
    }
}