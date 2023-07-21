public class ShipmentTriggerHandlerServiceCtrl {
    Static Id operShipId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();
    Static Id commShipId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Community Shipment').getRecordTypeId();
    
    public static void calculateShipmentAmount(List<Shipment__c> newShipmentList){
        List<ShipmentCalcUtil.ShipmentDetail> shipCalInput=new List<ShipmentCalcUtil.ShipmentDetail>();
        shipCalInput.addAll(GetShipmentAmountForTMS(newShipmentList));
        shipCalInput.addAll(getShipmentAmountForCommunity(newShipmentList));
        
        if(shipCalInput.size()>0){
            List<Shipment__c> lstShipToUpdate = new List<Shipment__c>();
            List<ShipmentCalcUtil.ShipmentDetail> resultAmtCal=ShipmentCalcUtil.shipmentCalculationUtility(shipCalInput);
            system.debug('resultAmtCal size ::'+resultAmtCal.size());
            system.debug('resultAmtCal ::'+resultAmtCal);
            if(resultAmtCal.size()>0){
                for(ShipmentCalcUtil.ShipmentDetail obj : resultAmtCal){
                    Shipment__c shipmentObj =new Shipment__c();
                    shipmentObj.Id = obj.CommunityUniqueId;
                    shipmentObj.Invoice_Calculated_Amount__c = obj.totalAmount;
                    system.debug('===CommunityUniqueId : '+obj.CommunityUniqueId);
                    lstShipToUpdate.add(shipmentObj);
                }
                system.debug('lstShipToUpdate::'+lstShipToUpdate);
                update lstShipToUpdate;
            }
            
        }
        
    }
    public static  List<ShipmentCalcUtil.ShipmentDetail>  GetShipmentAmountForTMS(List<Shipment__c> newShipmentList){
        List<ShipmentCalcUtil.ShipmentDetail> shipCalInput=new List<ShipmentCalcUtil.ShipmentDetail>();
        Set<Id> productIds = new Set<Id>();
        Set<String> productNames = new Set<String>();
        map<Id, String> productIdToProdNameMap = new map<Id, String>() ;
        map<String, Product2> prod2NametoIdMap = new  map<String, Product2> ();
        for(Shipment__c shipObjParent : newShipmentList){
            if(shipObjParent.RecordTypeId == operShipId && shipObjParent.Product_Name__c != null){
                productIds.add(shipObjParent.Product_Name__c);
                
            }
        }
        List<Product__c> productList = [SELECT Id, Name FROM Product__c WHERE id in :productIds ];
        for(Product__c prod:productList){
            productNames.add(prod.name);           
            productIdToProdNameMap.put(prod.Id,prod.Name);
        }
        List<Product2> prodList = [SELECT Id,Name,Product_Category__c FROM Product2 WHERE Name in : productNames];
        for(Product2 prod:prodList){
            prod2NametoIdMap.put(prod.Name,prod);
        }
        
        //Load Wrapper
        for(Shipment__c shipObjParent : newShipmentList){
            if(shipObjParent.RecordTypeId == operShipId && shipObjParent.Product_Name__c != null && shipObjParent.Invoice_Calculated_Amount__c ==null ){
                Map < String, Active_Pincode__c > pincodeMap = new Map < String, Active_Pincode__c > ();
                pincodeMap = Utility.getActivePinCode(); //get all active pincode from utility class.
                
                ShipmentCalcUtil.ShipmentDetail shipCal =new ShipmentCalcUtil.ShipmentDetail();
                shipCal.grossWeight =shipObjParent.Gross_Weight__c;
                shipCal.customerProdCategory = String.valueof(prod2NametoIdMap.get(productIdToProdNameMap.get(shipObjParent.Product_Name__c)).Product_Category__c);
                //shipCal.orderLineItemId=shipObjParent.Id; //ShipmentId
                shipCal.productId = String.valueof(prod2NametoIdMap.get(productIdToProdNameMap.get(shipObjParent.Product_Name__c)).Id); //ProductId '01t1m00000111gXAAQ'
                shipCal.isDestOfflineLoc =true;
                shipCal.isOriginOfflineLoc =true;
                shipCal.accountId=shipObjParent.Customer__c;
                shipCal.optForLiability='No';
                shipCal.CommunityUniqueId = shipObjParent.Id;
                if (pincodeMap.containsKey(shipObjParent.Origin_Pincode__c)){
                    Active_Pincode__c objPincode = pincodeMap.get(shipObjParent.Origin_Pincode__c);
                    system.debug('objPincode'+objPincode);
                    // shipCal.origin=objPincode.CITY__c;
                }
                if (pincodeMap.containsKey(shipObjParent.Destination_Pincode__c)){
                    Active_Pincode__c objPincodeDest = pincodeMap.get(shipObjParent.Destination_Pincode__c);
                    system.debug('objPincodeDest'+objPincodeDest);
                    //  shipCal.destination= objPincodeDest.CITY__c;
                }
                shipCalInput.add(shipCal);
            }
            
        }
        
        return shipCalInput;
    }
    public static List<ShipmentCalcUtil.ShipmentDetail> getShipmentAmountForCommunity(List<Shipment__c> newShipmentList){
        List<ShipmentCalcUtil.ShipmentDetail> shipCalInput=new List<ShipmentCalcUtil.ShipmentDetail>();
        set<String> bvcProductList = new Set<string>();
        map<String,Product2> producNameToId = new  map<String,Product2> ();
        for(Shipment__c shipObjParent : newShipmentList){
            if(shipObjParent.RecordTypeId == commShipId && shipObjParent.BVC_Products__c != null){
                bvcProductList.add(shipObjParent.BVC_Products__c);
            }
            
        }
        for(Product2 prod:[SELECT Id,Name,Product_Category__c FROM Product2 WHERE Name in : bvcProductList]){
            producNameToId.put(prod.name, prod);
        }
        for(Shipment__c shipObjParent : newShipmentList){
            if(shipObjParent.RecordTypeId == commShipId && shipObjParent.BVC_Products__c != null && shipObjParent.Invoice_Calculated_Amount__c ==null ){
                
                string originCity;
                string destiCity;
                Map < String, Active_Pincode__c > pincodeMap = new Map < String, Active_Pincode__c > ();
                pincodeMap = Utility.getActivePinCode(); //get all active pincode from utility class.
                if (pincodeMap.containsKey(shipObjParent.Origin_Pincode__c)){
                    Active_Pincode__c objPincode = pincodeMap.get(shipObjParent.Origin_Pincode__c);
                    //originCity = objPincode.CITY__c;
                }
                if (pincodeMap.containsKey(shipObjParent.Destination_Pincode__c)){
                    Active_Pincode__c objPincode = pincodeMap.get(shipObjParent.Destination_Pincode__c);
                    //   destiCity = objPincode.CITY__c;
                }
                system.debug('originCity::'+originCity); 
                system.debug('destiCity::'+destiCity); 
                
                ShipmentCalcUtil.ShipmentDetail shipCal =new ShipmentCalcUtil.ShipmentDetail();
                shipCal.grossWeight =shipObjParent.Gross_Weight__c;
                if(producNameToId.containskey(shipObjParent.BVC_Products__c) && String.valueof(producNameToId.get(shipObjParent.BVC_Products__c).Product_Category__c) != null && String.valueof(producNameToId.get(shipObjParent.BVC_Products__c).Product_Category__c) != ''){
                    shipCal.customerProdCategory = String.valueof(producNameToId.get(shipObjParent.BVC_Products__c).Product_Category__c); 
                }  
                if(producNameToId.containskey(shipObjParent.BVC_Products__c) ){
                    shipCal.productId = String.valueof(producNameToId.get(shipObjParent.BVC_Products__c).Id); //ProductId '01t1m00000111gXAAQ' 
                }
                
                shipCal.isDestOfflineLoc =true;
                shipCal.isOriginOfflineLoc =true;
                shipCal.accountId=shipObjParent.Customer__c;
                shipCal.optForLiability='No';
                shipCal.origin=originCity;
                shipCal.destination= destiCity;
                shipCal.CommunityUniqueId = shipObjParent.Id;
                shipCalInput.add(shipCal);
            } 
        }
        return shipCalInput;
    }
    
    public static void updateDeliveryRouteNos(
        Map<id,Shipment__c> newMap,
        Map<id,Shipment__c> oldMap)
    {
        set<Id> shipId = new Set<Id>();
        List<Shipment__c> shipmentList = new List<Shipment__c>();
        for(Shipment__c ship :newMap.values())
        {                     
            if(ship.Destination_Address_Name__c != Null)
            shipId.add(ship.Id);
         
        }
       
        for(Shipment__c shipments : [Select Id,Destination_Address_Name__c, Delivery_Route_Number__c,Destination_Address_Name__r.Delivery_Route_Number__c  from Shipment__c where Id=:shipId])
        {
            shipments.Delivery_Route_Number__c = shipments.Destination_Address_Name__r.Delivery_Route_Number__c;
            shipmentList.add(shipments);
        }
        if(shipmentList.size() > 0)
        {
            update shipmentList;
        }
        
    }
    
}