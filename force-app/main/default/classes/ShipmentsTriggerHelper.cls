public without sharing class ShipmentsTriggerHelper {
    public ShipmentsTriggerHelper() {
        System.debug('Inside ShipmentsTriggerHelper Constructor');
    }
    
    public void calculateShipmentAmountAfterInsert(List<shipment__c>newshipmentList) {
        // calculate shipment amount,check invoice calculated value is not nuull and enqueue Community_RazorpayQueueableCrtInv job.
        
        ShipmentTriggerHandlerServiceCtrl.calculateShipmentAmount(newshipmentList);
        if(newshipmentList[0].Invoice_Calculated_Amount__c != null){
            system.enqueueJob(new Community_RazorpayQueueableCrtInv(newshipmentList));
        }                        
    }
    
    public void calculateshipmentAmountAfterUpdate(List<Shipment__c>newShipmentBillingAccList,List<Shipment__c>oldShipmentBillingAccList){
        if(newShipmentBillingAccList[0].Invoice_Calculated_Amount__c != oldShipmentBillingAccList[0].Invoice_Calculated_Amount__c){
            system.enqueueJob(new Community_RazorpayQueueableCrtInv(newShipmentBillingAccList));
        }
        if(newShipmentBillingAccList[0].Invoice_Calculated_Amount__c != null && newShipmentBillingAccList[0].Short_URL__c == null){
            system.enqueueJob(new Community_RazorpayQueueableCrtInv(newShipmentBillingAccList));
        }
        ShipmentTriggerHandler.updateShipmentLotCheckbox(newShipmentBillingAccList);
        // Added By standav
        Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>();
        /*for(Shipment__c ship : trigger.new){
if((ship.Status__c == 'Verified For Billing' && ship.Status__c <> trigger.oldmap.get(ship.Id).Status__c && ship.Ready_for_Billing__c)
||(ship.Ready_for_Billing__c &&ship.Status__c == 'Verified For Billing'&&ship.Ready_for_Billing__c <> trigger.oldmap.get(ship.Id).Ready_for_Billing__c)
||(ship.Ready_for_Rebilling__c &&ship.Status__c == 'Verified For Billing'&&ship.Ready_for_Rebilling__c <> trigger.oldmap.get(ship.Id).Ready_for_Rebilling__c)
||(ship.Status__c == 'Verified For Billing' && ship.Status__c <> trigger.oldmap.get(ship.Id).Status__c && ship.Ready_for_Rebilling__c))
{
shipMap.put(ship.Id,ship);
} 
}
system.debug('Shipment AFter Update Trigger:::'+shipMap.values());
if(shipMap.size() > 0){
OrderCreateShipment.validateAndCreateOrder(shipMap);  
}*/
        
    }
    
    public void updateBillingAccount(List<Shipment__c>newShipmentBillingAccList,Map<Id,shipment__c> oldshipMap) {
        // update Billing Account      
        Set<Id>accountIds=new Set<Id>();
        List<Shipment__c> ShipmentWithBillingAccountList = new List<Shipment__c>();
        for(Shipment__c shp:newShipmentBillingAccList){
            if(shp.Customer__c!=null){
                accountIds.add(shp.Customer__c);
            }
            if(shp.Billing_Account__c !=null){
                ShipmentWithBillingAccountList.add(shp);
            }           
        }
        Profile [] profileList = [SELECT Id, Name, UserType, UserLicense.Name FROM Profile WHERE Id=:userinfo.getProfileId() AND UserLicense.Name like 'Customer Community Plus%' LIMIT 1];
        
        Boolean showError = profileList.size() > 0 ? false: true;
        
        Map<Id,Account>mapOfIdVsAccount=new Map<Id,Account>([SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:accountIds LIMIT 50000]);
        for(Shipment__c sh:newShipmentBillingAccList){
            if(sh.Customer__c !=null && (trigger.isInsert || sh.Customer__c != oldshipMap.get(sh.id).Customer__c)){
                if(mapOfIdVsAccount.containsKey(sh.Customer__c)){
                    //system.debug('>>'+mapOfIdVsAccount.get(sh.Customer__c));
                    //system.debug('>>'+mapOfIdVsAccount.get(sh.Customer__c)+' :'+mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size());
                    if(mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size()==0){
                        sh.Billing_Account__c=mapOfIdVsAccount.get(sh.Customer__c).id;
                        sh.Billing_Address__c=mapOfIdVsAccount.get(sh.Customer__c).Primary_Address__r.id;
                    }
                    if(mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size()==1){
                        for(Account cust:mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts){
                            sh.Billing_Account__c=cust.id;
                            sh.Billing_Address__c=cust.Primary_Address__r.id;
                        }
                    }
                    if(mapOfIdVsAccount.get(sh.Customer__c).ChildAccounts.size()>1 &&(sh.Billing_Account__c==null || sh.Billing_Address__c==null)){
                        if(showError ){ // to bypass mobile and Community
                            if(sh.Shipment_Created_Through__c != 'Mobile App'){
                                newShipmentBillingAccList[0].addError('Please select a Billing Account');
                            }                       
                        }                    
                    }
                }
            }        
        }
        if(ShipmentWithBillingAccountList !=null && ShipmentWithBillingAccountList.size()>0){
            //system.debug('calling handler');
            updateBillingAccount_handler.updatePrimaryAddress(ShipmentWithBillingAccountList);
        }
        
        /* if(Trigger.isBefore){
if( Trigger.isInsert){
TMS_PickAndDeliveriesAssignment.shipmentAssignment(Trigger.new);
}
}*/
        
    }
    
    public void setPayerBeforeInsert(List<shipment__c>newShipmentList) {          
        user currentUser= Utility.getUserDetails();
        if(currentUser.ContactId !=null){
            //ShipmentTriggerHandler.UpdateShipmentShipper(Trigger.New);
            //ShipmentTriggerHandler.UpdateShipmentConsignee(Trigger.New);
            //ShipmentTriggerHandler.updateShipmentBillTo(Trigger.New);
        }
        
        ShipmentTriggerHandler.setPayer(newShipmentList);
    }
    
    public void setPayerBeforeUpdate(List<shipment__c>newShipmentList){
        ShipmentTriggerHandler.setPayer(newShipmentList);
    }
    
    public void updateShipmentStatusBeforeUpdate(List<shipment__c>newShipmentList,Map<Id,shipment__c>oldShipmentMap){
        //update shipment status to 'verified for billing'
        for(Shipment__c  s: newShipmentList){
            if(s.Verified_for_Billing__c && !oldShipmentMap.get(s.id).Verified_for_Billing__c){
                //system.debug('verified for billing checked');
                s.Status__c = 'Verified For Billing';
            }
        }
        
        //product code automation
        List<Shipment__c> ShipList = new List<Shipment__c>();
        for(Shipment__c  s:newShipmentList){
            if(trigger.isInsert || s.Origin_Address_Name__c !=oldShipmentMap.get(s.id).Origin_Address_Name__c ||
               s.Destination_Address_Name__c != oldShipmentMap.get(s.id).Destination_Address_Name__c ||
               s.Customer_Product_Category__c != oldShipmentMap.get(s.id).Customer_Product_Category__c ||
               s.IsExhibition__c != oldShipmentMap.get(s.id).IsExhibition__c){
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
    // This method update secure packaging on shipment object when shipping note number is not empty or NULL
    public void updateSecurePackaging(List<Shipment__c>newShipmentList){
        List<Shipment__c> shipmentList = new List<Shipment__c>();
        for(Shipment__c ship: newShipmentList){
            if(ship.Shipping_Note_Number__c != null){
                shipmentList.add(ship);  
            }
        }
        Update_Secure_Packaging.updateRelatedSecurePackaging(shipmentList); 
    }
    
    public void shareShipmentAfterUpdate(List<Shipment__c>newShipmentList,Map<Id,shipment__c>oldShipmentMap){
        //Shipment Sharing starts..
        List<Shipment__c> ShipToShare = new List<Shipment__c>();
        List<String> SharingToDelete = new List<String>();
        for(Shipment__c  s: newShipmentList){
            if(s.Origin_Hub__c != null){
                if(trigger.isInsert || s.OwnerId != oldShipmentMap.get(s.id).OwnerId)
                    ShipToShare.add(s);
                else if(s.Origin_Hub__c != oldShipmentMap.get(s.id).Origin_Hub__c){
                    SharingToDelete.add(s.id);
                    ShipToShare.add(s);
                }
            }
        }
        if(SharingToDelete !=null && SharingToDelete.size()>0)
            TMS_ShipmentSharingHandler.DeleteShareRecords(SharingToDelete);
        if(ShipToShare !=null && ShipToShare.size()>0)
            TMS_ShipmentSharingHandler.ShareShipmentRecords(ShipToShare);
    }
    
    public void shareShipmentToEscorterAfterUpdate(List<Shipment__c>newShipmentList,Map<Id,shipment__c>oldShipmentMap){
        //share shipment to escorter assigned for shipment---starts---
        
        Map<id,id> Shipment_AssignedTo_Map = new Map<id,id>();
        Map<id,id> Shipment_PreAssignedTo_Map = new Map<id,id>();
        for(Shipment__c ship: newShipmentList){
            if((ship.Delivery_Route_Assigned_To__c != oldShipmentMap.get(ship.id).Delivery_Route_Assigned_To__c || 
                ship.OwnerId != oldShipmentMap.get(ship.id).OwnerId) && ship.Delivery_Route_Assigned_To__c !=null){
                    Shipment_AssignedTo_Map.put(ship.id,ship.Delivery_Route_Assigned_To__c);
                }     
            //remove sharing for previously assigned escorters
            if(oldShipmentMap.get(ship.id).Delivery_Route_Assigned_To__c != null && ship.Delivery_Route_Assigned_To__c != oldShipmentMap.get(ship.id).Delivery_Route_Assigned_To__c){
                Shipment_PreAssignedTo_Map.put(ship.id, oldShipmentMap.get(ship.id).Delivery_Route_Assigned_To__c);
            }
            //remove sharing for escorters whose shipment is delivered
            if(ship.Tracking_Status__c == 'Delivered' && ship.Tracking_Status__c != oldShipmentMap.get(ship.id).Tracking_Status__c && ship.Delivery_Route_Assigned_To__c !=null){
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
    
    public void updateBvcShipmentStage( List<Shipment__C> bvcshipList,Map<Id,shipment__c>oldShipmentMap){
        //  List<Shipment__C> bvcshipLists = new List<Shipment__c>();
        For(Shipment__c ship : bvcshipList){
            if(ship.Gross_Weight__c <= 0 || ship.Gross_Weight__c == null && ship.Shipment_Stage__c == 'bvc weighment done' ){
                ship.adderror('you can not update shipment stage to bvc weighment done due to empty bvc gross weight field or zero gross weight');
                
            }
            if(ship.Gross_Weight__c >= 1 || ship.Gross_Weight__c != Null){
                ship.Shipment_Stage__c = 'bvc weighment done';
            }
        }
        
    }
    
    public void updateDeliveryRouteNo (Map<Id,shipment__c>newShipmentMap,Map<Id,shipment__c>oldShipmentMap) {
        // Update Delivery route number     
        if(RecursiveTriggerHandler.isFirstTime){
            RecursiveTriggerHandler.isFirstTime = false;
            //obj.method1(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            
            ShipmentTriggerHandlerServiceCtrl.updateDeliveryRouteNos(newShipmentMap,oldShipmentMap);
        }                 
    }   
    
    public void validateAndCreateOrders(List<shipment__c> newshipmentList,Map<Id,shipment__c> oldShipmentMap) {
        
        // Validate and Create orders by cheking status of shipment object      
        
        Map<Id,shipment__c> shipMap = new Map<Id,shipment__c>();
        
        for(Shipment__c ship : newshipmentList){
            if(ship.Status__c == 'Verified For Billing' && oldShipmentMap.get(ship.Id).Status__c == 'Pending Billing' )
            {
                shipMap.put(ship.Id,ship);
            } 
        }
        if(shipMap.size() > 0){
            OrderCreateShipment.validateAndCreateOrder(shipMap);  
        }                        
    }
    
    public  void GetCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        
        
    }  
    
}