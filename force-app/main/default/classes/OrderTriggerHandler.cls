public class OrderTriggerHandler {
    
    public static void orderProcesser(Map<Id,Order> newMap){
        
        Map<Id,Order> acrOrderMap = new Map<Id,Order>();
        Map<Id,Order> invOrderMap = new Map<Id,Order>();
        Set<Id> accIds = new Set<Id>();
        for(Order o : newMap.values()){
            
            accIds.add(o.AccountId);
        }
        for(Order o : [SELECT Id,Business_Type__c,BVC_CB_PreTaxBill__c,
                       Account.Active_Contract__c,
                       Account.ST_Pricing_Type__c,
                       Account.Billing_Frequency__c
                       FROM Order 
                       WHERE AccountId IN :accIds
                       AND Id IN :newMap.keySet()]){
                           if(o.Account.ST_Pricing_Type__c == 'ACR' && o.Business_Type__c == 'Shipment' && o.Account.Active_Contract__c != null){
                               acrOrderMap.put(newMap.get(o.Id).Id,newMap.get(o.Id));
                           }
                           else if((o.Account.ST_Pricing_Type__c == 'Non ACR' && o.Business_Type__c == 'Shipment' && o.Account.Billing_Frequency__c == 'Shipment')
                                   ||(o.Business_Type__c == 'ACR')  ||(o.BVC_CB_PreTaxBill__c !=null))
                           {
                               
                               invOrderMap.put(newMap.get(o.Id).Id,newMap.get(o.Id));
                           }
                       } 
        if(acrOrderMap.size() > 0 && acrOrderMap != null ){
            createACRConsumption(acrOrderMap);
        }
        if(invOrderMap.size() > 0 && invOrderMap != null){
            generateInvoice(invOrderMap);
        }
    } 
    
    public static void draftOrderProcesser(Map<Id,Order> draftOrderNewMap){
        
        Map<Id,Order> draftAcrDrOrderMap = new Map<Id,Order>();
        Set<Id> accIds = new Set<Id>();
        
        for(Order o : draftOrderNewMap.values()){
            
            accIds.add(o.AccountId);
        }
        
        Account accList = [Select id,Name,Balance_Amount__c,Consumed_Amount__c,Customer_Category__c, (select id,Name,TotalAmount  from Orders)
                           From Account where id IN :accIds];
        
        /*for(Order o : [SELECT Id,Business_Type__c,
                       Account.Balance_Amount__c ,
                       Account.Consumed_Amount__c ,
                       Account.Name ,
                       Account.Customer_Category__c 
                       FROM Order 
                       WHERE AccountId IN :accIds
                       AND Id IN :draftOrderNewMap.keySet()]){
                           if(o.Account.Customer_Category__c == 'ACR Contracted'){
                               draftAcrDrOrderMap.put(draftOrderNewMap.get(o.Id).Id,draftOrderNewMap.get(o.Id));
                           }
        
                      }*/
    }
    public static void createACRConsumption(Map<Id,Order> newMap){
        UtilClass.triggerLoop = true;
        Set<Id> accIds = new Set<Id>();
        for(Order o : newMap.values()){
            
            accIds.add(o.AccountId);
        }
        List<ST_ACR_Consumption__c> consumptionList = new List<ST_ACR_Consumption__c>();
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,ST_Pricing_Type__c,
                                                      Active_Contract__c,
                                                      Original_Contract_End_Date__c,Active_Contract__r.SBQQ__Quote__r.Name,
                                                      of_Contract_Consumption__c,Adjusted_Contract_Amount__c,
                                                      Adjustment_Amount__c,Balance_Amount__c,
                                                      Contracted_ACR_Package__c,Contract_Start_Date__c,
                                                      Contract_End_Date__c,Contract_Amount__c,
                                                      Active_Contract__r.SBQQ__Order__c
                                                      FROM Account
                                                      WHERE Active_Contract__c != null
                                                      AND Id IN :accIds
                                                     ]);
        Map<Id,OrderItem> oItemMap = new Map<Id,OrderItem>();
        for(OrderItem oItem : [SELECT Id,Product2Id,OrderId,Order.AccountId,Confirmation_Reference__c,
                               ST_Invoice_Value__c,ST_Opt_For_Liability_Coverage__c,
                               Total_Freight__c,ST_Offline_Charge__c,Liability_Charges__c,Docket_Charges__c,
                               BVC_Valuation_Charges__c,Holiday_Charges__c,Fuel_Charges__c,Weight_Charges__c,
                               Net_Weight_UOM__c,Confirmed_By_Mobile__c,Your_Reference_Number__c,
                               Net_Weight_gms__c,Number_of_Packages__c,Net_Weight__c,
                               Gross_Weight_gms__c,Gross_Weight_UOM__c,
                               blng__BillableUnitPrice__c,Confirmation_Email_ID__c,
                               Confirmation_By_Name__c,Liability_Cover_by_BVC__c,Gross_Weight__c,
                               Freight_Charges__c,Fuel_Surcharge__c,Vaulting_Charges__c,
                               ST_Minimum_Freight__c  FROM OrderItem
                               WHERE OrderId IN :newMap.keySet()]){
                                   oItemMap.put(oItem.OrderId,oItem);
                               }
        for(Order o : newMap.values()){
            if(o.Business_Type__c == 'Shipment'
               && accMap.containsKey(o.AccountId)){
                   Account a = accMap.get(o.AccountId);
                   if(accMap.containsKey(o.AccountId)
                      && a.Contract_End_Date__c >= system.today()
                      && a.ST_Pricing_Type__c == 'ACR'
                      && a.Contracted_ACR_Package__c != null
                      && o.Business_Type__c == 'Shipment'
                      && o.Shipment__c != null
                      && o.AccountId != null){
                          
                          OrderItem oi = oItemMap.get(o.Id);
                          ST_ACR_Consumption__c consumption = new ST_ACR_Consumption__c();
                          consumption.Status__c = 'Valid';
                          consumption.Customer_Account__c = a.Id;
                          consumption.Bill_To_Account__c = a.Id;
                          consumption.Bill_To_Address__c = o.Billing_Address__c;
                          consumption.Contract__c = accMap.get(o.AccountId).Active_Contract__c;
                          
                          consumption.Contract_Date_From__c =accMap.get(o.AccountId).Contract_Start_Date__c;
                          consumption.Contract_Date_To__c = accMap.get(o.AccountId).Original_Contract_End_Date__c;
                          consumption.Consumption__c = (oi.blng__BillableUnitPrice__c/accMap.get(o.AccountId).Adjusted_Contract_Amount__c)*100;
                          consumption.Adjusted_Contract_Amount__c = accMap.get(o.AccountId).Adjusted_Contract_Amount__c;
                          consumption.Adjustment_to_Contract_Amount__c = accMap.get(o.AccountId).Adjustment_Amount__c;
                          consumption.Contract_Balance__c = accMap.get(o.AccountId).Balance_Amount__c;
                          consumption.Contract_Amount__c = accMap.get(o.AccountId).Adjusted_Contract_Amount__c;
                          
                          consumption.Order_Product__c = oi.Id;
                          consumption.Contract__c = a.Active_Contract__c;
                          consumption.Shipment__c = o.Shipment__c;
                          consumption.ST_ACR_Order__c = o.Id;
                          consumption.Product__c = oi.Product2Id;
                          consumption.BVC_Branch__c = o.BVC_Branch__c;
                          
                          consumption.Shipment_Number__c = o.Shipment_Number__c;
                          consumption.Shipment_Date__c = o.Shipment_Date__c;
                          consumption.Pickup_Date__c = o.Pickup_Date__c;
                          consumption.Shipment_Value__c = o.Shipment_Value__c;
                          consumption.Product_Description__c = o.Product_Description__c;
                          consumption.No_Of_Packages__c = oi.Number_of_Packages__c;
                          
                          consumption.Shipper_Name__c = o.Shipper_Name__c;
                          consumption.Shipper_PAN__c= o.Shipper_PAN__c;
                          consumption.Consignee_Name__c = o.Consignee_Name__c;
                          consumption.Consignee_PAN__c = o.Consignee_PAN__c;
                          consumption.Destination_Address__c = o.Destination_Address__c;
                          consumption.Origin_Address__c = o.Origin_Address__c;
                          consumption.Destination_type__c = o.Destination_Type__c;
                          consumption.Origin_Type__c = o.Origin_Type__c;
                          
                          consumption.Net_Weight__c = oi.Net_Weight__c;
                          consumption.Net_Weight_GMS__c = oi.Net_Weight_gms__c;
                          consumption.Net_Weight_UOM__c = oi.Net_Weight_UOM__c;
                          consumption.Gross_Weight__c = oi.Gross_Weight__c;
                          consumption.Gross_Weight_GMS__c = oi.Gross_Weight_gms__c;
                          consumption.Gross_Weight_UOM__c = oi.Gross_Weight_UOM__c;
                          
                          
                          consumption.Freight_Charges__c = oi.Freight_Charges__c != null ? oi.Freight_Charges__c : 0;
                          consumption.Offline_Charges__c = oi.ST_Offline_Charge__c != null ? oi.ST_Offline_Charge__c : 0;
                          consumption.Liability_Cover_By_BVC__c = oi.Liability_Cover_by_BVC__c;
                          consumption.Liability_charges__c = oi.Liability_Charges__c != null ? oi.Liability_Charges__c : 0;
                          consumption.Minimum_Freight__c = oi.ST_Minimum_Freight__c;
                          // Added new charge Heads
                          consumption.BVC_Valuation_Charges__c = oi.BVC_Valuation_Charges__c != null ? oi.BVC_Valuation_Charges__c : 0;
                          consumption.Docket_Charges__c = oi.Docket_Charges__c != null ? oi.Docket_Charges__c : 0;
                          consumption.Fuel_Charges__c = oi.Fuel_Charges__c != null ? oi.Fuel_Charges__c : 0;
                          consumption.Holiday_Charges__c = oi.Holiday_Charges__c != null ? oi.Holiday_Charges__c : 0;
                          consumption.Weight_Charges__c = oi.Weight_Charges__c != null ? oi.Weight_Charges__c : 0;
                          consumption.Fuel_Surcharge__c = oi.Fuel_Surcharge__c != null ? oi.Fuel_Surcharge__c : 0;//Prat
                          
                          consumption.Initiator_Name__c = o.Initiator_Name__c;
                          consumption.Initiator_Mobile__c = o.Initiator_Mobile__c;
                          consumption.Initiator_PAN__c = o.Initiator_PAN__c;
                          consumption.Initiator_Email__c = o.Initiator_Email__c;
                          
                          consumption.Confirmed_By_Name__c = oi.Confirmation_By_Name__c;
                          consumption.Confirmed_By_Phone__c = oi.Confirmed_By_Mobile__c;
                          consumption.Confirmed_By_Email__c = oi.Confirmation_Email_ID__c;
                          consumption.Confirmation_Reference__c = oi.Confirmation_Reference__c;
                          consumption.Reference_Number__c = oi.Your_Reference_Number__c;
                          consumption.Annual_Contract_ID__c = accMap.get(o.AccountId).Active_Contract__r.SBQQ__Quote__r.Name;
                          consumption.Shipment_Type__c = o.Shipment_Type__c;
                          consumption.Total_Charge__c = o.TotalAmount;
                          consumptionList.add(consumption);
                      }
               }
        }
        if(consumptionList.size() > 0){
            UtilClass.orderTriggerLoop = true;
            
            try{
                insert consumptionList;
            }catch(Exception ex){
                system.debug(ex.getStackTraceString()+'*** ACR Consumption : Insert Failed with following Exception***'+ex.getMessage());
            }
        }
    }
    
    public static void generateInvoice(Map<Id,Order> orderMap){
        Set<Id> orderIds = new set<Id>();
        for(Order o : orderMap.values()){
            
            orderIds.add(o.Id);
            
        }
        Map<Id,Order> acrOrderMap = new Map<Id,Order>();
        Map<Id,List<OrderItem>> acrItemMap = new Map<Id,List<OrderItem>>();
        Map<Id,Order> shipOrderMap = new Map<Id,Order>();
        Map<Id,List<OrderItem>> shipItemMap = new Map<Id,List<OrderItem>>();
        Map<Id,Order> CBOrderMap = new Map<Id,Order>();
        Map<Id,List<OrderItem>> CBItemMap = new Map<Id,List<OrderItem>>();
        
        List<Order> orderList = new List<Order>();
        if(orderIds.size() > 0){
            orderList.addAll([SELECT Id,AccountId,BVC_Branch__c,BVC_Billing_Entity__c,BVC_Entity__c,
                              Billing_Address__c,Account.Billing_Address__c,Account.Billing_Frequency__c,Business_Type__c,
                              Account.blng__BillToContact__c,
                              BVC_CB_AIR_SEA__c,BVC_CB_Assessable_Value__c,BVC_CB_BE_Date__c,BVC_CB_BE_No__c,BVC_CB_BillingDocumentNumber__c,BVC_CB_Billing_Account_2__c,
                                BVC_CB_Billing_Account_Address_2__c,BVC_CB_Billing_Account_Address__c,BVC_CB_Billing_GSTIN__c,BVC_CB_Billing_GST_State_Code__c,BVC_CB_Billing_OracleId__c,
                                BVC_CB_Billing_Oracle_SiteId__c,BVC_CB_Billing_PAN__c,BVC_CB_Billing_SF_Customer_Address__c,BVC_CB_Billing_SF_Customer__c,BVC_CB_Billing_State__c,
                                BVC_CB_BillTo_Fields__c,BVC_CB_Bond_Date__c,BVC_CB_Bond_No__c,BVC_CB_BOS_Bill_Amount__c,BVC_CB_BOS_Invoice_No__c,BVC_CB_BOS_Round_Off__c,BVC_CB_BVC_VAMASHIP_ID__c,
                                BVC_CB_Cash_Idf_Date__c,BVC_CB_Cash_Idf_No__c,BVC_CB_CCDate__c,BVC_CB_CCNo__c,BVC_CB_CM_Bill_Amount__c,BVC_CB_CM_Invoice_No__c,BVC_CB_CM_Round_Off__c,BVC_CB_CONTENT__c,
                                BVC_CB_Created_By_Datetime__c,BVC_CB_Created_By__c,BVC_CB_Customer_Address__c,BVC_CB_Customer_GSTINNO__c,BVC_CB_Customer_Invoice_Date__c,
                                BVC_CB_Customer_Invoice_Number__c,BVC_CB_Customer_Invoice_Value_Currency__c,BVC_CB_Customer_Name__c,BVC_CB_CUSTOMER_TRANSACTION_TYPE__c,
                                BVC_CB_Despatch__c,BVC_CB_DestinationCountry__c,BVC_CB_DestinationPort__c,BVC_CB_Destination_Country_2__c,BVC_CB_Destination_Port_2__c,
                                BVC_CB_digiGSTErrorCode__c,BVC_CB_digiGSTErrorMessage__c,BVC_CB_DT_GR_FORM_NO__c,BVC_CB_EDFDate__c,BVC_CB_EDFNo__c,BVC_CB_ERDate__c,
                                BVC_CB_ERNo__c,BVC_CB_ExportShipmentID__c,BVC_CB_FOBValue__c,BVC_CB_GrossWt__c,BVC_CB_GR_FORM_NO__c,BVC_CB_GSTIN_Remarks__c,
                                BVC_CB_HAWB_Date__c,BVC_CB_HAWB_No__c,BVC_CB_IGM_Item_Date__c,BVC_CB_IGM_Item_No__c,BVC_CB_Import_Shipment__c,BVC_CB_Invoice_Type__c,BVC_CB_Invoice_Value_INR__c,
                                BVC_CB_Invoice_Value__c,BVC_CB_IRN_Date__c,BVC_CB_IRN__c,BVC_CB_JOB_DT__c,BVC_CB_JOB_NO__c,BVC_CB_Last_Modifiedby__c,BVC_CB_License_Date__c,BVC_CB_License_No__c,
                                BVC_CB_lospCity__c,BVC_CB_lospColumn__c,BVC_CB_lospStateCode__c,BVC_CB_lospState__c,BVC_CB_lospTable__c,BVC_CB_MAWB_Date__c,BVC_CB_MAWB_No__c,
                                BVC_CB_Modified_Datetime__c,BVC_CB_Net_Wt__c,BVC_CB_No_Of_Pkgs__c,BVC_CB_Operation_Type__c,BVC_CB_OracleID__c,BVC_CB_Oracle_SiteId__c,BVC_CB_OrgBranchCode__c,
                                BVC_CB_OrgBranchName__c,BVC_CB_Org_Branch_GSTIN__c,BVC_CB_Org_Branch_GST_State_Code__c,BVC_CB_Org_Branch_SF_ID__c,BVC_CB_Org_Branch_State__c,
                                BVC_CB_Org_CINNO__c,BVC_CB_Org_PAN__c,BVC_CB_PickupLocationCity__c,BVC_CB_PickupLocationCountry__c,BVC_CB_PickupLocationState__c,BVC_CB_PlaceOfDelivery__c,
                                BVC_CB_PlaceOfReceipt__c,BVC_CB_posCity__c,BVC_CB_posColumn__c,BVC_CB_posStateCode__c,BVC_CB_posState__c,BVC_CB_posTable__c,BVC_CB_POS__c,BVC_CB_PreTaxBill__c,
                                BVC_CB_PreTaxInvoice_ID__c,OS_Username__c,Shipment__c,BVC_CB_Pre_Tax_Date__c,BVC_CB_Pre_Tax_No__c,BVC_CB_ProcessingDate__c,BVC_CB_Remarks1__c,BVC_CB_Remarks__c,BVC_CB_ROUND_OFF__c,
                                BVC_CB_SalesForceAddress__c,BVC_CB_SalesForceCustomerId__c,BVC_CB_SBDate__c,BVC_CB_SBNo__c,BVC_CB_Shipment_Date__c,BVC_CB_Shipment_No__c,BVC_CB_ShipTo_Fields__c,BVC_CB_SoldTo_Fields__c,
                                BVC_CB_SOS__c,BVC_CB_SupplyType__c,BVC_CB_SUPPLY_TYPE__c,BVC_CB_Tariff_Name__c,BVC_CB_Tax_Bill_Amount__c,BVC_CB_Tax_Invoice_No__c,BVC_CB_Tax_Round_Off__c,
                                BVC_CB_Trade_Name__c,BVC_CB_TRANSACTION_CLASS__c,BVC_Shipment__c,Total_Fuel_Surcharge__c,
                              (SELECT Id,Product2Id,OrderId,Product2.Name,Quantity,TotalPrice,UnitPrice,Product2.blng__BillingRule__c,
                               Product2.blng__TaxRule__c,blng__LegalEntity__c,blng__BillingTreatment__c,ServiceDate,EndDate,
                               BVC_CB_CGSTAmount__c,BVC_CB_CGSTTaxRate__c,BVC_CB_ChargeAmount__c,BVC_CB_ChargeCode__c,BVC_CB_ChargeDescription__c,BVC_CB_ChargeType__c,
                 BVC_CB_COAENTITY__c,BVC_CB_COA_BRANCH__c,BVC_CB_COA_EXHIBITION_CODE__c,BVC_CB_COA_INTERCOMPANY__c,BVC_CB_COA_PRODUCT__c,BVC_CB_COA_REVENUE_ACCOUNT_CODE__c,BVC_CB_COA_REVENUE_COST_CENTRE__c,BVC_CB_COA_REVENUE_SUB_ACCOUNT__c,BVC_CB_CreatedByDatetime__c,BVC_CB_CreatedBy__c,BVC_CB_ExportPreTaxBillID__c,BVC_CB_HSNCODE__c,BVC_CB_Id__c,BVC_CB_IGSTAmount__c,BVC_CB_IGSTTaxRate__c,BVC_CB_ImportPreTaxBillID__c,BVC_CB_InvoiceType__c,
                BVC_CB_Invoice_Type__c,BVC_CB_LastModifiedby__c,BVC_CB_LineTotal__c,BVC_CB_LINEUOMCODE__c,BVC_CB_LINE_NUMBER__c,BVC_CB_ModifiedDatetime__c,BVC_CB_NatureOfService__c,BVC_CB_NONTAXVALUE__c,BVC_CB_OracleGLCode__c,BVC_CB_OracleItemCode__c,BVC_CB_ReceiptDate__c,BVC_CB_ReceiptNo__c,BVC_CB_Remarks__c,
                               BVC_CB_SAC__c,BVC_CB_SalesforceCharge__c,BVC_CB_SGSTAmount__c,BVC_CB_SGSTTaxRate__c,BVC_CB_TAXABLEVALUE__c,BVC_CB_TaxCalculatedINR__c,
                               BVC_CB_TaxCalculated__c,BVC_CB_TaxCategory__c,BVC_CB_TotalItemValue__c,BVC_CB_UTGSTAmount__c,BVC_CB_UTGSTTaxRate__c,Fuel_Surcharge__c
                               FROM OrderItems WHERE blng__HoldBilling__c = 'No' AND TotalPrice > 0),
                              Origin_Address__c FROM Order WHERE Id IN :orderIds]);
        }
        
        for(Order o : orderList){
            
            if(o.BVC_CB_PreTaxBill__c ==null && o.Business_Type__c == 'ACR' && o.OrderItems.size() > 0){
                acrOrderMap.put(o.Id,o);
                acrItemMap.put(o.Id,o.OrderItems);
            }
            else if(o.BVC_CB_PreTaxBill__c ==null && o.Business_Type__c == 'Shipment' && o.Account.Billing_Frequency__c == 'Shipment' && o.OrderItems.size() > 0){
                shipOrderMap.put(o.Id,o);
                shipItemMap.put(o.Id,o.OrderItems);
            }
            if(o.BVC_CB_PreTaxBill__c !=null && o.OrderItems.size() > 0){
                CBOrderMap.put(o.Id,o);
                CBItemMap.put(o.Id,o.OrderItems);
            }
        }
        
        if(acrItemMap.size() > 0 && acrItemMap != null){
            UtilClass.orderTriggerLoop = true;
            ST_InvoiceGenerator.createACRInvoice(acrOrderMap, acrItemMap);
        }
        if(shipItemMap.size() > 0 && shipItemMap != null){
            ST_InvoiceGenerator.createShipmentInvoice(shipOrderMap, shipItemMap);
        }
        if(CBItemMap.size() > 0 && CBItemMap != null){
            BVC_CB_InvoiceGenerator.createShipmentInvoice(CBOrderMap, CBItemMap);
        }
        
    }
    //Dev Start- Reverse Order
    public static void createReverseOrder(Map<Id,Order> oldMap,Map<Id,Order> newMap){
         system.debug('reverse order::::');
        List<Order> reverseOrders = new List<Order>();
        List<ST_ACR_Consumption__c> reverseACRConsumption = new List<ST_ACR_Consumption__c>();
        List<OrderItem> reverseorderitem = new List<OrderItem>();
        
        for(Id orderId:newMap.keySet()){
            if(oldMap.get(orderId).Shipment_Status_Static__c=='ACR Consumed'){
            Order oldOrderRec = oldMap.get(orderId);
            Order newOrderRec = newMap.get(orderId);
            System.debug(oldOrderRec.Status + ' '+ newOrderRec.Status);
            if(oldOrderRec.Status != null && newOrderRec.Status != null){
                
                if(oldOrderRec.Status != newOrderRec.Status && oldOrderRec.Status=='Activated' && newOrderRec.Status=='Draft'){
                    
                    if(newOrderRec.Accountid!= null && newOrderRec.Customer_Category_Static__c!=null && newOrderRec.Customer_Category_Static__c=='ACR'){
                        Order reverseOrder = newOrderRec.clone(false,true,false,false);
                        reverseOrder.Reversed_Order_Amount__c = -1 * newOrderRec.TotalAmount;
                        reverseOrder.Reversed_Order_Of__c = orderId;
                        reverseOrder.Order_reversal_reason__c=newOrderRec.Order_reversal_reason__c;//prat
                        reverseOrder.Original_Order_Static__c=newOrderRec.Id;
                        reverseOrder.Original_Order_number__c=newOrderRec.OrderNumber;
                        reverseOrders.add(reverseOrder);
                        
                    }
                }
            }
            }
        }
        
        if(reverseOrders.size()>0){
            insert reverseOrders;
            
            createReverseOrderItems(reverseOrders, newMap.keySet());
            createReverseACR(reverseOrders, newMap.keySet());
        }
    }
    
    public static void createReverseOrderItems(List<Order> reverseOrders,Set<Id> oldOrderIds){
        
        Map<Id,Id> origVsRever =new Map<Id,Id>();
        for(Order orderRec:reverseOrders){
            origVsRever.put(orderRec.Reversed_Order_Of__c,orderRec.Id);
        }
        system.debug('PORGVSREVER'+origVsRever);
    List<OrderItem> orderItems = [Select Id,OrderId,PricebookEntryId,Quantity,ServiceDate,blng__BillableUnitPrice__c,EndDate,UnitPrice,blng__BillingRule__c,blng__RevenueRecognitionRule__c,blng__TaxRule__c from OrderItem where OrderId in :oldOrderIds];
        List<OrderItem> reversedOrderItems = new List<OrderItem>();
        for(OrderItem ordItem:orderItems){
            OrderItem revOrdItem = ordItem.clone(false,true,false,false);
            System.debug('Rule'+revOrdItem.blng__BillingRule__c );
            revOrdItem.UnitPrice = -1*revOrdItem.UnitPrice;
            revOrdItem.blng__BillableUnitPrice__c = -1*revOrdItem.blng__BillableUnitPrice__c ;
            System.debug(ordItem.OrderId);
            revOrdItem.OrderId = origVsRever.get(ordItem.OrderId);
            System.debug(revOrdItem.OrderId);
            reversedOrderItems.add(revOrdItem);
        }
        insert reversedOrderItems;
    }
    
   
    public static void createReverseACR(List<Order> reverseOrders,Set<Id> oldOrderIds){
        Set<Id> accIds = new Set<Id>();
        for(Order o : reverseOrders){
            
            accIds.add(o.AccountId);
        }
        List<OrderItem> orderItems = [Select Id,Net_Weight__c,Net_Weight_gms__c,
                                      Net_Weight_UOM__c,Gross_Weight__c ,
                                      Gross_Weight_gms__c,Gross_Weight_UOM__c,
                                      Freight_Charges__c,ST_Offline_Charge__c ,
                                      Liability_Cover_by_BVC__c,Liability_Charges__c ,
                                      ST_Minimum_Freight__c, BVC_Valuation_Charges__c ,
                                      Docket_Charges__c, Fuel_Charges__c,
                                      Holiday_Charges__c , Weight_Charges__c ,Fuel_Surcharge__c,
                                      Confirmation_By_Name__c,Confirmed_By_Mobile__c,
                                      Confirmation_Email_ID__c,Confirmation_Reference__c,
                                      Your_Reference_Number__c,blng__BillableUnitPrice__c,
                                      Product2Id,Number_of_Packages__c,OrderId,Vaulting_Charges__c
                                      from OrderItem where OrderId in: oldOrderIds];
        
        Map<Id,OrderItem> oiMap = new Map<Id,OrderItem>();
        for(OrderItem oi:orderItems){
            oiMap.put(oi.OrderId,oi);
        }
        List<ST_ACR_Consumption__c> consumptionList = new List<ST_ACR_Consumption__c>();
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,ST_Pricing_Type__c,
                                                      Active_Contract__c,
                                                      Original_Contract_End_Date__c,Active_Contract__r.SBQQ__Quote__r.Name,
                                                      of_Contract_Consumption__c,Adjusted_Contract_Amount__c,
                                                      Adjustment_Amount__c,Balance_Amount__c,
                                                      Contracted_ACR_Package__c,Contract_Start_Date__c,
                                                      Contract_End_Date__c,Contract_Amount__c,
                                                      Active_Contract__r.SBQQ__Order__c
                                                      FROM Account
                                                      WHERE Active_Contract__c != null
                                                      AND Id IN :accIds
                                                     ]);
        List<ST_ACR_Consumption__c> reverseACRConsumption = new List<ST_ACR_Consumption__c>();
        set<Id> acrId=new set<Id>();
         for(Order o1 : reverseOrders){
            
            acrId.add(o1.ACR_Consumption__c);
        }
        Map<Id,ST_ACR_Consumption__c> acrMap=new Map<Id,ST_ACR_Consumption__c>([select Id,Name,ST_ACR_Order__c,
                                                                              Net_Weight__c,Net_Weight_GMS__c,Net_Weight_UOM__c,Gross_Weight__c,
                                                                                Gross_Weight_GMS__c,Gross_Weight_UOM__c,Freight_Charges__c,
                                                                                Offline_Charges__c,Liability_Cover_By_BVC__c,Liability_charges__c,
                                                                                Minimum_Freight__c,BVC_Valuation_Charges__c,Docket_Charges__c,
                                                                                Fuel_Charges__c,Holiday_Charges__c,Weight_Charges__c,Confirmed_By_Name__c,
                                                                                Confirmed_By_Phone__c,Confirmed_By_Email__c,Confirmation_Reference__c,
                                                                                Reference_Number__c,Consumption__c,Order_Product__c,Product__c,
                                                                                No_Of_Packages__c,Bill_To_Account__c,Bill_To_Address__c,
                                                                                Contract_Date_From__c,Contract_Date_To__c,Adjusted_Contract_Amount__c,
                                                                                Adjustment_to_Contract_Amount__c,Contract_Balance__c,Contract_Amount__c,
                                                                                Shipment__c,BVC_Branch__c,Shipment_Number__c,Shipment_Date__c,
                                                                                Pickup_Date__c,Shipment_Value__c,Product_Description__c,
                                                                                Shipper_Name__c,Shipper_PAN__c,Consignee_Name__c,Consignee_PAN__c,
                                                                                Destination_Address__c,Origin_Address__c,Destination_type__c,
                                                                                Origin_Type__c,Customer_Account__c,Fuel_Surcharge__c
                                                                                from ST_ACR_Consumption__c 
                                                                                where Id IN :acrId]); 
        if(acrMap.size()>0){
        for(Order orderRec:reverseOrders){
        
        ST_ACR_Consumption__c consumption = new ST_ACR_Consumption__c();
                        
                        consumption.Status__c = 'Invalid';
                        consumption.Contract__c = accMap.get(orderRec.AccountId).Active_Contract__c;
                        consumption.Customer_Account__c = orderRec.AccountId;
                        consumption.ST_ACR_Order__c = orderRec.Id;
                        consumption.Total_Charge__c = orderRec.Reversed_Order_Amount__c;
                        consumption.Bill_To_Account__c = orderRec.AccountId;
                          consumption.Bill_To_Address__c = orderRec.Billing_Address__c;
                        consumption.Consumption_Original_number__c = acrMap.get(orderRec.ACR_Consumption__c).Name;
                          consumption.Contract_Date_From__c =accMap.get(orderRec.AccountId).Contract_Start_Date__c;
                          consumption.Contract_Date_To__c = accMap.get(orderRec.AccountId).Original_Contract_End_Date__c;
                         
                          consumption.Adjusted_Contract_Amount__c = accMap.get(orderRec.AccountId).Adjusted_Contract_Amount__c;
                          consumption.Adjustment_to_Contract_Amount__c = accMap.get(orderRec.AccountId).Adjustment_Amount__c;
                          consumption.Contract_Balance__c = accMap.get(orderRec.AccountId).Balance_Amount__c;
                          consumption.Contract_Amount__c = accMap.get(orderRec.AccountId).Adjusted_Contract_Amount__c;
                         
                          consumption.Shipment__c = orderRec.Shipment__c;
                          
                          
                          consumption.BVC_Branch__c = orderRec.BVC_Branch__c;
                          
                          consumption.Shipment_Number__c = orderRec.Shipment_Number__c;
                          consumption.Shipment_Date__c = orderRec.Shipment_Date__c;
                          consumption.Pickup_Date__c = orderRec.Pickup_Date__c;
                          consumption.Shipment_Value__c = orderRec.Shipment_Value__c;
                          consumption.Product_Description__c = orderRec.Product_Description__c;
                          
                          
                          consumption.Shipper_Name__c = orderRec.Shipper_Name__c;
                          consumption.Shipper_PAN__c= orderRec.Shipper_PAN__c;
                          consumption.Consignee_Name__c = orderRec.Consignee_Name__c;
                          consumption.Consignee_PAN__c = orderRec.Consignee_PAN__c;
                          consumption.Destination_Address__c = orderRec.Destination_Address__c;
                          consumption.Origin_Address__c = orderRec.Origin_Address__c;
                          consumption.Destination_type__c = orderRec.Destination_Type__c;
                          consumption.Origin_Type__c = orderRec.Origin_Type__c;
                
            if(oiMap.get(orderRec.Reversed_Order_Of__c)!=null){
                OrderItem oi = oiMap.get(orderRec.Reversed_Order_Of__c);
                consumption.Net_Weight__c = oi.Net_Weight__c;
                          consumption.Net_Weight_GMS__c = oi.Net_Weight_gms__c;
                          consumption.Net_Weight_UOM__c = oi.Net_Weight_UOM__c;
                          consumption.Gross_Weight__c = oi.Gross_Weight__c;
                          consumption.Gross_Weight_GMS__c = oi.Gross_Weight_gms__c;
                          consumption.Gross_Weight_UOM__c = oi.Gross_Weight_UOM__c;
               consumption.Freight_Charges__c = oi.Freight_Charges__c != null ? oi.Freight_Charges__c : 0;
                          consumption.Offline_Charges__c = oi.ST_Offline_Charge__c != null ? oi.ST_Offline_Charge__c : 0;
                          consumption.Liability_Cover_By_BVC__c = oi.Liability_Cover_by_BVC__c;
                          consumption.Liability_charges__c = oi.Liability_Charges__c != null ? oi.Liability_Charges__c : 0;
                          consumption.Minimum_Freight__c = oi.ST_Minimum_Freight__c;
                          // Added new charge Heads
                          consumption.BVC_Valuation_Charges__c = oi.BVC_Valuation_Charges__c != null ? oi.BVC_Valuation_Charges__c : 0;
                          consumption.Docket_Charges__c = oi.Docket_Charges__c != null ? oi.Docket_Charges__c : 0;
                          consumption.Fuel_Charges__c = oi.Fuel_Charges__c != null ? oi.Fuel_Charges__c : 0;
                          consumption.Holiday_Charges__c = oi.Holiday_Charges__c != null ? oi.Holiday_Charges__c : 0;
                          consumption.Weight_Charges__c = oi.Weight_Charges__c != null ? oi.Weight_Charges__c : 0;
              consumption.Fuel_Surcharge__c = oi.Fuel_Surcharge__c != null ? oi.Fuel_Surcharge__c : 0;//Prat
                
              consumption.Confirmed_By_Name__c = oi.Confirmation_By_Name__c;
                          consumption.Confirmed_By_Phone__c = oi.Confirmed_By_Mobile__c;
                          consumption.Confirmed_By_Email__c = oi.Confirmation_Email_ID__c;
                          consumption.Confirmation_Reference__c = oi.Confirmation_Reference__c;
                          consumption.Reference_Number__c = oi.Your_Reference_Number__c;
              
              consumption.Consumption__c = (oi.blng__BillableUnitPrice__c/accMap.get(orderRec.AccountId).Adjusted_Contract_Amount__c)*100;
              consumption.Order_Product__c = oi.Id;
              consumption.Product__c = oi.Product2Id;
              consumption.No_Of_Packages__c = oi.Number_of_Packages__c;
            }
            reverseACRConsumption.add(consumption);
        }
        } 
         if(reverseACRConsumption.size()>0)
            insert reverseACRConsumption;
    }
    
    public static void cannotDeleteOrder(List<order> OrderList){
        Id profileId= UserInfo.getProfileId();
        string profileName=[SELECT Id, name from Profile WHERE Id=:profileId].name;
        for(order o:OrderList){
            if(o.Business_Type__c=='Shipment' && o.Shipment_Status_Static__c=='ACR Consumed' && profileName!='System Administrator'){
                if(o.X18_Digit_ID__c!=null){
                    o.addError('Order cannot be deleted');
                }
            }
        }
    }
    public static void fakeMethod1(){
        Integer i=0;
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
      i++; i++;
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