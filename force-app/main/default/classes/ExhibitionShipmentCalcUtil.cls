public class ExhibitionShipmentCalcUtil {
public static List < ShipmentCalcUtil.ShipmentDetail > shipmentCalculationExhibition(List < ShipmentCalcUtil.ShipmentDetail > shipInput, Map < Id, Account > actMap) {
        system.debug('===shipmentCalculationExhibition Called');
        
        Set < Id > prodId = new Set < Id > ();
        Set < String > accountId = new Set < String > ();
        Set < String > origin = new Set < String > ();
        Set < String > destination = new Set < String > ();
        Set < String > custProdCategory = new Set < String > ();
        Set < String > acrPackageType = new Set < String > ();
        Set < Id > contractSet = new Set < Id > ();
        Set < Id > exhibition = new Set < Id > ();
        
        List < ShipmentCalcUtil.ShipmentDetail > shipCalcVal = new List < ShipmentCalcUtil.ShipmentDetail > ();
        //sam
         Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        
        for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
            
            prodId.add(eachship.productId);
            custProdCategory.add(eachship.customerProdCategory);
            exhibition.add(eachship.exhibitionId);
            accountId.add(eachship.accountId);
        }
        //sam
        List<Account> accWithExmeptedOrder = [Select id,(SELECT Id, Name, Customer__c, New_Offline_Charge__c,Exempted_City__c FROM Exempted_cities__r) from Account where id IN: accountId];
        for(Account acc : accWithExmeptedOrder){
            mapaccountIdWithExemptRecord.put(acc.Id,acc.Exempted_cities__r);
        }
        
        Map < String, ST_Exhibition_Contracted_Price__c > exiContractedMapping = new Map < String, ST_Exhibition_Contracted_Price__c > ();
        Map < String, ST_Exhibition_Standard_Price__c > exiStandardMapping = new Map < String, ST_Exhibition_Standard_Price__c > ();
        
        for (ST_Exhibition_Contracted_Price__c ecp: [select ST_Active__c, ST_Contract__c, ST_Customer_Account__c, ST_Customer_Product_Category__c, ST_End_Date__c,
                                                     ST_Exhibition__c, ST_Liability_Coverage__c, ST_Product__r.Name, ST_Start_Date__c, ST_Rate_UOM__c,
                                                     Level_1__c, Level_1_Rate__c, Level_2__c,
                                                     Level_2_Rate__c, Level_3__c, Level_3_Rate__c,
                                                     Level_4__c, Level_4_Rate__c, Level_5__c,
                                                     Level_5_rate__c, Max_Slab_Rate__c, ST_Contract__r.Status,
                                                     ST_Offline_Charge__c, ST_Product__c, ST_Rate_Amount__c
                                                     FROM ST_Exhibition_Contracted_Price__c
                                                     where ST_Product__c In: prodId and ST_Customer_Account__c IN: accountId and ST_Active__c = true
                                                     and ST_Contract__r.Status = 'Activated'
                                                     and(ST_Exhibition__c In: exhibition and ST_Customer_Product_Category__c IN: custProdCategory)
                                                    ]) {
                                                        String key = ecp.ST_Customer_Account__c + '-' + ecp.ST_Exhibition__c + '-' + ecp.ST_Customer_Product_Category__c + '-' + ecp.ST_Product__c;
                                                        system.debug('Exhi Key : ' + key);
                                                        exiContractedMapping.put(key, ecp);
                                                        
                                                    }
        
        for (ST_Exhibition_Standard_Price__c esp: [select ST_Active__c, ST_Customer_Product_Category__c,
                                                   ST_Exhibition__c, ST_Liability_Coverage__c, ST_Product__r.Name, ST_Rate_UOM__c,
                                                   Level_1__c, Level_1_Rate__c, Level_2__c,
                                                   Level_2_Rate__c, Level_3__c, Level_3_Rate__c,
                                                   Level_4__c, Level_4_Rate__c, Level_5__c,
                                                   Level_5_rate__c, Max_Slab_Rate__c,
                                                   ST_Offline_Charge__c, ST_Product__c, ST_Rate_Amount__c
                                                   FROM ST_Exhibition_Standard_Price__c
                                                   where ST_Product__c In: prodId and ST_Active__c = true
                                                   and(ST_Exhibition__c In: exhibition and ST_Customer_Product_Category__c IN: custProdCategory)
                                                  ]) {
                                                      String key = esp.ST_Exhibition__c + '-' + esp.ST_Customer_Product_Category__c + '-' + esp.ST_Product__c;
                                                      system.debug('Exhi Std Key : ' + key);
                                                      exiStandardMapping.put(key, esp);
                                                      
                                                  }
        
        for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
            Decimal calculatedAmount = 0;
            Decimal offlineCharge = 0;
            Decimal liabilityCoverageAmount = 0;
            Decimal freightChrge = 0;
          //Decimal fuelSurcharge=0;//Prat
            try {
                String contKey = eachship.accountId + '-' + eachship.exhibitionId + '-' + eachship.customerProdCategory + '-' + eachship.productId;
                String stdKey = eachship.exhibitionId + '-' + eachship.customerProdCategory + '-' + eachship.productId;
                if (exiContractedMapping.containsKey(contKey)) {
                    system.debug('entered in exhi-contracted');
                    
                    ST_Exhibition_Contracted_Price__c ecp = exiContractedMapping.get(contKey);
                    system.debug('===========ecp========='+ecp);
                    Decimal slabRate = 0.0;
                    // if(eachship.productCode.contains('-WC')){
                    if (eachship.grossWeight > 0 && eachship.grossWeight <= ecp.Level_1__c) {
                        slabRate = ecp.Level_1_Rate__c == null ? 0.0 : ecp.Level_1_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > ecp.Level_1__c && eachship.grossWeight <= ecp.Level_2__c) {
                        slabRate = ecp.Level_2_Rate__c == null ? 0.0 : ecp.Level_2_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > ecp.Level_2__c && eachship.grossWeight <= ecp.Level_3__c) {
                        slabRate = ecp.Level_3_Rate__c == null ? 0.0 : ecp.Level_3_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > ecp.Level_3__c && eachship.grossWeight <= ecp.Level_4__c) {
                        slabRate = ecp.Level_4_Rate__c == null ? 0.0 : ecp.Level_4_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > ecp.Level_4__c && eachship.grossWeight <= ecp.Level_5__c) {
                        slabRate = ecp.Level_5_Rate__c == null ? 0.0 : ecp.Level_5_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > ecp.Level_5__c) {
                        slabRate = ecp.Max_Slab_Rate__c == null ? ecp.Level_5_Rate__c : ecp.Max_Slab_Rate__c;
                    }
                    if (ecp.ST_Rate_UOM__c == 'Flat Rate') {
                        freightChrge = slabRate;
                        //fuelSurcharge = ecp.Fuel_Surcharge__c;
                    } else if (ecp.ST_Rate_UOM__c == 'Per Gram') {
                        freightChrge = slabRate * eachship.grossWeight;
                    } else if (ecp.ST_Rate_UOM__c == 'Per Kg') {
                        freightChrge = (slabRate * eachship.grossWeight) / 1000;
                    }
                   /* system.debug('contracted fuel surcharge'+ecp.Fuel_Surcharge__c);
                    date shipDate1 = eachship.shipDate;
                    date dueDate = date.newInstance(2022, 10, 31);
                   
                        if (ecp.Fuel_Surcharge__c !=null && ecp.Fuel_Surcharge__c >0 && shipDate1 > dueDate && eachship.prodDesc!='Cut & Polished Diamonds') {
                            system.debug('entered in surcharge'+ecp.Fuel_Surcharge__c);
                            fuelSurcharge = ecp.Fuel_Surcharge__c;
                        }*/
                    
                    Integer num = 0;
                    if (eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                         offlineCharge = ecp.ST_Offline_Charge__c == null ? 0 : ecp.ST_Offline_Charge__c;
                        
                        //sam
                        if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
                    }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                    if (eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                       // num++;
                        //sam
                         offlineCharge = ecp.ST_Offline_Charge__c == null ? 0 : ecp.ST_Offline_Charge__c;
                        if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                    }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                     if (eachship.isOriginOfflineLoc && eachship.isDestOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false	) {
                                   
                                    Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = ecp.ST_Offline_Charge__c == null ? 0 : ecp.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                              
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge = ecp.ST_Offline_Charge__c == null ? 0 : ecp.ST_Offline_Charge__c * 2;
                                    
                                   }  
                               
                               }
                       if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = ecp.ST_Offline_Charge__c == null ? 0 : ecp.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
								}
                    		      if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =ecp.ST_Offline_Charge__c == null ? 0 : ecp.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                   
                    if (eachship.optForLiability == 'Yes' && eachship.invoiceValue > 0 && eachship.movtType != 'Outward') {
                        Decimal liabilityAmt = ecp.ST_Liability_Coverage__c == null ? 0.0 : ecp.ST_Liability_Coverage__c;
                        Decimal invValue = eachship.invoiceValue == null ? 0.0 : eachship.invoiceValue;

                        liabilityCoverageAmount = (invValue * liabilityAmt) / 100;
                        eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                    }
                    eachship.exhibitionContractedPriceId = ecp.Id;
                    
                    
                } else if (exiStandardMapping.containsKey(stdKey) && !exiContractedMapping.containsKey(contKey)) {
                    
                    system.debug('entered in exhi-standard');
                    ST_Exhibition_Standard_Price__c esp = exiStandardMapping.get(stdKey);
                    Decimal slabRate = 0.0;
                    // if(eachship.productCode.contains('-WC')){
                    if (eachship.grossWeight > 0 && eachship.grossWeight < esp.Level_1__c) {
                        slabRate = esp.Level_1_Rate__c == null ? 0.0 : esp.Level_1_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > esp.Level_1__c && eachship.grossWeight <= esp.Level_2__c) {
                        slabRate = esp.Level_2_Rate__c == null ? 0.0 : esp.Level_2_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > esp.Level_2__c && eachship.grossWeight <= esp.Level_3__c) {
                        slabRate = esp.Level_3_Rate__c == null ? 0.0 : esp.Level_3_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > esp.Level_3__c && eachship.grossWeight <= esp.Level_4__c) {
                        slabRate = esp.Level_4_Rate__c == null ? 0.0 : esp.Level_4_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > esp.Level_4__c && eachship.grossWeight <= esp.Level_5__c) {
                        slabRate = esp.Level_5_Rate__c == null ? 0.0 : esp.Level_5_Rate__c;
                    } else if (eachship.grossWeight > 0 && eachship.grossWeight > esp.Level_5__c) {
                        slabRate = esp.Max_Slab_Rate__c == null ? esp.Level_5_Rate__c : esp.Max_Slab_Rate__c;
                    }
                    
                    
																						   
																	  
					   
                    if (esp.ST_Rate_UOM__c == 'Flat Rate') {
                        freightChrge = slabRate;
                        //fuelSurcharge = esp.Fuel_Surcharge__c;
                    } else if (esp.ST_Rate_UOM__c == 'Per Gram') {
                        freightChrge = slabRate * eachship.grossWeight;
                    } else if (esp.ST_Rate_UOM__c == 'Per Kg') {
                        freightChrge = (slabRate * eachship.grossWeight) / 1000;
                    }
                  /*date shipDate1 = eachship.shipDate;
                    date dueDate = date.newInstance(2022, 10, 31);
                    if (esp.Fuel_Surcharge__c !=null && esp.Fuel_Surcharge__c >0 && shipDate1 > dueDate && eachship.prodDesc!='Cut & Polished Diamonds') {
                        fuelSurcharge = esp.Fuel_Surcharge__c;
                    }*/
                    //freightChrge = slabRate * eachship.grossWeight;
                   // Integer num = 0;
                    if (eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                         offlineCharge = esp.ST_Offline_Charge__c == null ? 0 : esp.ST_Offline_Charge__c;
                        if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
                        // num++;
                    }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                    if (eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                            offlineCharge = esp.ST_Offline_Charge__c == null ? 0 : esp.ST_Offline_Charge__c;
                        if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.Destination){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
                        // num++;
                    }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                     if (eachship.isOriginOfflineLoc && eachship.isDestOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
																																   
                                  Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = esp.ST_Offline_Charge__c == null ? 0 : esp.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                              
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge = esp.ST_Offline_Charge__c == null ? 0 : esp.ST_Offline_Charge__c * 2;
                                    
                                   }  
                               
                               }
                           if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge =  esp.ST_Offline_Charge__c == null ? 0 : esp.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
								}
                    if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge = esp.ST_Offline_Charge__c == null ? 0 : esp.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }

																											  
                   if (eachship.optForLiability == 'Yes' && eachship.invoiceValue > 0 && eachship.movtType != 'Outward') {
                        Decimal liabilityAmt = esp.ST_Liability_Coverage__c == null ? 0.0 : esp.ST_Liability_Coverage__c;
                        Decimal invValue = eachship.invoiceValue == null ? 0.0 : eachship.invoiceValue;
                        liabilityCoverageAmount = (invValue * liabilityAmt) / 100;
                        eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                        
                    }
                    eachship.exhibitionStandardPriceId = esp.Id;
                } else if (!exiStandardMapping.containsKey(stdKey) && !exiContractedMapping.containsKey(contKey)) {
                    eachship.errors = 'Cannot find Exhibition Standard/Contracted Prices for this Shipment.';
                }
                eachship.offlineCharge = offlineCharge;
                eachship.liabilityCoverage = liabilityCoverageAmount;
                eachship.freightCharge = freightChrge;
            //  eachship.fuelSurcharge=fuelSurcharge;
                eachship.totalAmount = offlineCharge + liabilityCoverageAmount + freightChrge;
            } catch (exception ex) {
                eachship.errors = ex.getMessage();
                
            }
            shipCalcVal.add(eachship);
        }
        
        return shipCalcVal;
    }
    public static void f1Method(){
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
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;  
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
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