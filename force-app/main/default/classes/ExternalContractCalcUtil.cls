public class ExternalContractCalcUtil {
    
    public static String getSobjectList(Set<Id> shipmentIds) {
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keyset());
        String query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id =:shipmentIds';
        system.debug('===query : '+query);
        return query;
        
    }
    
    public static void createExternalContractShipment(Map<String,List<ShipmentCalcUtil.ShipmentDetail>> extContractToSummaryMap, Map<String,External_Contract_Shipment_Summary__c> extIdToSummaryMap, Set<Id> shipmentIds)
    {
        system.debug('===createExternalContractShipment called');
        External_Contract_Shipment__c extContractShip;
        Map<Id,Shipment__c> shipObjMap = new Map<Id,Shipment__c>();
        List<External_Contract_Shipment__c> extContShipToBeInserted = new List<External_Contract_Shipment__c>();
        String query = getSobjectList(shipmentIds);
        List<Shipment__c> lstSObject = Database.query(query);
        system.debug('=== lstSObject : '+lstSObject.size());
        
        for(Shipment__c sh : lstSObject){
            shipObjMap.put(sh.Id, sh);
        }
        system.debug('=== shipObjMap : '+shipObjMap.size());
        
        system.debug('=== extContractToSummaryMap : '+extContractToSummaryMap.size());
        system.debug('=== extIdToSummaryMap : '+extIdToSummaryMap.size());
        for(String mapKey : extContractToSummaryMap.keySet()){
            
            for(ShipmentCalcUtil.ShipmentDetail eachship : extContractToSummaryMap.get(mapKey))
            {	
                string filterId = eachship.externalContractId;
                if(eachShip.filterById != null){
                    filterId = filterId +'##'+ eachShip.filterById;
                }
                //string filterId = eachship.externalContractId+'##'+eachShip.filterById;
                system.debug('Filter ID : ECS ::'+filterId);
                extContractShip = new External_Contract_Shipment__c();
                extContractShip.Customer__c = eachship.accountId; 
                extContractShip.Order__c = eachship.orderId;
                extContractShip.External_Contract__c = eachship.externalContractId;
                extContractShip.Product__c = eachship.productId;
                extContractShip.Shipment__c = eachship.orderLineItemId;
                extContractShip.Shipment_Summary__c = extIdToSummaryMap.get(filterId).Id;
                system.debug('=== 1 : ');
                extContractShip.Shipment_Number__c = shipObjMap.get(eachship.orderLineItemId).Shipping_Note_Number__c;
                extContractShip.Shipment_Date__c = shipObjMap.get(eachship.orderLineItemId).Shipment_Date__c;
                extContractShip.BVC_Branch__c = shipObjMap.get(eachship.orderLineItemId).Origin_Hub__c;
                extContractShip.Pickup_Date_Time__c = shipObjMap.get(eachship.orderLineItemId).Pickup_Time_Date__c;
                extContractShip.Shipper_PAN__c = shipObjMap.get(eachship.orderLineItemId).Shipper_PAN_TMS__c;
                extContractShip.Consignee_PAN__c = shipObjMap.get(eachship.orderLineItemId).Consignee_PAN_TMS__c;
                extContractShip.Origin_Type__c = shipObjMap.get(eachship.orderLineItemId).Origin_Type__c;
                extContractShip.Origin_Address__c = shipObjMap.get(eachship.orderLineItemId).Origin_Address_Line_1__c == null ? '' : shipObjMap.get(eachship.orderLineItemId).Origin_Address_Line_1__c + ' ' + shipObjMap.get(eachship.orderLineItemId).Origin_Address_Line_2__c == null ? '' : shipObjMap.get(eachship.orderLineItemId).Origin_Address_Line_2__c;
                extContractShip.Origin_City__c = shipObjMap.get(eachship.orderLineItemId).Origin_Address_City__c;
                extContractShip.Origin_State__c = shipObjMap.get(eachship.orderLineItemId).Origin_Address_State__c;
                extContractShip.Origin_PinCode__c = shipObjMap.get(eachship.orderLineItemId).Origin_Address_Pincode__c;
                extContractShip.Destination_Address__c = shipObjMap.get(eachship.orderLineItemId).Destination_Address_Line1__c == null ? '' : shipObjMap.get(eachship.orderLineItemId).Destination_Address_Line1__c + ' ' + shipObjMap.get(eachship.orderLineItemId).Destination_Address_Line_2__c == null ? '' : shipObjMap.get(eachship.orderLineItemId).Destination_Address_Line_2__c;
                extContractShip.Destination_City__c = shipObjMap.get(eachship.orderLineItemId).Destination_Address_City__c;
                extContractShip.Destination_State__c = shipObjMap.get(eachship.orderLineItemId).Destination_Address_State__c;
                extContractShip.Destination_Pincode__c = shipObjMap.get(eachship.orderLineItemId).Destination_Address_Pincode__c;
                extContractShip.Destination_Type__c = shipObjMap.get(eachship.orderLineItemId).Destination_Type__c;
                extContractShip.Gross_Weight_gms__c = shipObjMap.get(eachship.orderLineItemId).Gross_weight_in_Gram__c;
                extContractShip.Net_Weight__c = shipObjMap.get(eachship.orderLineItemId).Net_Weight__c;
                extContractShip.Number_of_Packages__c = shipObjMap.get(eachship.orderLineItemId).Number_of_Packages__c;
                extContractShip.Your_Reference_No__c = shipObjMap.get(eachship.orderLineItemId).Your_Reference_No__c;
                extContractShip.Initiator_Name__c = shipObjMap.get(eachship.orderLineItemId).Initiator_Name__c;
                extContractShip.Initiator_PAN__c = shipObjMap.get(eachship.orderLineItemId).Initiator_PAN__c;
                extContractShip.Initiator_Email__c = shipObjMap.get(eachship.orderLineItemId).Initiator_Email__c;
                extContractShip.Initiator_Mobile__c = shipObjMap.get(eachship.orderLineItemId).Initiator_Mobile__c;
                extContractShip.Confirmation_Reference__c = shipObjMap.get(eachship.orderLineItemId).Confirmation_Reference__c;
                extContractShip.Confirmed_By_Name__c = shipObjMap.get(eachship.orderLineItemId).Confirmed_By_Name__c;
                extContractShip.Confirmed_By_Email_ID__c = shipObjMap.get(eachship.orderLineItemId).Confirmed_By_Email_ID__c;
                extContractShip.Confirmed_By_Mobile__c = shipObjMap.get(eachship.orderLineItemId).Confirmed_By_Mobile__c;
                extContractShip.Liability_Cover_By_BVC__c = shipObjMap.get(eachship.orderLineItemId).Liability_Cover_By_BVC__c;
                extContractShip.Offline_Charges__c = shipObjMap.get(eachship.orderLineItemId).Offline_Charges__c;
                extContractShip.Freight_Charges_c__c = shipObjMap.get(eachship.orderLineItemId).Freight_Charges__c;
                extContractShip.Net_Weight_gms__c = shipObjMap.get(eachship.orderLineItemId).Net_weight_in_Gram__c;
                extContractShip.Net_Weight_UOM__c = shipObjMap.get(eachship.orderLineItemId).Net_Weight_UOM_TMS__c;
                extContractShip.Gross_Weight_UOM__c = shipObjMap.get(eachship.orderLineItemId).Gross_Weight_UOM_TMS__c;
                extContractShip.Gross_Weight__c = shipObjMap.get(eachship.orderLineItemId).Gross_Weight__c;
                extContractShip.Shipment_Type_c__c = shipObjMap.get(eachship.orderLineItemId).Shipment_Type__c;
                extContractShip.Product_Description__c = shipObjMap.get(eachship.orderLineItemId).Product_Description__c;
                extContractShip.Shipment_Value__c = shipObjMap.get(eachship.orderLineItemId).Customer_Product_Value__c;
                extContractShip.Exhibition__c = shipObjMap.get(eachship.orderLineItemId).Exhibition__c;
                //extContractShip.Liability_Charges__c   = integer.ValueOf(shipObjMap.get(eachship.orderLineItemId).Insurance_Liability__c);
                extContractShip.Bill_To_Account__c = shipObjMap.get(eachship.orderLineItemId).Bill_To_Account__c;
                //extContractShip.Billing_Address__c = shipObjMap.get(eachship.orderLineItemId).Billing_Address__c;
                extContractShip.Total_Charge__c = shipObjMap.get(eachship.orderLineItemId).Total_Charge__c;
                
                system.debug('===Before Insert');
                extContShipToBeInserted.add(extContractShip);
            }
        }
        system.debug('===Size of  extContShipToBeInserted : '+extContShipToBeInserted.size());
        if(!extContShipToBeInserted.isEmpty()){
            
            
            Database.SaveResult[] lsr = Database.insert(extContShipToBeInserted,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('ECS with Id :'+result.getId()+' Successfully Inserted');
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('ECS fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
        
    }
    
    public static void createExternalContractShipmentAndSummary(List<ShipmentCalcUtil.ShipmentDetail> shipInput)
    {
        Date currentDate = date.today(); 
        Set<Id> accIds = new Set<Id>();
        Set<Id> extContId = new Set<Id>();
        Set<Id> shipmentIds = new Set<Id>();
        Set<Id> hubIds = new Set<Id>();
        Set<Id> blngEntityIds = new Set<Id>();
        Map<Id,String> ecSummarybyMap = new Map<Id,String>();
		External_Contract_Shipment__c extContractShip;
        
        Map<String,External_Contract_Shipment_Summary__c> extIdToSummaryMap = new Map<String,External_Contract_Shipment_Summary__c>();
        Map<String,List<ShipmentCalcUtil.ShipmentDetail>> extContractToSummaryMap = new Map<String,List<ShipmentCalcUtil.ShipmentDetail>>();
        Map<String,List<ShipmentCalcUtil.ShipmentDetail>> extContSummaryExistMap = new Map<String,List<ShipmentCalcUtil.ShipmentDetail>>();
        Map<String,List<ShipmentCalcUtil.ShipmentDetail>> allextContractToSummaryMap = new Map<String,List<ShipmentCalcUtil.ShipmentDetail>>();
        Map<Id,Shipment__c> shipObjMap = new Map<Id,Shipment__c>();
        
        for(ShipmentCalcUtil.ShipmentDetail eachship : shipInput)
        {
            accIds.add(eachship.accountId);
            extContId.add(eachship.externalContractId);
            shipmentIds.add(eachship.orderLineItemId);
            
            String mapKey = eachship.accountId + '##' + eachship.externalContractId + '##' + eachship.productId;
            if(eachship.filterById != null ){
                mapKey = mapKey+ '##' + eachship.filterById;
            }
            if(extContractToSummaryMap.containsKey(mapKey)){
                extContractToSummaryMap.get(mapKey).add(eachship);
            }else {
                extContractToSummaryMap.put(mapKey, new List<ShipmentCalcUtil.ShipmentDetail>{eachship});
            }
            if(allextContractToSummaryMap.containsKey(mapKey)){
                allextContractToSummaryMap.get(mapKey).add(eachship);
            }else {
                allextContractToSummaryMap.put(mapKey, new List<ShipmentCalcUtil.ShipmentDetail>{eachship});
            }
            //allextContractToSummaryMap.put(mapKey, eachship);
        }
        String query = getSobjectList(shipmentIds);
        List<Shipment__c> lstSObject = Database.query(query);
        system.debug('=== lstSObject : '+lstSObject.size());
        
        for(Shipment__c sh : lstSObject){
            shipObjMap.put(sh.Id, sh);
        }
        Date Shipment_date;
        for(String mapKey : extContractToSummaryMap.keySet()){
            
            for(ShipmentCalcUtil.ShipmentDetail eachship : extContractToSummaryMap.get(mapKey))
            {	
                string filterId = eachship.externalContractId;
                if(eachShip.filterById != null){
                    filterId = filterId +'##'+ eachShip.filterById;
                }
                //string filterId = eachship.externalContractId+'##'+eachShip.filterById;
                system.debug('Filter ID : ECS ::'+filterId);
                extContractShip = new External_Contract_Shipment__c();
                extContractShip.Shipment_Number__c = shipObjMap.get(eachship.orderLineItemId).Shipping_Note_Number__c;
                Shipment_Date = shipObjMap.get(eachship.orderLineItemId).Shipment_Date__c;
            }
        }
	
        //To identify existing Shipment Summary record
        for(External_Contract_Shipment_Summary__c eCSS : [SELECT Id, Name, Customer__c, 
                                                          External_Contract__c, Start_Date__c,
                                                          External_Contract__r.Filter_By__c,
                                                          External_Contract__r.Monthly_Contract__c,
                                                          End_Date__c,Product__c,Origin_Hub__c,
                                                          Billing_Entity__c
                                                          FROM External_Contract_Shipment_Summary__c
                                                          WHERE Customer__c =:accIds AND External_Contract__c =: extContId
                                                          AND Start_Date__c <= :Shipment_Date
                                                          AND End_Date__c >= :Shipment_Date
                                                          AND Lock_this_summary__c = FALSE ])
        {
            system.debug('===To Identify Summary record');
            String filterId='';
            String mapKey = eCSS.Customer__c + '##' + eCSS.External_Contract__c + '##' + eCSS.Product__c ;
            if(ecss.External_Contract__r.Filter_By__c == 'Billing Entity'){
                mapKey = mapKey + '##'+ ecss.Billing_Entity__c;
            }
            else if(ecss.External_Contract__r.Filter_By__c == 'Origin Hub'){
                mapKey = mapKey + '##' + ecss.Origin_Hub__c;
            }
            else{
                mapKey = mapKey; 
            }
            system.debug('Map Key:>'+mapKey);
            if(extContractToSummaryMap.containsKey(mapKey)) //&& ((eCSS.External_Contract__r.Monthly_Contract__c == true && eCSS.Start_Date__c == currentDate.toStartOfMonth() && eCSS.End_Date__c == currentDate.addMonths(1).toStartOfMonth().addDays(-1)) 
                                                           //    || (eCSS.External_Contract__r.Monthly_Contract__c == false && eCSS.Start_Date__c == currentDate && eCSS.End_Date__c == currentDate)))
            {	
                
                
                system.debug('===Summary record found');
                
                if(ecss.External_Contract__r.Filter_By__c == 'Billing Entity'){
                    filterId = ecss.Billing_Entity__c;
                }
                else if(ecss.External_Contract__r.Filter_By__c == 'Origin Hub'){
                    filterId = ecss.Origin_Hub__c;
                }else{
                    //filterId = '';
                }
                String filterById = eCSS.External_Contract__c;
                if(filterId != null && filterId != ''){
                    filterById = filterById + '##' + filterId;
                }
                extContSummaryExistMap.put(mapKey,extContractToSummaryMap.get(mapKey));
                extContractToSummaryMap.remove(mapKey);
                system.debug('extIdToSummaryMap : Key'+filterById+'ECSS:Id'+eCSS.Id);
                extIdToSummaryMap.put(filterById,eCSS );
                
            }
        }
        
        //To create External Contract Shipment Summary record
        if(!extContractToSummaryMap.isEmpty()){
            system.debug('===To create New Summary record');
            External_Contract_Shipment_Summary__c extContSummary;
            Date startDate = System.Date.today().toStartOfMonth(); 
            Date endDate = startDate.addMonths(1).addDays(-1);
            List<External_Contract_Shipment_Summary__c> extContSummToBeInserted = new List<External_Contract_Shipment_Summary__c>();
            for(String keyMap : extContractToSummaryMap.keySet())
            {
                extContSummary = new External_Contract_Shipment_Summary__c(); //extContMap
                extContSummary.Customer__c = extContractToSummaryMap.get(keyMap)[0].accountId;
                extContSummary.Creation_Date__c = system.today();
                extContSummary.External_Contract__c = extContractToSummaryMap.get(keyMap)[0].externalContractId;
                extContSummary.Summary_Type__c = extContractToSummaryMap.get(keyMap)[0].isMonthlyContract == true ? 'Monthly' : 'Daily';
                extContSummary.Start_Date__c = shipObjMap.get(extContractToSummaryMap.get(keyMap)[0].orderLineItemId).Shipment_Date__c.toStartOfMonth();
                extContSummary.End_Date__c = extContSummary.Start_Date__c.addMonths(1).addDays(-1);
                extContSummary.Product__c = extContractToSummaryMap.get(keyMap)[0].productId;
                if(extContractToSummaryMap.get(keyMap)[0].filterById != null
                  ){
                      extContSummary.Billing_Entity__c = extContractToSummaryMap.get(keyMap)[0].blngEntityId;
                      extContSummary.Origin_Hub__c =  extContractToSummaryMap.get(keyMap)[0].originHub;  
                  }
                
                extContSummToBeInserted.add(extContSummary);
                
                system.debug('New ECSS EC Key:'+extContSummary.External_Contract__c +'##'+ extContractToSummaryMap.get(keyMap)[0].filterById);
                
                string key = extContSummary.External_Contract__c ;
                if(extContractToSummaryMap.get(keyMap)[0].filterById != null){
                    key = extContSummary.External_Contract__c +'##' +extContractToSummaryMap.get(keyMap)[0].filterById; 
                }
                extIdToSummaryMap.put(key, extContSummary );
            }
            
            if(!extContSummToBeInserted.isEmpty())
            {
                Database.SaveResult[] lsr = Database.insert(extContSummToBeInserted,false);
                for(Database.SaveResult result : lsr){
                    if(result.isSuccess()){
                        system.debug('ECSS with Id :'+result.getId()+' Successfully Inserted');
                    }
                    else{
                        for(Database.Error err : result.getErrors()){
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ECSS fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        system.debug('===extContractToSummaryMap : '+extContractToSummaryMap);
        system.debug('===extIdToSummaryMap : '+extIdToSummaryMap);
        //To create External Contract Shipment record
        createExternalContractShipment(allextContractToSummaryMap, extIdToSummaryMap, shipmentIds);
        
        
    }
    
    //Called from ShipmentUtil
    public static Map<String, List<ShipmentCalcUtil.ShipmentDetail>> checkExternalContract(List<ShipmentCalcUtil.ShipmentDetail> shipInput){
        set<Id> accountIds =new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Boolean isExtContractFound = false;
        Map<String, List<ShipmentCalcUtil.ShipmentDetail>> shipInputMap = new Map<String, List<ShipmentCalcUtil.ShipmentDetail>>();
        List<ShipmentCalcUtil.ShipmentDetail> shipInputList;
        
        for(ShipmentCalcUtil.ShipmentDetail eachship: shipInput){
            accountIds.add(eachship.accountId);
            productIds.add(eachship.productId);
        }
        
        List<External_Contract__c> extContractList = [Select Id, Customer__c, Product__c, Activated_By__c, Activation_Date__c,
                                                      Active__c, Charge_UOM__c, Customer_Product_Category__c, Destination_City__c,
                                                      ST_Destination_City__c,ST_Origin_City__c,Filter_By__c,
                                                      Exhibition__c, Monthly_Contract__c, Monthly_Fee__c, Number_Of_Shipment__c,
                                                      Origin_City__c, Shipment_Charge_Beyond_Limit__c
                                                      FROM External_Contract__c
                                                      WHERE Customer__c IN : accountIds AND Product__c IN :productIds
                                                      AND Active__c = true ORDER BY CreatedDate ASC];
        
        
        for(ShipmentCalcUtil.ShipmentDetail eachship: shipInput){
            
            isExtContractFound = false;
            //shipInputList = new List<ShipmentCalcUtil.ShipmentDetail>();
            
            for(External_Contract__c fetchrec : extContractList)
            {   
                System.debug('Ship ProductId ===> '+eachship.productId+ ' EC ProductId ===> '+fetchrec.Product__c);
                System.debug('Ship accountId ===> '+eachship.accountId+ ' EC accountId ===> '+fetchrec.Customer__c);
                System.debug('Ship Origin ===> '+eachship.origin+ ' EC Origin ===> '+fetchrec.ST_Origin_City__c);
                System.debug('Ship Destination ===> '+eachship.destination+ ' EC Destination ===> '+fetchrec.ST_Destination_City__c);
                system.debug('Ship Filter Id:>'+eachship.filterById);
                if(eachship.productId == fetchrec.Product__c && eachship.accountId == fetchrec.Customer__c
                   && ((fetchrec.ST_Origin_City__c== 'All' && fetchrec.ST_Destination_City__c=='All') || (fetchrec.ST_Origin_City__c== NULL && fetchrec.ST_Destination_City__c==NULL) || (eachship.origin == fetchrec.ST_Origin_City__c && eachship.destination == fetchrec.ST_Destination_City__c))
                   && ((fetchrec.Exhibition__c == null) || (eachship.customerProdCategory == fetchrec.Customer_Product_Category__c && eachship.exhibitionId == fetchrec.Exhibition__c)))
                {
                    isExtContractFound = true;
                    eachship.ExternalContractId = fetchrec.Id;
                    eachship.isMonthlyContract = fetchrec.Monthly_Contract__c;
                    if(fetchrec.Filter_By__c == 'Origin Hub'){
                        eachShip.filterById = eachShip.originHub;
                    }
                    else if(fetchrec.Filter_By__c == 'Billing Entity'){
                        eachShip.filterById = eachShip.blngEntityId;
                    }else{
                        
                    }
                    
                    //To segregate the Shipment input coming from Community
                    if(eachship.orderLineItemId <> null && eachship.orderLineItemId <> '')
                    {
                        if(!shipInputMap.containsKey('ExternalContract')){
                            //shipInputList.add(eachship);
                            shipInputMap.put('ExternalContract',new List<ShipmentCalcUtil.ShipmentDetail>{eachship});
                            //shipInputMap.put('ExternalContract',shipInputList);
                        }
                        else if(shipInputMap.containsKey('ExternalContract')){
                            shipInputMap.get('ExternalContract').add(eachship);
                        }
                        
                        
                    }
                    //To segregate the Shipment input coming from Salesforce CPQ
                    else if(eachship.orderLineItemId == null || eachship.orderLineItemId == '')
                    {
                        //isExtContractFound = true;
                        if(!shipInputMap.containsKey('CommunityExtContract')){
                            shipInputMap.put('CommunityExtContract',new List<ShipmentCalcUtil.ShipmentDetail>{eachship});
                            
                        }
                        else if(shipInputMap.containsKey('CommunityExtContract')){
                            shipInputMap.get('CommunityExtContract').add(eachship);
                        }
                        
                    }
                    
                }
            }//End Of Inner Loop
            
            if(isExtContractFound == false){
                //eachship.ExternalContractId = ;
                eachship.isMonthlyContract = false;
                if(!shipInputMap.containsKey('NOTFOUND')){
                    shipInputMap.put('NOTFOUND',new List<ShipmentCalcUtil.ShipmentDetail>{eachship});
                    //shipInputList.add(eachship);
                    //shipInputMap.put('CommunityExtContract',shipInputList);
                }
                else if(shipInputMap.containsKey('NOTFOUND')){
                    shipInputMap.get('NOTFOUND').add(eachship);
                }
                
            }
            
            
        }//Outer loop
        
        return shipInputMap;
        
    }//End of method
    
}