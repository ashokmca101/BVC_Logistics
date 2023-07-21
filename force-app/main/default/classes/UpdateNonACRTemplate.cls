public class UpdateNonACRTemplate {
    
    /* @future
public static void quoteRecordLock (List<Id> quoteIds){
List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c WHERE id in:quoteIds];
Approval.LockResult[] DemoList = Approval.lock(quoteList, false);

for(Approval.LockResult lr : DemoList ) {
if (lr.isSuccess()) {
} 
else {
// Operation failed, so get all errors   message              
for(Database.Error err : lr.getErrors()) {
System.debug('The following error has occurred.');                    
System.debug(err.getStatusCode() + ': ' + err.getMessage());
}
}
}
}*/
    public static void afterInsert(List<SBQQ__Quote__c> newQuoteList,Map<Id,SBQQ__Quote__c> oldQuoteMap){
        UtilClass.triggerLoop = true;
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        for(SBQQ__Quote__c newquote : newQuoteList){
            
            SBQQ__Quote__c oldQuote = oldQuoteMap.get(newquote.Id);
            system.debug('newquote.SBQQ__Status__c++'+newquote.SBQQ__Status__c+'Old status++'+oldQuote.SBQQ__Status__c);
            if(((newquote.SBQQ__LineItemCount__c>0 ) 
                || (newquote.SBQQ__Status__c == 'Approved' && oldQuote.SBQQ__Status__c != 'Approved' ))
               && newquote.Business_Type__c == 'Non ACR'){
                   quoteIds.add(newquote.id);
               }
        }
        if(quoteIds.size()>0){
            
            List<SBQQ__QuoteLine__c>  quoteLineList = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c qli : [SELECT Id,SBQQ__Quote__c,SBQQ__ProductCode__c,ST_Rate_Amount__c,ST_Gross_Weight_Slabs__c,
                                          ST_Minimum_Freight__c,ST_Liability_Coverage__c,ST_Offline_Charge__c,
                                          ST_Rate_UOM__c,SBQQ__Product__c,SBQQ__ProductName__c,SBQQ__Product__r.Name,Fuel_Surcharge__c 
                                          FROM SBQQ__QuoteLine__c 
                                          WHERE SBQQ__Quote__c =: quoteIds]){
                                              quoteLineList.add(qli);
                                              prodIds.add(qli.SBQQ__Product__c);
                                          }
             system.debug(quoteLineList[0].Fuel_Surcharge__c);
            system.debug('Product IDs :::'+prodIds);
            Map<Id,Map<String,Non_ACR_Template__c>> nonACRbyQuote = new Map<Id,Map<String,Non_ACR_Template__c>>();
            for(Non_ACR_Template__c act : [SELECT Id,ST_BVC_Service__c,ST_0_1_KG__c,ST_1_01_3_KG__c,ST_3_01_10_KG__c,ST_10_01_20_KG__c,ST_20_01_Kg__c,Quote__c FROM Non_ACR_Template__c WHERE Quote__c IN :quoteIds]){
                if(nonACRbyQuote.containsKey(act.Quote__c)){
                    nonACRbyQuote.get(act.Quote__c).put(act.ST_BVC_Service__c,act);
                }else{
                    nonACRbyQuote.put(act.Quote__c, new Map<String,Non_ACR_Template__c>{act.ST_BVC_Service__c=>act});
                }
                
            }
            Map<String,Map<String,ST_NonACR_Standard_Price__c>> nonACRstdPriceMap = new Map<String,Map<String,ST_NonACR_Standard_Price__c>>();
            for(ST_NonACR_Standard_Price__c price : [SELECT Id,ST_Min_Gross_Weight__c,
                                                     ST_Max_Gross_Weight__c,ST_Rate_Amount__c,
                                                     ST_Gross_Weight_Slabs__c,ST_Product__c
                                                     FROM ST_NonACR_Standard_Price__c
                                                     WHERE ST_Product__c   IN :prodIds]){
                                                         Map<String,ST_NonACR_Standard_Price__c> stdWeightMap = new Map<String,ST_NonACR_Standard_Price__c>();
                                                         
                                                         if(!nonACRstdPriceMap.containsKey(price.ST_Product__c)){
                                                             stdWeightMap.put(price.ST_Gross_Weight_Slabs__c,price);
                                                             nonACRstdPriceMap.put(price.ST_Product__c,stdWeightMap);
                                                         }
                                                         else{
                                                             nonACRstdPriceMap.get(price.ST_Product__c).put(price.ST_Gross_Weight_Slabs__c,price);
                                                         }
                                                     }
            system.debug('Non ACR Standard Price Map:::KeySet'+nonACRstdPriceMap.keySet());
            //List<Non_ACR_Template__c> newNonAcrTempList = new List<Non_ACR_Template__c>();
            Map<String,Non_ACR_Template__c> nonACRTemplatemap = new  Map<String,Non_ACR_Template__c>();
            List<Non_ACR_Template__c> nonACRTemplateList = new List<Non_ACR_Template__c>();
            system.debug('nonACRstdPriceMap:::'+nonACRstdPriceMap);
            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                if(quoteLine.SBQQ__Product__r.Name.contains('Surface C2C')
                   ||quoteLine.SBQQ__Product__r.Name.contains('Express C2C')
                   ||quoteLine.SBQQ__Product__r.Name.contains('Within City')){
                       
                       if(!nonACRbyQuote.containsKey(quoteLine.SBQQ__Quote__c)){
                           Non_ACR_Template__c newNonAcrTemp= new Non_ACR_Template__c();
                           newNonAcrTemp.ST_Quote_Line__c = quoteLine.Id;
                           nonACRTemplateList.add(newNonAcrTemp);
                           if(!nonACRTemplatemap.containskey(quoteLine.SBQQ__ProductCode__c)){
                               nonACRTemplatemap.put(quoteLine.SBQQ__ProductCode__c,newNonAcrTemp);
                               system.debug('Non ACR Template Map***PUT'+nonACRTemplatemap);
                           }
                           else {
                               newNonAcrTemp = nonACRTemplatemap.get(quoteLine.SBQQ__ProductCode__c);
                               system.debug('Non ACR Template Map***GET'+nonACRTemplatemap);
                           }
                           
                           newNonAcrTemp.ST_BVC_Service__c  = quoteLine.SBQQ__ProductName__c;
                           newNonAcrTemp.ST_Cost_Per__c = (quoteLine.ST_Rate_UOM__c == 'Flat Rate'? 'Per Shipment '+quoteLine.ST_Rate_UOM__c :  quoteLine.ST_Rate_UOM__c+' Gross Weight');
                           newNonAcrTemp.Quote__c  = quoteLine.SBQQ__Quote__c;
                           newNonAcrTemp.ST_Minimum_Freight_Per_Shipment__c = quoteLine.ST_Minimum_Freight__c;
                           newNonAcrTemp.ST_Offline_Loc_Chg_Per_Shipment_If_Appl__c = quoteLine.ST_Offline_Charge__c;
                           newNonAcrTemp.Liability_Coverage_If_Requested__c = quoteLine.ST_Liability_Coverage__c;
                           system.debug(quoteLine.Fuel_Surcharge__c);
                           newNonAcrTemp.Fuel_Surcharge_if_requested__c = quoteLine.Fuel_Surcharge__c;
                           if(quoteLine.SBQQ__Product__r.Name.contains('Surface C2C') || quoteLine.SBQQ__Product__r.Name.contains('Within City')){
                               newNonAcrTemp.ST_0_1_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_1_01_3_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_3_01_10_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_10_01_20_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_20_01_Kg__c = quoteLine.ST_Rate_Amount__c;
                           }
                           else if(quoteLine.SBQQ__Product__r.Name.contains( 'SilverSHIP Express C2C')){
                               if(quoteLine.ST_Gross_Weight_Slabs__c == '0 - 20 Kg'){
                                   newNonAcrTemp.ST_0_1_KG__c = quoteLine.ST_Rate_Amount__c;
                                   newNonAcrTemp.ST_1_01_3_KG__c = quoteLine.ST_Rate_Amount__c;
                                   newNonAcrTemp.ST_3_01_10_KG__c = quoteLine.ST_Rate_Amount__c;
                                   newNonAcrTemp.ST_10_01_20_KG__c = quoteLine.ST_Rate_Amount__c;
                               }else{
                                   newNonAcrTemp.ST_20_01_Kg__c = quoteLine.ST_Rate_Amount__c;
                               }
                           }               
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '0 - 1 Kg'){
                               newNonAcrTemp.ST_0_1_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++0 - 1 Kg'+quoteLine.ST_Rate_Amount__c);
                           }                
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '1.01 - 3 Kg'){
                               newNonAcrTemp.ST_1_01_3_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++1.01 - 3 Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '3.01 - 10 Kg'){
                               newNonAcrTemp.ST_3_01_10_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++3.01 - 10 Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '10.01 - 20 Kg'){
                               newNonAcrTemp.ST_10_01_20_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++10.01 - 20 Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           else if(quoteLine.ST_Gross_Weight_Slabs__c == '20.01+ Kg'){
                               newNonAcrTemp.ST_20_01_Kg__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++20.01+ Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           
                           
                           
                       }else if(nonACRbyQuote.containsKey(quoteLine.SBQQ__Quote__c) && nonACRbyQuote.get(quoteLine.SBQQ__Quote__c).containsKey(quoteLine.SBQQ__Product__r.Name)){
                           Non_ACR_Template__c newNonAcrTemp = nonACRbyQuote.get(quoteLine.SBQQ__Quote__c).get(quoteLine.SBQQ__Product__r.Name);
                           newNonAcrTemp.ST_Minimum_Freight_Per_Shipment__c = quoteLine.ST_Minimum_Freight__c;
                           newNonAcrTemp.ST_Offline_Loc_Chg_Per_Shipment_If_Appl__c = quoteLine.ST_Offline_Charge__c;
                           newNonAcrTemp.Liability_Coverage_If_Requested__c = quoteLine.ST_Liability_Coverage__c;
                           newNonAcrTemp.Fuel_Surcharge_if_requested__c = quoteLine.Fuel_Surcharge__c;
                           if(quoteLine.SBQQ__Product__r.Name.contains('Surface C2C') || quoteLine.SBQQ__Product__r.Name.contains('Within City')){
                               newNonAcrTemp.ST_0_1_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_1_01_3_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_3_01_10_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_10_01_20_KG__c = quoteLine.ST_Rate_Amount__c;
                               newNonAcrTemp.ST_20_01_Kg__c = quoteLine.ST_Rate_Amount__c;
                           }
                           else if(quoteLine.SBQQ__Product__r.Name.contains( 'SilverSHIP Express C2C')){
                               if(quoteLine.ST_Gross_Weight_Slabs__c == '0 - 20 Kg'){
                                   newNonAcrTemp.ST_0_1_KG__c = quoteLine.ST_Rate_Amount__c;
                                   newNonAcrTemp.ST_1_01_3_KG__c = quoteLine.ST_Rate_Amount__c;
                                   newNonAcrTemp.ST_3_01_10_KG__c = quoteLine.ST_Rate_Amount__c;
                                   newNonAcrTemp.ST_10_01_20_KG__c = quoteLine.ST_Rate_Amount__c;
                               }else{
                                   newNonAcrTemp.ST_20_01_Kg__c = quoteLine.ST_Rate_Amount__c;
                               }
                           }               
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '0 - 1 Kg'){
                               newNonAcrTemp.ST_0_1_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++0 - 1 Kg'+quoteLine.ST_Rate_Amount__c);
                           }                
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '1.01 - 3 Kg'){
                               newNonAcrTemp.ST_1_01_3_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++1.01 - 3 Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '3.01 - 10 Kg'){
                               newNonAcrTemp.ST_3_01_10_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++3.01 - 10 Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           else if (quoteLine.ST_Gross_Weight_Slabs__c == '10.01 - 20 Kg'){
                               newNonAcrTemp.ST_10_01_20_KG__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++10.01 - 20 Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           
                           else if(quoteLine.ST_Gross_Weight_Slabs__c == '20.01+ Kg'){
                               newNonAcrTemp.ST_20_01_Kg__c = quoteLine.ST_Rate_Amount__c;
                               system.debug('Contract Pricing+++20.01+ Kg'+quoteLine.ST_Rate_Amount__c);
                           }
                           nonACRTemplatemap.put(quoteLine.SBQQ__ProductCode__c,newNonAcrTemp);
                       }
                   }
            }
            system.debug('nonACRTemplatemap:::Final Rate Amount:::keySet '+nonACRTemplatemap.keySet());
            system.debug('nonACRTemplatemap:::Final Rate Amount:::values '+nonACRTemplatemap.values());
            upsert nonACRTemplatemap.values();
        }
    }
    
    public static void deleteNonACRTemplate(List<SBQQ__Quote__c> newQuoteList,Map<Id,SBQQ__Quote__c> oldQuoteMap){
        Set<Id> quoteIds = new Set<Id>();
        for(SBQQ__Quote__c newquote :  newQuoteList){
            SBQQ__Quote__c oldQuote =  oldQuoteMap.get(newquote.Id);
            if(((newquote.SBQQ__LineItemCount__c>0 && newquote.SBQQ__LineItemCount__c < oldQuote.SBQQ__LineItemCount__c) 
                || (newquote.SBQQ__Status__c == 'Approved' && oldQuote.SBQQ__Status__c != 'Approved' ))
               && newquote.Business_Type__c == 'Non ACR'){
                   quoteIds.add(newquote.Id);
               }  
        }
        List<Non_ACR_Template__c> deleteList = new List<Non_ACR_Template__c>();
        if(quoteIds != null && quoteIds.size() > 0){
            deleteList.addAll([Select id from Non_ACR_Template__c where  Quote__c In:quoteIds]);  
        }
        System.debug('Delete ids '+deleteList);
        if(deleteList.size()>0){
            delete deleteList;
            
        }
    }
}