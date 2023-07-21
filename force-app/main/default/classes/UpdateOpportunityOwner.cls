public class UpdateOpportunityOwner {
    public static void updateOwner(List<Opportunity> newOpps) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]);
        
        for (Opportunity opp : newOpps) {
            if (opp.AccountId != null && accountMap.containsKey(opp.AccountId)) {
                opp.OwnerId = accountMap.get(opp.AccountId).OwnerId;
            }
        }
        
        update newOpps;
    }
}