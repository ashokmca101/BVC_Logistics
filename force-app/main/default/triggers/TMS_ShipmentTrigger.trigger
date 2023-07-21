//damco Team
trigger TMS_ShipmentTrigger on Shipment__c (before update,before insert,after Insert, after update) {
    if(trigger.isbefore && trigger.isupdate){
        for(Shipment__c  s: trigger.new){
            // added lines by imran
            /*Integer x=0;
            if(s.Pickup__c!=null)
            {
                Pickup__c pk = [select Id,Pickup_Status__c,Name from Pickup__c where Id=:s.Pickup__c limit 1];
                 if(s.Tracking_Status__c=='Created' || s.Tracking_Status__c=='Out for Pickup' || s.Tracking_Status__c=='Picked Up')
                 {
                     x = x+1;
                 }
                 if(pk.Pickup_Status__c!='Completed' && x==0)
                 {                     
                    s.addError('Complete the Pickup '+pk.Name+' Then Proceeds');                   
                 }
                
            }*/
            // upto here
            if(s.Verified_for_Billing__c && !trigger.oldmap.get(s.id).Verified_for_Billing__c && s.Customer_Product_Category__c!='BATH' && s.Customer_Product_Category__c!='eSHIP'  ){
                //system.debug('verified for billing checked');
                s.Status__c = 'Verified For Billing';
            }
        }
    }
    //product code automation
    if(trigger.isBefore){
        List<Shipment__c> ShipList = new List<Shipment__c>();
        for(Shipment__c  s: trigger.new){
            if(trigger.isInsert || s.Origin_Address_Name__c != trigger.oldmap.get(s.id).Origin_Address_Name__c ||
                s.Destination_Address_Name__c != trigger.oldmap.get(s.id).Destination_Address_Name__c ||
              s.Customer_Product_Category__c != trigger.oldmap.get(s.id).Customer_Product_Category__c ||
              s.IsExhibition__c != trigger.oldmap.get(s.id).IsExhibition__c){
                   s.BVC_Product_Name__c = '';
                   s.Product_Code__c = '';
                   if(s.Origin_Address_City__c!=null && s.Destination_Address_City__c !=null && (s.Customer_Product_Category__c!=null || s.IsExhibition__c)){
                       ShipList.add(s);
                   }
               }
        }
        if(ShipList!=null && ShipList.size()>0)
            TMS_ProductCodeHandler.UpdateProductDetails(ShipList);
    }
    //product code automation
    //
    //Shipment Sharing starts..
    if(trigger.isAfter){
        List<Shipment__c> ShipToShare = new List<Shipment__c>();
        List<String> SharingToDelete = new List<String>();
        for(Shipment__c  s: trigger.new){
            if(s.Origin_Hub__c != null){
                if(trigger.isInsert || s.OwnerId != trigger.oldMap.get(s.id).OwnerId)
                    ShipToShare.add(s);
                else if(s.Origin_Hub__c != trigger.oldMap.get(s.id).Origin_Hub__c){
                    SharingToDelete.add(s.id);
                    ShipToShare.add(s);
                }
            }
        }
        if(SharingToDelete !=null && SharingToDelete.size()>0)
            System.debug('11.SharingToDelete :'+SharingToDelete);
            TMS_ShipmentSharingHandler.DeleteShareRecords(SharingToDelete);
        if(ShipToShare !=null && ShipToShare.size()>0)
            TMS_ShipmentSharingHandler.ShareShipmentRecords(ShipToShare);
        
        //share shipment to escorter assigned for shipment---starts---
        if(trigger.isUpdate){
            Map<id,id> Shipment_AssignedTo_Map = new Map<id,id>();
            Map<id,id> Shipment_PreAssignedTo_Map = new Map<id,id>();
            for(Shipment__c ship: trigger.new){
                if((ship.Delivery_Route_Assigned_To__c != trigger.oldMap.get(ship.id).Delivery_Route_Assigned_To__c || 
                   ship.OwnerId != trigger.oldMap.get(ship.id).OwnerId) && ship.Delivery_Route_Assigned_To__c !=null){
                    Shipment_AssignedTo_Map.put(ship.id,ship.Delivery_Route_Assigned_To__c);
                }
                //remove sharing for previously assigned escorters
                if(trigger.oldMap.get(ship.id).Delivery_Route_Assigned_To__c != null && ship.Delivery_Route_Assigned_To__c != trigger.oldMap.get(ship.id).Delivery_Route_Assigned_To__c){
                    Shipment_PreAssignedTo_Map.put(ship.id, trigger.oldMap.get(ship.id).Delivery_Route_Assigned_To__c);
                }
                //remove sharing for escorters whose shipment is delivered
                if(ship.Tracking_Status__c == 'Delivered' && ship.Tracking_Status__c != trigger.oldMap.get(ship.id).Tracking_Status__c && ship.Delivery_Route_Assigned_To__c !=null){
                    Shipment_PreAssignedTo_Map.put(ship.id, ship.Delivery_Route_Assigned_To__c);
                }
            }
            if(Shipment_PreAssignedTo_Map !=null && Shipment_PreAssignedTo_Map.size()>0){
               TMS_ShipmentSharingHandler.deleteSharingForEscorters(Shipment_PreAssignedTo_Map);
            }
            if(Shipment_AssignedTo_Map !=null && Shipment_AssignedTo_Map.size()>0){
                TMS_ShipmentSharingHandler.SharingForEscorters(Shipment_AssignedTo_Map);
            }
        }
        //share pickup to escorter assigned for pickup---ends---
    }
    //Shipment Sharing ends.. 
    
}