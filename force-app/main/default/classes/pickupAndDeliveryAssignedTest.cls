@isTest(seeAllData=False)
public class pickupAndDeliveryAssignedTest {
    static testMethod void testPickUpDelivery(){
         Account acc = new Account();
        acc.name = 'Shipping Account';
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        acc.KYC_Indicator_for_Domestic_Flag__c = true;
        insert acc;
        
        Account acct = new Account();
        acct.name = 'Shipping Accounts';
        acct.ST_Pricing_Type__c = 'Non ACR';
        acct.Customer_Category__c = 'Non Contracted';
        acct.Billing_Frequency__c = 'Monthly';
        acct.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acct.GST_Registered__c = true;
        acct.Billing_Cycle__c = '26-25';
        acct.KYC_Status__c = 'API Verified';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        acct.KYC_Indicator_for_Domestic_Flag__c = true;
        
      	insert acct;
        
        Hub__c hubs = new Hub__c();
        hubs.Name = 'Hub Test Record';
        hubs.Branch__c = 'AGRA';
        insert hubs;
        
        Pickup_Delivery_Route__c pDR = new Pickup_Delivery_Route__c();
        pDR.Hub__c = hubs.Id;
        pDR.Name = 'R-12345';
        pDR.Delivery_Route_Assigned_To__c = null;
         pDR.Pickup_Route_Assigned_To__c = UserInfo.getUserId();
        insert pDR;
       
        Datetime yesterdays = Datetime.now().addDays(-4);
        Test.setCreatedDate(pDR.Id, yesterdays);
       
        
        
        Test.startTest();
        pickupAndDeliveryAssigned ba= new pickupAndDeliveryAssigned();
        Id jobid= Database.executeBatch(ba,1);       
        Test.stopTest();
        
    }
}