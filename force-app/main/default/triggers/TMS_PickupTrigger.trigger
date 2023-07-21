trigger TMS_PickupTrigger on Pickup__c (after Insert, after update,before insert,before update) {
    //pickup shring code...
    if(trigger.isAfter){
        List<Pickup__c> PickToShare = new List<Pickup__c>();
        List<String> SharingToDelete = new List<String>();
         if(trigger.isInsert){
             set<Id> ids=new set<Id>(); 
              for(Pickup__c  pick: trigger.new){
                if(pick.Shipper_Address__c!=null){
                    system.debug('Shipper_Address__c found');
                    ids.add(pick.id) ;
                }
              }
             if(ids !=null && ids.size()>0){
               TMS_PickupHandler.updatePickUp(ids);  
            }
         }
        for(Pickup__c  pick: trigger.new){
            if(pick.BVC_Origin_Hub__c != null){
                if(trigger.isInsert)
                    PickToShare.add(pick);
                else if(pick.BVC_Origin_Hub__c != trigger.oldMap.get(pick.id).BVC_Origin_Hub__c){
                    SharingToDelete.add(pick.id);
                    PickToShare.add(pick);
                }
            }
        }
        if(SharingToDelete !=null && SharingToDelete.size()>0)
            TMS_PickupSharingHandler.DeleteShareRecords(SharingToDelete);
        if(PickToShare !=null && PickToShare.size()>0)
            TMS_PickupSharingHandler.SharePickupRecords(PickToShare);
        
        //share pickup to escorter assigned for pickup---starts---
        if(trigger.isUpdate){
             set<Id> ids=new set<Id>(); 
            Map<id,id> pickup_AssignedTo_Map = new Map<id,id>();
            Map<id,id> pickup_PreAssignedTo_Map = new Map<id,id>();
            for(Pickup__c  pick: trigger.new){
                if(pick.Shipper_Address__c!=null && pick.Shipper_Address__c!=trigger.oldMap.get(pick.id).Shipper_Address__c){
                    system.debug('Shipper_Address__c found');
                    ids.add(pick.id) ;
                }
                if(pick.Pickup_Assigned_To__c != trigger.oldMap.get(pick.id).Pickup_Assigned_To__c && pick.Pickup_Assigned_To__c !=null){
                    system.debug('assigned');
                    pickup_AssignedTo_Map.put(pick.id,pick.Pickup_Assigned_To__c);
                }
                //remove sharing for previously assigned escorters
                if(trigger.oldMap.get(pick.id).Pickup_Assigned_To__c != null && pick.Pickup_Assigned_To__c != trigger.oldMap.get(pick.id).Pickup_Assigned_To__c){
                    pickup_PreAssignedTo_Map.put(pick.id, trigger.oldMap.get(pick.id).Pickup_Assigned_To__c);
                }
                //remove sharing for escorters whose pickup is complete/cancelled
                /*if((pick.Pickup_Status__c =='Completed' || pick.Pickup_Status__c =='Cancelled') && pick.Pickup_Status__c != trigger.oldMap.get(pick.id).Pickup_Status__c && pick.Pickup_Assigned_To__c !=null){
                pickup_PreAssignedTo_Map.put(pick.id, pick.Pickup_Assigned_To__c);
               }*/
                
            }
            if(pickup_PreAssignedTo_Map !=null && pickup_PreAssignedTo_Map.size()>0){
                TMS_PickupSharingHandler.deleteSharingForEscorters(pickup_PreAssignedTo_Map);
            }
            if(pickup_AssignedTo_Map !=null && pickup_AssignedTo_Map.size()>0){
                TMS_PickupSharingHandler.SharingForEscorters(pickup_AssignedTo_Map);
            }
            if(ids !=null && ids.size()>0){
               TMS_PickupHandler.updatePickUp(ids);  
            }
              
        }
        //share pickup to escorter assigned for pickup---ends---
    }
    
    //Used for Pickupfiledupdate
    If(Trigger.isbefore && Trigger.isInsert){
        TMS_PickupHandler.updatepickupFields(Trigger.new);
        
    }
     
    //Sharing ends...
   
    
    //Code added by Rafi Khan for OTP generation for pickup assigned to --> escortors
    If(Trigger.isBefore){
        if (Trigger.isInsert || Trigger.isUpdate) {
            
            //Set<Id> escorterUserIds = new Set<Id>();
            for(Pickup__c  pick: trigger.new){
                if (pick.Pickup_Assigned_To__c != null && (trigger.isInsert || (trigger.isUpdate && pick.Pickup_Assigned_To__c != trigger.oldMap.get(pick.Id).Pickup_Assigned_To__c))) {
                    system.debug('assigned');
                    //escorterUserIds.add(pick.Pickup_Assigned_To__c);
                }
                
            }
            
           // Map<Id, User> escorterUsers = new Map<Id, User>([SELECT Id, UserRole.Name FROM User WHERE Id IN :escorterUserIds AND UserRole.Name = 'Escorter']);

            for (Pickup__c pick : trigger.new) {
                if (pick.Pickup_Assigned_To__c != null && pick.OTP__c == null && (trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(pick.Id).OTP__c == null))) {
                    
                    Integer otpLength = 4;
                    String allowedChars = '0123456789';
                    String otp = '';
                    
                    while (otp.length() < otpLength) {
                        Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), allowedChars.length());
                        otp += allowedChars.charAt(randomIndex);
                    }
                    
                    pick.OTP__c = otp;
                }
            
            }

        }
    }
    //OTP generation Code ends here
    
    
}