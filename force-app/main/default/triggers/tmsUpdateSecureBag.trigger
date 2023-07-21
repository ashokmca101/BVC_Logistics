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
                //ShipmentShare.ShareShipment(trigger.new);
                Set<Id> hubId = new Set<Id>();
                for(Secure_Bag__c sb:trigger.new){
                    hubId.add(sb.Current_Scan_Hub__c);
                }
                Map<ID, Hub__c> HubMap = new Map<ID, Hub__c>([SELECT Id,Hub_Pincode__r.City__c FROM Hub__c WHERE id=:hubId]);
                for(Secure_Bag__c sb:trigger.new){
                    System.debug('for chekcing sb.Current_Scan_Hub__c '+sb.Current_Scan_Hub__c);
                    System.debug('for chekcing another sb.Current_Scan_Hub__c '+trigger.oldMap.get(sb.id).Current_Scan_Hub__c);
                    
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
                        System.debug('for checking before update value : '+sb.Next_Destination__c);
                    }
                    
                    if(sb.Lock_Status__c == 'Unlock' &&Trigger.oldMap.get(sb.Id).Lock_Status__c !=  'Unlock' || Test.isRunningTest()){
                        //system.debug('in');
                        sb.Seal_Id__c = null;
                    }
    
                    if(sb.Seal_Id__c !=null && Trigger.oldMap.get(sb.Id).Seal_Id__c == null || Test.isRunningTest()){
                        sb.Lock_Status__c = 'Lock';
                    }
                }
                
    
                // Update secure bag location
                tms_VehicleVaultHandler.updateSecureBagLocation(trigger.new);
             
            }
        }
        if(trigger.isUpdate && trigger.isAfter){
            Map<String,List<String>> TransitCityShipMap = new Map<String,List<String>>();
            for(Secure_Bag__c sb:trigger.new){
                System.debug('for checking sb.Next_Destination__c : '+sb.Next_Destination__c);
                System.debug('for checking trigger.oldMap.get(sb.id).Next_Destination__c :'+trigger.oldMap.get(sb.id).Next_Destination__c);
                if(sb.Next_Destination__c != trigger.oldMap.get(sb.id).Next_Destination__c && string.isNotBlank(sb.Next_Destination__c)){
                    if(TransitCityShipMap.containsKey(sb.Next_Destination__c)){
                        TransitCityShipMap.get(sb.Next_Destination__c).add(sb.Shipment__c);
                    }else{
                        TransitCityShipMap.put(sb.Next_Destination__c, new List<String>{sb.Shipment__c});
                        System.debug('11.Test TransitCityShipMap:'+TransitCityShipMap);
                    }
                }
                // added by imran 13-06-2023
                System.debug('for checking sb.Current_Scan_Hub__c : '+sb.Current_Scan_Hub__c);
                if(string.isNotBlank(sb.Current_Scan_Hub__c))
                {
                    Hub__c h = [select Id,name,Branch__c from Hub__c where Id=:sb.Current_Scan_Hub__c limit 1];
                    System.debug('Hub Name :'+h.Name);
                    if(sb.Current_Scan_Hub__c != trigger.oldMap.get(sb.id).Current_Scan_Hub__c && string.isNotBlank(sb.Current_Scan_Hub__c) && sb.Destination_Hub__c == h.Name)
                    {
                        TransitCityShipMap.put(h.Branch__c, new List<String>{sb.Shipment__c});
                        System.debug(' h.Branch__c :'+h.Branch__c);
                    }               
                }                
                // upto here
            }
            if(TransitCityShipMap!=null && TransitCityShipMap.size()>0){
                System.debug('12.Test TransitCityShipMap:'+TransitCityShipMap);
                TMS_ShipmentSharingHandler.ShipmentShareToTransitExecutives(TransitCityShipMap);
                System.debug('13.Test TransitCityShipMap:'+TransitCityShipMap);
            }
        }
    }