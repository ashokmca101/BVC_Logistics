public without sharing class updateBillingAccount_handler {
    //added to update primary billing address from billing account
    public static void updatePrimaryAddress(List<Shipment__c> ShipList){
        Set<id> BillingAccSet = new Set<id>();
        for(Shipment__c sh:ShipList){
            BillingAccSet.add(sh.Billing_Account__c);
        }
        Map<id,Account> PrimaryAddressMap = new Map<id,Account>([select Primary_Address__c FROM Account WHERE id=:BillingAccSet]);
        for(Shipment__c ship:ShipList){
            if(PrimaryAddressMap.containsKey(ship.Billing_Account__c) && PrimaryAddressMap.get(ship.Billing_Account__c).Primary_Address__c !=null){
                ship.Billing_Address__c = PrimaryAddressMap.get(ship.Billing_Account__c).Primary_Address__c;
                ship.BillTo_Party_Address__c=PrimaryAddressMap.get(ship.Billing_Account__c).Primary_Address__c;
            }
        }
    }
}