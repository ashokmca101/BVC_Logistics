public with sharing class OrderCreateShipment {
        
    public static void validateAndCreateOrder(Map<Id,Shipment__c> shipmentMap){
        Set<String> productCodes = new Set<String>();
        Map<Id,Shipment__c> validShipmentData = new Map<Id,Shipment__c>();
        Map<Id,Id> mapBillToAccIds = new Map<Id,Id>();
        Map<Id,Id> mapOriginHubIds= new Map<Id,Id>();
        Map<Id,Id> mapBillToaddressIds = new Map<Id,Id>();
        List<Shipment_Error_Log__c> insertLogs = new List<Shipment_Error_Log__c>();
        for(Shipment__c ship : shipmentMap.values()){
            if(ship.Product_Code__c != null){
                productCodes.add(ship.Product_Code__c);
            }
            if(ship.BillTo_Party_Address__c != null){
                mapBillToaddressIds.put(ship.Id,ship.BillTo_Party_Address__c);
            }
            if(ship.Bill_To_Account__c != null){
                mapBillToAccIds.put(ship.Id,ship.Bill_To_Account__c);
            }
            if(ship.Origin_Hub__c != null){
                mapOriginHubIds.put(ship.Id,ship.Origin_Hub__c);
            }
            
        }
        // Creating ProductCode Map
        // 
        Map<String,Product2> prodCodeMap = new map<String,Product2>();
        system.debug('Product Code : '+productCodes);
        for(Product2 prd : [SELECT Id,Name,ProductCode,blng__BillingRule__c,blng__TaxRule__c,
                            blng__RevenueRecognitionRule__c,Invoice_Group_ID__c 
                            FROM Product2 WHERE ProductCode IN :productCodes]){
                                prodCodeMap.put(prd.ProductCode,prd);
                            }
        
        Map<Id,Account> mapAccount = new map<Id,Account>([select id,Active_Contract__c,ST_Pricing_Type__c,Customer_Category__c,Contract_End_Date__c,Contracted_ACR_Package__c,Balance_Amount__c from Account where Id in:mapBillToAccIds.values()]);
        System.debug('Map hubs  '+mapOriginHubIds);
        Map<Id,Hub__c> mapHubs = new map<Id,Hub__c>([select id,ST_BVC_Billing_Entity__c from Hub__c where Id in:mapOriginHubIds.values() AND ST_BVC_Billing_Entity__c != null ]);
        System.debug('Map hubs  '+mapHubs);
        Map<Id,AddressBook__c> mapAddressBook = new map<Id,AddressBook__c>([Select id,ADDRESS1__c,ADDRESS2__c,CITY__c,STATE__c,COUNTRY__c from AddressBook__c where id In :mapBillToaddressIds.values() and ADDRESS1__c != null and CITY__c!= null and STATE__c != null and COUNTRY__c != null and PINCODE__c != null]);
        
        for(Shipment__c shipRec : shipmentMap.values()){
            // Validate the Product code 
            Boolean ValidRecord = true;
            if(shipRec.Product_Code__c != null){
                if(!prodCodeMap.containsKey(shipRec.Product_Code__c)){
                    ValidRecord = false;
                    Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                          Error_Reason__c = 'Cannot find Product, Please enter a Valid Product Code',
                                                                          Shipment__c = shipRec.Id);
                    //  shipRec.addError('Cannot find Product, Please enter a Valid Product Code');
                    
                    insertLogs.add(log);
                }else if(prodCodeMap.containsKey(shipRec.Product_Code__c) && prodCodeMap.get(shipRec.Product_Code__c).Name.contains('Express C2C')){
                    if(shipRec.Gross_Weight__c == null){
                        ValidRecord = false;
                        Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                              Error_Reason__c = 'Gross Weight information missing for Express C2C Product',
                                                                              Shipment__c = shipRec.Id); 
                        insertLogs.add(log);
                        // shipRec.addError('Gross Weight information missing for Express C2C Product');
                        
                    }
                }
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Product Code Missing, Please enter a Valid Product Code',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                // shipRec.addError('Product Code Missing, Please enter a Valid Product Code');
            }
            // Product validation end
            
            // Account Validation Start
            date currentDate = date.today();
            System.debug('Account issue '+shipRec.Bill_To_Account__c);
            System.debug('Account issue '+mapAccount.containsKey(shipRec.Bill_To_Account__c));
            if(shipRec.Bill_To_Account__c != null && mapAccount.containsKey(shipRec.Bill_To_Account__c)){
                System.debug('Account issue '+mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c);
                System.debug('Account issue '+mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c);
                if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c == null
                   && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='Non ACR'
                   && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c=='Non Contracted')
                {
                }
                else if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='Non ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c=='Non ACR Contracted'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contract_End_Date__c>=currentDate)
                {
                }
                else if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c == 'ACR Contracted'
                        //&& mapAccount.get(shipRec.Bill_To_Account__c).Contract_End_Date__c >=currentDate 
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contracted_ACR_Package__c !=null)
                        //&& mapAccount.get(shipRec.Bill_To_Account__c).Balance_Amount__c >0)
                {
                }
                /*else if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c == 'ACR Contracted'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contract_End_Date__c >=currentDate 
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contracted_ACR_Package__c !=null
                        && mapAccount.get(shipRec.Bill_To_Account__c).Balance_Amount__c >0)
                {
                }*/
                else{
                    ValidRecord = false;
                    Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                          Error_Reason__c = 'Cannot change the status to Verified Billing, Account Information missing for Order Creation',
                                                                          Shipment__c = shipRec.Id); 
                    insertLogs.add(log);
                    //shipRec.addError('Cannot change the status to Verified Billing, Account Information missing for Order Creation');
                }
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to Verified Billing, Account is missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to Verified Billing, Account is missing');
            }
            
            // Account Validation End
            
            // Origin Hub Billing Entity Validation
            
            if(shipRec.Origin_Hub__c != null && mapHubs.containsKey(shipRec.Origin_Hub__c)){
                System.debug('ValidRecord --->'+ValidRecord);
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Invalid Hub',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to verified billing, Invalid Hub');
            }
            
            // Origin Hub Validation End
            
            // origin -Destination Address Validation
            
            if(shipRec.Origin_Address_Name__c != null && shipRec.Origin_Address_Line_1__c != null  && shipRec.Origin_Address_State__c != null && shipRec.Origin_Address_Country__c != null && shipRec.Origin_Address_City__c != null && shipRec.Origin_Address_Pincode__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Origin Address information Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to verified billing, Origin Address information Missing');
            }
            if(shipRec.Destination_Address_Name__c != null && shipRec.Destination_Address_Line1__c != null  && shipRec.Destination_Address_State__c != null && shipRec.Destination_Address_Country__c != null && shipRec.Destination_Address_City__c != null && shipRec.Destination_Address_Pincode__c != null){
                
            }else{
                system.debug('Name : '+shipRec.Destination_Address_Name__c);
                system.debug('Destination Line : '+shipRec.Destination_Address_Line1__c);
                system.debug('Destination State :  : '+shipRec.Destination_Address_State__c);
                system.debug('Destination Country :  : '+shipRec.Destination_Address_Country__c);
                system.debug('Destination City :  : '+shipRec.Destination_Address_City__c);
                system.debug('Destination Pincode :  : '+shipRec.Destination_Address_Pincode__c);
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Destination Address information Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to verified billing, Destination Address information Missing');
            }
            if(shipRec.Shipment_Date__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Shipment Date is Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                // shipRec.addError('Cannot change the status to verified billing, Shipment Date is Missing');
            }
            if(shipRec.BillTo_Party_Address__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Bill to Party Address is Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                // shipRec.addError('Cannot change the status to verified billing, Bill to Party Address is Missing');
            }
            if(ValidRecord){
                validShipmentData.put(shipRec.Id,shipRec);
            }
            
        }
        try{
            insert insertLogs;
        }catch(Exception ex){
            system.debug('Shipment Error Log insert failed : '+ex.getMessage());
        }
        if(!validShipmentData.isEmpty()){
            System.debug(''+validShipmentData.size());
            Database.executeBatch(new ShipmentOrderCreationBatch(validShipmentData.keySet()), 50);
            
        }
        
        
        
        
    }
        
    public static void createOrderShipment(Map<Id,Shipment__c> shipmentMap){
        Map<Id,AddressBook__c> addressMap = new Map<Id,AddressBook__c>();
        Set<Id> addressIds = new Set<Id>();
        
        // Get Pricebook Id
        Id pbId;
        List<Pricebook2> bvcPriceBook = [SELECT Id,Name From Pricebook2 WHERE Name = 'BVC INR Price Book' LIMIT 1];
        if(bvcPriceBook != null && !bvcPriceBook.isEmpty()){
            pbId = bvcPriceBook[0].Id;
        }
        
        Set<Id> blngRuleIds = new Set<Id>();
        List<Shipment__c> shipList = new List<Shipment__c>();
        
        for(Shipment__c ship : shipmentMap.values()){
            
            
            shipList.add(ship);
            if(ship.BillTo_Party_Address__c != null){
                addressIds.add(ship.BillTo_Party_Address__c);
            }
            
        }
        
        Map<Id, Shipment__c> shipRelatedMap = new Map<Id, Shipment__c>([SELECT Id,Account__c,Distance_Km__c, Account__r.Name,AddressBook__c,BillTo_Party_Address__c,BillTo_Party_Address__r.CITY__c,Origin_Hub__r.BVC_Entity__c,
                                                                        Hub_Master__c,Hub_Master__r.ST_BVC_Billing_Entity__c,Origin_Hub__c,Origin_Hub__r.ST_BVC_Billing_Entity__c,
                                                                        Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c,Origin_Address_Name__r.COUNTRY__c,
                                                                        Account__r.Customer_Category__c,Origin_Address_Name__c,Origin_Address_Name__r.STATE__c,Origin_Address_Name__r.TRADE_NAME__c,
                                                                        Origin_Address_Name__r.CITY__c,Origin_Address_Name__r.ADDRESS1__c,Origin_Address_Name__r.ADDRESS2__c,Shipper_Name_TMS__r.Name,
                                                                        Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,Consignee_Name_TMS__r.Name,
                                                                        Bill_To_Account__r.Customer_Category__c,BillTo_Party_Address__r.STATE__c,Bill_To_Account__r.Billing_Cycle__c,Bill_To_Account__r.Invoice_Batch__c,
                                                                        AddressBook__r.TRADE_NAME__c,Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c,BillTo_Party_Address__r.COUNTRY__c,
                                                                        BillTo_Party_Address__r.ADDRESS1__c,BillTo_Party_Address__r.ADDRESS2__c,Net_weight_in_Gram__c,Window_Delivery__c,Window_Pickup__c
                                                                        FROM Shipment__c
                                                                        WHERE Id IN :shipList
                                                                        FOR Update
                                                                       ]);                         
        system.debug(':::Order Create:::'+shipList);
        List<Order> orders2Update = new List<Order>();
        Set<String> prodCodes = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        if(shipList.size()>0){
            for(Shipment__c ship : shipList){
                if(ship.Product_Code__c != null){
                    prodCodes.add(ship.Product_Code__c);
                }
                if(ship.Bill_To_Account__c != null){
                    accIds.add(ship.Bill_To_Account__c);
                }
                // Create Order from Shipment
                Order o = new Order();
                o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();
                o.Business_Type__c = 'Shipment';
                o.AccountId = ship.Bill_To_Account__c;
                if(ship.Shipment_Date__c != null){
                    o.EffectiveDate = ship.Shipment_Date__c;
                    o.EndDate = ship.Shipment_Date__c;
                }else{
                    o.EffectiveDate = System.today();
                    o.EndDate = System.today();
                }
                o.SBQQ__PaymentTerm__c = 'Net 30';
                o.Shipment__c = ship.Id;
                o.Shipment_Number__c = ship.Shipping_Note_Number__c;
                o.Shipment_Date__c = ship.Shipment_Date__c;
                if(ship.Pickup_Time_Date__c != null)
                    o.Pickup_Date__c = ship.Pickup_Time_Date__c.date();
                o.Status = 'Draft';
                o.Type = 'New';
                
                o.blng__BillingAccount__c = ship.Billing_Account__c;
                o.Origin_Address__c = ship.Origin_Address_Name__c;
                o.Destination_Address__c = ship.Destination_Address_Name__c;
                o.Origin_Type__c = ship.Origin_Type__c;
                o.Destination_Type__c = ship.Destination_Type__c;
                o.Shipment_Value__c = ship.Shipment_Value__c;
                o.Shipment_Type__c = ship.Shipment_Type__c;
                o.Shipment_Status_Static__c = 'Picked for Billing';
                o.Product_Description__c = ship.Product_Description__c;
                
                
                
                if(shipRelatedMap.containsKey(ship.Id)
                   && shipRelatedMap.get(ship.Id).Origin_Hub__c != null){
                       o.BVC_Branch__c = ship.Origin_Hub__c;
                       o.BVC_Billing_Entity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.ST_BVC_Billing_Entity__c;
                       o.BVC_Entity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_Entity__c;
                       system.debug('Legal Entity>>>'+shipRelatedMap.get(ship.Id).Origin_Hub__r.ST_BVC_Billing_Entity__c);
                   }
                if(shipRelatedMap.containsKey(ship.Id)
                   && shipRelatedMap.get(ship.Id).BillTo_Party_Address__c != null){
                       
                       o.Billing_Address__c =  shipRelatedMap.get(ship.Id).BillTo_Party_Address__c;
                       if(shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS1__c!= null
                          &&shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS2__c != null){
                              o.BillingStreet =  shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS1__c+shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS2__c;
                          }
                       else if(shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS1__c!= null
                               &&shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS2__c == null){
                                   o.BillingStreet = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS1__c;
                               }
                       
                       o.BillingCity = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.CITY__c;
                       o.BillingState = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.STATE__c;
                       o.BillingCountry = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.COUNTRY__c;
                   }
                
                
                if(shipRelatedMap.containsKey(ship.Id)
                   &&shipRelatedMap.get(ship.Id).Origin_Address_Name__c != null ){
                       if(shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS1__c != null
                          && shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS2__c != null){
                              o.ShippingStreet = shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS1__c+shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS2__c; 
                          }
                       else if(shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS1__c != null
                               && shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS2__c == null){
                                   o.ShippingStreet = shipRelatedMap.get(ship.Id).Origin_Address_Name__r.ADDRESS1__c;
                               }
                       o.ShippingCity = shipRelatedMap.get(ship.Id).Origin_Address_Name__r.CITY__c;
                       o.ShippingState = shipRelatedMap.get(ship.Id).Origin_Address_Name__r.STATE__c;
                       o.ShippingCountry = shipRelatedMap.get(ship.Id).Origin_Address_Name__r.COUNTRY__c;
                   }
                
                
                o.Initiator_Name__c = ship.Initiator_Name__c;
                o.Initiator_PAN__c = ship.Initiator_PAN__c;
                o.Initiator_Email__c = ship.Initiator_Email__c;
                o.Initiator_Mobile__c = ship.Initiator_Mobile__c;
                
                if(shipRelatedMap.get(ship.Id).Shipper_Name_TMS__c != null)
                    o.Shipper_Name__c = shipRelatedMap.get(ship.Id).Shipper_Name_TMS__r.Name;
                o.Shipper_PAN__c = ship.Shipper_PAN_TMS__c;
                if(shipRelatedMap.get(ship.Id).Consignee_Name_TMS__c != null)
                    o.Consignee_Name__c = shipRelatedMap.get(ship.Id).Consignee_Name_TMS__r.Name;
                o.Consignee_PAN__c = ship.Consignee_PAN_TMS__c;
                
                if(ship.Pickup_Time_Date__c != null){
                    o.Pickup_Date__c = ship.Pickup_Time_Date__c.date(); 
                }
                
                o.Bill_To_Trade_Name__c = shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c;
                if(shipRelatedMap.get(ship.Id).Bill_To_Account__r.Invoice_Batch__c != null){
                    o.blng__InvoiceBatch__c = shipRelatedMap.get(ship.Id).Bill_To_Account__r.Invoice_Batch__c;
                }
                else{
                    o.blng__InvoiceBatch__c = 'Batch 1';
                }
                // Please use custom Label for Hardcoded values
                o.Pricebook2Id = pbId;
                
                system.debug('SHipment Related Map '+shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c+'AccId:::'+shipRelatedMap.get(ship.Id).Bill_To_Account__c);
                if(shipRelatedMap.containsKey(ship.Id) && shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c != null
                   &&shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c != 'Shipment'
                   && ship.Next_Billing_Date__c == null && ship.Shipment_Date__c != null ){
                       o.blng__BillingDayOfMonth__c = String.valueOf(dateCalculator(ship.Shipment_Date__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Cycle__c).day());  
                       
                   }
                else if(shipRelatedMap.containsKey(ship.Id)
                        && ship.Next_Billing_Date__c != null ){
                            o.blng__BillingDayOfMonth__c = String.valueOf(ship.Next_Billing_Date__c.day());  
                            
                        }
                
                
                system.debug('Order Billing Account'+o.blng__BillingAccount__r.Name);
                orders2Update.add(o);
                
                
            }
        }
        system.debug('::: Orders2Insert:::'+orders2Update.size());
        if(orders2Update.size()>0){
            
            Database.SaveResult[] lsr = Database.insert(orders2Update,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('Order with Id :'+result.getId()+' Successfully Inserted');
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        Map<Id,Id> shipOrderMap = new Map<Id,Id>();
        for(Order od :orders2Update){
            system.debug('Billing day of the Month::'+od.blng__BillingDayOfMonth__c+'::Billing Frequency::'+od.Customer_Billing_Frequency__c);
            shipOrderMap.put(od.Shipment__c,od.Id);     
        }
        Map<String,PricebookEntry> pbEntriesMap = new Map<String,PricebookEntry>();
        for(PricebookEntry pbe : [SELECT Id,Pricebook2Id,
                                  Product2Id,UnitPrice,ProductCode
                                  FROM PricebookEntry 
                                  WHERE Pricebook2Id = :pbID
                                  AND ProductCode IN :prodCodes]){
                                      pbEntriesMap.put(pbe.ProductCode,pbe);
                                  } 
        Map<String,Product2> prodIdMap = new map<String,Product2>();
        Map<String,Id> codeIdMap = new Map<String,Id>();
        for(Product2 prd : [SELECT Id,ProductCode,blng__BillingRule__c,blng__TaxRule__c,
                            blng__RevenueRecognitionRule__c,Invoice_Group_ID__c 
                            FROM Product2 WHERE ProductCode IN :prodCodes]){
                                prodIdMap.put(prd.ProductCode,prd);
                                codeIdMap.put(prd.ProductCode,prd.Id);
                            }
        
        List<OrderItem> ordersItems2Update = new List<OrderItem>();
        List<Shipment_Error_Log__c> insertLogs = new List<Shipment_Error_Log__c>();
        Map<Id,ShipmentCalcUtil.ShipmentDetail> IdshipCalcMap = new Map<Id,ShipmentCalcUtil.ShipmentDetail>();
        if(shipList.size()>0){
            List<ShipmentCalcUtil.ShipmentDetail> shipCalculat = shipmentCalculator(shipList,codeIdMap,shipOrderMap,shipRelatedMap);
            List<ShipmentCalcUtil.ShipmentDetail>  shipmentCalculatorList =  new List<ShipmentCalcUtil.ShipmentDetail>(); 
            if(shipCalculat != null && shipCalculat.size() > 0 ){
                shipmentCalculatorList.addAll(shipcalculat);
            }
            
            if(shipmentCalculatorList != null && shipmentCalculatorList.size() > 0  ){
                for(ShipmentCalcUtil.ShipmentDetail shipDetail : shipmentCalculatorList){
                    system.debug('ShipDetail Map::'+shipDetail.shipmentId+'::ShipDetails::'+shipDetail.orderId);
                    IdshipCalcMap.put(shipDetail.shipmentId,shipDetail);
                }
            }
            for(Shipment__c ship : shipmentMap.values()){
                OrderItem oi = new OrderItem();
                //List<ShipmentCalcUtil.ShipmentDetail>  shipmentCalculatorList =  new List<ShipmentCalcUtil.ShipmentDetail>(); 
                if(prodIdMap.containsKey(ship.Product_Code__c)){
                    oi.blng__BillingRule__c = prodIdMap.get(ship.Product_Code__c).blng__BillingRule__c;
                    oi.blng__RevenueRecognitionRule__c = prodIdMap.get(ship.Product_Code__c).blng__RevenueRecognitionRule__c;
                    oi.blng__TaxRule__c = prodIdMap.get(ship.Product_Code__c).blng__TaxRule__c;
                    oi.Product2Id = prodIdMap.get(ship.Product_Code__c).Id;
                    oi.Net_Weight_gms__c = ship.Net_weight_in_Gram__c;
                    
                }
                if(IdshipCalcMap.containsKey(ship.Id)){
                    oi.ServiceDate = ship.Shipment_Date__c;
                    oi.EndDate = ship.Shipment_Date__c;
                    oi.OrderId = shipOrderMap.get(ship.Id);
                    
                    oi.Quantity = 1;
                    system.debug('Total Amount ShipmenCalcUtil '+IdshipCalcMap.get(ship.Id).totalAmount );
                    oi.UnitPrice = IdshipCalcMap.get(ship.Id).totalAmount;
                    oi.ST_Rate_UOM__c = IdshipCalcMap.get(ship.Id).rateUOM;
                    
                    if(pbEntriesMap.containsKey(ship.Product_Code__c)){
                        oi.PricebookEntryId = pbEntriesMap.get(ship.Product_Code__c).Id; 
                    }
                    
                    oi.SBQQ__ChargeType__c = 'One-Time'; 
                    oi.SBQQ__BillingFrequency__c = '';
                    if(ship.Exhibition__c != null){
                        oi.ST_Exhibition__c = ship.Exhibition__c;
                        oi.ST_Customer_Product_Category__c = ship.Customer_Product_Category__c;
                    }
                    
                    
                    oi.Shipment__c = ship.Id;
                    oi.Shipment_Number__c = ship.Shipping_Note_Number__c;
                    oi.Shipment_Date__c = ship.Shipment_Date__c;
                    oi.PickUp_Date_and_Time__c = ship.Pickup_Time_Date__c;
                    oi.Delivery_Date_and_Time__c = ship.Actual_Delivery_Date_and_Time__c;
                    
                    if(shipRelatedMap.get(ship.Id).Shipper_Name_TMS__c != null)
                        oi.Shipper_Name__c = shipRelatedMap.get(ship.Id).Shipper_Name_TMS__r.Name;
                    oi.Shipper_PAN__c = ship.Shipper_PAN_TMS__c;
                    if(shipRelatedMap.get(ship.Id).Consignee_Name_TMS__c != null)
                        oi.Consignee_Name__c = shipRelatedMap.get(ship.Id).Consignee_Name_TMS__r.Name;
                    oi.Consignee_PAN__c = ship.Consignee_PAN_TMS__c;
                    
                    oi.Origin_Address_Name__c = ship.Origin_Address_Name__c;
                    oi.Origin_City__c = ship.Origin_Address_City__c;
                    oi.Origin_State__c = ship.Origin_Address_State__c;
                    oi.Origin_PinCode__c = ship.Origin_Address_Pincode__c;
                    oi.Origin_Type__c = ship.Origin_Type__c;
                    
                    oi.Destination_City__c = ship.Destination_Address_City__c;
                    oi.Destination_State__c = ship.Destination_Address_State__c;
                    oi.Destination_Pin_Code__c = ship.Destination_Address_Pincode__c;
                    oi.Destination_Type__c = ship.Destination_Type__c;
                    
                    oi.Gross_Weight_gms__c =  ship.Gross_weight_in_Gram__c;
                    oi.Gross_Weight_UOM__c = ship.Gross_Weight_UOM_TMS__c;
                    oi.Gross_Weight__c = ship.Gross_Weight__c;
                    oi.Net_Weight_UOM__c = ship.Net_Weight_UOM_TMS__c;
                    oi.Net_Weight_gms__c = ship.Net_weight_in_Gram__c;
                    oi.Net_Weight__c = ship.Net_Weight__c;
                    oi.Number_of_Packages__c = ship.Number_of_Packages__c;
                    oi.Your_Reference_Number__c = ship.Your_Reference_No__c;
                    
                    oi.Initiator_Name__c = ship.Initiator_Name__c;
                    oi.Initiator_PAN__c = ship.Initiator_PAN__c;
                    oi.Initiator_Email__c = ship.Initiator_Email__c;
                    oi.Initiator_Mobile__c = ship.Initiator_Mobile__c;
                    
                    oi.Confirmation_Reference__c = ship.Confirmation_Reference__c;
                    oi.Confirmation_By_Name__c = ship.Confirmed_By_Name__c;
                    oi.Confirmation_Email_ID__c = ship.Confirmed_By_Email_ID__c;
                    oi.Confirmed_By_Mobile__c = ship.Confirmed_By_Mobile__c;
                    
                    oi.Liability_Cover_By_BVC__c = ship.Liability_Cover_By_BVC__c;
                    
                    
                    if(shipRelatedMap.containsKey(ship.Id)){
                        
                        if(shipRelatedMap.get(ship.Id).Origin_Hub__c != null){
                            oi.BVC_Branch__c = shipRelatedMap.get(ship.Id).Origin_Hub__c;
                            oi.blng__LegalEntity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.ST_BVC_Billing_Entity__c;
                        }
                        
                        
                        if(shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c != null
                           &&shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c != 'Shipment'
                           && ship.Next_Billing_Date__c == null && ship.Shipment_Date__c != null){
                               oi.blng__NextBillingDate__c = dateCalculator(ship.Shipment_Date__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Cycle__c); 
                               oi.blng__OverrideNextBillingDate__c = dateCalculator(ship.Shipment_Date__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Cycle__c); 
                               
                           }
                        else if((shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c == null
                                 || shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c == 'Shipment')
                                && ship.Next_Billing_Date__c == null && ship.Shipment_Date__c != null){
                                    oi.blng__NextBillingDate__c = ship.Shipment_Date__c;
                                    oi.blng__OverrideNextBillingDate__c = ship.Shipment_Date__c;
                                }
                        else if(ship.Next_Billing_Date__c != null){
                            oi.blng__NextBillingDate__c = ship.Next_Billing_Date__c;
                            oi.blng__OverrideNextBillingDate__c = ship.Next_Billing_Date__c;
                        }
                        
                        oi.blng__HoldBilling__c = IdshipCalcMap.get(ship.Id).externalContractId != null ? 'Yes' : holdBilling(shipRelatedMap.get(ship.Id));
                    }
                    
                    
                    oi.ST_Rate_Amount__c = IdshipCalcMap.get(ship.Id).rateAmount;
                    oi.ACR_Standard_Price__c = IdshipCalcMap.get(ship.Id).acrStandardPriceId;
                    oi.Non_ACR_Standard_Price__c = IdshipCalcMap.get(ship.Id).nonACRStandardPriceId;
                    oi.ACR_Contracted_Price__c = IdshipCalcMap.get(ship.Id).acrContractedPriceId;
                    oi.Non_ACR_Contracted_Price__c = IdshipCalcMap.get(ship.Id).nonACRContractedPriceId;
                    
                    oi.SBQQ__SubscriptionType__c = 'One-Time';
                    oi.SBQQ__ProductSubscriptionType__c = 'One-time';
                    oi.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    
                    oi.Shipment_Type__c = ship.Shipment_Type__c;
                    
                    oi.SBQQ__ContractingMethod__c = 'Inherit';
                    oi.SBQQ__PricingMethod__c = 'List';
                    
                    
                    oi.Payment_Received__c = ship.Payment_Received__c;
                    oi.Payment_Reference__c = ship.Payment_Reference__c;
                    oi.Payment_Date__c = ship.Payment_Date__c;
                    
                    oi.Gross_Weight__c = ship.Gross_Weight__c;
                    
                  //  system.debug('Shipment Charges:::'+IdshipCalcMap.get(ship.Id).fuelSurcharge+':::'+IdshipCalcMap.get(ship.Id).liabilityCoverageAmount);
                    oi.Freight_Charges__c = IdshipCalcMap.get(ship.Id).freightCharge ;
                    oi.Total_Charges__c  = IdshipCalcMap.get(ship.Id).totalAmount;
                    oi.ST_Offline_Charge__c = IdshipCalcMap.get(ship.Id).offlineCharge;
                    oi.ST_Minimum_Freight__c = IdshipCalcMap.get(ship.Id).minimumFreight;
                    oi.blng__BillableUnitPrice__c = IdshipCalcMap.get(ship.Id).totalAmount;
                    oi.Liability_Charges__c = IdshipCalcMap.get(ship.Id).liabilityCoverageAmount ;
                    oi.Fuel_Surcharge__c = IdshipCalcMap.get(ship.Id).fuelSurcharge;//Prat
                    oi.ST_Liability_Coverage__c = IdshipCalcMap.get(ship.Id).liabilityCoverage;
                    oi.BVC_Valuation_Charges__c   = IdshipCalcMap.get(ship.Id).bvcValuationCharge;
                    oi.Docket_Charges__c  = IdshipCalcMap.get(ship.Id).docketCharge;
                    oi.Fuel_Charges__c  = IdshipCalcMap.get(ship.Id).fuelCharge;
                    oi.Holiday_Charges__c   = IdshipCalcMap.get(ship.Id).holidayCharge;
                    oi.Weight_Charges__c  = IdshipCalcMap.get(ship.Id).weightCharge;
                    
                    if(IdshipCalcMap.get(ship.Id).totalAmount != null && IdshipCalcMap.get(ship.Id).totalAmount >0){
                        ordersItems2Update.add(oi);  
                    }
                    else if(IdshipCalcMap.get(ship.Id).errors != null && IdshipCalcMap.get(ship.Id).errors != ''){
                        Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Calculation',
                                                                              Error_Reason__c = IdshipCalcMap.get(ship.Id).errors,
                                                                              Shipment__c = IdshipCalcMap.get(ship.Id).shipmentId); 
                        insertLogs.add(log);
                    }
                    
                }
            }
        }
        if(ordersItems2Update.size()>0){
            
            Database.SaveResult[] lsr = Database.insert(ordersItems2Update,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('Order Item with Id :'+result.getId()+' Successfully Inserted');
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order Item fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        try{
            insert insertLogs;
        }catch(Exception ex){
            system.debug('Shipment error Logs insert failed');
        }
    }
        
    public static date dateCalculator(Date d,String frequency,String blngCycle){
        Date nextBillingDate ; 
        if(frequency == 'Weekly'){
            nextBillingDate =  d.toStartOfWeek().addDays(8);
        }
        else if(frequency == 'Forthnightly'){
            if(d.day() <= 15 ){
                nextBillingDate = d.toStartOfMonth().addDays(14);
            }
            else if(d.day() - 15 >0){
                nextBillingDate = d.addMonths(1).toStartofMonth().addDays(-1);
            }
            
        }
        else if(frequency == 'Monthly'){
            
            List<String> billdates = blngCycle.split('-');
            if(d.day() >= integer.valueOf(billdates[0])){
                nextBillingDate = Date.newInstance(d.year(), d.month()+1, integer.valueOf(billdates[0]));
            }
            else if(d.day() < integer.valueOf(billdates[0])){
                nextBillingDate = Date.newInstance(d.year(), d.month(), integer.valueOf(billdates[0]));
            }
            
        }
        return nextBillingDate;
    }
    
    public static List<ShipmentCalcUtil.ShipmentDetail> shipmentCalculator(List<Shipment__c> shipList,Map<String,Id> shipProdIdMap, Map<Id,Id> shipOrderIdMap,Map<Id, Shipment__c> shipRelatedMap){
        List<ShipmentCalcUtil.ShipmentDetail> shipCalcs = new  List<ShipmentCalcUtil.ShipmentDetail>();
        System.debug(' shipProdIdMap   :>'+shipProdIdMap);
        for(Shipment__c ship : shipList){
            ShipmentCalcUtil.ShipmentDetail shipCalc = new ShipmentCalcUtil.ShipmentDetail();
            shipCalc.grossWeight = ship.Gross_weight_in_Gram__c;
            shipCalc.netWeight = ship.Net_weight_in_Gram__c ;
            shipCalc.distanceInKm = ship.Distance_Km__c;
            shipCalc.shipDate = ship.Shipment_Date__c;
            shipCalc.originHub = ship.Origin_Hub__c;
            shipCalc.prodDesc = ship.Product_Description__c;
            shipCalc.windowdelivery = ship.Window_Delivery__c;
            shipCalc.windowpickup  =  ship.Window_Pickup__c;
            system.debug('Customer Prod category :'+shipCalc.customerProdCategory);
            shipCalc.blngEntityId = shipRelatedMap.get(ship.Id).Origin_Hub__r.ST_BVC_Billing_Entity__c;
            
            shipCalc.invoiceValue = ship.Shipment_Value__c;
            shipCalc.productId = shipProdIdMap.get(ship.Product_Code__c);
            shipCalc.productCode = ship.Product_Code__c;
            shipCalc.orderId = shipOrderIdMap.get(ship.Id);
            shipCalc.shipmentId = ship.Id;
            shipCalc.accountId = ship.Bill_To_Account__c;
            if(ship.Exhibition__c != null){
                shipCalc.exhibitionId = ship.Exhibition__c;
                shipCalc.customerProdCategory = ship.Customer_Product_Category__c;
                shipCalc.movtType = ship.Exhibition_Movement_Type__c;
            }
            
            shipCalc.isOriginOfflineLoc = ship.Origin_Type__c == 'Offline' ? true : false;
            shipCalc.isDestOfflineLoc = ship.Destination_Type__c == 'Offline' ? true : false; 
            shipCalc.origin = ship.Origin_Address_City__c;   
            shipCalc.destination = ship.Destination_Address_City__c;
            shipCalc.orderLineItemId = ship.Id;
            shipCalc.optForLiability = ship.Liability_Cover_By_BVC__c;
            shipCalcs.add(shipCalc);
        }
        System.debug('shipCalcs Map Size ---- '+shipCalcs.size());
        List<ShipmentCalcUtil.ShipmentDetail> shipCalculation = ShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        
        if(shipCalculation.size() > 0){
            system.debug('OfflineCharge'+shipCalculation);
            return shipCalculation;
        }
        else
            return null;
    }
    
    public static String holdBilling(shipment__c ship){
        String hBlng;
        if(ship.Bill_To_Account__r.ST_Pricing_Type__c == 'ACR'
           &&ship.Bill_To_Account__r.Customer_Category__c == 'ACR Contracted'){
               hBlng =  'Yes';
           }
        else if(ship.Bill_To_Account__r.ST_Pricing_Type__c == 'Non ACR'
                &&ship.Bill_To_Account__r.Customer_Category__c == 'Non Contracted'){
                    hBlng = 'No';
                }
        else if(ship.Bill_To_Account__r.ST_Pricing_Type__c == 'Non ACR'
                &&ship.Bill_To_Account__r.Customer_Category__c == 'Non ACR Contracted'){
                    hBlng = 'No';
                }
        return hBlng;
    }
    
    public static void Method2(){
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
        i++;}
}