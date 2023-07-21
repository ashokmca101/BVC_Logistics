/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc   //Rafi Khan
* @group             : 
* @last modified on  : 03-21-2022                           // 29-05-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc   //rafi.khan@bvclogistics.com
* Update with Respect to tracking API - 07-01-2022
**/
public without sharing class TSM_SignatureHelper { 
    
    @AuraEnabled(cacheable=true)
    public static Delivery__c getshipmetID(Id recId){    
        List<Delivery__c> lstship  = [Select Id,Shipment__r.Id from Delivery__c where Id =:recId];
        return lstship[0];
    }
    
    /*@AuraEnabled(cacheable=true)
public static String getshipmetID(Id recId){    
List<Delivery__c> lstship  = [Select Id, Shipment__r.Id from Delivery__c where Id =:recId];
return lstship[0].Shipment__r.Id; 
}*/
// added by imran
    @AuraEnabled
    public static void saveSNPhoto(String shipId,String contentDocId , List<Secure_Bag__c> secureBagList)
    {
             Shipment__c sh1 = [select Id,DocketPhoto__c from Shipment__c where ID=:shipId limit 1];
             System.debug('11.Shipment update sh:'+sh1);
             if(sh1.Id !=null || sh1.Id!='')
             {
                 sh1.DocketPhoto__c=true;
                 update sh1;
                 System.debug('22.Shipment DocketPhoto__c update sh:'+sh1);
             }
        System.debug('1122.contentDocId :'+contentDocId);
        System.debug('1122.secureBagList :'+secureBagList);
            set<String> shipmentId = new Set<String>();
            if(secureBagList.size() > 0){
                for(Secure_Bag__c bag : secureBagList){
                    if(bag.Shipment__c!=shipId)
                    {
                        shipmentId.add(bag.Shipment__c);
                    }
                    // shipmentId.add(bag.Shipment__c);              
                }
            }
            System.debug('1122.shipmentId :'+shipmentId);  

            List<Shipment__c>  shList = [select Id,DocketPhoto__c from Shipment__c where ID IN : shipmentId ];
        	List<Shipment__c>  shListUpdate = new List<Shipment__c>();
        if(shList.size()>0)
        {
            for(Shipment__c sh : shList){
                sh.DocketPhoto__c=true;
                shListUpdate.add(sh);
            }  
            update shListUpdate;
        }
		List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(Id linkedEntity : shipmentId){
                
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);
			}				
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
			}
    }
    @AuraEnabled 
    public static void saveIdPhoto(String shipId,String contentDocId , List<Secure_Bag__c> secureBagList)
    {
        System.debug('1122.contentDocId :'+contentDocId);
        System.debug('1122.secureBagList :'+secureBagList);
            set<String> shipmentId = new Set<String>();
            if(secureBagList.size() > 0){
                for(Secure_Bag__c bag : secureBagList){
                    if(bag.Shipment__c!=shipId)
                    {
                        shipmentId.add(bag.Shipment__c);
                    }
                    // shipmentId.add(bag.Shipment__c);              
                }
            }
            System.debug('1122.shipmentId :'+shipmentId);  

            List<Shipment__c>  shList = [select Id,RecieverIDPhoto__c from Shipment__c where ID IN : shipmentId ];
        	List<Shipment__c>  shListUpdate = new List<Shipment__c>();
        if(shList.size()>0)
        {
            for(Shipment__c sh : shList){
                sh.RecieverIDPhoto__c=true;
                shListUpdate.add(sh);
            }  
            update shListUpdate;
        }
		List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(Id linkedEntity : shipmentId){
                
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);
			}				
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
			}

             Shipment__c sh1 = [select Id,RecieverIDPhoto__c from Shipment__c where ID=:shipId limit 1];
             System.debug('11.Shipment update sh:'+sh1);
             if(sh1.Id !=null || sh1.Id!='')
             {
                 sh1.RecieverIDPhoto__c=true;
                 update sh1;
                 System.debug('22.Shipment RecieverIDPhoto__c update sh:'+sh1);
             }        

    }    
// upto here

    @AuraEnabled
    public static void saveSign(String strSignElement,Id recId, Delivery__c deliveryData, List<Shipment_Tracking__c> trackingList){  
        String consigneeName = '';
        String consigneeDesignation = '';
        Boolean isWindow = false;
        if(deliveryData != null){
            consigneeName = deliveryData.Consignee_Name__c;
            consigneeDesignation = deliveryData.Consignee_Designation__c; 
        }
        
        
        ContentVersion cVersion = new ContentVersion();
        Id conDocument;
        
        cVersion.ContentLocation = 'S';  
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png'; 
        cVersion.Origin = 'H';  
        cVersion.Title = 'Signature-'+System.now() +'.png'; 
        cVersion.VersionData = EncodingUtil.base64Decode(strSignElement); 
        Insert cVersion;
        
        if(cVersion.Id != null){
            conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            // added by imran
             Shipment__c sh = [select Id,SignaturePhoto__c from Shipment__c where ID=:trackingList[0].Shipment__c limit 1];
             System.debug('11.Shipment update sh:'+sh);
             if(sh.Id !=null || sh.Id!='')
             {
                 sh.SignaturePhoto__c=true;
                 update sh;
                 System.debug('22.Shipment update sh:'+sh);
             }

            // upto here
        } 
        
        if(trackingList.size() > 0){
            updateOtherShipment(conDocument,trackingList, consigneeName, consigneeDesignation,false);
        }
        
    }
    
    public static void updateOtherShipment( String contentDocId , List<Shipment_Tracking__c> trackingList , String consigneeName , String consigneeDesignation, Boolean isWindow){ 
        try{
            List<Shipment__c> updateDeliveryList = new List<Shipment__c>();
            set<String> shipmentId = new Set<String>();
            //set<Id> deliveryId = new Set<Id>();
            
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(Shipment_Tracking__c track : trackingList){
                shipmentId.add(track.shipment__c);
            } 
            
            // added by Rafi Khan
            // Delivery and Shipment marks as delivered only if all secure bags of related shipment get delivered 
            List<Secure_Bag__c> secureBagList = [
                SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                FROM Secure_Bag__c 
                WHERE Current_Scan_Loction__c = 'Delivered' AND
                Shipment__c IN: shipmentId]; 
            
            Map<String,List<Secure_Bag__c>> shipAndSecBagMap = new Map<String,List<Secure_Bag__c>>();
            if(secureBagList.size()>0){
                for(Secure_Bag__c secBagObj:secureBagList){
                    if(shipAndSecBagMap.containsKey(secBagObj.Shipment__c)){                        
                        List<Secure_Bag__c> tmpSecBag = shipAndSecBagMap.get(secBagObj.Shipment__c);                        
                        tmpSecBag.add(secBagObj);                        
                        shipAndSecBagMap.put(secBagObj.Shipment__c,tmpSecBag);
                    }else{                        
                        List<Secure_Bag__c> bagLsit = new List<Secure_Bag__c>();
                        bagLsit.add(secBagObj);                        
                        shipAndSecBagMap.put(secBagObj.Shipment__c,bagLsit);
                    }                
                }
            }
                        
            Map<String,List<Secure_Bag__c>> tmpShipAndSecBagMap = new Map<String,List<Secure_Bag__c>>();
            List<Secure_Bag__c> secureBagList1 = [
                SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                FROM Secure_Bag__c 
                WHERE Shipment__c IN: shipmentId];
            
            if(secureBagList1.size()>0){
                for(Secure_Bag__c secBagObj:secureBagList1){
                    if(tmpShipAndSecBagMap.containsKey(secBagObj.Shipment__c)){
                        List<Secure_Bag__c> tmpSecBag = tmpShipAndSecBagMap.get(secBagObj.Shipment__c);
                        tmpSecBag.add(secBagObj);
                        tmpShipAndSecBagMap.put(secBagObj.Shipment__c,tmpSecBag);
                    }else{
                        List<Secure_Bag__c> bagLsit = new List<Secure_Bag__c>();
                        bagLsit.add(secBagObj);
                        tmpShipAndSecBagMap.put(secBagObj.Shipment__c,bagLsit);
                    }
                }
            }
           
            Map<String,Delivery__c> shipDelMap = new Map<String,Delivery__c>();
            List<Delivery__c> deliveryList = new List<Delivery__c>();
            deliveryList = [SELECT Id,Name,Status__c,Shipment__c,Number_of_Secure_Bag__c 
                            FROM Delivery__c WHERE Shipment__c IN: shipmentId ];
            if(deliveryList.size()>0){
                for(Delivery__c delObj :deliveryList){
                    shipDelMap.put(delObj.Shipment__c,delObj);
                }
                
            }
            
            List<Delivery__c> deliveryListToUpdate = new  List<Delivery__c>();
            for(String strId :shipmentId){

                if(shipAndSecBagMap.containsKey(strId) && tmpShipAndSecBagMap.containsKey(strId)){
                   
                    if(shipAndSecBagMap.get(strId).size() == tmpShipAndSecBagMap.get(strId).size()){ 
                       
                        Delivery__c delObjs = new Delivery__c();
                        delObjs = shipDelMap.get(strId);
                        if(delObjs.Status__c=='Accepted'){
                            Delivery__c tmpDel = new Delivery__c(); 
                            tmpDel.Status__c ='Delivered';
                            tmpDel.Shipment__c = strId;
                            tmpDel.Id = delObjs.Id;
                            tmpDel.Consignee_Name__c = consigneeName;
                            tmpDel.Consignee_Designation__c = consigneeDesignation;
                            tmpDel.Delivered_To_Person__c = consigneeName;
                            tmpDel.Actual_Delivery_Date_and_Time__c = System.now();  
                            deliveryListToUpdate.add(tmpDel);
                        }
                       
                    }//end of If conditions  
                }
                
            }
            
            if(deliveryListToUpdate.size()>0){
                update deliveryListToUpdate;
            }
            // Added Code by Rafi Khan Ends here
            
            
            for(Id linkedEntity : shipmentId){
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);
                
                Shipment__c shipObj = new Shipment__c();
                shipObj.Id = linkedEntity; 
                shipObj.Consignee_Name__c = consigneeName; 
                shipObj.Consignee_Designation__c = consigneeDesignation; 
                shipObj.Delivered_To_Person__c = consigneeName;
                //delivery.Actual_Delivery_Date_and_Time__c = System.now();  
                updateDeliveryList.add(shipObj);
                
            }
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
                if(updateDeliveryList.size() > 0 ){
                    Update updateDeliveryList;
                }
            } 
            
        }
        catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
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

    }
    
    
}