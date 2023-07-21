public with sharing class QuoteLineTriggerHandler {
    
    /*********************************************************************************************
    		test class- QuoteTriggerTest
    *********************************************************************************************/
    public static void updateQuoteLineChargeFields(List<SBQQ__QuoteLine__c> newList){
        for(SBQQ__QuoteLine__c line : newList){
            if(line.ST_Offline_Charge__c != null){
                line.Prior_Offline_Charge__c = line.ST_Offline_Charge__c;
            }
            if(line.ST_Liability_Coverage__c != null){
                line.Prior_Liability_Coverage__c = line.ST_Liability_Coverage__c;
            }
           
            if(line.ST_Minimum_Freight__c != null){
                line.Prior_Freight_Charge__c = line.ST_Minimum_Freight__c;
            }
             if(line.Fuel_Surcharge__c != null){
                line.Prior_Fuel_Surcharge__c = line.Fuel_Surcharge__c;//added
            }
            
            
           UtilClass.qliRecursionCheck = true;
        }
    }
    
    public static void quoteLineMaxDiscount(List<SBQQ__QuoteLine__c> newList,Map<Id,SBQQ__QuoteLine__c> oldQliMap){
        for(SBQQ__QuoteLine__c line : newList){
            if(!line.SBQQ__ProductCode__c.contains('EXHIBI')){
                if(oldQliMap == null){
                    if(line.STT_Freight_Invoice_Value__c != null || line.ST_Rate_Discount__c != null  || line.Offline_Charge_Discount_Percent__c != null 
                       || line.ST_Minimum_Percent__c != null  || line.Liability_Coverage_Discount_Percent__c != null|| line.Fuel_Surcharge_Discount_Percent__c != null){
                           Decimal[] DecList = new list<Decimal>{line.ST_Minimum_Percent__c, line.Offline_Charge_Discount_Percent__c,line.STT_Freight_Invoice_Value__c, line.ST_Rate_Discount__c, line.Liability_Coverage_Discount_Percent__c,line.Fuel_Surcharge_Discount_Percent__c};
                               DecList.sort();
                           system.debug('delist after sort 1+++'+DecList);
                           line.Max_Discount__c = DecList[5];
                           system.debug('decList at 4======'+DecList[4]);
                           UtilClass.qliRecursionCheck = true;
                    }  
                }
                else if(oldQliMap != null && oldQliMap.containskey(line.Id)){
                    SBQQ__QuoteLine__c oldLine = oldQliMap.get(Line.Id);
                    if(line.STT_Freight_Invoice_Value__c != oldLine.STT_Freight_Invoice_Value__c
                       || line.ST_Rate_Discount__c != oldLine.ST_Rate_Discount__c 
                       || line.Offline_Charge_Discount_Percent__c != oldLine.Offline_Charge_Discount_Percent__c 
                       || line.ST_Minimum_Percent__c != oldLine.ST_Minimum_Percent__c
                       || line.Liability_Coverage_Discount_Percent__c != oldLine.Liability_Coverage_Discount_Percent__c
                       || line.Fuel_Surcharge_Discount_Percent__c != oldLine.Fuel_Surcharge_Discount_Percent__c){
                           Decimal[] DecList = new list<Decimal>{line.ST_Minimum_Percent__c, line.Offline_Charge_Discount_Percent__c,line.STT_Freight_Invoice_Value__c, line.ST_Rate_Discount__c, line.Liability_Coverage_Discount_Percent__c, line.Fuel_Surcharge_Discount_Percent__c};
                               DecList.sort();
                           system.debug('delist after sort 2+++'+DecList);
                           line.Max_Discount__c = DecList[5];
                           system.debug('decList at 4======'+DecList[5]);
                           UtilClass.qliRecursionCheck = true;
                    } 
                }  
            }
            else if( line.SBQQ__ProductCode__c.contains('EXHIBI') && line.ST_Customer_Product_Category__c != '' && line.ST_Customer_Product_Category__c != null){
               		 if(oldQliMap == null){
                    if(line.Offline_Charge_Discount_Percent__c != null || line.Liability_Coverage_Discount_Percent__c != null|| line.Fuel_Surcharge_Discount_Percent__c != null || line.Slab_Level_1_Discount_Percent__c != null || line.Slab_Level_5_Discount_Percent__c != null
                       || line.Slab_Level_2_Discount_Percent__c != null || line.Slab_Level_3_Discount_Percent__c != null|| line.Slab_Level_4_Discount_Percent__c != null){
                      	   Decimal[] DecList = new list<Decimal>{line.Offline_Charge_Discount_Percent__c , line.Liability_Coverage_Discount_Percent__c, line.Slab_Level_1_Discount_Percent__c, line.Slab_Level_2_Discount_Percent__c, line.Slab_Level_3_Discount_Percent__c, line.Slab_Level_4_Discount_Percent__c, line.Slab_Level_5_Discount_Percent__c,line.Max_Slab_Rate_Discount__c};
                          	   DecList.sort();
                           system.debug('delist after sort 3+++'+DecList);
                           line.Max_Discount__c = DecList[7];
                           system.debug('decList at 7======'+DecList[7]);
                           UtilClass.qliRecursionCheck = true;
                    }  
                }
                else if(oldQliMap != null && oldQliMap.containskey(line.Id)){
                    SBQQ__QuoteLine__c oldLine = oldQliMap.get(Line.Id);
                    if(line.Offline_Charge_Discount_Percent__c != oldLine.Offline_Charge_Discount_Percent__c 
                       || line.Liability_Coverage_Discount_Percent__c != oldLine.Liability_Coverage_Discount_Percent__c
                       || line.Fuel_Surcharge_Discount_Percent__c != oldLine.Fuel_Surcharge_Discount_Percent__c
                       || line.Slab_Level_1_Rate__c != oldLine.Slab_Level_1_Rate__c
                       || line.Slab_Level_2_Rate__c != oldLine.Slab_Level_2_Rate__c
                       || line.Slab_Level_3_Rate__c != oldLine.Slab_Level_3_Rate__c
                       || line.Slab_Level_4_Rate__c != oldLine.Slab_Level_4_Rate__c
                       || line.Slab_Level_5_Rate__c != oldLine.Slab_Level_5_Rate__c){
                           Decimal[] DecList = new list<Decimal>{line.Offline_Charge_Discount_Percent__c, line.Liability_Coverage_Discount_Percent__c, line.Fuel_Surcharge_Discount_Percent__c,  line.Slab_Level_1_Discount_Percent__c, line.Slab_Level_2_Discount_Percent__c, line.Slab_Level_3_Discount_Percent__c, line.Slab_Level_4_Discount_Percent__c, line.Slab_Level_5_Discount_Percent__c,line.Max_Slab_Rate_Discount__c};
                               DecList.sort();
                           system.debug('delist after sort 4+++'+DecList);
                           line.Max_Discount__c = DecList[7];
                           system.debug('decList at 7======'+DecList[7]);
                           UtilClass.qliRecursionCheck = true;
                       } 
                }   
            }
        }
    }
    
}