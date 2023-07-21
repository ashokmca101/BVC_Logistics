/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger tmsUpdateSecureBag on Secure_Bag__c (before insert,before update,after update) {
    List<Secure_Bag__c>updateList=new List<Secure_Bag__c>();
    if(Trigger.isBefore){
        if(trigger.isUpdate){
            system.debug('in update');
            Set<Id> hubId = new Set<Id>();
            for(Secure_Bag__c sb:trigger.new){
                hubId.add(sb.Current_Scan_Hub__c);
            }
            Map<ID, Hub__c> HubMap = new Map<ID, Hub__c>([SELECT Id,Hub_Pincode__r.City__c FROM Hub__c WHERE id=:hubId]);
            for(Secure_Bag__c sb:trigger.new){
                if(sb.Current_Scan_Hub__c!=null && sb.Current_Scan_Hub__c != trigger.oldMap.get(sb.id).Current_Scan_Hub__c){
                    sb.Current_Origin_City__c = HubMap.get(sb.Current_Scan_Hub__c).Hub_Pincode__r.City__c;
                    sb.Finalised_Linehaul_Number__c = null;
                    sb.Flight_Schedule__c = null;
                    sb.Linehaul_Type__c  = '';
                    //sb.Seal_Id__c = null;
                    sb.Vehicle__c = null;
                    sb.Flight_Date_Time__c = null;
                    sb.Next_Destination__c = null;
                    sb.Finalized_Time__c = null;
                }
                
                if(sb.Lock_Status__c == 'Unlock' &&Trigger.oldMap.get(sb.Id).Lock_Status__c !=  'Unlock'){
                    //system.debug('in');
                    sb.Seal_Id__c = null;
                }

                if(sb.Seal_Id__c !=null && Trigger.oldMap.get(sb.Id).Seal_Id__c == null){
                    sb.Lock_Status__c = 'Lock';
                }
                
                
            }
            
            // Update secure bag location
            tms_VehicleVaultHandler.updateSecureBagLocation(trigger.new);
            
        }
      
    }
    if(trigger.isUpdate && trigger.isAfter){
        System.debug('11.After SB Tigger');
        Map<String,List<String>> TransitCityShipMap = new Map<String,List<String>>();
        
        Set<Id> scanHubIds = new Set<Id>();
        for (Secure_Bag__c sb : trigger.new) {
            //if (sb.Current_Scan_Hub__c != trigger.oldMap.get(sb.Id).Current_Scan_Hub__c && String.isNotBlank(sb.Current_Scan_Hub__c)) {
                scanHubIds.add(sb.Current_Scan_Hub__c);
            //}
        }
        
        Map<Id, Hub__c> hubMap = new Map<Id, Hub__c>([SELECT Id, Branch__c FROM Hub__c WHERE Id IN :scanHubIds]);
        
        for(Secure_Bag__c sb:trigger.new){
            System.debug('11. Loop');
            if(sb.Next_Destination__c != trigger.oldMap.get(sb.id).Next_Destination__c && string.isNotBlank(sb.Next_Destination__c)){
                if(TransitCityShipMap.containsKey(sb.Next_Destination__c)){
                    System.debug('11. True Block');
                    TransitCityShipMap.get(sb.Next_Destination__c).add(sb.Shipment__c);
                }else{
                    System.debug('11. False Block');
                    TransitCityShipMap.put(sb.Next_Destination__c, new List<String>{sb.Shipment__c});
                }
            }
            
            // added by imran and changes made by rafi
            if(sb.Current_Scan_Hub__c != trigger.oldMap.get(sb.id).Current_Scan_Hub__c && string.isNotBlank(sb.Current_Scan_Hub__c)){
                if(TransitCityShipMap.containsKey(sb.Current_Scan_Hub__c)){
                    System.debug('11. Current_Scan_Hub__c True Block');
                    TransitCityShipMap.get(sb.Current_Scan_Hub__c).add(sb.Shipment__c);
                }else{
                    Hub__c hb = hubMap.get(sb.Current_Scan_Hub__c);
                    System.debug('for checking hubMap.get(sb.Current_Scan_Hub__c '+hubMap.get(sb.Current_Scan_Hub__c));
                    if (hb != null) {
                        System.debug('for checking hb.Branch__c '+hb.Branch__c);
                        String branch = hb.Branch__c;
                        if (TransitCityShipMap.containsKey(branch)) {
                            TransitCityShipMap.get(branch).add(sb.Shipment__c);
                        } else {
                            TransitCityShipMap.put(branch, new List<String>{sb.Shipment__c});
                        }
                    }
                    
                    
                    
                    
                    //TransitCityShipMap.put(hb.Branch__c, new List<String>{sb.Shipment__c});
                }
            }   
            //upto Here
            
        }
        System.debug('for checking TransitCityShipMap '+TransitCityShipMap);
        System.debug('for checking TransitCityShipMapsize '+TransitCityShipMap.size());
        if(TransitCityShipMap!=null && TransitCityShipMap.size()>0){
            System.debug('11.Sharing SB');
            TMS_ShipmentSharingHandler.ShipmentShareToTransitExecutives(TransitCityShipMap);
        }
    }
}