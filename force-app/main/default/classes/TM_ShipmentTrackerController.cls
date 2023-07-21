/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc  //rafi.khan@bvclogistics.com
* @group             : 
* @last modified on  : 02-10-2022              //28-04-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc  //rafi.khan@bvclogistics.com
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   07-15-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class TM_ShipmentTrackerController {
    
    @AuraEnabled
    /*
The method takes a String parameter bagId and returns a custom object ShipmetWrap
that contains information related to shipments associated with the given bagId.
*/
    public static ShipmetWrap bagBySealId(String bagId){
        try {
            ShipmetWrap ShipmetWrapData = new ShipmetWrap(); 
            Map<String,Secure_Bag__c> shipmentRecord = new Map<String,Secure_Bag__c>();
            Set<String> snn = new Set<String>();
            Set<String> bag = new Set<String>();
            
            if(bagId != null && bagId != ''){
                for(Secure_Bag__c secureBag : [
                    SELECT Id, Name , Shipment__c, Shipping_Note_Number__c, Cargo_Type__c, Seal_Id__c,
                    Seal_Id__r.Name, Current_Scan_Hub__r.name, Current_Destination_City__c, Shipment__r.Shipper_Name_TMS__r.Name,
                    Shipment__r.Consignee_Name_TMS__r.Name,Destination_Hub__c, Secure_Bag__r.Name, Secure_Bag__r.Id,
                    Secure_Packaging_Identifier__c,Shipment__r.Destination_Hub__c,Shipment__r.Origin_Hub__c
                    FROM Secure_Bag__c
                    WHERE Seal_Id__r.Name =: bagId LIMIT 50000
                ]){
                    shipmentRecord.put(secureBag.Secure_Bag__r.Name, secureBag);
                    snn.add(secureBag.Shipping_Note_Number__c);
                    bag.add(secureBag.Secure_Bag__r.Name);
                    
                    ShipmetWrapData.cargoType = secureBag.Cargo_Type__c;
                    ShipmetWrapData.destinationCity = secureBag.Current_Destination_City__c;
                    ShipmetWrapData.destinationhub = secureBag.Destination_Hub__c;
                }
            }
            
            if(!shipmentRecord.isEmpty() && shipmentRecord != null){
                ShipmetWrapData.typeOfBag = 'Seal-Bag';
                ShipmetWrapData.shipmentRecordMap = shipmentRecord;
                ShipmetWrapData.numberOfShippingNote = snn.size();
                ShipmetWrapData.numberOfBag = bag.size();
            }else{
                throw new AuraHandledException('This seal Id is not associated with shipment');
            }  
            
            return ShipmetWrapData;
            
        } catch(System.NoAccessException noAccess){
            throw new AuraHandledException('Insufficient  access rights on '+bagId);
        }catch (Exception e) { 
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    /*
The method takes a single parameter of type ShipmetWrap,
which contains information about the shipment and the secure bags associated with it.
The purpose of this method is to update the scanning status of the secure bags to "In Progress"
then updates the records using the Database.Update method.
*/
    public static Boolean scanningInProgress(ShipmetWrap bagData){
        try {
            Boolean running  = false;
            
            List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
            if(bagData != null){
                if(bagData.shipmentRecordMap != null){
                    for(Secure_Bag__c bag : bagData.shipmentRecordMap.values()){
                        Secure_Bag__c secureBag = new Secure_Bag__c();
                        secureBag.Id = bag.Id;
                        secureBag.Scanning_Status__c ='In Progress';
                        secureBagList.add(secureBag); 
                    }
                    
                    if(secureBagList.size() > 0){
                        Database.Update(secureBagList);
                        running = true;
                    }  
                }else{
                    throw new AuraHandledException('This bag is not associated with shipment');
                }
            } 
            
            return running; 
            
        } catch(System.NoAccessException noAccess){
            throw new AuraHandledException('Insufficient  access rights on Secure Bag  Record.');
        }catch (Exception e)  {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    /*
The method takes three parameters: bagId, trackingrecord, and bagMode.
bagId is a string parameter that represents the ID of the Secure Bag record that needs to be fetched.
trackingrecord is an instance of the Shipment_Tracking__c object that holds the tracking data for a shipment.
bagMode is a string parameter that indicates the mode in which the bag is being handled.

The method starts by initializing a new instance of the ShipmetWrap class, which is a custom class that holds information about a shipment,
including a map of Secure Bag records associated with the shipment.

Finally, the method returns the ShipmetWrap instance.
*/
    public static ShipmetWrap bagBySecureBagId(String bagId , Shipment_Tracking__c trackingrecord, String bagMode){
        Integer Index = 1;
        String errorData = '';
        try { 
            
            ShipmetWrap ShipmetWrapData = new ShipmetWrap();            
            Map<String,Secure_Bag__c> shipmentRecord = new Map<String,Secure_Bag__c>();
            
            if(bagId != null && bagId != ''){
                for(Secure_Bag__c secureBag : [
                    SELECT Id, Name , Shipment__c, Shipment__r.Name,Shipment__r.Customer__r.Name,
                    Shipment__r.Origin_Address_City__c,Shipment__r.Consignee_Name_TMS__r.Name,Shipment__r.Consignee_Name_TMS__c,
                    Shipment__r.Shipper_Name_TMS__r.Name, Shipment__r.Consignee_Name__c, 
                    Current_Origin_City__c, Shipment__r.Delivery_Route_Assigned_To__c, Shipping_Note_Number__c, 
                    Cargo_Type__c, Seal_Id__c, Seal_Id__r.Name, Current_Destination_City__c, Destination_Hub__c, 
                    Secure_Bag__r.Name, Shipment__r.Destination_Address_City__c, Shipment__r.Origin_Hub__c, Shipment__r.Destination_Hub__c,
                    Secure_Packaging_Identifier__c
                    FROM Secure_Bag__c
                    WHERE Secure_Bag__r.Name =: bagId LIMIT 1
                ]){ 
                    
                    if(secureBag.Shipment__r.Delivery_Route_Assigned_To__c != UserInfo.getUserId() && trackingrecord.Location__c == 'Out for Delivery'){
                        errorData = 'Insufficient  access rights on  '+bagId;
                        throw new AuraHandledException('Insufficient  access rights on  '+bagId);
                        
                    }else{
                        shipmentRecord.put(secureBag.Secure_Bag__r.Name, secureBag);
                    }
                }
            }
            
            if(!shipmentRecord.isEmpty()){
                
                ShipmetWrapData.typeOfBag = 'Secure-Bag';
                ShipmetWrapData.shipmentRecordMap = shipmentRecord; 
                //ShipmetWrapData.index = Index; 
                
                if(bagMode == 'Misrouted'){
                    Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();
                    shipmentTracking = trackingrecord;
                    
                    if(shipmentRecord.containsKey(bagId)){
                        if(shipmentRecord.get(bagId).Shipment__c != null){
                            shipmentTracking.Shipment__c = shipmentRecord.get(bagId).Shipment__c  ;
                        } 
                    } 
                    
                    shipmentTracking.Scan_Time__c = DateTime.now();
                    if(shipmentTracking != null){
                        if(bagMode!='Misrouted'){
                            Database.insert(shipmentTracking);
                        }
                    }
                    
                    Secure_Bag__c bag = new Secure_Bag__c();
                    if(shipmentRecord.containsKey(bagId)){
                        bag.Id = shipmentRecord.get(bagId).Id;
                    } 
                    
                    bag.Is_Misrouted__c = true;
                    bag.Scanning_Status__c = 'Scanned'; 
                    bag.Current_Scan_Hub__c = shipmentTracking.Hub__c;
                    bag.Current_Scan_Date_and_Time__c = DateTime.now();
                    bag.Tracking__c = shipmentTracking.Id;
                    bag.Current_Scan_Airport__c = shipmentTracking.Airport__c;
                    Database.Update(Bag);
                    Index++;
                    
                } 
            }else{
                errorData = 'This bag is not associated with shipment';
                throw new AuraHandledException('This bag is not associated with shipment');
                
            }
            
            return ShipmetWrapData;
            
        } catch(System.NoAccessException noAccess){
            throw new AuraHandledException('Insufficient  access rights on  '+bagId);
        } catch (Exception e) {
            throw new AuraHandledException(''+errorData);
        }
    }
    
    @AuraEnabled
    /*
The purpose of the method is to update the Secure_Bag__c records associated with a shipment, and create Shipment_Tracking__c records for the shipment based on the provided tracking information.
It first checks if the Hub__c and Airport__c fields of the Shipment_Tracking__c record are blank and sets the Hub__c to the hub of the currently logged in user if the Location__c is not set to "Out for Delivery".
It then retrieves the Shipment__c records associated with the Secure_Bag__c records provided in the wrapper object and creates new Shipment_Tracking__c records for each shipment based on the tracking information provided.
It then updates the Secure_Bag__c records based on whether or not the associated shipment has a corresponding Shipment_Tracking__c record and updates the lock status of the bags if necessary.
Finally, it inserts the new Shipment_Tracking__c records created and updates the Secure_Bag__c and Shipment__c records.
*/
    public static void updateSecureBag(Shipment_Tracking__c trackingRecord, List<Secure_Bag__c> secureBagList, ShipmetWrap shipmetWrapData, String lockStatus){
        try { 
            Set<Id> shipmentId = new Set<Id>();
            Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>(); 
            Map<Id,Shipment_Tracking__c> shipmnetTrackingMap = new Map<Id,Shipment_Tracking__c>();
            Map<Id,Secure_Bag__c> updateSecureBag = new Map<Id,Secure_Bag__c>(); 
            
            if(String.isBlank(trackingRecord.Hub__c) && String.isBlank(trackingRecord.Airport__c) &&  trackingRecord.Location__c != 'Out for Delivery'){
                trackingRecord.Hub__c = LoggedInUserHub();
            } 
            
            if(shipmetWrapData != null){
                
                if(!shipmetWrapData.shipmentRecordMap.isEmpty()){
                    for( Secure_Bag__c bag : shipmetWrapData.shipmentRecordMap.values()){
                        shipmentId.add(bag.Shipment__c);    
                    } 
                }
                
                if(shipmentId.size() > 0){
                    shipmentMap = new Map <Id, Shipment__c>([ 
                        SELECT Id,Origin_Hub__c,Destination_Hub__c,Destination_Hub__r.Airport__c,Origin_Hub__r.Airport__c 
                        FROM Shipment__c WHERE Id IN:shipmentId 
                    ]);
                }
                
                Map<String,String> trackingShipBagMap = new Map<String,String>();
                for(Secure_Bag__c secBagObj : secureBagList){
                    trackingShipBagMap.put(secBagObj.shipment__c,secBagObj.shipment__c);
                }
                
                
                
                if(!shipmentMap.isEmpty()){
                    for(Shipment__c  ship : shipmentMap.values()){
                        if(trackingShipBagMap.containsKey(ship.Id)){
                            Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();                        
                            shipmentTracking = trackingRecord.clone(false,false,false,false);
                            shipmentTracking.Shipment__c = null; 
                            shipmentTracking.Scan_Time__c = DateTime.now();
                            
                            if(String.isNotBlank(ShipmentTracking.Hub__c)){ 
                                if(ShipmentTracking.Hub__c ==ShipmentMap.get(ship.Id).Destination_Hub__c){
                                    ShipmentTracking.Location__c='Destination Hub';
                                    
                                }else if(ShipmentTracking.Hub__c == ShipmentMap.get(ship.Id).Origin_Hub__c){
                                    ShipmentTracking.Location__c='Origin Hub';
                                    
                                }else {                                    
                                    ShipmentTracking.Location__c='Transit Hub';
                                } 
                                
                            } else if(String.isNotBlank(ShipmentTracking.Airport__c)){
                                
                                if(ShipmentTracking.Airport__c ==ShipmentMap.get(ship.Id).Destination_Hub__r.Airport__c){
                                    ShipmentTracking.Location__c='Destination Port';
                                    
                                }else if(ShipmentTracking.Airport__c ==ShipmentMap.get(ship.Id).Origin_Hub__r.Airport__c){
                                    ShipmentTracking.Location__c='Origin Port';
                                    
                                }else {
                                    ShipmentTracking.Location__c = 'Transit Port';
                                    
                                }
                            } 
                            
                            shipmentTracking.Shipment__c = ship.Id; 
                            shipmnetTrackingMap.put(shipmentTracking.Shipment__c,shipmentTracking);
                        }
                        
                    } 
                    
                    if(!shipmnetTrackingMap.isEmpty()){
                        
                        Insert shipmnetTrackingMap.values();
                        List<Shipment__c> tempShipment = new List<Shipment__c>(); 
                        for(Secure_Bag__c secureBag : shipmetWrapData.shipmentRecordMap.values()){
                            
                            Secure_Bag__c bag = new Secure_Bag__c();
                            bag.id = secureBag.Id;
                            
                            Shipment__c ship = new Shipment__c();
                            
                            if(secureBagList.size() > 0){
                                
                                if(shipmnetTrackingMap.containsKey(secureBag.Shipment__c) && secureBagList.contains(secureBag)){
                                    bag.Is_Count_Mismatch__c =  false;
                                    bag.Current_Scan_Loction__c =  shipmnetTrackingMap.get(secureBag.Shipment__c).Location__c;
                                    bag.Current_Scan_Hub__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Hub__c != null ? shipmnetTrackingMap.get(secureBag.Shipment__c).Hub__c : null;
                                    bag.Seal_Id__c = secureBag.Seal_Id__c;
                                    
                                    if(bag.Current_Scan_Hub__c!=null){
                                        if((bag.Current_Scan_Hub__c != secureBag.Shipment__r.Destination_Hub__c) && (bag.Current_Scan_Hub__c != secureBag.Shipment__r.Origin_Hub__c)){
                                            bag.Is_Misrouted__c = true;
                                        }else{
                                            bag.Is_Misrouted__c = false;
                                        }
                                        
                                    }
                                    
                                    bag.Tracking__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Id;
                                    bag.Current_Scan_Airport__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Airport__c != null ? shipmnetTrackingMap.get(secureBag.Shipment__c).Airport__c  : null;
                                    bag.Current_Scan_Date_and_Time__c = DateTime.now();
                                    
                                    if(lockStatus == 'Unlock'){
                                        bag.Lock_Status__c = lockStatus;
                                    }
                                    
                                }else{
                                    bag.Scanning_Status__c = 'In Progress';
                                    bag.Tracking__c = null;
                                    bag.Is_Count_Mismatch__c =  true;                                     
                                    ship.Id = secureBag.Shipment__c;
                                    ship.Is_Count_Mismatch__c = true;
                                    
                                } 
                            }else{
                                bag.Scanning_Status__c = 'In Progress';
                                bag.Tracking__c = null;
                                bag.Is_Count_Mismatch__c =  true;
                                
                                ship.Id = secureBag.Shipment__c;
                                ship.Is_Count_Mismatch__c = true;
                            }
                            
                            if(!tempShipment.contains(ship) && ship.Id != null  ){
                                tempShipment.add(ship);
                            }
                            updateSecureBag.put(bag.Id,bag); 
                        }
                        
                        
                        if(updateSecureBag.values().size() > 0 ){ 
                            Update updateSecureBag.values();  
                            
                            //Code Added by Rafi Khan for Unlock Seal.
                            //this code is executed only for scaned bags
                            Map<String,List<Secure_Bag__c>> shipBagMap = new Map<String,List<Secure_Bag__c>>(); 
                            if(secureBagList.size()>0){
                                for(Secure_Bag__c secBag:secureBagList){
                                    if(shipBagMap.containsKey(secBag.Shipment__c)){
                                        List<Secure_Bag__c> tmpBagList = shipBagMap.get(secBag.Shipment__c);
                                        tmpBagList.add(secBag);
                                        shipBagMap.put(secBag.Shipment__c,tmpBagList);							
                                    }else{
                                        List<Secure_Bag__c> tmpBagLists = new List<Secure_Bag__c>();
                                        tmpBagLists.add(secBag);
                                        shipBagMap.put(secBag.Shipment__c,tmpBagLists);	
                                    }									
                                }
                            }
                            
                            //This code is executed to create map for all shipment and corroesponding secure bags
                            Map<String,List<Secure_Bag__c>> exstingShipBagMap = new Map<String,List<Secure_Bag__c>>(); 
                            if(!shipmetWrapData.shipmentRecordMap.isEmpty()){
                                for( Secure_Bag__c secBag : shipmetWrapData.shipmentRecordMap.values()){
                                    if(exstingShipBagMap.containsKey(secBag.Shipment__c)){
                                        List<Secure_Bag__c> tmpBagList = exstingShipBagMap.get(secBag.Shipment__c);
                                        tmpBagList.add(secBag);
                                        exstingShipBagMap.put(secBag.Shipment__c,tmpBagList);							
                                    }else{
                                        List<Secure_Bag__c> tmpBagLists = new List<Secure_Bag__c>();
                                        tmpBagLists.add(secBag);
                                        exstingShipBagMap.put(secBag.Shipment__c,tmpBagLists);	
                                    }	
                                }                            
                            }
                            
                            List<Shipment_Tracking__c> shipTrakingList = new List<Shipment_Tracking__c>();
                            shipTrakingList = shipmnetTrackingMap.values();
                            Map<String,String> mapShipAndLocation = new Map<String,String>();
                            for(Shipment_Tracking__c sObj :shipTrakingList){
                                if(sObj.Location__c!=null && sObj.Shipment__c!=null){
                                    mapShipAndLocation.put(sObj.Shipment__c,sObj.Location__c);
                                }
                            }
                            
                            List<Shipment__c> updateShippingList = new List<Shipment__c>();
                            for(Secure_Bag__c secBag : secureBagList){
                                System.debug('for checking exstingShipBagMap.containsKey(secBag.Shipment__c) '+exstingShipBagMap.containsKey(secBag.Shipment__c));
                                System.debug('for checking exstingShipBagMap.get(secBag.Shipment__c).size() '+exstingShipBagMap.get(secBag.Shipment__c).size());
                                if(exstingShipBagMap.containsKey(secBag.Shipment__c)){
                                
                                    if(exstingShipBagMap.get(secBag.Shipment__c).size()==shipBagMap.get(secBag.Shipment__c).size()){
                                        Shipment__c shipObj = new Shipment__c();
                                        shipObj.Tracking_Status__c =  mapShipAndLocation.get(secBag.Shipment__c);
                                        shipObj.Id = secBag.Shipment__c;
                                        if(!updateShippingList.contains(shipObj)){
                                            updateShippingList.add(shipObj);
                                        }
                                        
                                    }   
                                }                               
                            }
                            update updateShippingList;
                        }
                        
                        
                    }else{
                        System.debug('for chekcing exceptions first');
                        // throw new AuraHandledException('Tracking Record Update failed');
                    }
                } 
            } 
            
        }catch(System.NoAccessException noAccess){
            System.debug('for chekcing exceptions second');
            throw new AuraHandledException('Insufficient  access rights on Secure bag and Shipment.');
        } catch (Exception e) {
            System.debug('for chekcing exceptions third '+e.getMessage());
            System.debug('for chekcing exceptions third '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    //upadateScanBagsWithNoseal method added by Rafi for creating tracking record of the scanned bag if it is not in seal.
    //and updating shipment linehaul not processed flag true.
    @auraEnabled
    public static void upadateScanBagsWithNoseal(Shipment_Tracking__c trackingRecord,List<Secure_Bag__c> secureBagList){
        try{
            
            Set<Id> shipmentId = new Set<Id>();
            Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>(); 
            Map<Id,Shipment_Tracking__c> shipmnetTrackingMap = new Map<Id,Shipment_Tracking__c>();
            Map<Id,Secure_Bag__c> updateSecureBag = new Map<Id,Secure_Bag__c>(); 
            
            if(String.isBlank(trackingRecord.Hub__c) && String.isBlank(trackingRecord.Airport__c) &&  trackingRecord.Location__c != 'Out for Delivery'){
                trackingRecord.Hub__c = LoggedInUserHub();
            } 
            
            if(secureBagList.size() > 0){
                for(Secure_Bag__c bag : secureBagList){
                    shipmentId.add(bag.Shipment__c);              
                }
                
                if(shipmentId.size() > 0){
                    shipmentMap = new Map <Id, Shipment__c>([ 
                        SELECT Id,Origin_Hub__c,Destination_Hub__c,Destination_Hub__r.Airport__c,Origin_Hub__r.Airport__c 
                        FROM Shipment__c WHERE Id IN:shipmentId 
                    ]); 
                }
                
                if(!shipmentMap.isEmpty()){
                    for(Shipment__c  ship : shipmentMap.values()){
                        
                        Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();
                        
                        shipmentTracking = trackingRecord.clone(false,false,false,false);
                        shipmentTracking.Shipment__c = null; 
                        shipmentTracking.Scan_Time__c = DateTime.now();
                        
                        if(String.isNotBlank(ShipmentTracking.Hub__c)){
                            
                            if(ShipmentTracking.Hub__c == ShipmentMap.get(ship.Id).Destination_Hub__c){
                                ShipmentTracking.Location__c='Destination Hub';
                                
                            }else if(ShipmentTracking.Hub__c == ShipmentMap.get(ship.Id).Origin_Hub__c ){ 
                                ShipmentTracking.Location__c='Origin Hub';
                                
                            }else{
                                
                                ShipmentTracking.Location__c='Transit Hub';
                            } 
                            
                        }else if(String.isNotBlank(ShipmentTracking.Airport__c)){
                            
                            if(ShipmentTracking.Airport__c ==ShipmentMap.get(ship.Id).Destination_Hub__r.Airport__c){
                                ShipmentTracking.Location__c='Destination Port';
                                
                            }else if(ShipmentTracking.Airport__c == ShipmentMap.get(ship.Id).Origin_Hub__r.Airport__c){ 
                                ShipmentTracking.Location__c='Origin Port';
                                
                            }else{
                                ShipmentTracking.Location__c = 'Transit Port';
                            }
                        } 
                        shipmentTracking.Shipment__c =  ship.Id ;
                        shipmnetTrackingMap.put(shipmentTracking.Shipment__c,shipmentTracking); 
                        
                    } 
                }
                if(!shipmnetTrackingMap.isEmpty()){
                    Insert shipmnetTrackingMap.values();
                }
                
                
                List<String> shipmentIdList = new List<String>();
                for(Secure_Bag__c secBag : secureBagList){
                    shipmentIdList.add(secBag.Shipment__c);
                }
                List<Shipment__c> shipmentList = [Select Id,Linehaul_not_Processed__c from Shipment__c
                                                  WHERE Id IN:shipmentIdList];
                for(Shipment__c obj:shipmentList){
                    obj.Linehaul_not_Processed__c = true;           
                }
                update shipmentList;
            }   
        }catch (Exception e) {
            System.debug('Error on line number '+e.getLineNumber());
            System.debug('Error Message '+e.getMessage());
        }
        
    }
    
    @AuraEnabled
    /*
This method is designed to retrieve a Secure Bag record based on a provided Secure Bag ID and update a field called Scanning__c with the value "Update Required."
If the Secure Bag record is not found, the method throws an exception. Additionally, if the user does not have sufficient access to the Secure Bag record, the method throws a different exception indicating that the user has insufficient access rights.

May be this method is used for updating the status of Secure Bags associated with a particular shipment.

*/
    public static Secure_Bag__c secureBagGet(String secureBagId){
        try {  
            Secure_Bag__c secureBag =   [
                SELECT Id, Name , Shipment__c, Scanning__c, Shipping_Note_Number__c, Cargo_Type__c, Current_Destination_City__c, Destination_Hub__c, Secure_Bag__r.Name
                FROM Secure_Bag__c 
                WHERE Secure_Bag__r.Name =: secureBagId 
                LIMIT 1 ];
            
            if(secureBag != null){
                secureBag.Scanning__c = 'Update Required';
                Update secureBag;
            }else{
                throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');    
            }
            
            return secureBag; 
            
        }catch(System.NoAccessException noAccess){
            throw new AuraHandledException('Insufficient  access rights on '+secureBagId);
        } catch (Exception e) {
            throw new AuraHandledException('\n - This Secure Bag is not associated with shipment.');
        }
    }
    
    @AuraEnabled
    /*
It updates the tracking information for each secure bag in the secureBagList and updates the corresponding Secure_Bag__c records.
It also updates the location of the shipment in the Shipment__c record based on the location information in the trackingRecord parameter.
*/
    public static void updateNormalBag(Shipment_Tracking__c trackingRecord, List<Secure_Bag__c> secureBagList ){
        try {
            
            Set<Id> shipmentId = new Set<Id>();
            Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>(); 
            Map<Id,Shipment_Tracking__c> shipmnetTrackingMap = new Map<Id,Shipment_Tracking__c>();
            Map<Id,Secure_Bag__c> updateSecureBag = new Map<Id,Secure_Bag__c>();
            
            if(String.isBlank(trackingRecord.Hub__c) && String.isBlank(trackingRecord.Airport__c) &&  trackingRecord.Location__c != 'Out for Delivery'){
                trackingRecord.Hub__c = LoggedInUserHub();
            } 
            
            
            if(secureBagList.size() > 0){
                for(Secure_Bag__c bag : secureBagList){
                    shipmentId.add(bag.Shipment__c);              
                }
                
                if(shipmentId.size() > 0){
                    shipmentMap = new Map <Id, Shipment__c>([ 
                        SELECT Id,Origin_Hub__c,Destination_Hub__c,Destination_Hub__r.Airport__c,Origin_Hub__r.Airport__c 
                        FROM Shipment__c WHERE Id IN:shipmentId 
                    ]); 
                }
                
                if(!shipmentMap.isEmpty()){
                    for(Shipment__c  ship : shipmentMap.values()){
                        
                        Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();
                        
                        shipmentTracking = trackingRecord.clone(false,false,false,false);
                        shipmentTracking.Shipment__c = null; 
                        shipmentTracking.Scan_Time__c = DateTime.now();
                        
                        if(String.isNotBlank(ShipmentTracking.Hub__c)){
                            
                            if(ShipmentTracking.Hub__c == ShipmentMap.get(ship.Id).Destination_Hub__c){
                                ShipmentTracking.Location__c='Destination Hub';
                                
                            }else if(ShipmentTracking.Hub__c == ShipmentMap.get(ship.Id).Origin_Hub__c ){ 
                                ShipmentTracking.Location__c='Origin Hub';
                                
                            }else{
                                
                                ShipmentTracking.Location__c='Transit Hub';
                            } 
                            
                        }else if(String.isNotBlank(ShipmentTracking.Airport__c)){
                            
                            if(ShipmentTracking.Airport__c ==ShipmentMap.get(ship.Id).Destination_Hub__r.Airport__c){
                                ShipmentTracking.Location__c='Destination Port';
                                
                            }else if(ShipmentTracking.Airport__c == ShipmentMap.get(ship.Id).Origin_Hub__r.Airport__c){ 
                                ShipmentTracking.Location__c='Origin Port';
                                
                            }else{
                                ShipmentTracking.Location__c = 'Transit Port';
                            }
                        } 
                        shipmentTracking.Shipment__c =  ship.Id ;
                        shipmnetTrackingMap.put(shipmentTracking.Shipment__c,shipmentTracking); 
                        
                    } 
                    
                    if(!shipmnetTrackingMap.isEmpty()){
                        
                        Insert shipmnetTrackingMap.values();
                        
                        
                        for(Secure_Bag__c secureBag :  secureBagList){
                            Secure_Bag__c bag = new Secure_Bag__c();
                            bag.id = secureBag.Id;
                            
                            if(shipmnetTrackingMap.containsKey(secureBag.Shipment__c)){
                                bag.Current_Scan_Loction__c =  shipmnetTrackingMap.get(secureBag.Shipment__c).Location__c;
                                bag.Current_Scan_Hub__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Hub__c != null ? shipmnetTrackingMap.get(secureBag.Shipment__c).Hub__c : null;
                                
                                if(bag.Current_Scan_Hub__c!=null){
                                    if((bag.Current_Scan_Hub__c != secureBag.Shipment__r.Destination_Hub__c) && (bag.Current_Scan_Hub__c != secureBag.Shipment__r.Origin_Hub__c)){
                                        bag.Is_Misrouted__c = true;
                                    }else{
                                        bag.Is_Misrouted__c = false;
                                    }
                                    
                                }
                                
                                bag.Tracking__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Id;
                                bag.Current_Scan_Airport__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Airport__c != null ? shipmnetTrackingMap.get(secureBag.Shipment__c).Airport__c  : null;
                                bag.Current_Scan_Date_and_Time__c = DateTime.now(); 
                                bag.Scanning_Status__c = 'Scanned';
                                bag.Scanning__c = 'Updated';
                            }
                            updateSecureBag.put(bag.Id,bag); 
                        }  
                    }
                }
            }
            
            
            if(updateSecureBag.values().size() > 0 ){ 
                Update updateSecureBag.values();
                
                //Code Added by Rafi Khan for updation of tracking status on shipment to remove Set Tracking Status schedule flow
                //tracking status on shipment is updated only when location of created tracking record and Current Scan Location of all secure bags are same.
                
                List<Shipment_Tracking__c> shipTrakingList = new List<Shipment_Tracking__c>();
                shipTrakingList = shipmnetTrackingMap.values();
                
                List<String> locationList = new List<String>();
                List<String> shipmentList = new List<String>();
                
                Map<String,String> mapShipAndLocation = new Map<String,String>();
                
                for(Shipment_Tracking__c sObj :shipTrakingList){
                    if(sObj.Location__c!=null && sObj.Shipment__c!=null){
                        locationList.add(sObj.Location__c);
                        shipmentList.add(sObj.Shipment__c);
                        mapShipAndLocation.put(sObj.Shipment__c,sObj.Location__c);
                    }
                }//end of for loop
                
                List<Secure_Bag__c> secBagList1 = new List<Secure_Bag__c>();
                secBagList1 = [Select Id, Name From Secure_Bag__c
                               where Shipment__c IN:shipmentList];
                
                List<Secure_Bag__c> secBagListWithTrackingLocation = new List<Secure_Bag__c>();
                secBagListWithTrackingLocation = [Select Id, Name From Secure_Bag__c
                                                  where Shipment__c IN:shipmentList
                                                  AND Current_Scan_Loction__c IN:locationList];
                
                if(secBagListWithTrackingLocation.size()>0 && (secBagList1.size() == secBagListWithTrackingLocation.size())){
                    List<Shipment__c> shipList = new List<Shipment__c>();
                    shipList = [Select Id,Name,Tracking_Status__c from Shipment__c
                                Where Id IN:shipmentList];
                    
                    if(shipList.size()>0){
                        List<Shipment__c> updateShippingList = new List<Shipment__c>();
                        for(Shipment__c obj:shipList){
                            Shipment__c tmpUpdate = new Shipment__c();
                            tmpUpdate.Tracking_Status__c =  mapShipAndLocation.get(obj.Id);
                            tmpUpdate.Linehaul_not_Processed__c = false;
                            tmpUpdate.Id = obj.Id;
                            updateShippingList.add(tmpUpdate);
                        }//end of for loop
                        if(updateShippingList.size()>0){
                            update updateShippingList;
                        }
                    }
                }//Added Code upto here  
                
                
            }
        } catch(System.NoAccessException noAccess){
            throw new AuraHandledException('Insufficient  access rights on Secured Bags');
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    /*
This method used to determine the "Hub" of the currently logged-in user, which can have one of three values:
1. If the user is a "Manager", their Hub will be the Hub associated with the most recent FSE_Sales__c record where they are listed as the Sales_Person__c.
2. If the user is an "Operations Field Executive", their Hub will be "Field Executive".
3. If the user does not fall into either of these categories or if no Hub can be determined for any reason, the method will return null.
*/
    public static string LoggedInUserHub(){
        FSE_Sales__c[] UserHub = [ SELECT Hub__r.Name,Hub__c FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() AND Type__c='Manager' ORDER BY CreatedDate DESC LIMIT 1];
        
        if(UserHub != null && UserHub.size()> 0 && UserHub[0].Hub__c !=null){
            return UserHub[0].Hub__c;
        }else{
            id LoggedInProfileId = UserInfo.getProfileId();
            Profile p = [SELECT Id,name FROM Profile WHERE id=:LoggedInProfileId];
            if(p!= null && LoggedInProfileId!=null && (p.Name=='Operations Field Executive'))
                return 'Field Executive';
            else
                return null;
        }
        
    }
    
    public static string LoggedInUserHubWithBranchName(){
        FSE_Sales__c[] UserHub = [ SELECT Id,Hub__r.Branch__c,Hub__c FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() AND Type__c='Manager' ORDER BY CreatedDate DESC LIMIT 1];
        
        if(UserHub != null && UserHub.size()> 0 && UserHub[0].Hub__c !=null){
            return UserHub[0].Hub__r.Branch__c; 
        }else{
            id LoggedInProfileId = UserInfo.getProfileId();
            Profile p = [SELECT Id,name FROM Profile WHERE id=:LoggedInProfileId];
            if(p!= null && LoggedInProfileId!=null && (p.Name=='Operations Field Executive'))
                return 'Field Executive';
            else
                return null;
        }
        
    }
    
    
    @testVisible class ShipmetWrap{
        
        @AuraEnabled
        public String typeOfBag{get;set;}
        
        @AuraEnabled
        public Map<String,Secure_Bag__c> shipmentRecordMap {get;set;}
        
        @AuraEnabled
        public Integer numberOfBag{get;set;}
        
        @AuraEnabled
        public Integer numberOfShippingNote{get;set;}
        
        @AuraEnabled
        public String cargoType{get;set;}
        
        @AuraEnabled
        public String destinationCity{get;set;}
        
        @AuraEnabled
        public String destinationhub{get;set;}
        
        
        
    } 
}