public class tms_VehicleVaultHandler {
    //This method updates the Current_Scan_Location__c field on a list of Secure_Bag__c records 
    //based on the corresponding Location__c field value in a related Shipment_Tracking__c record.
    public static void updateSecureBagLocation(List<Secure_Bag__c> secureBag)
    {
        Set<Id> shipId = new Set<Id>();
        for(Secure_Bag__c bag : secureBag)
        {
            shipId.add(bag.Tracking__c);			
        }
        
        List<Shipment_Tracking__c> listTracking = [Select Id,Location__c,BVC_Vehicle__c,Vaults__c from Shipment_Tracking__c where id =:shipId];
        for(Secure_Bag__c newBag : secureBag)
        {
            if(newBag.Tracking__c	!= null && 	(listTracking[0].BVC_Vehicle__c != null || listTracking[0].Vaults__c != null) )
            {
                newBag.Current_Scan_Loction__c	= listTracking[0].Location__c;
            }
            System.debug('for checking in newBag.Current_Scan_Loction__c :'+newBag.Current_Scan_Loction__c);
        }
        
    }
    
    
}