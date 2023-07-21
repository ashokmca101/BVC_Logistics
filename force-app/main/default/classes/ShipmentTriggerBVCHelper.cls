public class ShipmentTriggerBVCHelper {

    Public static List<SBQQ__Quote__c> insertRecord(List<Shipment__c> newShipment){
        
        set<Id> accId =new set<Id>();
        set<Id> ShipId =new set<Id>();
        for(Shipment__c ship:newShipment){
            accId.add(ship.Customer__c);
            ShipId.add(ship.id); 
        }
        List<Account> AccList =[select id,eSHIP_Contract__c,BATH_Contract__c  from Account where Id IN :accId];
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        set<Id> ConId =new set<Id>();
        for(Account A:AccList){
            if(A.eSHIP_Contract__c!=null || A.BATH_Contract__c!=null){
                ConId.add(A.eSHIP_Contract__c);
                ConId.add(A.BATH_Contract__c);
            }
        }
        integer PackageToTest;  
        List<Contract> conList =[select id,Account.Billing_Address__c,BVC_Entity__c,BVC_Billing_Entity__c,Slab_Criteria__c,Is_Legacy_Contract__c,Contract_Amount__c,BVC_Branch__c,Tariff_Plan__c,AccountId,BVC_Service__c,Contracted_ACR_Package__c,Business_Type__c   from Contract where Id IN :ConId];//getting eship contracts
        List<SBQQ__Quote__c> newQuoteList= new List<SBQQ__Quote__c>();
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();
        for (Shipment__c shipment : newShipment){ 
                SBQQ__Quote__c newQuote= new SBQQ__Quote__c();
                if(conList.size()>0){
                    for(Contract C:conList){
                        if(C.BVC_Service__c==shipment.Customer_Product_Category__c || C.BVC_Service__c==shipment.Customer_Product_Category__c){
                            if(C.AccountId==shipment.Customer__c){
                                
                                if(C.Contract_Amount__c!=null){
                                   PackageToTest=Integer.valueOf(C.Contract_Amount__c);
                                   newQuote.Package_Amount__c=String.valueOf(PackageToTest);
                                }
                                newQuote.Is_Legacy_Contract__c=C.Is_Legacy_Contract__c;
                                if(C.Tariff_Plan__c!=null){
                                    newQuote.Tariff_Plan_Bath_Eship__c=C.Tariff_Plan__c;
                                }
                                if(C.BVC_Branch__c!=null){
                                    newQuote.BVC_Branch__c=C.BVC_Branch__c;
                                }
                                if(C.BVC_Billing_Entity__c!=null){
                                    newQuote.BVC_Billing_Entity__c=C.BVC_Billing_Entity__c;
                                }
                                if(C.BVC_Entity__c!=null){
                                    newQuote.BVC_Entity__c=C.BVC_Entity__c;
                                }
                                if(C.Slab_Criteria__c!=null){
                                  newQuote.Slab_Criteria__c=C.Slab_Criteria__c;  
                                }
                                if(C.Account.Billing_Address__c!=null){newQuote.Billing_Address__c=C.Account.Billing_Address__c;
                                }
                                newQuote.Business_Type__c=C.Business_Type__c;//mapping from contract eship
                            }
                        }
                    }
                }
                if(shipment.Customer__c!=null){
                  newQuote.SBQQ__Account__c=shipment.Customer__c;  
                }
                //system.debug('record type id'+gsRecordTypeID);
                newQuote.RecordTypeId=gsRecordTypeID;
               
                newQuote.Shipment__c=shipment.Id; 
                //newQuote.SBQQ__Primary__c=true; 
                newQuote.SBQQ__PricebookId__c=BVCPricebook.id;
                newQuote.SBQQ__SubscriptionTerm__c=12;
                newQuote.SBQQ__StartDate__c=Date.today();
                newQuote.Contract_Signed_Date__c=Date.today();
                if(shipment.Total_Invoice_Value__c!=null){
                    newQuote.Total_Invoice_Value__c = shipment.Total_Invoice_Value__c;  
                }
                newQuote.BVC_Service__c = shipment.Customer_Product_Category__c;
                if(shipment.Visit_Outcome__c!=null){
                    newQuote.Visit_Outcome__c = shipment.Visit_Outcome__c;  
                }            
                if(shipment.Origin_Destination_Pairing__c!=null){
                    newQuote.Origin_Destination_Pairing__c = shipment.Origin_Destination_Pairing__c;
                }         
                
                if(shipment.Net_Weight__c!=null){
                    newQuote.Net_Weight__c = shipment.Net_Weight__c;
                }
                if(shipment.Gross_Weight__c!=null){
                    newQuote.BVC_Gross_Weight__c = shipment.Gross_Weight__c;
                }
                if(shipment.Shipment_Type__c!=null){
                    newQuote.Shipment_Type__c = shipment.Shipment_Type__c;
                }
                if(shipment.Net_Weight_UOM__c!=null){
                    newQuote.Net_Weight_UOM__c = shipment.Net_Weight_UOM__c;
                }
                if(shipment.Gross_Weight_UOM__c!=null){
                    newQuote.Gross_Weight_UOM__c = shipment.Gross_Weight_UOM__c;
                } 
                newQuoteList.add(newQuote);
            }
            if(newQuoteList.size()>0){
                insert newQuoteList;
            }
        return newQuoteList;
    }
    Public static void createOrderNew(List<Shipment__c> newShipment){
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
        }
        Set<Id> qtIds =new Set<Id>();
        List<SBQQ__Quote__c> newQuote = [select id,SBQQ__Account__c,SBQQ__Account__r.eSHIP_Contract__c,SBQQ__Account__r.BATH_Contract__c,BVC_Entity__c,Billing_Address__c,BVC_Branch__c,BVC_Service__c,Shipment__c,SBQQ__NetAmount__c,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Ordered__c,CreatedDate from SBQQ__Quote__c  where Shipment__c IN :shipIds];
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
                if(ship.Customer_Product_Category__c=='BATH' && ShipIdQuoteMap.get(ship.Id).SBQQ__Account__r.BATH_Contract__c!=null){
                    o.Contract_ID_Map__c=ShipIdQuoteMap.get(ship.Id).SBQQ__Account__r.BATH_Contract__c;
                }else if(ship.Customer_Product_Category__c=='eSHIP' && ShipIdQuoteMap.get(ship.Id).SBQQ__Account__r.eSHIP_Contract__c !=null){
                    o.Contract_ID_Map__c=ShipIdQuoteMap.get(ship.Id).SBQQ__Account__r.eSHIP_Contract__c; 
                }
                
                o.Status = 'Draft';
                o.Type = 'New';
                if( ship.Billing_Account__c!=null){
                    o.blng__BillingAccount__c = ship.Billing_Account__c;
                }
                if(ship.Origin_Address_Name__c!=null){
                   o.Origin_Address__c = ship.Origin_Address_Name__c; 
                }else{
                    o.Origin_Address__c=ShipIdQuoteMap.get(ship.Id).Billing_Address__c;
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
                //oi.Secure_Logistics_Charges__c=oi.Additional_Charges_eSHIP__c+oi.COD_Charges_eSHIP__c+oi.Freight_Charges_eSHIP__c+oi.Fuel_Surcharges_eSHIP__c+oi.Liability_Charges_eSHIP__c+oi.Weight_Charges_eSHIP__c;
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
    }
    /*Public static void createOrder(List<Shipment__c> newShipment){
        
        Set<Id> shipIds = new Set<Id>();
        Set<Id> CusIds = new Set<Id>();
        Map<Id,Decimal> logisCharge = new Map<Id,Decimal>();
        Map<Id,Decimal> commissionCharge = new Map<Id,Decimal>();
        Map<Id,Decimal> secureLogisCharge = new Map<Id,Decimal>();
        Map<Id,String> secureLogisChargeMap = new Map<Id,String>();
        
        Map<Id,Decimal> eSHIPAdditionalCharge = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPCODCharges = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPeSHIPFreight = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPFuelSurcharge = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPLiabilityCharges = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPWeightCharge = new Map<Id,Decimal>();
        
        eShipCharges eshipChargesJson = new eShipCharges();
        for(Shipment__c S:newShipment){
            shipIds.add(S.Id);
            CusIds.add(S.Customer__c);
        }
        Set<Id> qtIds =new Set<Id>();
        List<SBQQ__Quote__c> newQuote = [select id,BVC_Branch__c,BVC_Service__c,Shipment__c,SBQQ__NetAmount__c,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Ordered__c,CreatedDate from SBQQ__Quote__c  where Shipment__c IN :shipIds];
        for(SBQQ__Quote__c QtRec:newQuote){
            qtIds.add(QtRec.Id);
        }
        List<SBQQ__QuoteLine__c> QtLines = [select id,SBQQ__ProductFamily__c,SBQQ__ProductCode__c,SBQQ__ListPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : qtIds];
        for(SBQQ__QuoteLine__c QtLine:QtLines){
            if(QTline.SBQQ__ProductFamily__c=='BATH freight Charge'){
                if(QTline.SBQQ__ProductCode__c=='Bath Commission / Success Fees'){
                    if(commissionCharge.get(QTline.SBQQ__Quote__c)!=null){
                        decimal OldCommicharge=commissionCharge.get(QTline.SBQQ__Quote__c);
                        commissionCharge.put(QTline.SBQQ__Quote__c,(QTline.SBQQ__ListPrice__c+OldCommicharge));
                    }else{
                        commissionCharge.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                    }
                }
                else if(QTline.SBQQ__ProductCode__c=='Bath Fright Secure Logistics Charges'){
                    if(logisCharge.get(QTline.SBQQ__Quote__c)!=null){
                        decimal Oldlogischarge=logisCharge.get(QTline.SBQQ__Quote__c);
                        logisCharge.put(QTline.SBQQ__Quote__c,(QTline.SBQQ__ListPrice__c+Oldlogischarge));
                    }else{
                        logisCharge.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                    }
                }
            }
            
            else if(QTline.SBQQ__ProductFamily__c=='Eship freight Charge'){
                 if(QTline.SBQQ__ProductCode__c=='Additional Charge'){
                      eshipChargesJson.AdditionalCharge=QTline.SBQQ__ListPrice__c;
                      eSHIPAdditionalCharge.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                      //QTline.Additional_Charges_eSHIP__c=QTline.SBQQ__ListPrice__c;
                   }else if(QTline.SBQQ__ProductCode__c=='COD Charges'){
                       eshipChargesJson.CODCharges=QTline.SBQQ__ListPrice__c;
                       eSHIPCODCharges.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                       //QTline.COD_Charges_eSHIP__c=QTline.SBQQ__ListPrice__c;
                   }else if(QTline.SBQQ__ProductCode__c=='eSHIP Freight'){
                       eshipChargesJson.eSHIPFreight=QTline.SBQQ__ListPrice__c;
                       eSHIPeSHIPFreight.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                       //QTline.Freight_Charges_eSHIP__c=QTline.SBQQ__ListPrice__c; 
                   }else if(QTline.SBQQ__ProductCode__c=='Fuel Surcharge'){
                       eshipChargesJson.FuelSurcharge=QTline.SBQQ__ListPrice__c;
                       eSHIPFuelSurcharge.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                       //QTline.Fuel_Surcharges_eSHIP__c=QTline.SBQQ__ListPrice__c;
                   }else if(QTline.SBQQ__ProductCode__c=='Liability Charges'){
                       eshipChargesJson.LiabilityCharges=QTline.SBQQ__ListPrice__c;
                       eSHIPLiabilityCharges.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                       //QTline.Liability_Charges_eSHIP__c=QTline.SBQQ__ListPrice__c;
                   }else if(QTline.SBQQ__ProductCode__c=='Weight Charge'){
                       eshipChargesJson.WeightCharge=QTline.SBQQ__ListPrice__c;
                       eSHIPWeightCharge.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                       //QTline.Weight_Charges_eSHIP__c=QTline.SBQQ__ListPrice__c;
                  }
                string eSHIPJSON = JSON.serialize(eshipChargesJson);
                secureLogisChargeMap.put(QTline.SBQQ__Quote__c,eSHIPJSON);
                if(secureLogisCharge.get(QTline.SBQQ__Quote__c)!=null){
                   decimal OldSecurelogischarge=secureLogisCharge.get(QTline.SBQQ__Quote__c);
                   secureLogisCharge.put(QTline.SBQQ__Quote__c,(QTline.SBQQ__ListPrice__c+OldSecurelogischarge));
                }else{
                   secureLogisCharge.put(QTline.SBQQ__Quote__c,QTline.SBQQ__ListPrice__c);
                }
            }
        }
        
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<Product2> productBATH =[select Id,ProductCode from Product2 where ProductCode IN ('BVC BATH','BVC eSHIP')];
        List<SBQQ__QuoteLine__c>  quoteLineList = new List<SBQQ__QuoteLine__c>();
        PricebookEntry pbEntryBath = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:productBATH[0].Id];
        PricebookEntry pbEntryeShip = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:productBATH[1].Id];
        for(SBQQ__Quote__c QtRec:newQuote){
            if(QtRec.BVC_Service__c=='BATH'){
                SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        		quoteLine1.SBQQ__PricebookEntryId__c=pbEntryBath.Id;
        		quoteLine1.SBQQ__ChargeType__c='One-Time';
        		quoteLine1.SBQQ__Product__c=productBATH[0].id;
        		quoteLine1.SBQQ__StartDate__c=Date.Today();
                quoteLine1.SBQQ__EndDate__c=Date.Today();
        		quoteLine1.SBQQ__Quantity__c=1;
                quoteLine1.Shipment__c=QtRec.Shipment__c;
                quoteLine1.SBQQ__SubscriptionType__c = 'One-Time';
            	quoteLine1.SBQQ__ProductSubscriptionType__c = 'One-time';
            	quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        		
        		//quoteLine1.SBQQ__SubscriptionTerm__c = 1;
        		quoteLine1.SBQQ__NetPrice__c=commissionCharge.get(QtRec.Id)+logisCharge.get(QtRec.Id);
        		quoteLine1.SBQQ__ListPrice__c=commissionCharge.get(QtRec.Id)+logisCharge.get(QtRec.Id);
                quoteLine1.Commission_Charges__c=commissionCharge.get(QtRec.Id);
                quoteLine1.Logistics_Charges__c=logisCharge.get(QtRec.Id);
                quoteLine1.BVC_Branch__c=QtRec.BVC_Branch__c;
                quoteLine1.BATHeSHIPChargesMap__c='Bath Commission Success Fees '+commissionCharge.get(QtRec.Id)+'-'+'Bath Fright Secure Logistics Charges'+logisCharge.get(QtRec.Id);
        		quoteLine1.SBQQ__Quote__c=QtRec.Id;
            	quoteLineList.add(quoteLine1);
            }else if(QtRec.BVC_Service__c=='eSHIP'){
                SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        		quoteLine2.SBQQ__PricebookEntryId__c=pbEntryeShip.Id;
        		quoteLine2.SBQQ__ChargeType__c='One-Time';
                quoteLine2.BVC_Branch__c=QtRec.BVC_Branch__c;
        		quoteLine2.SBQQ__Product__c=productBATH[1].id;
        		quoteLine2.SBQQ__StartDate__c=Date.Today();
                quoteLine2.SBQQ__EndDate__c=Date.Today();
        		quoteLine2.SBQQ__Quantity__c=1;
                quoteLine2.Shipment__c=QtRec.Shipment__c;
        		quoteLine2.SBQQ__SubscriptionType__c = 'One-Time';
            	quoteLine2.SBQQ__ProductSubscriptionType__c = 'One-time';
            	quoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        		//quoteLine2.SBQQ__SubscriptionTerm__c = 1;
        		quoteLine2.SBQQ__NetPrice__c=secureLogisCharge.get(QtRec.Id);
        		quoteLine2.SBQQ__ListPrice__c=secureLogisCharge.get(QtRec.Id);
                quoteLine2.Secure_Logistics_Charges__c=secureLogisCharge.get(QtRec.Id);
                quoteLine2.BATHeSHIPChargesMap__c=secureLogisChargeMap.get(QtRec.Id);
                eShipCharges eshipj=(eShipCharges)JSON.deserialize(secureLogisChargeMap.get(QtRec.Id),eShipCharges.class );
                quoteLine2.Additional_Charges_eSHIP__c=eshipj.AdditionalCharge;
                quoteLine2.COD_Charges_eSHIP__c=eshipj.CODCharges;
                quoteLine2.Freight_Charges_eSHIP__c=eshipj.eSHIPFreight;
                quoteLine2.Fuel_Surcharges_eSHIP__c=eshipj.FuelSurcharge;
                quoteLine2.Liability_Charges_eSHIP__c=eshipj.LiabilityCharges;
                quoteLine2.Weight_Charges_eSHIP__c=eshipj.WeightCharge;
                
                /*quoteLine2.Additional_Charges_eSHIP__c=eSHIPAdditionalCharge.get(QtRec.Id);
                quoteLine2.COD_Charges_eSHIP__c=eSHIPCODCharges.get(QtRec.Id);
                quoteLine2.Freight_Charges_eSHIP__c=eSHIPeSHIPFreight.get(QtRec.Id);
                quoteLine2.Fuel_Surcharges_eSHIP__c=eSHIPFuelSurcharge.get(QtRec.Id);
                quoteLine2.Liability_Charges_eSHIP__c=eSHIPLiabilityCharges.get(QtRec.Id);
                quoteLine2.Weight_Charges_eSHIP__c=eSHIPWeightCharge.get(QtRec.Id);*/
        		
               /*quoteLine2.SBQQ__Quote__c=QtRec.Id;
            	quoteLineList.add(quoteLine2);
            }
        }
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        if(QtLines.size()>0){
            Delete QtLines;
        }
        for(Shipment__c S:newShipment){
          for(SBQQ__Quote__c quote:newQuote){
              if(quote.SBQQ__Status__c=='Draft' && quote.Shipment__c==S.Id && quote.SBQQ__NetAmount__c>0){
                 quote.SBQQ__Status__c='Ordered';
                 quote.SBQQ__Ordered__c=true;
               }
           }
        }        
        if(newQuote.size()>0){
            update newQuote; 
        }
        
    } */
    
    Public static void deleteOldQuote(List<Shipment__c> newShipment){
        
        Set<Id> shipIds = new Set<Id>();
        for(Shipment__c S:newShipment){
            shipIds.add(S.Id);
        }
        List<SBQQ__Quote__c> newQuote = [select id from SBQQ__Quote__c  where Shipment__c IN :shipIds ORDER BY CreatedDate Desc Limit 1];   

        if(newQuote.size()>0){
            delete newQuote;
        }
        
    } 
    Public static void rebillingOrder(List<Shipment__c> newShipment){
        Set<Id> ShipIds = new Set<Id>();
        for(Shipment__c ship:newShipment){
            ShipIds.add(ship.Id);
        }
        List<Order> orderList = [select id,Shipment__c from Order where Shipment__c IN :ShipIds];
        Set<Id> orderIds = new Set<Id>();
        for(Order Odr:orderList){
            orderIds.add(Odr.Id);
        }
        List<ST_ACR_Consumption__c> ACRConsumedLst =[select id,ST_ACR_Order__c from ST_ACR_Consumption__c where ST_ACR_Order__c IN :orderIds];
        if(ACRConsumedLst.size()>0){
            system.debug('ACRConsumedLst =======delete'+ACRConsumedLst);
            delete ACRConsumedLst;
        }
        Set<Id> orderInvoicedList = new Set<Id>();
        List<blng__InvoiceLine__c> invoiceLineList = [select id,blng__OrderProduct__r.OrderId from blng__InvoiceLine__c where Shipment__c IN :ShipIds];
        for(blng__InvoiceLine__c invLine:invoiceLineList){
            orderInvoicedList.add(invLine.blng__OrderProduct__r.OrderId); 
            
        }
        //List<blng__Invoice__c> invoiceList = [select id,blng__Order__c from blng__Invoice__c where blng__Order__c IN :orderIds];
        //for(blng__Invoice__c inv:invoiceList){
            //inv.Invoice_Cancellation_Status__c='Cancelled';
            //orderInvoicedList.add(inv.blng__Order__c); 
            
        //}
        for(Order O:orderList){
            if(!orderInvoicedList.contains(O.ID)){
               O.Status='Cancelled';   
           }	
        }
        //if(invoiceList.size()>0){
            //Update invoiceList;
        //}
        
        if(orderList.size()>0){
        	Update orderList;  
        }
    } 
    
    public static void updateQuote(set<id> shipmentid){
        list<SBQQ__Quote__c> qlist = [select id,  Quick_Calculate_BVC__c,Shipment__c from SBQQ__Quote__c where Shipment__c IN : shipmentid];
		for(SBQQ__Quote__c  q1 : qlist){
            if(q1.Quick_Calculate_BVC__c == true){
                q1.Quick_Calculate_BVC__c = false;
                        
            }else{
                q1.Quick_Calculate_BVC__c = true;
            }
        }
        update qlist;
                
    }
}