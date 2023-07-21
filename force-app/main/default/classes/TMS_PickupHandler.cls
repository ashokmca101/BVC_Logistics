public class TMS_PickupHandler {
    public static void updatePickUp(set<Id> ids){ 
        List<Pickup__c>pickuplist = new List<Pickup__c>();
        for(Pickup__c obj:[select Id,Pickup_Route_Number__c,Pickup_Assigned_To__c,Shipper_Address__c from Pickup__c where Id in : ids LIMIT 50000]){
            //ID PickupRouteNumber=getPickupRouteNumber(obj.Shipper_Address__c);
            //obj.Pickup_Route_Number__c=PickupRouteNumber;
            //obj.Pickup_Assigned_To__c=getPickupRouteAssignedTo(PickupRouteNumber);
              pickuplist.add(obj);
        }
        update pickuplist;
        List<Shipment__c> shipList = new List<Shipment__c>();
        for(Pickup__c pick : [Select Id,Shipment__c from pickup__c where Id in : ids])
        {
            System.debug('HHHHHHH::'+pick.shipment__c);
              Shipment__c ship = new Shipment__c();
       		  ship.Id = pick.Shipment__c;
              ship.Pickup__c =pick.Id;
              //Ship.Tracking_Status__c='Out for Pickup';
            shipList.add(ship);
        }
        System.debug('shipList'+shipList);
        if(shipList.size() > 0)
            
        {
           //update shipList;
        }
      
        
    }    
    public static Id getPickupRouteNumber(Id shipperAddressId){
        Id pickupRouteNumber=null;
        AddressBook__c  shipAdd=new AddressBook__c ();
        shipAdd=[select Id,Pickup_Route_Number__c from AddressBook__c where Id =: shipperAddressId limit 1];
        if (shipAdd!=null)
            pickupRouteNumber=shipAdd.Pickup_Route_Number__c;
        return pickupRouteNumber;
    }    
    /*public static Id getPickupRouteAssignedTo(Id pickupRouteNumber){
        Id pickupRouteAssigned=null;
        if(pickupRouteNumber!=null){
            Pickup_Delivery_Route__c  obj=new Pickup_Delivery_Route__c ();
            obj=[select Id,Pickup_Route_Assigned_To__c from Pickup_Delivery_Route__c  where Id =: pickupRouteNumber limit 1];
            if (obj!=null)
                pickupRouteAssigned=obj.Pickup_Route_Assigned_To__c;
        }
        return pickupRouteAssigned;
    }*/
    
    // Used to update pickup customer Email and phone
    public static void updatepickupFields(List<Pickup__c> newpickups ){
    Set<Id> accountIds = new Set<Id>();
    for (Pickup__c pickup : newpickups) {
        accountIds.add(pickup.Customer__c);
    }
    
    // Query the Account records related to the Pickup__c records
    Map<Id, Account> accounts = new Map<Id, Account>([
        SELECT Id, 	Primary_Customer_Email__c, Phone
        FROM Account
        WHERE Id IN :accountIds
    ]);
    
    // Update the Pickup__c records based on the Account records
    for (Pickup__c pickup : newpickups) {
        Account account = accounts.get(pickup.Customer__c);
        if (account != null) {
            pickup.Primary_Customer_Email__c = account.Primary_Customer_Email__c;
            pickup.Customer_Phone__c = account.Phone;
        }
    }
        
    }
}