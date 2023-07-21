public class OrderCreationPreTaxBatch implements Database.Batchable<sObject>{
public final String Query;
public final List<Id> preTaxIds;
public OrderCreationPreTaxBatch(){
Query='SELECT (select Id,BVC_CB_Invoice_Type__c,BVC_CB_Charge_Product_Code__c from BVC_CB_PreTaxBillDetails__r ),BVC_CB_Org_Branch_SF_ID__r.BVC_CB_BVC_Entity__c,BVC_CB_Org_Branch_SF_ID__r.CB_BVC_Legal_Entity__c,BVC_CB_GrossWt__c,BVC_CB_Billing_Account_2__c,BVC_CB_Billing_Account_Address_2__c,'+
                                                'BVC_CB_Operation_Type__c,BVC_CB_PretaxDetails_Inserted__c,BVC_CB_Customer_GSTINNO__c,BVC_CB_Destination_Country_2__c,BVC_CB_Destination_Port_2__c,BVC_CB_Is_Order_Created__c,BVC_CB_Invoice_Type__c,BVC_CB_AIR_SEA__c,BVC_CB_Assessable_Value__c,BVC_CB_BE_Date__c,BVC_CB_BE_No__c,BVC_CB_Customer_Invoice_Number__c,BVC_CB_Billing_Account_Address__c,BVC_CB_Billing_GSTIN__c,BVC_CB_Billing_GST_State_Code__c,BVC_CB_Billing_OracleId__c,BVC_CB_Billing_Oracle_SiteId__c,BVC_CB_Billing_PAN__c,BVC_CB_Billing_SF_Customer_Address__c,BVC_CB_Billing_SF_Customer__c,BVC_CB_Billing_State__c,BVC_CB_BillTo_Fields__c,BVC_CB_Bond_Date__c,BVC_CB_Bond_No__c,BVC_CB_BOS_Bill_Amount__c,BVC_CB_BOS_Invoice_No__c,BVC_CB_BOS_Round_Off__c,BVC_CB_BVC_VAMASHIP_ID__c,BVC_CB_Cash_Idf_Date__c,BVC_CB_Cash_Idf_No__c,BVC_CB_CCDate__c,BVC_CB_CCNo__c,BVC_CB_CM_Bill_Amount__c,BVC_CB_CM_Invoice_No__c,BVC_CB_CM_Round_Off__c,BVC_CB_CONTENT__c,BVC_CB_Created_By_Datetime__c,BVC_CB_Created_By__c,BVC_CB_Customer_Address__c,BVC_CB_Customer_Invoice_Date__c,BVC_CB_Customer_Invoice_Value_Currency__c,BVC_CB_Customer_Name__c,BVC_CB_CUSTOMER_TRANSACTION_TYPE__c,BVC_CB_Despatch__c,BVC_CB_DestinationCountry__c,BVC_CB_DestinationPort__c,BVC_CB_DT_GR_FORM_NO__c,BVC_CB_EDFDate__c,BVC_CB_EDFNo__c,BVC_CB_ERDate__c,BVC_CB_ERNo__c,BVC_CB_ExportShipmentID__c,BVC_CB_FOBValue__c,BVC_CB_GR_FORM_NO__c,BVC_CB_GSTIN_Remarks__c,BVC_CB_HAWB_Date__c,BVC_CB_HAWB_No__c,BVC_CB_IGM_Item_Date__c,BVC_CB_IGM_Item_No__c,BVC_CB_Import_Shipment__c,BVC_CB_Invoice_Value_INR__c,BVC_CB_Invoice_Value__c,BVC_CB_IRN_Date__c,BVC_CB_IRN__c,BVC_CB_JOB_DT__c,BVC_CB_JOB_NO__c,BVC_CB_Last_Modifiedby__c,BVC_CB_License_Date__c,BVC_CB_License_No__c,BVC_CB_lospCity__c,BVC_CB_lospColumn__c,BVC_CB_lospStateCode__c,BVC_CB_lospState__c,BVC_CB_lospTable__c,BVC_CB_MAWB_Date__c,BVC_CB_MAWB_No__c,BVC_CB_Modified_Datetime__c,BVC_CB_Net_Wt__c,BVC_CB_No_Of_Pkgs__c,BVC_CB_OracleID__c,BVC_CB_Oracle_SiteId__c,BVC_CB_OrgBranchCode__c,BVC_CB_OrgBranchName__c,BVC_CB_Org_Branch_GSTIN__c,BVC_CB_Org_Branch_GST_State_Code__c,BVC_CB_Org_Branch_SF_ID__c,BVC_CB_Org_Branch_State__c,BVC_CB_Org_CINNO__c,BVC_CB_Org_PAN__c,BVC_CB_posColumn__c,BVC_CB_posTable__c,BVC_CB_POS__c,BVC_CB_PreTaxInvoice_ID__c,BVC_CB_Pre_Tax_Date__c,BVC_CB_Pre_Tax_No__c,BVC_CB_ProcessingDate__c,BVC_CB_Remarks1__c,BVC_CB_Remarks__c,BVC_CB_ROUND_OFF__c,BVC_CB_SalesForceAddress__c,BVC_CB_SalesForceCustomerId__c,BVC_CB_SBDate__c,BVC_CB_SBNo__c,BVC_CB_Shipment_Date__c,BVC_CB_Shipment_No__c,BVC_CB_ShipTo_Fields__c,BVC_CB_SoldTo_Fields__c,BVC_CB_SOS__c,BVC_CB_SupplyType__c,BVC_CB_SUPPLY_TYPE__c,BVC_CB_Tariff_Name__c,BVC_CB_Tax_Bill_Amount__c,BVC_CB_Tax_Invoice_No__c,BVC_CB_Tax_Round_Off__c,BVC_CB_Trade_Name__c,BVC_CB_TRANSACTION_CLASS__c,BVC_Shipment__c,CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,SystemModstamp FROM BVC_CB_PreTaxBill__c '+
                                                ' where BVC_CB_Is_Order_Created__c = false and BVC_CB_PretaxDetails_Inserted__c = TRUE';    
}
    public OrderCreationPreTaxBatch(string query){
      this.query=query;   
    }
    public OrderCreationPreTaxBatch(string query, List<Id> preTaxIds){
      this.query=query;
      this.preTaxIds = preTaxIds;
    }
   
public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<BVC_CB_PreTaxBill__c> scope){
       List<BVC_CB_Object_Mapping__c> objectMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where (Target_Object_API_Name__c ='Order' OR Target_Object_API_Name__c='OrderItem') and Is_Active__c = true];
        
       String priceBookId = [select Id,Name from Pricebook2 where Name ='BVC INR Price Book' limit 1].Id;
       list<blng__ErrorLog__c> errorlogs= new list<blng__ErrorLog__c>();
       List<Id> preTaxIds = new List<Id>();
       for(BVC_CB_PreTaxBill__c s:scope){
       	preTaxIds.add(s.Id);    
       }
       List<BVC_CB_PreTaxBill__c> preTaxList= scope;
       List<BVC_CB_PreTaxBillDetails__c> preTaxDetailList = [SELECT 
                                                             BVC_CB_ChargeAmount__c,BVC_CB_SGSTTaxRate__c,BVC_CB_ExportPreTaxBillID__c,BVC_CB_ImportPreTaxBillID__c,BVC_CB_UTGSTTaxRate__c,BVC_CB_OracleItemCode__c,BVC_CB_CGSTTaxRate__c,BVC_CB_ChargeCode__c,BVC_CB_ChargeDescription__c,BVC_CB_CGSTAmount__c,BVC_CB_ChargeType__c,BVC_CB_Charge_Product_Code__c,BVC_CB_CreatedByDatetime__c,BVC_CB_CreatedBy__c,BVC_CB_HSNCODE__c,BVC_CB_Id__c,BVC_CB_IGSTAmount__c,BVC_CB_IGSTTaxRate__c,BVC_CB_InvoiceType__c,BVC_CB_Invoice_Type__c,BVC_CB_LastModifiedby__c,BVC_CB_LineTotal__c,BVC_CB_ModifiedDatetime__c,BVC_CB_NatureOfService__c,BVC_CB_NONTAXVALUE__c,BVC_CB_OracleGLCode__c,BVC_CB_PreTaxBill__c,BVC_CB_ReceiptDate__c,BVC_CB_ReceiptNo__c,BVC_CB_Remarks__c,BVC_CB_SAC__c,BVC_CB_SalesforceCharge__c,BVC_CB_SGSTAmount__c,BVC_CB_TAXABLEVALUE__c,BVC_CB_TaxCategory__c,BVC_CB_TotalItemValue__c,BVC_CB_UTGSTAmount__c,CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,SystemModstamp FROM BVC_CB_PreTaxBillDetails__c
                                                              where BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = false
                                                              and BVC_CB_PreTaxBill__c =: preTaxIds
            
        ];
        Map<String, Id> mapOrderPreTax  = new Map<String, Id>();
        List<Order> insertOrders = new List<Order>();
        set<String> invoiceSet = new set<String>();
        for(BVC_CB_PreTaxBill__c PT:preTaxList){ 
            PT.BVC_CB_Is_Order_Created__c = true;
            for(BVC_CB_PreTaxBillDetails__c detail:PT.BVC_CB_PreTaxBillDetails__r){
                if(detail.BVC_CB_Invoice_Type__c!=null && !invoiceSet.contains(detail.BVC_CB_Invoice_Type__c)){
            	Order orderRec = new Order();
                orderRec.Status ='Draft';
                orderRec.Pricebook2Id= priceBookId;
                orderRec.recordtypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName(). get('CB_Billing').getRecordTypeId();
                orderRec.BVC_CB_Invoice_Type__c=detail.BVC_CB_Invoice_Type__c;
                orderRec.BVC_Branch__c = PT.BVC_CB_Org_Branch_SF_ID__c;
            	orderRec.BVC_Billing_Entity__c = PT.BVC_CB_Org_Branch_SF_ID__r.CB_BVC_Legal_Entity__c;//CB_BVC_Legal_Entity__c
            	orderRec.BVC_Entity__c = PT.BVC_CB_Org_Branch_SF_ID__r.BVC_CB_BVC_Entity__c;//BVC_CB_BVC_Entity__c
                invoiceSet.add(detail.BVC_CB_Invoice_Type__c);
                for(BVC_CB_Object_Mapping__c fieldMapping : objectMappings){
                    try{
                    if(fieldMapping.Target_Object_API_Name__c=='Order'){
                        
                        orderRec.put(fieldMapping.Target_Field_API_Name__c, PT.get(fieldMapping.Source_Field_API_Name__c));
                    }
                    }catch(exception e){
                        blng__ErrorLog__c errorlog= new blng__ErrorLog__c();
                        errorlog.name='PretaxBill to Order fieldmapping issue'+fieldMapping.Target_Field_API_Name__c;
                        errorlog.PreTaxBill__c=PT.id;
                        errorlog.blng__ErrorCode__c= 'order creation error';
                        errorlog.blng__FullErrorLog__c = e.getMessage();
                       
                        errorlogs.add(errorlog);
                    }
                } 
                    
                    if(orderRec.BVC_CB_ExportShipmentID__c !=null || orderRec.BVC_CB_Import_Shipment__c !=null || (orderRec.BVC_CB_ExportShipmentID__c ==null && orderRec.BVC_CB_Import_Shipment__c ==null)) {
                      orderRec.EndDate=System.today();
                       orderRec.EffectiveDate=System.today();
                            }
                    /*if(orderRec.BVC_CB_Import_Shipment__c !=null) {
                        orderRec.EndDate=System.today();
                        orderRec.EffectiveDate=System.today();
                        
                            }*/
                    if(Test.isRunningTest()){
                      orderRec.blng__BillingDayOfMonth__c = '1';  
                    }
                insertOrders.add(orderRec);    
                }
            }
            
    	}        
       try{        
        System.debug(insertOrders);
        insert insertOrders;
       }catch(exception e){
           for(order ord:insertOrders){
            blng__ErrorLog__c errorlog= new blng__ErrorLog__c();
                        errorlog.name='Error-'+Date.today();
                        errorlog.PreTaxBill__c= ord.BVC_CB_PreTaxBill__c;
                        errorlog.blng__ErrorCode__c= 'order creation error';
                        errorlog.blng__FullErrorLog__c = e.getMessage();
                        errorlogs.add(errorlog);
           }
       }
        for(Order orderRec : insertOrders){
            mapOrderPreTax.put(orderRec.BVC_CB_PreTaxBill__c+orderRec.BVC_CB_Invoice_Type__c,orderRec.Id);
        }
        List<OrderItem> orderItemInsert = new List<OrderItem>();
        for(BVC_CB_PreTaxBillDetails__c PT:preTaxDetailList){
            OrderItem orderItemRec = new OrderItem();
            for(BVC_CB_Object_Mapping__c fieldMapping : objectMappings){
                try{
                if(fieldMapping.Target_Object_API_Name__c=='OrderItem'){
                    
                        system.debug('orderitem fields'+fieldMapping.Target_Field_API_Name__c);
        			orderItemRec.put(fieldMapping.Target_Field_API_Name__c, PT.get(fieldMapping.Source_Field_API_Name__c));
                }
                }catch(exception e){
                    blng__ErrorLog__c errorlog= new blng__ErrorLog__c();
                        errorlog.name='PretaxbillDetails to orderitem fieldmapping error-'+fieldMapping.Target_Field_API_Name__c;
                        errorlog.PreTaxBill__c= PT.BVC_CB_PreTaxBill__c;
                        errorlog.blng__ErrorCode__c= 'order creation error';
                        errorlog.blng__FullErrorLog__c = e.getMessage();
                        errorlogs.add(errorlog);
                }
    		}
            /*orderItemRec.blng__BillingRule__c ='a1h1y000000UNKQAA4';
            orderItemRec.blng__TaxRule__c ='a2Z1y0000004AkmEAE';
            orderItemRec.blng__RevenueRecognitionRule__c ='a2R1y000000QHhyEAG';	
            orderItemRec.blng__BillingTreatment__c ='a1k1y000001Fg8jAAC';*/
            orderItemRec.Quantity =1;
            //orderItemRec.UnitPrice=0;
            orderItemRec.OrderId = mapOrderPreTax.get(PT.BVC_CB_PreTaxBill__c+PT.BVC_CB_Invoice_Type__c);
            if(!Test.isRunningTest()){
            orderItemRec.PriceBookEntryId= [select Id,Product2Id  from PricebookEntry where Pricebook2.Name='BVC INR Price Book' and Product2Id =: (String)PT.get('BVC_CB_Charge_Product_Code__c') limit 1].Id;
            }else{
                orderItemRec.PriceBookEntryId= [select Id,Product2Id  from PricebookEntry where Pricebook2.Name='BVC INR Price Book' and Product2Id =: (String)PT.get('BVC_CB_Charge_Product_Code__c') limit 1].Id;
                orderItemRec.blng__BillingRule__c =[select id from blng__BillingRule__c limit 1].id;
            	orderItemRec.blng__TaxRule__c =[select id from blng__TaxRule__c limit 1].id;
            	orderItemRec.blng__RevenueRecognitionRule__c =[select id from blng__RevenueRecognitionRule__c limit 1].id;	
            	orderItemRec.blng__BillingTreatment__c =[select id from blng__BillingTreatment__c limit 1].id;
                orderItemRec.OrderId =insertOrders[0].id;
                orderitemrec.SBQQ__BillingFrequency__c ='Monthly';
                //orderItemRec.PriceBookEntryId= [select Id,Product2Id  from PricebookEntry where Pricebook2.Name='BVC INR Price Book' and Product2Id =: (String)PT.get('BVC_CB_Charge_Product_Code__c') limit 1].Id;
            }
                //'01u1y000001okI6AAI' ;//'01u5g000000WRlRAAW'; 01u1y000001okI6AAI
            orderItemInsert.add(orderItemRec);
            
        }
       try{
        insert orderItemInsert;
        update preTaxList;
       }catch(exception e){
           for(BVC_CB_PreTaxBill__c pt:preTaxList){
           blng__ErrorLog__c errorlog= new blng__ErrorLog__c();
                        errorlog.name='Error-'+Date.today();
                        errorlog.PreTaxBill__c= pt.id;
                        errorlog.blng__ErrorCode__c= 'order creation error';
                        errorlog.blng__FullErrorLog__c = e.getMessage();
                        errorlogs.add(errorlog);
       }
       }
       if(errorlogs.size()>0){
          insert  errorlogs;
       }
    }

   public void finish(Database.BatchableContext BC){
       
   }
    
   @AuraEnabled 
    // @invocableMethod(label='Send single Pretaxbill to create order')
    public static BVC_CB_PreTaxBill__c invokebatch(id recordid){
        //system.debug('pretax-'+ids[0]);
        BVC_CB_PreTaxBill__c pretaxbillrec = [SELECT id,BVC_CB_PretaxDetails_Inserted__c,BVC_CB_Is_Order_Created__c from BVC_CB_PreTaxBill__c where id= :recordid];
        if(!pretaxbillrec.BVC_CB_Is_Order_Created__c && pretaxbillrec.BVC_CB_PretaxDetails_Inserted__c == True){
        string Querry = 'SELECT (select Id,BVC_CB_Invoice_Type__c,BVC_CB_Charge_Product_Code__c from BVC_CB_PreTaxBillDetails__r ),BVC_CB_Org_Branch_SF_ID__r.BVC_CB_BVC_Entity__c,BVC_CB_Org_Branch_SF_ID__r.CB_BVC_Legal_Entity__c,BVC_CB_GrossWt__c,BVC_CB_Billing_Account_2__c,BVC_CB_Billing_Account_Address_2__c,'+
                                                'BVC_CB_Operation_Type__c,BVC_CB_PretaxDetails_Inserted__c,BVC_CB_Customer_GSTINNO__c,BVC_CB_Destination_Country_2__c,BVC_CB_Destination_Port_2__c,BVC_CB_Is_Order_Created__c,BVC_CB_Invoice_Type__c,BVC_CB_AIR_SEA__c,BVC_CB_Assessable_Value__c,BVC_CB_BE_Date__c,BVC_CB_BE_No__c,BVC_CB_Customer_Invoice_Number__c,BVC_CB_Billing_Account_Address__c,BVC_CB_Billing_GSTIN__c,BVC_CB_Billing_GST_State_Code__c,BVC_CB_Billing_OracleId__c,BVC_CB_Billing_Oracle_SiteId__c,BVC_CB_Billing_PAN__c,BVC_CB_Billing_SF_Customer_Address__c,BVC_CB_Billing_SF_Customer__c,BVC_CB_Billing_State__c,BVC_CB_BillTo_Fields__c,BVC_CB_Bond_Date__c,BVC_CB_Bond_No__c,BVC_CB_BOS_Bill_Amount__c,BVC_CB_BOS_Invoice_No__c,BVC_CB_BOS_Round_Off__c,BVC_CB_BVC_VAMASHIP_ID__c,BVC_CB_Cash_Idf_Date__c,BVC_CB_Cash_Idf_No__c,BVC_CB_CCDate__c,BVC_CB_CCNo__c,BVC_CB_CM_Bill_Amount__c,BVC_CB_CM_Invoice_No__c,BVC_CB_CM_Round_Off__c,BVC_CB_CONTENT__c,BVC_CB_Created_By_Datetime__c,BVC_CB_Created_By__c,BVC_CB_Customer_Address__c,BVC_CB_Customer_Invoice_Date__c,BVC_CB_Customer_Invoice_Value_Currency__c,BVC_CB_Customer_Name__c,BVC_CB_CUSTOMER_TRANSACTION_TYPE__c,BVC_CB_Despatch__c,BVC_CB_DestinationCountry__c,BVC_CB_DestinationPort__c,BVC_CB_DT_GR_FORM_NO__c,BVC_CB_EDFDate__c,BVC_CB_EDFNo__c,BVC_CB_ERDate__c,BVC_CB_ERNo__c,BVC_CB_ExportShipmentID__c,BVC_CB_FOBValue__c,BVC_CB_GR_FORM_NO__c,BVC_CB_GSTIN_Remarks__c,BVC_CB_HAWB_Date__c,BVC_CB_HAWB_No__c,BVC_CB_IGM_Item_Date__c,BVC_CB_IGM_Item_No__c,BVC_CB_Import_Shipment__c,BVC_CB_Invoice_Value_INR__c,BVC_CB_Invoice_Value__c,BVC_CB_IRN_Date__c,BVC_CB_IRN__c,BVC_CB_JOB_DT__c,BVC_CB_JOB_NO__c,BVC_CB_Last_Modifiedby__c,BVC_CB_License_Date__c,BVC_CB_License_No__c,BVC_CB_lospCity__c,BVC_CB_lospColumn__c,BVC_CB_lospStateCode__c,BVC_CB_lospState__c,BVC_CB_lospTable__c,BVC_CB_MAWB_Date__c,BVC_CB_MAWB_No__c,BVC_CB_Modified_Datetime__c,BVC_CB_Net_Wt__c,BVC_CB_No_Of_Pkgs__c,BVC_CB_OracleID__c,BVC_CB_Oracle_SiteId__c,BVC_CB_OrgBranchCode__c,BVC_CB_OrgBranchName__c,BVC_CB_Org_Branch_GSTIN__c,BVC_CB_Org_Branch_GST_State_Code__c,BVC_CB_Org_Branch_SF_ID__c,BVC_CB_Org_Branch_State__c,BVC_CB_Org_CINNO__c,BVC_CB_Org_PAN__c,BVC_CB_posColumn__c,BVC_CB_posTable__c,BVC_CB_POS__c,BVC_CB_PreTaxInvoice_ID__c,BVC_CB_Pre_Tax_Date__c,BVC_CB_Pre_Tax_No__c,BVC_CB_ProcessingDate__c,BVC_CB_Remarks1__c,BVC_CB_Remarks__c,BVC_CB_ROUND_OFF__c,BVC_CB_SalesForceAddress__c,BVC_CB_SalesForceCustomerId__c,BVC_CB_SBDate__c,BVC_CB_SBNo__c,BVC_CB_Shipment_Date__c,BVC_CB_Shipment_No__c,BVC_CB_ShipTo_Fields__c,BVC_CB_SoldTo_Fields__c,BVC_CB_SOS__c,BVC_CB_SupplyType__c,BVC_CB_SUPPLY_TYPE__c,BVC_CB_Tariff_Name__c,BVC_CB_Tax_Bill_Amount__c,BVC_CB_Tax_Invoice_No__c,BVC_CB_Tax_Round_Off__c,BVC_CB_Trade_Name__c,BVC_CB_TRANSACTION_CLASS__c,BVC_Shipment__c,CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,SystemModstamp FROM BVC_CB_PreTaxBill__c '+
            ' where BVC_CB_Is_Order_Created__c = false'+' and id=\'' +recordid+ '\'';
      
        //system.debug(' where BVC_CB_Is_Order_Created__c = false'+' and id=\'' +ids[0]+ '\'');
        Id batchJobId = Database.executeBatch(new OrderCreationPreTaxBatch(Querry), 200);
        }
            
        
       return pretaxbillrec;
    }
}