public class OpportunityValidationClass {
    public static void validateOpportunity(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        for (Opportunity opp : newOpportunities) {
            // Check if the Dummy_Customer__c checkbox is false
            if (!opp.Dummy_Customer__c) {
                
                if (String.isBlank(opp.AccountId)) {
                    opp.AccountId.addError('Customer is required when Dummy Customer is false.');
                }
            } else { // Dummy_Customer__c is true
               
                if (newOpportunities.contains(opp) && (String.isBlank(opp.Contact_Person_Name__c) || String.isBlank(opp.Contact_Person_Phone_Number__c))) {
                    opp.Contact_Person_Name__c.addError('Contact Person Name and Contact Person Phone Number are required when Dummy Customer is true.');
                }
            }
        }
    }
}