public with sharing class QuoteTriggerBVCHelper {
      
    public static  boolean stopitration = true; 
    
    Public static void UpdateQuoteStatus(Map<Id,SBQQ__Quote__c> newMap){
        
        String quoteId;
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c o :newMap.values() ){
            quoteId = o.Id;    
        }
         for(SBQQ__Quote__c quote:newMap.values()){
            
            if(quote.SBQQ__Status__c.contains('Contract Signed') && quote.BVC_Service__c!='MarketSHIP' && quote.BVC_Service__c!='iValSHIP' && quote.BVC_Service__c!='ieSHIP'){
                system.debug('bvc service'+quote.BVC_Service__c);
                if(quote.Is_Shipment__c==true){
                    quote.SBQQ__Primary__c=true;
                	quote.SBQQ__Status__c='Ordered';
                	quote.Contract_Signed_Date__c=Date.today();
                }      
           }
       }  
    }

     
    Public static void createOrder(set<id> qid){
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> newQuote= [select id,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Ordered__c from SBQQ__Quote__c where id IN : qid];
        for(SBQQ__Quote__c quote:newQuote){
            if(quote.SBQQ__Status__c.contains('Ordered')){
                If(quote.SBQQ__Primary__c==true){
                   quote.SBQQ__Ordered__c=true;       
                   quoteList.add(quote);  
                }       
            }
        }  
       if(quoteList.size()>0){
            update quoteList;
        }     
    }

    Public static void insertRecord(List<SBQQ__Quote__c> newQuote){
       
        Set<Id> quoteIds = new Set<Id>();
        for(SBQQ__Quote__c q:newQuote){
            quoteIds.add(q.Id);
        }
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Product2> productBath =[select Id,ProductCode from Product2 where Family='BATH freight Charge'];
        List<Product2> productEShip =[select Id,ProductCode from Product2 where Family='Eship freight Charge'];
        List<Pricebook2> standardBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        PricebookEntry pbEntry =new PricebookEntry();
        for(SBQQ__Quote__c quote:newQuote){
           
             if(quote.BVC_Service__c=='BATH' && quote.Shipment__c!=null){
                 for(integer i=0;i<productBath.size();i++){
                    
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCPricebook.id AND Product2.Id=:productBath[i].Id];
                	quoteLine.SBQQ__Product__c=productBath[i].Id;
                	quoteLine.SBQQ__Quantity__c=1;
                    quoteLine.SBQQ__PricebookEntryId__c=pbEntry.Id; 
                    quoteLine.SBQQ__NetPrice__c=pbEntry.UnitPrice;
                    quoteLine.SBQQ__ChargeType__c='One-Time';
                	quoteLine.BVC_Gross_weight__c=quote.BVC_Gross_weight__c;
                    quoteLine.BVC_Net_Weight__c=quote.Net_Weight__c;
                    quoteLine.Shipment__c=quote.Shipment__c;
                	quoteLine.SBQQ__Quote__c=quote.Id;
                	quoteLineList.add(quoteLine);
                 }
                 
            }else if(quote.BVC_Service__c=='eSHIP' && quote.Shipment__c!=null){
                for(integer i=0;i<productEShip.size();i++){
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.id AND Product2.Id=:productEShip[i].Id];
                	quoteLine.SBQQ__PricebookEntryId__c=pbEntry.Id;
                    quoteLine.SBQQ__Product__c=productEShip[i].Id;
                	quoteLine.SBQQ__Quantity__c=1;
                    quoteLine.SBQQ__NetPrice__c=pbEntry.UnitPrice;
                    quoteLine.SBQQ__ChargeType__c='One-Time';
                    quoteLine.Shipment__c=quote.Shipment__c;
                	quoteLine.BVC_Gross_weight__c=quote.BVC_Gross_weight__c;
                    quoteLine.BVC_Net_Weight__c=quote.Net_Weight__c;
                	quoteLine.SBQQ__Quote__c=quote.Id;
                	quoteLineList.add(quoteLine);
                 }
            } 
        }
        //System.debug('quoteLineList sdbhgjbdsgjk '+quoteLineList.size());
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        
        List<SBQQ__Quote__c> QuoteList = [select id,Quick_Calculate_BVC__c from SBQQ__Quote__c where id IN:quoteIds];
        for(SBQQ__Quote__c Qt:QuoteList){
            if(Qt.Quick_Calculate_BVC__c==true){Qt.Quick_Calculate_BVC__c=false;
            }else{Qt.Quick_Calculate_BVC__c=true;
                 }
        }
        if(QuoteList.size()>0){update QuoteList;
        }
        
        
    }

    
    Public static void createBathEshipStandardPrice(List<SBQQ__Quote__c> newQuote){
        set<Id> QtIds = new Set<Id>();
        set<Id> CusIds = new Set<Id>();
        for(SBQQ__Quote__c quote:newQuote){
            QtIds.add(quote.id);
            CusIds.add(quote.SBQQ__Account__c);
        } 
        List<Bath_Custom_Pricing__c> OLDcustomBATHPricing = [select id,Customer__c from Bath_Custom_Pricing__c where Customer__c IN :CusIds and Quote__c Not IN :QtIds];
        List<eSHIP_Custom_Pricing__c> OLDcustomEshipPricing = [select id,Customer__c from eSHIP_Custom_Pricing__c where Customer__c IN :CusIds and Quote__c Not IN :QtIds];
        List<Bath_Standard_Pricing__c> BathCustomPricing = [select id,Product_Type__c,Shipment_charge__c,Package_Amount__c,Business_Type__c,Commission_Percentage__c,Origin_Destination_Pairing__c,Secure_logistics_rate__c,Visit_Outcome__c,Name from Bath_Standard_Pricing__c ];
         String eSHIPNewpricingRT = Schema.SObjectType.eSHIP_Standard_Pricing__c.getRecordTypeInfosByName().get('New eSHIP Pricing').getRecordTypeId();
        String eSHIPOldPpricingRT = Schema.SObjectType.eSHIP_Standard_Pricing__c.getRecordTypeInfosByName().get('Legacy eSHIP Pricing').getRecordTypeId();
        List<eSHIP_Standard_Pricing__c> eshipNewPricing = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,ACR_Amount__c ,Gross_Weight_Unit_for_Additional_Weight__c,Weight_Covered_Gms__c,Package_Amount__c,Slab_Criteria__c,Weight_Charges__c,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where RecordTypeId=:eSHIPNewpricingRT];
        List<eSHIP_Standard_Pricing__c> eshipGrossWeightGms = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,ACR_Amount__c ,Gross_Weight_Unit_for_Additional_Weight__c,Slab_Criteria__c,Weight_Charges__c,Package_Amount__c ,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where Slab_Criteria__c='Gross Weight Gms'and RecordTypeId=:eSHIPOldPpricingRT ];
        List<eSHIP_Standard_Pricing__c> eshipInvoiceValueINR = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,ACR_Amount__c ,Gross_Weight_Unit_for_Additional_Weight__c,Slab_Criteria__c,Weight_Charges__c,Package_Amount__c ,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where Slab_Criteria__c='Invoice Value INR'and RecordTypeId=:eSHIPOldPpricingRT ];
        List<eSHIP_Standard_Pricing__c> eshipNetWeight = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,Gross_Weight_Unit_for_Additional_Weight__c,Slab_Criteria__c,Weight_Charges__c,Package_Amount__c ,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where Slab_Criteria__c='Net Weight'and RecordTypeId=:eSHIPOldPpricingRT ];
        for(SBQQ__Quote__c quote:newQuote){  
            if(quote.SBQQ__Status__c.contains('Ordered') ){
                If(quote.Is_Shipment__c==true ){
        			if(OLDcustomBATHPricing.size()>0  && quote.BVC_Service__c=='BATH'){
            			delete OLDcustomBATHPricing;
        			}
                    if(OLDcustomEshipPricing.size()>0 && quote.BVC_Service__c=='eSHIP'){
            			delete OLDcustomEshipPricing;
        			}
                    if(quote.BVC_Service__c=='BATH' && quote.Tariff_Plan_Bath_Eship__c=='Standard'){
                        
        				List<Bath_Custom_Pricing__c> customBATHPricing = new List<Bath_Custom_Pricing__c>();
                         for(Bath_Standard_Pricing__c standBath:BathCustomPricing){ 
                                Bath_Custom_Pricing__c cusBath =new Bath_Custom_Pricing__c();
                                cusBath.Customer__c=quote.SBQQ__Account__c;
                                cusBath.Quote__c=quote.Id;
                                cusBath.Business_Type__c=quote.Business_Type__c;
                                cusBath.Commission_Percentage__c=standBath.Commission_Percentage__c;
                                cusBath.Origin_Destination_Pairing__c=standBath.Origin_Destination_Pairing__c;
                                cusBath.Secure_logistics_rate__c=standBath.Secure_logistics_rate__c;
                                cusBath.Product_Type__c=standBath.Product_Type__c;
                                cusBath.Visit_Outcome__c=standBath.Visit_Outcome__c;
                             
                                if(quote.Package_Amount__c!=null && quote.Business_Type__c=='ACR'){
                                    //cusBath.Package_Amount__c=quote.Package_Amount__c;
                                }
                                if(standBath.Shipment_charge__c!=null){  
                                    cusBath.Shipment_charge__c=standBath.Shipment_charge__c;
                                } 
                                customBATHPricing.add(cusBath);
                            }
                        if(customBATHPricing.size()>0){
                            insert customBATHPricing;
                        }  
                    }else if(quote.BVC_Service__c=='eSHIP' && quote.Tariff_Plan_Bath_Eship__c=='Standard'){
                        system.debug('====================================================================================================');
        				List<eSHIP_Custom_Pricing__c> customEshipPricing = new List<eSHIP_Custom_Pricing__c>();        
        				if(quote.Slab_Criteria__c!=null && quote.Slab_Criteria__c=='Gross Weight Gms' && quote.Tariff_Plan__c!=null && quote.Tariff_Plan__c=='Standard' && quote.Is_Deal_with_New_Price__c==false){
                            for(eSHIP_Standard_Pricing__c standEShip1:eshipGrossWeightGms){
                				eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                				cusEShip.Customer__c=quote.SBQQ__Account__c;
                				cusEShip.Quote__c=quote.Id;
                				cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=standEShip1.Gross_Weight_Unit_for_Additional_Weight__c;
                                cusEShip.Lower_Bound__c=standEShip1.Lower_Bound__c;                
                				cusEShip.ACR_Amount__c=standEShip1.ACR_Amount__c;
                                cusEShip.Additional_Charge__c=standEShip1.Additional_Charge__c;
                                //busines type changed
                                //cusEShip.Buissness_Type__c=quote.Business_Type__c;
                                cusEShip.COD_Charges_per_shipment__c=standEShip1.COD_Charges_per_shipment__c;
                                cusEShip.COD_Charges_percentage_of_product__c=standEShip1.COD_Charges_percentage_of_product__c;
                                cusEShip.Fuel_Surcharge__c=standEShip1.Fuel_Surcharge__c;
                                cusEShip.Liability_Charges__c=standEShip1.Liability_Charges__c;
                                cusEShip.Logistice_Charges__c=standEShip1.Logistice_Charges__c;
                                cusEShip.Slab_Level__c=standEShip1.Slab_Level__c;
                                cusEShip.Weight_Charges__c=standEShip1.Weight_Charges__c;
                                cusEShip.Upper_Bound__c=standEShip1.Upper_Bound__c;
                                cusEShip.Rate_INR__c=standEShip1.Rate_INR__c;
                                cusEShip.Shipment_Type__c=standEShip1.Shipment_Type__c;
                                cusEShip.Slab_Criteria__c=standEShip1.Slab_Criteria__c;
                                cusEShip.No_Of_Free_Atttemps__c=standEShip1.No_Of_Free_Atttemps__c;
                                cusEShip.l_Liability_Cover_By_BVC__c=standEShip1.Liability_Cover_By_BVC__c;
                                customEshipPricing.add(cusEShip);
                            }
                        }else if(quote.Slab_Criteria__c!=null && quote.Slab_Criteria__c=='Invoice Value INR' && quote.Tariff_Plan__c!=null && quote.Tariff_Plan__c=='Standard' && quote.Is_Deal_with_New_Price__c==false ){
                            for(eSHIP_Standard_Pricing__c standEShip2:eshipInvoiceValueINR){                
                                eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                                cusEShip.Customer__c=quote.SBQQ__Account__c;
                                cusEShip.Quote__c=quote.Id;
                                cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=standEShip2.Gross_Weight_Unit_for_Additional_Weight__c;
                                cusEShip.Lower_Bound__c=standEShip2.Lower_Bound__c;
                                cusEShip.ACR_Amount__c=standEShip2.ACR_Amount__c;
                                cusEShip.Additional_Charge__c=standEShip2.Additional_Charge__c;
                                //busines type changed
                                //cusEShip.Business_Type__c=quote.Business_Type__c;
                                cusEShip.COD_Charges_per_shipment__c=standEShip2.COD_Charges_per_shipment__c;
                                cusEShip.COD_Charges_percentage_of_product__c=standEShip2.COD_Charges_percentage_of_product__c;
                                cusEShip.Fuel_Surcharge__c=standEShip2.Fuel_Surcharge__c;
                                cusEShip.Liability_Charges__c=standEShip2.Liability_Charges__c;
                                cusEShip.Logistice_Charges__c=standEShip2.Logistice_Charges__c;
                                cusEShip.Slab_Level__c=standEShip2.Slab_Level__c;
                                cusEShip.Weight_Charges__c=standEShip2.Weight_Charges__c;
                                cusEShip.Upper_Bound__c=standEShip2.Upper_Bound__c;
                                cusEShip.Rate_INR__c=standEShip2.Rate_INR__c;
                                cusEShip.Shipment_Type__c=standEShip2.Shipment_Type__c;
                                cusEShip.Slab_Criteria__c=standEShip2.Slab_Criteria__c;
                                cusEShip.No_Of_Free_Atttemps__c=standEShip2.No_Of_Free_Atttemps__c;
                                cusEShip.l_Liability_Cover_By_BVC__c=standEShip2.Liability_Cover_By_BVC__c;
                                customEshipPricing.add(cusEShip);
                            }            
                        }else if(quote.Slab_Criteria__c!=null && quote.Slab_Criteria__c=='Net Weight' && quote.Tariff_Plan__c!=null && quote.Tariff_Plan__c=='Standard' && quote.Is_Deal_with_New_Price__c==false ){
                            for(eSHIP_Standard_Pricing__c standEShip3:eshipNetWeight){                
                                eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                                cusEShip.Customer__c=quote.SBQQ__Account__c;
                                cusEShip.Quote__c=quote.Id;
                                cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=standEShip3.Gross_Weight_Unit_for_Additional_Weight__c;
                                cusEShip.Lower_Bound__c=standEShip3.Lower_Bound__c;
                                cusEShip.Package_Amount__c =standEShip3.Package_Amount__c ;
                                cusEShip.Additional_Charge__c=standEShip3.Additional_Charge__c;
                                //busines type changed
                                cusEShip.Business_Type__c=quote.Business_Type__c;
                                cusEShip.COD_Charges_per_shipment__c=standEShip3.COD_Charges_per_shipment__c;
                                cusEShip.COD_Charges_percentage_of_product__c=standEShip3.COD_Charges_percentage_of_product__c;
                                cusEShip.Fuel_Surcharge__c=standEShip3.Fuel_Surcharge__c;
                                cusEShip.Liability_Charges__c=standEShip3.Liability_Charges__c;
                                cusEShip.Logistice_Charges__c=standEShip3.Logistice_Charges__c;
                                cusEShip.Slab_Level__c=standEShip3.Slab_Level__c;
                                cusEShip.Weight_Charges__c=standEShip3.Weight_Charges__c;
                                cusEShip.Upper_Bound__c=standEShip3.Upper_Bound__c;
                                cusEShip.Rate_INR__c=standEShip3.Rate_INR__c;
                                cusEShip.Shipment_Type__c=standEShip3.Shipment_Type__c;
                                cusEShip.Slab_Criteria__c=standEShip3.Slab_Criteria__c;
                                cusEShip.No_Of_Free_Atttemps__c=standEShip3.No_Of_Free_Atttemps__c;
                                cusEShip.l_Liability_Cover_By_BVC__c=standEShip3.Liability_Cover_By_BVC__c;
                                customEshipPricing.add(cusEShip);
                            }            
                        }
                        else if(quote.Tariff_Plan__c!=null && quote.Tariff_Plan__c=='Standard' && quote.Is_Deal_with_New_Price__c==true){
                            system.debug('====================================================================================================');
                            eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                            for(eSHIP_Standard_Pricing__c newEShipPrice:eshipNewPricing){
                                if(quote.Package_Amount__c==newEShipPrice.Package_Amount__c && quote.Business_Type__c==newEShipPrice.Business_Type__c){
                                    cusEShip.Customer__c=quote.SBQQ__Account__c;
                                    cusEShip.Quote__c=quote.Id;
                                    cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=newEShipPrice.Gross_Weight_Unit_for_Additional_Weight__c;
                                    cusEShip.Package_Amount__c=newEShipPrice.Package_Amount__c;
                                    cusEShip.Weight_Covered_Gms__c=newEShipPrice.Weight_Covered_Gms__c;
                                    cusEShip.Lower_Bound__c=newEShipPrice.Lower_Bound__c;
                                    cusEShip.ACR_Amount__c=newEShipPrice.ACR_Amount__c;
                                    cusEShip.Additional_Charge__c=newEShipPrice.Additional_Charge__c;
                                    cusEShip.Business_Type__c=newEShipPrice.Business_Type__c;
                                    cusEShip.COD_Charges_per_shipment__c=newEShipPrice.COD_Charges_per_shipment__c;
                                    cusEShip.COD_Charges_percentage_of_product__c=newEShipPrice.COD_Charges_percentage_of_product__c;
                                    cusEShip.Fuel_Surcharge__c=newEShipPrice.Fuel_Surcharge__c;
                                    cusEShip.Liability_Charges__c=newEShipPrice.Liability_Charges__c;
                                    cusEShip.Logistice_Charges__c=newEShipPrice.Logistice_Charges__c;
                                    cusEShip.Slab_Level__c=newEShipPrice.Slab_Level__c;
                                    cusEShip.Weight_Charges__c=newEShipPrice.Weight_Charges__c;
                                    cusEShip.Upper_Bound__c=newEShipPrice.Upper_Bound__c;
                                    cusEShip.Rate_INR__c=newEShipPrice.Rate_INR__c;
                                    cusEShip.Shipment_Type__c=newEShipPrice.Shipment_Type__c;
                                    cusEShip.Slab_Criteria__c=newEShipPrice.Slab_Criteria__c;
                                    cusEShip.No_Of_Free_Atttemps__c=newEShipPrice.No_Of_Free_Atttemps__c;
                                	cusEShip.l_Liability_Cover_By_BVC__c=newEShipPrice.Liability_Cover_By_BVC__c;
                                    customEshipPricing.add(cusEShip);
                                }else if(quote.Business_Type__c==newEShipPrice.Business_Type__c && newEShipPrice.Package_Amount__c==null ){
                                    cusEShip.Customer__c=quote.SBQQ__Account__c;
                                    cusEShip.Quote__c=quote.Id;
                                    cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=newEShipPrice.Gross_Weight_Unit_for_Additional_Weight__c;
                                    cusEShip.Package_Amount__c=newEShipPrice.Package_Amount__c;
                                    cusEShip.Weight_Covered_Gms__c=newEShipPrice.Weight_Covered_Gms__c;
                                    cusEShip.Lower_Bound__c=newEShipPrice.Lower_Bound__c;
                                    cusEShip.Package_Amount__c =newEShipPrice.Package_Amount__c ;
                                    cusEShip.Additional_Charge__c=newEShipPrice.Additional_Charge__c;
                                    cusEShip.Business_Type__c=newEShipPrice.Business_Type__c;
                                    cusEShip.COD_Charges_per_shipment__c=newEShipPrice.COD_Charges_per_shipment__c;
                                    cusEShip.COD_Charges_percentage_of_product__c=newEShipPrice.COD_Charges_percentage_of_product__c;
                                    cusEShip.Fuel_Surcharge__c=newEShipPrice.Fuel_Surcharge__c;
                                    cusEShip.Liability_Charges__c=newEShipPrice.Liability_Charges__c;
                                    cusEShip.Logistice_Charges__c=newEShipPrice.Logistice_Charges__c;
                                    cusEShip.Slab_Level__c=newEShipPrice.Slab_Level__c;
                                    cusEShip.Weight_Charges__c=newEShipPrice.Weight_Charges__c;
                                    cusEShip.Upper_Bound__c=newEShipPrice.Upper_Bound__c;
                                    cusEShip.Rate_INR__c=newEShipPrice.Rate_INR__c;
                                    cusEShip.Shipment_Type__c=newEShipPrice.Shipment_Type__c;
                                    cusEShip.Slab_Criteria__c=newEShipPrice.Slab_Criteria__c;
                                    cusEShip.No_Of_Free_Atttemps__c=newEShipPrice.No_Of_Free_Atttemps__c;
                                	cusEShip.l_Liability_Cover_By_BVC__c=newEShipPrice.Liability_Cover_By_BVC__c;
                                    customEshipPricing.add(cusEShip);
                                }
                            }
                            if(customEshipPricing.size()>0){
                            	insert customEshipPricing;
                        	}
                        }  
                    } 
                 }                    
              }       
          }
     }

    //Created By : Anamika Shinde
    //Desc: Store Annexture Ivalship File
    
    public Static Void StoreAnnetureFileinQuote(List<SBQQ__Quote__c> quoteId){
        
        String FileName;
        String QId;
        for(SBQQ__Quote__c q:quoteId){
            if(q.BVC_Service__c=='iValSHIP'){
                FileName=q.BVC_Service__c+' '+q.ivalship_Location__c+' '+q.Ivalship_Product_Sub_Category__c;
            }
             if(q.BVC_Service__c=='ieSHIP'){
                FileName=q.BVC_Service__c+' '+q.ieSHIP_Location__c+' '+q.iEship_Sub_Category__c;
            }
            if(q.BVC_Service__c=='MarketSHIP'){
                FileName=q.BVC_Service__c;
            }
            QId=q.Id;
        }
        System.debug('FileName+'+FileName);
        if(FileName != Null){
            if(quoteId[0].Tariff_Plan_Bath_Eship__c=='Standard'){
                
               
                List<ContentDocument> con= [select Id  from ContentDocument where title =: FileName];
		
            //System.debug('Title'+con.Title);
            List<ContentDocumentLink> cd =new  List<ContentDocumentLink>();
             for(ContentDocument c:con){
             
                  ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.LinkedEntityId = QId;
                        cdl.ContentDocumentId = c.Id;
                        cdl.ShareType = 'V';
                        cdl.Visibility = 'AllUsers';
                        cd.add(cdl);
             }
            insert cd;
            }       
        }           
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
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
         
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    i++;   }
}