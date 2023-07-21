public class OpportunityDuplicateValidator {
    
    public static void checkForDuplicates(List<Opportunity> newOpportunities) {
        Set<Id> accountIds = new Set<Id>();
        Map<String, String> productStageMap = new Map<String, String>();
        
        for (Opportunity opportunity : newOpportunities) {
            if (opportunity.AccountId != Null) {
            accountIds.add(opportunity.AccountId);
            String productKey = generateProductKey(opportunity);
            productStageMap.put(productKey, opportunity.StageName);
        }
        }
        
        Map<String, Opportunity> existingOpportunities = new Map<String, Opportunity>();
        
        for (Opportunity existingOpportunity : [SELECT Id, AccountId, BVC_L2_Product__c, StageName
                                               FROM Opportunity
                                               WHERE AccountId IN :accountIds
                                               AND StageName NOT IN ('Deal Lost', 'Contact Later', 'Won - Shipments Started')]) {
            String productKey = generateProductKey(existingOpportunity);
            existingOpportunities.put(productKey, existingOpportunity);
        }
        
        for (Opportunity newOpportunity : newOpportunities) {
            If(newOpportunity.AccountId != Null ||newOpportunity.AccountId != '' ){
            String productKey = generateProductKey(newOpportunity);
                if (existingOpportunities.containsKey(productKey)) {
                Opportunity existingOpportunity = existingOpportunities.get(productKey);
                String existingStageName = productStageMap.get(productKey);
                if (existingStageName != null && !isAllowedStage(existingStageName)) {
                    newOpportunity.AccountId.addError('Duplicate Deal Found of This Customer ' + 
                                            ' With BVC Proudct Value: ' + existingOpportunity.BVC_L2_Product__c 
                                           );
                }
                
            }
        }
        }
    }
    
    private static String generateProductKey(Opportunity opportunity) {
        return opportunity.AccountId + '#' + opportunity.BVC_L2_Product__c;
    }
    
    private static Boolean isAllowedStage(String stageName) {
        Set<String> allowedStages = new Set<String>{
            'Deal Lost', 'Contact Later', 'Won - Shipments Started'
        };
        return allowedStages.contains(stageName);
    }
}