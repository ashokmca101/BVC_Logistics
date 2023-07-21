@isTest
public class OpportunityValidationClassTest {
    @isTest
    static void testOpportunityValidation() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a test Opportunity with Dummy_Customer__c checkbox set to false and missing AccountId
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'Test Opportunity 1',
            Dummy_Customer__c = false
        );
        
        // Create a test Opportunity with Dummy_Customer__c checkbox set to true and missing required fields
        Opportunity testOpportunity2 = new Opportunity(
            Name = 'Test Opportunity 2',
            Dummy_Customer__c = true
        );
        
        Test.startTest();
        
        // Trigger the validation logic
        OpportunityValidationClass.validateOpportunity(new List<Opportunity>{ testOpportunity1, testOpportunity2 }, new Map<Id, Opportunity>());
        
        Test.stopTest();
        
        // Verify the error messages
        System.assertEquals(1, testOpportunity1.getErrors().size());
        System.assertEquals('Customer is required when Dummy Customer is false.', testOpportunity1.getErrors()[0].getMessage());
        
        System.assertEquals(1, testOpportunity2.getErrors().size());
        System.assertEquals('Contact Person Name and Contact Person Phone Number are required when Dummy Customer is true.', testOpportunity2.getErrors()[0].getMessage());
    }
}