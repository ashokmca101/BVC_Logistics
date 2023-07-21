public class ShipOrderCreatnBathEshipBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful {
   // public string shipIds;
    List<Id> ids = new List<Id>();
    public ShipOrderCreatnBathEshipBatch(List<Id> ids){ 
        System.debug('Shipment Ids '+ids);
        this.ids = ids;   
    }
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
 
        string query = 'SELECT Id,Customer__r.Business_Type_eSHIP__c,Customer__r.Billing_Frequency__c,Customer__r.Business_Type_BATH__c,Customer__r.BATH_Contract__c,Customer__r.eSHIP_Contract__c,Net_Weight__c,Gross_Weight__c,Account__c,Destination_Address_City__c,Customer_Product_Category__c,Billing_Entity_Name_TMS__c,Product_Description__c,Shipment_Type__c,Shipment_Value__c,Destination_Type__c,Origin_Type__c,Destination_Address_Name__c,Billing_Account__c,Shipment_Date__c,Distance_Km__c, Account__r.Name,AddressBook__c,BillTo_Party_Address__c,BillTo_Party_Address__r.CITY__c,Origin_Hub__r.BVC_Entity__c,Hub_Master__c,Hub_Master__r.ST_BVC_Billing_Entity__c,Origin_Hub__c,Origin_Hub__r.ST_BVC_Billing_Entity__c,Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c,Origin_Address_Name__r.COUNTRY__c,Account__r.Customer_Category__c,Origin_Address_Name__c,Origin_Address_Name__r.STATE__c,Origin_Address_Name__r.TRADE_NAME__c,Origin_Address_Name__r.CITY__c,Origin_Address_Name__r.ADDRESS1__c,Origin_Address_Name__r.ADDRESS2__c,Shipper_Name_TMS__r.Name,Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,Consignee_Name_TMS__r.Name,Bill_To_Account__r.Customer_Category__c,BillTo_Party_Address__r.STATE__c,Bill_To_Account__r.Billing_Cycle__c,Bill_To_Account__r.Invoice_Batch__c,AddressBook__r.TRADE_NAME__c,Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c,BillTo_Party_Address__r.COUNTRY__c,BillTo_Party_Address__r.ADDRESS1__c,BillTo_Party_Address__r.ADDRESS2__c,Net_weight_in_Gram__c,Window_Delivery__c,Window_Pickup__c FROM Shipment__c WHERE Id IN :ids LIMIT 805';
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){
        System.debug('>>> execute start at ' + DateTime.now().format('yyyy/MM/dd hh:mm:ss'));
		integer count=0;
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<Product2> productBATH =[select Id,blng__RevenueRecognitionRule__c,blng__BillingRule__c,blng__TaxRule__c,ProductCode from Product2 where ProductCode IN ('BVC BATH','BVC eSHIP')];
        PricebookEntry pbEntryBath = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:productBATH[0].Id];
        PricebookEntry pbEntryeShip = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:productBATH[1].Id];
        
        
        system.debug('newShipment::::::::'+newShipment);
        Set<Id> shipIds = new Set<Id>();
        Map<Id,SBQQ__Quote__c> ShipIdQuoteMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,Decimal> BATHlogisCharge = new Map<Id,Decimal>();
        Map<Id,Decimal> BATHcommissionCharge = new Map<Id,Decimal>();
        
		
		Map<Id,Decimal> eSHIPAdditionalCharge = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPCODCharges = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPeSHIPFreight = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPFuelSurcharge = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPLiabilityCharges = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPWeightCharge = new Map<Id,Decimal>();        
        
        for(Shipment__c S:newShipment){
            shipIds.add(S.Id);
            S.Verified_for_Billing__c=true;
            S.Verified_for_Billling__c='Yes';
            if(S.Customer_Product_Category__c=='BATH' && S.Customer__r.Business_Type_BATH__c=='Non ACR'){
                if(S.Customer__r.Billing_Frequency__c=='Monthly' || S.Customer__r.Billing_Frequency__c=='Weekly'){
              		S.Status__c='Picked for Billing';  
                }else{
                    S.Status__c='Billed';
                }
            }else if(S.Customer_Product_Category__c=='eSHIP' && S.Customer__r.Business_Type_eSHIP__c=='Non ACR'){
                if(S.Customer__r.Billing_Frequency__c=='Monthly' || S.Customer__r.Billing_Frequency__c=='Weekly'){
              		S.Status__c='Picked for Billing';  
            	}else{
                    S.Status__c='Billed';
                }
            }
            
        }
        Set<Id> qtIds =new Set<Id>();
        List<SBQQ__Quote__c> newQuote = [select id,BVC_Entity__c,Billing_Address__c,BVC_Branch__c,BVC_Service__c,Shipment__c,SBQQ__NetAmount__c,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Ordered__c,CreatedDate from SBQQ__Quote__c  where Shipment__c IN :shipIds];
        for(SBQQ__Quote__c QtRec:newQuote){
            qtIds.add(QtRec.Id);
            ShipIdQuoteMap.put(QtRec.Shipment__c, QtRec);
        }
        List<SBQQ__QuoteLine__c> QtLinesList = [select id,SBQQ__ProductFamily__c,Shipment__c,SBQQ__ProductCode__c,SBQQ__ListPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : qtIds];
        for(SBQQ__QuoteLine__c QtLine:QtLinesList){
            if(QTline.SBQQ__ProductFamily__c=='BATH freight Charge'){
                if(QTline.SBQQ__ProductCode__c=='Bath Commission / Success Fees'){
                   BATHcommissionCharge.put(QTline.Shipment__c,(QTline.SBQQ__ListPrice__c));
                }
                else if(QTline.SBQQ__ProductCode__c=='Bath Fright Secure Logistics Charges'){
                   BATHlogisCharge.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c);
                }
            }
            
            else if(QTline.SBQQ__ProductFamily__c=='Eship freight Charge'){
                   if(QTline.SBQQ__ProductCode__c=='Additional Charge'){
                   		eSHIPAdditionalCharge.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c);
                   }else if(QTline.SBQQ__ProductCode__c=='COD Charges'){
                       eSHIPCODCharges.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c);
                   }else if(QTline.SBQQ__ProductCode__c=='eSHIP Freight'){
                       eSHIPeSHIPFreight.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c); 
                   }else if(QTline.SBQQ__ProductCode__c=='Fuel Surcharge'){
                       eSHIPFuelSurcharge.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c);
                   }else if(QTline.SBQQ__ProductCode__c=='Liability Charges'){
                       eSHIPLiabilityCharges.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c);
                   }else if(QTline.SBQQ__ProductCode__c=='Weight Charge'){
                       eSHIPWeightCharge.put(QTline.Shipment__c,QTline.SBQQ__ListPrice__c);
                  }  
            }
        }
        system.debug(':::Order Create:::'+newShipment);
        List<Order> orders2Update = new List<Order>();
        if(newShipment.size()>0){
            for(Shipment__c ship : newShipment){
                count++;
                System.debug(':::::order creation count:::::::::'+count);
                Order o = new Order();
                o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();
                o.Business_Type__c = 'Shipment';
                o.AccountId = ship.Bill_To_Account__c;
                o.blng__BillingAccount__c = ship.Bill_To_Account__c;
                if(ship.Shipment_Date__c != null){
                    o.Shipment_Date__c = ship.Shipment_Date__c;
                }
                o.EffectiveDate = System.today();
                o.EndDate = System.today();
                o.SBQQ__PaymentTerm__c = 'Net 30';
                o.Shipment__c = ship.Id;
                //o.Shipment_Number__c = ship.Shipping_Note_Number__c;
                if(ship.Customer_Product_Category__c=='BATH' && ship.Customer__r.BATH_Contract__c!=null){
                    o.Contract_ID_Map__c=ship.Customer__r.BATH_Contract__c;
                }else if(ship.Customer_Product_Category__c=='eSHIP' && ship.Customer__r.eSHIP_Contract__c!=null){
                    o.Contract_ID_Map__c=ship.Customer__r.eSHIP_Contract__c;
                }
                
                o.Status = 'Draft';
                o.Type = 'New';
                if( ship.Billing_Account__c!=null){
                    o.blng__BillingAccount__c = ship.Billing_Account__c;
                }
                if(ship.Origin_Address_Name__c!=null){
                   o.Origin_Address__c = ship.Origin_Address_Name__c; 
                }
                if(ship.Destination_Address_Name__c!=null){
                  o.Destination_Address__c = ship.Destination_Address_Name__c;  
                }
                if(ship.Origin_Type__c!=null){
                  o.Origin_Type__c = ship.Origin_Type__c;  
                }
                if(ship.Destination_Type__c!=null){
                  o.Destination_Type__c = ship.Destination_Type__c;  
                }
                if(ship.Shipment_Value__c!=null){
                  o.Shipment_Value__c = ship.Shipment_Value__c;  
                }
                if(ship.Shipment_Type__c!=null){
                  o.Shipment_Type__c = ship.Shipment_Type__c;  
                }
                
                o.Shipment_Status_Static__c = 'Picked for Billing';
                if(ship.Product_Description__c!=null){
                   o.Product_Description__c = ship.Product_Description__c; 
                }
                if(ShipIdQuoteMap.get(ship.Id).BVC_Branch__c!=null){
                   o.BVC_Branch__c = ShipIdQuoteMap.get(ship.Id).BVC_Branch__c; 
                }
                if(ship.Billing_Entity_Name_TMS__c!=null){
                  o.BVC_Billing_Entity__c = ship.Billing_Entity_Name_TMS__c;  
                }
                if(ShipIdQuoteMap.get(ship.Id).BVC_Entity__c!=null){
                  o.BVC_Entity__c = ShipIdQuoteMap.get(ship.Id).BVC_Entity__c;  
                }
                if(ShipIdQuoteMap.get(ship.Id).Id!=null){
                   o.SBQQ__Quote__c=ShipIdQuoteMap.get(ship.Id).Id; 
                }
                if(ShipIdQuoteMap.get(ship.Id).Billing_Address__c!=null){
                  o.Billing_Address__c = ShipIdQuoteMap.get(ship.Id).Billing_Address__c;  
                }
                o.Pricebook2Id = BVCPricebook.Id;
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
            shipOrderMap.put(od.Shipment__c,od.Id);     
        }
       

        List<OrderItem> ordersItems2Update = new List<OrderItem>();
        for(Shipment__c ship : newShipment){
            OrderItem oi = new OrderItem();
            if(ship.Customer_Product_Category__c=='BATH'){
                oi.blng__BillingRule__c = productBATH[0].blng__BillingRule__c;
            	oi.blng__RevenueRecognitionRule__c = productBATH[0].blng__RevenueRecognitionRule__c;
            	oi.blng__TaxRule__c = productBATH[0].blng__TaxRule__c;
            	oi.Product2Id = productBATH[0].Id;
                oi.PricebookEntryId = pbEntryBath.Id; 
            }else if(ship.Customer_Product_Category__c=='eSHIP'){
                oi.blng__BillingRule__c = productBATH[1].blng__BillingRule__c;
            	oi.blng__RevenueRecognitionRule__c = productBATH[1].blng__RevenueRecognitionRule__c;
            	oi.blng__TaxRule__c = productBATH[1].blng__TaxRule__c;
            	oi.Product2Id = productBATH[1].Id;
                oi.PricebookEntryId = pbEntryeShip.Id;
            }
            if(ship.Net_weight_in_Gram__c!=null){
              oi.Net_Weight_gms__c = ship.Net_weight_in_Gram__c;  
            }
            oi.EndDate = System.today();
            oi.OrderId = shipOrderMap.get(ship.Id);
            oi.Quantity = 1;
            
            //oi.ST_Rate_UOM__c = IdshipCalcMap.get(ship.Id).rateUOM;
            
            oi.SBQQ__ChargeType__c = 'One-Time'; 
            oi.SBQQ__BillingFrequency__c = '';
            if(ship.Customer_Product_Category__c!=null){
               oi.ST_Customer_Product_Category__c = ship.Customer_Product_Category__c; 
            }
            
     		oi.Shipment__c = ship.Id;
            if(ship.Shipment_Date__c!=null){
               oi.Shipment_Date__c = ship.Shipment_Date__c; 
            }
            
            //oi.Shipper_Name__c = shipRelatedMap.get(ship.Id).Shipper_Name_TMS__r.Name;
            //oi.Consignee_Name__c = shipRelatedMap.get(ship.Id).Consignee_Name_TMS__r.Name;
            if(ship.Origin_Address_Name__c!=null){
               oi.Origin_Address_Name__c = ship.Origin_Address_Name__c; 
            }
            if(ship.Destination_Address_City__c!=null){
              oi.Destination_City__c = ship.Destination_Address_City__c;  
            }
            if(ship.Gross_Weight__c!=null){
               oi.Gross_Weight__c = ship.Gross_Weight__c; 
            }
            if(ship.Net_Weight__c!=null){
              oi.Net_Weight__c = ship.Net_Weight__c;  
            }
            if(ShipIdQuoteMap.get(ship.Id).BVC_Branch__c!=null){
              oi.BVC_Branch__c = ShipIdQuoteMap.get(ship.Id).BVC_Branch__c;  
            }
            if(ShipIdQuoteMap.get(ship.Id).BVC_Entity__c!=null){
              oi.BVC_Entity__c = ShipIdQuoteMap.get(ship.Id).BVC_Entity__c;  
            }
            if(ship.Billing_Entity_Name_TMS__c!=null){
               oi.blng__LegalEntity__c = ship.Billing_Entity_Name_TMS__c; 
            }
            if(ship.Shipment_Date__c!=null){
               oi.blng__NextBillingDate__c = ship.Shipment_Date__c; 
            }
            
            oi.ServiceDate=Date.Today();
            //oi.blng__OverrideNextBillingDate__c = ship.Shipment_Date__c;

            oi.SBQQ__SubscriptionType__c = 'One-Time';
            oi.SBQQ__ProductSubscriptionType__c = 'One-time';
            oi.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            if(ship.Shipment_Type__c!=null){
               oi.Shipment_Type__c = ship.Shipment_Type__c; 
            }
            
            oi.SBQQ__ContractingMethod__c = 'Inherit';
            oi.SBQQ__PricingMethod__c = 'List';
            // Total Bath
            if(BATHlogisCharge.get(ship.Id)!=null){
              oi.Logistics_Charges__c=BATHlogisCharge.get(ship.Id);  
            }
            if(BATHcommissionCharge.get(ship.Id)!=null){
               oi.Commission_Charges__c=BATHcommissionCharge.get(ship.Id); 
            }
            
            if(eSHIPAdditionalCharge.get(ship.Id)!=null){
               oi.Additional_Charges_eSHIP__c=eSHIPAdditionalCharge.get(ship.Id); 
            }
            if(eSHIPCODCharges.get(ship.Id)!=null){
               oi.COD_Charges_eSHIP__c=eSHIPCODCharges.get(ship.Id); 
            }
            if(eSHIPeSHIPFreight.get(ship.Id)!=null){
              oi.Freight_Charges_eSHIP__c=eSHIPeSHIPFreight.get(ship.Id);  
            }
            if(eSHIPFuelSurcharge.get(ship.Id)!=null){
              oi.Fuel_Surcharges_eSHIP__c=eSHIPFuelSurcharge.get(ship.Id);  
            }
            if(eSHIPLiabilityCharges.get(ship.Id)!=null){
               oi.Liability_Charges_eSHIP__c=eSHIPLiabilityCharges.get(ship.Id); 
            }
            if(eSHIPWeightCharge.get(ship.Id)!=null){
              oi.Weight_Charges_eSHIP__c=eSHIPWeightCharge.get(ship.Id);  
            }
            
            //Total eSHIP
            if(ship.Customer_Product_Category__c=='BATH'){
                oi.UnitPrice = oi.Logistics_Charges__c+oi.Commission_Charges__c;
                oi.blng__BillableUnitPrice__c= oi.Logistics_Charges__c+oi.Commission_Charges__c;
            }else if(ship.Customer_Product_Category__c=='eSHIP'){
                oi.Secure_Logistics_Charges__c=eSHIPAdditionalCharge.get(ship.Id)+eSHIPCODCharges.get(ship.Id)+eSHIPeSHIPFreight.get(ship.Id)+eSHIPFuelSurcharge.get(ship.Id)+eSHIPLiabilityCharges.get(ship.Id)+eSHIPWeightCharge.get(ship.Id);
                oi.UnitPrice = oi.Secure_Logistics_Charges__c;
                oi.blng__BillableUnitPrice__c=oi.Secure_Logistics_Charges__c;
            }  
            ordersItems2Update.add(oi);  
                   
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
        if(newShipment.size()>0){
            update newShipment;
        }
        System.debug('>>> execute end at ' + DateTime.now().format('yyyy/MM/dd hh:mm:ss'));
        
    }
    public void finish(Database.BatchableContext bc){
        ShipmentBulkVerificationHndlr newdata = new ShipmentBulkVerificationHndlr();
        newdata.sendMail('Hello sir , Your Bulk Verification is Done.');      
       
    }
    
}