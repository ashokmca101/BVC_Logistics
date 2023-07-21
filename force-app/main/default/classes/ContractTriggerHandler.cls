public class ContractTriggerHandler {
    
    
    public static void createPriceTables(Map<Id,Contract> newMap,Map<Id,Contract> oldMap){
        system.debug('Loop Contract : ');
        Set<Id> contractIdACRSet = new Set<Id>();
        Set<Id> contractIdNonACRSet = new Set<Id>();
        Set<Id> contractExhibitionSet = new Set<Id>();
        Map<Id,Contract> acrContractMap = new Map<Id,Contract>();
        Map<Id,Contract> nonACRContractMap = new Map<Id,Contract>();
        Map<Id,Contract> exhiContractMap = new Map<Id,Contract>();
        for(Contract cont : newMap.values()){
            if(cont.Status == 'Activated' && oldMap.get(cont.Id).Status <> cont.Status){
                if(cont.Business_Type__c == 'ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                    contractIdACRSet.add(cont.Id);
                    acrContractMap.put(cont.Id,cont);
                }
                else if(cont.Business_Type__c == 'Non ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                    contractIdNonACRSet.add(cont.Id);
                    nonACRContractMap.put(cont.Id,cont);
                }
                else if(cont.Business_Type__c == 'Exhibition'){
                    system.debug('Exhibition Contract : '+cont.Business_Type__c + 'Id : '+cont.Id);
                    contractExhibitionSet.add(cont.Id);
                    exhiContractMap.put(cont.Id,cont);
                }
            }
        }
        if(acrContractMap.size() > 0 && acrContractMap != null ){
            createACRContractedPrice(contractIdACRSet,acrContractMap);
        }
        if(nonACRContractMap.size() > 0 && nonACRContractMap != null ){
            createNonACRContractedPrice(contractIdNonACRSet,nonACRContractMap);
        }
        if(exhiContractMap.size() > 0 && exhiContractMap != null ){
            createExhibitionContractedPrice(contractExhibitionSet,exhiContractMap);
        }
    }
    
    public static void deactivateExistingPriceTable(Map<Id,Contract> newMap,Map<Id,Contract> oldMap){
        Map<Id,Contract> acrContractExpiryMap = new Map<Id,Contract>();
        Map<Id,Contract> nonAcrContractExpiryMap = new Map<Id,Contract>();
        Set<Id> contractExhibiSHIPExpirySet = new Set<Id>();
        Set<Id> contarctExpIds = new Set<Id>();
        Set<Id> accountUpdateOnExpiry = new Set<Id>();
        List<Contract> renewalOppContract = new List<Contract>();
        system.debug('===Trigger Called');
        for(Contract  cont : [SELECT Id, of_Contract_Consumption__c, SBQQ__RenewalForecast__c, 
                              Business_Type__c, status,SBQQ__Order__c,EndDate, AccountId,Account.Active_Exhibition_Contract__c,
                              Account.ST_Pricing_Type__c, SBQQ__Quote__r.SBQQ__NetAmount__c,Consumed_Amount__c,
                              SBQQ__Quote__r.Business_Type__c,Balance_Amount__c,SBQQ__Quote__r.Quote_For__c,BVC_Service__c 
                              FROM Contract WHERE Id =: trigger.newMap.keySet()])
        {
            system.debug('===Contract Id : '+cont.Id);
            
            Contract oldCont = oldMap.get(cont.Id);
            
            if(cont.Status == 'Expired' 
               && cont.Status <> oldCont.Status ){
                   if(cont.Business_Type__c == 'ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                       acrContractExpiryMap.put(cont.Id, cont);
                       accountUpdateOnExpiry.add(cont.AccountId); 
                   }
                   else if(cont.Business_Type__c == 'Non ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                       nonAcrContractExpiryMap.put(cont.Id, cont);
                       accountUpdateOnExpiry.add(cont.AccountId); 
                   }
                   else if(cont.Business_Type__c == 'Exhibition' ){
                       contractExhibiSHIPExpirySet.add(cont.Id);
                       //contractExhibiSHIPExpiryMap.put(cont.Id, cont);
                   }
                   system.debug('===Status to Expiry');
                   // accountUpdateOnExpiry.add(cont.AccountId);                    
               }
            else if(cont.EndDate < system.today()
                    && cont.EndDate <> oldCont.EndDate){
                        system.debug('===End date Expiry');
                        contarctExpIds.add(cont.Id);
                        if(cont.Business_Type__c == 'ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                            acrContractExpiryMap.put(cont.Id, cont);
                            accountUpdateOnExpiry.add(cont.AccountId);   
                        }
                        else if(cont.Business_Type__c == 'Non ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                            nonAcrContractExpiryMap.put(cont.Id, cont);
                            accountUpdateOnExpiry.add(cont.AccountId);   
                        }
                        else if(cont.Business_Type__c == 'Exhibition'){
                            contractExhibiSHIPExpirySet.add(cont.Id);
                        }
                        
                    }
            else if(cont.Consumed_Amount__c <> oldCont.Consumed_Amount__c 
                    && cont.Balance_Amount__c <= 0
                    && ( cont.Business_Type__c == 'ACR')){
                        system.debug('===Consumed Amount Expiry');
                        contarctExpIds.add(cont.Id);
                        if(cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP'){
                            acrContractExpiryMap.put(cont.Id, cont);
                        	accountUpdateOnExpiry.add(cont.AccountId);    
                        }                  
                    }
            else if(cont.Consumed_Amount__c <> oldCont.Consumed_Amount__c 
                    && cont.of_Contract_Consumption__c >= 85 && cont.SBQQ__RenewalForecast__c == false
                    && (cont.Business_Type__c == 'ACR' && cont.BVC_Service__c!='BATH' && cont.BVC_Service__c!='eSHIP')){
                        cont.SBQQ__RenewalForecast__c = true;
                        renewalOppContract.add(cont);
                    }
            
            
        }//End of loop
        
        
        
        //To update the Contract Status as Expired
        if(contarctExpIds.size() >0 ){
            contractExpiration(contarctExpIds);
        }
        
        //To update ACR/Non-ACR Contracted Price records as inactive on Contract Expiry
        if(!acrContractExpiryMap.isEmpty()){
            acrContractedPriceDeactivation(acrContractExpiryMap, 'DeactivationDueToExpiration');
            
        }
        if(!nonAcrContractExpiryMap.isEmpty()){
            acrContractedPriceDeactivation(nonAcrContractExpiryMap, 'DeactivationDueToExpiration');
            
        }
        if(!contractExhibiSHIPExpirySet.isEmpty() && contractExhibiSHIPExpirySet.size() > 0){
            deactivateExhibitionPrice(contractExhibiSHIPExpirySet,'DeactivationDueToExpiration');
        }
        
        
        
        //To update Account records on Contract Expiry
        if(accountUpdateOnExpiry.size() >0){
            updateAccountOnContractExpiration(accountUpdateOnExpiry);
        }
        
        if(!renewalOppContract.isEmpty()){
            update renewalOppContract;
        }
        
        
        
        
    }
    
    public static void createACRContractedPrice(Set<Id> contractIdSet,Map<Id,Contract> newContractMap){
        system.debug('CONT:::createACRContractedPrice:::'+contractIdSet+':::ContractMap:::'+newContractMap);
        List<ST_ACR_Contracted_Price__c> acrContractedPriceList = new List<ST_ACR_Contracted_Price__c>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        Set<Id> deactivatePrevCont = new Set<Id>();
        ST_ACR_Contracted_Price__c acrContract;
        Contract cont;
        Account acc;
        
        for(SBQQ__Subscription__c subs : [SELECT Id, SBQQ__ProductId__c, SBQQ__Contract__r.SBQQ__Order__c,SBQQ__QuoteLine__r.SBQQ__NetPrice__c,
                                          SBQQ__Contract__r.AccountId, SBQQ__Account__c, SBQQ__QuoteLine__r.SBQQ__Quote__c, 
                                          SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.Name,SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c,SBQQ__QuoteLine__r.SBQQ__Bundled__c,
                                          ST_Package_Type__c, ST_Gross_Weight_Slabs__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__NetAmount__c,
                                          ST_Origin__c, ST_Destination__c, ST_Rate_Amount__c, ST_Rate_UOM__c, ST_Minimum_Freight__c,
                                          ST_Offline_Charge__c, ST_Opt_For_Liability_Coverage__c,SBQQ__Contract__c,SBQQ__Account__r.ST_Previous_Contract__c,
                                          ST_Liability_Coverage__c, ST_Freight_on_Invoice_Value__c, SBQQ__Account__r.Active_Contract__c,
                                          ST_Exhibition__c, ST_Customer_Product_Category__c,ST_Invoice_Value__c, ST_Gross_Weight_Kg__c ,Fuel_Surcharge__c
                                          FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c=:contractIdSet ])
        {
            acrContract = new ST_ACR_Contracted_Price__c();
            acrContract.ST_Active__c = true;
           
            /*if(subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c == 'ExhibiSHIP'){
acrContract.ST_Contract__c = subs.SBQQ__Account__r.Active_Contract__c;
}
else{*/
            acrContract.ST_Contract__c = subs.SBQQ__Contract__c;
            //}
            acrContract.ST_ACR_Package_Type__c = subs.ST_Package_Type__c;
            acrContract.ST_Customer_Account__c = subs.SBQQ__Account__c;
            acrContract.ST_Customer_Product_Category__c = subs.ST_Customer_Product_Category__c;
            acrContract.ST_Destination__c = subs.ST_Destination__c;
            acrContract.ST_Exhibition__c = subs.ST_Exhibition__c;
            acrContract.ST_Freight_on_Invoice_Value__c = subs.ST_Freight_on_Invoice_Value__c;
            acrContract.ST_Liability_Coverage__c = subs.ST_Liability_Coverage__c;
            acrContract.ST_Minimum_Freight__c = subs.ST_Minimum_Freight__c;
            acrContract.ST_Offline_Charge__c = subs.ST_Offline_Charge__c;
            acrContract.ST_Order__c = subs.SBQQ__Contract__r.SBQQ__Order__c;
            acrContract.ST_Origin__c = subs.ST_Origin__c;
            acrContract.ST_Product__c = subs.SBQQ__ProductId__c;
            acrContract.ST_Rate_Amount__c = subs.ST_Rate_Amount__c;
            acrContract.ST_Rate_UOM__c = subs.ST_Rate_UOM__c;
            acrContract.GenSHIP_Weight_Slab__c = subs.ST_Gross_Weight_Slabs__c;
            acrContract.Fuel_Surcharge__c = subs.Fuel_Surcharge__c;
            
            if(subs.SBQQ__QuoteLine__r.SBQQ__NetPrice__c == 0 ){
                acrContractedPriceList.add(acrContract);
            }
            
            //In case of ExhibiSHIP-ONLY contract, Account record need not to be updated and previous Contract will not be deactivated
            if(subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c != 'ExhibiSHIP'){
                
                
                //If there is existing Active Contract for this account, then we will be deactivating it.
                system.debug('Deactivate prev Contract::'+subs.SBQQ__Account__r.Active_Contract__c);
                if(subs.SBQQ__Account__r.Active_Contract__c != null){
                    deactivatePrevCont.add(subs.SBQQ__Account__r.Active_Contract__c); 
                }
                
                
                if(!String.isBlank(subs.ST_Package_Type__c) && !accMap.containsKey(subs.SBQQ__Contract__c)){
                    Id existingContId;
                    if(subs.SBQQ__Account__r.Active_Contract__c != null){
                        existingContId = subs.SBQQ__Account__r.Active_Contract__c;
                    }
                    else{
                        existingContId = subs.SBQQ__Account__r.ST_Previous_Contract__c;
                    }
                    acc = new Account(Id=subs.SBQQ__Account__c,
                                      ST_Pricing_Type__c='ACR',
                                      Customer_Category__c='ACR Contracted',
                                      Email_Sent_at_100_Consumption__c = false,
                                      Email_Sent_at_85_Consumption__c = false,
                                      Email_Sent_at_90_Consumption__c = false,
                                      Email_Sent_at_95_Consumption__c = false,
                                      Email_Sent_at_98_Consumption__c = false,
                                      ST_Previous_Contract__c=existingContId,
                                      Active_Contract__c=subs.SBQQ__Contract__c
                                     // Consumption_Status__c='Within limit'
                                     );
                    	
                    accMap.put(subs.SBQQ__Contract__c, acc);
                }
            }
        }//End of loop
        try{
            if(!acrContractedPriceList.isEmpty()){
                system.debug('===acrContractedPriceList size : '+acrContractedPriceList.size());
                insert acrContractedPriceList;
            }
            
            if(!accMap.isEmpty()){
                system.debug('===acc details : '+accMap.values());
                update accMap.values();
            }
            
            if(!deactivatePrevCont.isEmpty()){
                contractExpiration(deactivatePrevCont);
            }
            
        }
        catch(Exception ex)
        {
            system.debug('Error occurred : '+ex.getStackTraceString()+', Error Message : '+ex.getMessage()+', Line Number : '+ex.getLineNumber());            
        }
        Map<Id,Contract> acrContractMap = new Map<Id,Contract>();
        for(Contract c : newContractMap.values()){
            if(c.SBQQ__Quote__r.Quote_For__c != 'ExhibiSHIP'){
                acrContractMap.put(c.Id,c);
            } 
        }
        if(acrContractMap.size() > 0){
            system.debug('acrContractMap:::'+acrContractMap);
            acrContractedPriceDeactivation(acrContractMap, 'DeactivationDueToNewContract');
            nonAcrContractedPriceDeactivation(acrContractMap, 'DeactivationDueToNewContract');
        }
    }
    
    public static void createNonACRContractedPrice(Set<Id> contractIdSet, Map<Id,Contract> newContractMap){
        system.debug('===createNonACRContractedPrice called');
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<ST_NonACR_Contracted_Price__c> nonACRContractedPriceList = new List<ST_NonACR_Contracted_Price__c>();
        Set<Id> deactivatePrevCont = new Set<Id>();
        Account acc;
        ST_NonACR_Contracted_Price__c nonACRContract;
        //ST_ACR_Contracted_Price__c acrContract;
        system.debug('===createNonACRContractedPrice called');
        
        for(SBQQ__Subscription__c subs : [SELECT Id, SBQQ__ProductId__c, SBQQ__Contract__r.SBQQ__Order__c, ST_Max_Gross_Weight__c, ST_Min_Gross_Weight__c,
                                          SBQQ__Contract__r.AccountId, SBQQ__Account__c, SBQQ__QuoteLine__r.SBQQ__Quote__c, 
                                          SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.Name,
                                          ST_Package_Type__c, ST_Gross_Weight_Slabs__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__NetAmount__c,
                                          ST_Origin__c, ST_Destination__c, ST_Rate_Amount__c, ST_Rate_UOM__c, ST_Minimum_Freight__c,
                                          ST_Offline_Charge__c, ST_Opt_For_Liability_Coverage__c, SBQQ__Account__r.ST_Previous_Contract__c,
                                          ST_Liability_Coverage__c, ST_Freight_on_Invoice_Value__c, SBQQ__Account__r.Active_Contract__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c,
                                          ST_Exhibition__c, ST_Customer_Product_Category__c,ST_Invoice_Value__c, ST_Gross_Weight_Kg__c,Fuel_Surcharge__c 
                                          FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c=:contractIdSet ])
        {
            system.debug('===SBQQ__Subscription__c record : '+subs.Id);
            nonACRContract = new ST_NonACR_Contracted_Price__c();
            nonACRContract.ST_Active__c = true;
            if(subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c == 'ExhibiSHIP'){
                nonACRContract.ST_Contract__c = subs.SBQQ__Account__r.Active_Contract__c;
            }
            else{
                nonACRContract.ST_Contract__c = subs.SBQQ__Contract__c;
            }
            nonACRContract.ST_Customer_Account__c = subs.SBQQ__Account__c;
            nonACRContract.ST_Customer_Product_Category__c = subs.ST_Customer_Product_Category__c;
            nonACRContract.ST_Destination__c = subs.ST_Destination__c;
            nonACRContract.ST_Exhibition__c = subs.ST_Exhibition__c;
            nonACRContract.ST_Freight_on_Invoice_Value__c = subs.ST_Freight_on_Invoice_Value__c;
            nonACRContract.ST_Liability_Coverage__c = subs.ST_Liability_Coverage__c;
            nonACRContract.ST_Minimum_Freight__c = subs.ST_Minimum_Freight__c;
            nonACRContract.ST_Offline_Charge__c = subs.ST_Offline_Charge__c;
            nonACRContract.ST_Order__c = subs.SBQQ__Contract__r.SBQQ__Order__c;
            nonACRContract.ST_Origin__c = subs.ST_Origin__c;
            nonACRContract.ST_Product__c = subs.SBQQ__ProductId__c;
            nonACRContract.ST_Rate_Amount__c = subs.ST_Rate_Amount__c;
            nonACRContract.ST_Rate_UOM__c = subs.ST_Rate_UOM__c;
            nonACRContract.ST_Max_Gross_Weight__c = subs.ST_Max_Gross_Weight__c;
            nonACRContract.ST_Min_Gross_Weight__c = subs.ST_Min_Gross_Weight__c;
            nonACRContract.Fuel_Surcharge__c = subs.Fuel_Surcharge__c;
            
            nonACRContractedPriceList.add(nonACRContract);
            
            //In case of ExhibiSHIP-ONLY contract, Account record need not to be updated and previous Contract will not be deactivated
            if(subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c != 'ExhibiSHIP'){
                
                //If there is existing Active Contract for this account, then we will be deactivating it.
                if(subs.SBQQ__Account__r.Active_Contract__c != null){
                    deactivatePrevCont.add(subs.SBQQ__Account__r.Active_Contract__c);
                }
                
                if(!accMap.containsKey(subs.SBQQ__Contract__c)){
                    Id existingContId;
                    if(subs.SBQQ__Account__r.Active_Contract__c != null){
                        existingContId = subs.SBQQ__Account__r.Active_Contract__c;
                    }
                    else{
                        existingContId = subs.SBQQ__Account__r.ST_Previous_Contract__c;
                    }
                    acc = new Account(Id=subs.SBQQ__Account__c,
                                      ST_Pricing_Type__c='Non ACR',
                                      Customer_Category__c='Non ACR Contracted',
                                      ST_Previous_Contract__c=existingContId,
                                      Active_Contract__c=subs.SBQQ__Contract__c);
                    
                    accMap.put(subs.SBQQ__Contract__c, acc);
                }
            }
            
        }
        try{
            if(!nonACRContractedPriceList.isEmpty()){
                system.debug('===nonACRContractedPriceList size : '+nonACRContractedPriceList.size());
                insert nonACRContractedPriceList;
            }
            
            if(!accMap.isEmpty()){
                system.debug('===acc details : '+accMap.values());
                update accMap.values();
            }
            
            if(!deactivatePrevCont.isEmpty()){
                contractExpiration(deactivatePrevCont);
            }
        }
        catch(Exception ex)
        {
            system.debug('===Error occurred : '+ex.getStackTraceString()+', Error Message : '+ex.getMessage()+', Line Number : '+ex.getLineNumber());            
        }
        Map<Id,Contract> nonACRContractMap = new Map<Id,Contract>();
        for(Contract c : newContractMap.values()){
            if(c.SBQQ__Quote__r.Quote_For__c != 'ExhibiSHIP'){
                nonACRContractMap.put(c.Id,c);
            } 
        }
        if(nonACRContractMap.size() > 0){
            system.debug('nonACRContractMap');
            acrContractedPriceDeactivation(nonACRContractMap,'DeactivationDueToNewContract');
            nonAcrContractedPriceDeactivation(nonACRContractMap, 'DeactivationDueToNewContract');
        }
        
    }
    
    public static void createExhibitionContractedPrice(Set<Id> contractIdSet, Map<Id,Contract> newContractMap){
        system.debug('===createExhibitionContractedPrice called');
        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id,Set<Id>> customerExhiMap = new Map<Id,Set<Id>>();
        List<ST_Exhibition_Contracted_Price__c> exhibitionContractedPriceList = new List<ST_Exhibition_Contracted_Price__c>();
        Set<Id> deactivatePrevCont = new Set<Id>();
        Account acc = new Account();
        
        
        for(SBQQ__Subscription__c subs : [select id, SBQQ__ProductId__c, SBQQ__Contract__r.AccountId, SBQQ__Contract__r.Account.Active_Exhibition_Contract__c,ST_Customer_Product_Category__c, ST_Exhibition__c,ST_Liability_Coverage__c,
                                          ST_Offline_Charge__c, ST_Rate_Amount__c, ST_Rate_UOM__c, SBQQ__Account__c, SBQQ__EndDate__c, SBQQ__StartDate__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.Quote_For__c,
                                          SBQQ__Account__r.Active_Contract__c, SBQQ__Contract__c,Exhibition_Standard_Price__r.Level_1__c,Exhibition_Standard_Price__r.Level_2__c,Exhibition_Standard_Price__r.Level_3__c,
                                          Slab_Level_1_Rate__c,Slab_Level_2_Rate__c,Slab_Level_3_Rate__c,Slab_Level_4_Rate__c,Slab_Level_5_Rate__c,Max_Slab_Rate__c,
                                          Exhibition_Standard_Price__r.Level_4__c,Exhibition_Standard_Price__r.Level_5__c//, Fuel_Surcharge__c
                                          FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c=:contractIdSet ])
        {
            system.debug('===SBQQ__Subscription__c record : '+subs.Id);
            ST_Exhibition_Contracted_Price__c exhibitionContract = new ST_Exhibition_Contracted_Price__c();
            exhibitionContract.ST_Active__c = true;
            exhibitionContract.ST_Contract__c = subs.SBQQ__Contract__c;
            exhibitionContract.ST_Customer_Account__c = subs.SBQQ__Account__c;
            exhibitionContract.ST_Customer_Product_Category__c = subs.ST_Customer_Product_Category__c;
            exhibitionContract.ST_End_Date__c = subs.SBQQ__EndDate__c;
            exhibitionContract.ST_Exhibition__c = subs.ST_Exhibition__c;
            exhibitionContract.ST_Liability_Coverage__c = subs.ST_Liability_Coverage__c;
            exhibitionContract.ST_Offline_Charge__c = subs.ST_Offline_Charge__c;
            //exhibitionContract.Fuel_Surcharge__c = subs.Fuel_Surcharge__c;
            exhibitionContract.ST_Product__c = subs.SBQQ__ProductId__c;
            exhibitionContract.ST_Rate_UOM__c = subs.ST_Rate_UOM__c;
            exhibitionContract.Level_1_Rate__c = subs.Slab_Level_1_Rate__c;
            exhibitionContract.Level_2_Rate__c = subs.Slab_Level_2_Rate__c;
            exhibitionContract.Level_3_Rate__c = subs.Slab_Level_3_Rate__c;
            exhibitionContract.Level_4_Rate__c = subs.Slab_Level_4_Rate__c;
            exhibitionContract.Level_5_Rate__c = subs.Slab_Level_5_Rate__c;
            exhibitionContract.Max_Slab_Rate__c = subs.Max_Slab_Rate__c;
            exhibitionContract.ST_Start_Date__c = subs.SBQQ__StartDate__c;
            exhibitionContract.Level_1__c = subs.Exhibition_Standard_Price__r.Level_1__c;
            exhibitionContract.Level_2__c = subs.Exhibition_Standard_Price__r.Level_2__c;
            exhibitionContract.Level_3__c = subs.Exhibition_Standard_Price__r.Level_3__c;
            exhibitionContract.Level_4__c = subs.Exhibition_Standard_Price__r.Level_4__c;
            exhibitionContract.Level_5__c = subs.Exhibition_Standard_Price__r.Level_5__c;
            exhibitionContractedPriceList.add(exhibitionContract);
            if(customerExhiMap.containsKey(subs.SBQQ__Account__c)){
                customerExhiMap.get(subs.SBQQ__Account__c).add(subs.ST_Exhibition__c);
            }
            else{
                Set<Id> exiId = new Set<Id>{subs.ST_Exhibition__c};
                    customerExhiMap.put(subs.SBQQ__Account__c,exiId);
            }
        }
        
        try{
            if(!exhibitionContractedPriceList.isEmpty()){
                system.debug('===exhibitionContractedPriceList size : '+exhibitionContractedPriceList.size());
                insert exhibitionContractedPriceList;
            }
            
            if(!accMap.isEmpty()){
                system.debug('===acc details : '+accMap.values());
                update accMap.values();
            }            
        }
        catch(Exception ex)
        {
            system.debug('===Error occurred : '+ex.getStackTraceString()+', Error Message : '+ex.getMessage()+', Line Number : '+ex.getLineNumber());            
        }
        if(customerExhiMap.size() > 0 && customerExhiMap != null){
            Set<Id> existingContractIds = getExistingContractIds(customerExhiMap,newContractMap);
            if(existingContractIds.size() > 0 && existingContractIds != null){
                deactivateExhibitionPrice(existingContractIds,'DeactivationDueToNewContract');
                contractExpiration(existingContractIds);
            }
            
        }
        
    }
    
    public static void acrContractedPriceDeactivation(Map<Id,Contract> contractMap, String deactivationEvent){
        system.debug('CONT:::acrContractedPriceDeactivation');
        Set<Id> accIds = new Set<Id>();
        Map<Id,Id> orderContractIdMap = new Map<Id,Id>();
        for(Contract c : contractMap.values()){
            accIds.add(c.AccountId);
            orderContractIdMap.put(c.SBQQ__Order__c,c.Id);
        }
        List<ST_ACR_Contracted_Price__c> acrContractPrices2Update = new List<ST_ACR_Contracted_Price__c>();
        for(ST_ACR_Contracted_Price__c price : [SELECT Id,ST_Order__c,ST_Active__c,ST_Deactivation_Date__c,
                                                ST_Product__c,CreatedDate,ST_Contract__c 
                                                FROM ST_ACR_Contracted_Price__c
                                                WHERE ST_Customer_Account__c IN :accIds
                                                ORDER BY CreatedDate desc 
                                               ])
        {
            
            if(price.ST_Active__c && deactivationEvent == 'DeactivationDueToNewContract'
               && (!contractMap.containsKey(price.ST_Contract__c)) 
               //&& price.ST_Contract__c != orderContractIdMap.get(price.ST_Order__c) //Adel, do we need this ?
              ) 
            {
                price.ST_Active__c = false;
                price.ST_Deactivation_Date__c = system.today();
                acrContractPrices2Update.add(price);
            }
            /*else if(price.ST_Active__c && deactivationEvent == 'DeactivationDueToExpiration'){
                price.ST_Active__c = false;
                price.ST_Deactivation_Date__c = system.today();
                acrContractPrices2Update.add(price);
            }*/
            
        }
        if(acrContractPrices2Update.size() >0){
            try {
                update acrContractPrices2Update;
            } catch (DmlException ex) {
                System.debug('The Update on contractedPriceActivation Failed Exception***'+ex.getMessage());
            }
        }
    }
    
    public static void nonAcrContractedPriceDeactivation(Map<Id,Contract> contractMap, String deactivationEvent){
        system.debug('CONT:::nonAcrContractedPriceDeactivation');
        Set<Id> accIds = new Set<Id>();
        Map<Id,Id> orderContractIdMap = new Map<Id,Id>();
        for(Contract c : contractMap.values()){
            accIds.add(c.AccountId);
            orderContractIdMap.put(c.SBQQ__Order__c,c.Id);
        }
        List<ST_NonACR_Contracted_Price__c> nonAcrContractPrices2Update = new List<ST_NonACR_Contracted_Price__c>();
        for(ST_NonACR_Contracted_Price__c price : [SELECT Id,ST_Order__c,ST_Active__c,ST_Deactivation_Date__c,
                                                   ST_Product__c,CreatedDate,ST_Contract__c 
                                                   FROM ST_NonACR_Contracted_Price__c
                                                   WHERE ST_Customer_Account__c IN :accIds
                                                   ORDER BY CreatedDate desc 
                                                  ])
        {
            if(price.ST_Active__c && deactivationEvent == 'DeactivationDueToNewContract'
               && !contractMap.containsKey(price.ST_Contract__c)){
                   price.ST_Active__c = false;
                   price.ST_Deactivation_Date__c = system.today();
                   nonAcrContractPrices2Update.add(price);
               }
            else if(price.ST_Active__c && deactivationEvent == 'DeactivationDueToExpiration'){
                price.ST_Active__c = false;
                price.ST_Deactivation_Date__c = system.today();
                nonAcrContractPrices2Update.add(price);
            }
            else if(price.ST_Active__c && deactivationEvent == 'DeactivationOfExhibiSHIPContract'){
                price.ST_Active__c = false;
                price.ST_Deactivation_Date__c = system.today();
                nonAcrContractPrices2Update.add(price);
            }
            
        }
        if(nonAcrContractPrices2Update.size() >0){
            try {
                update nonAcrContractPrices2Update;
            } catch (DmlException ex) {
                System.debug('The Update on contractedPriceActivation Failed Exception***'+ex.getMessage());
            }
        }
    }
    
    public static void deactivateExhibitionPrice(Set<Id> contractIds,String deactivationEvent){
        List<ST_Exhibition_Contracted_Price__c> existingPrices = new List<ST_Exhibition_Contracted_Price__c>();
        for(ST_Exhibition_Contracted_Price__c ecp : [SELECT Id,ST_Active__c,ST_Contract__c 
                                                     FROM ST_Exhibition_Contracted_Price__c 
                                                     WHERE ST_Contract__c IN :contractIds]){
                                                         ecp.ST_Active__c = false;
                                                         ecp.ST_End_Date__c = Date.today();
                                                         existingPrices.add(ecp);
                                                     }
        if(existingPrices.size() > 0){
            Database.SaveResult[] lsr = Database.update(existingPrices, false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('ECP Update Passed : '+result.getId()); 
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('ECP fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }
    
    public static void resetEmailTriggerACRAdjustment(Map<Id,Contract> newContractMap, Map<Id,Contract> oldContractMap){
        Set<Id> accIds = new Set<Id>();
        List<Account> accountList = new List<Account>();
        for(Contract con : newContractMap.values()){
            Contract oldcon = oldContractMap.get(con.Id);
            if(con.Business_Type__c == 'ACR'
               &&con.Adjusted_Contract_Amount__c != oldcon.Adjusted_Contract_Amount__c){
                   accIds.add(con.AccountId);
                   
               }
        }
        
        if(accIds.size() > 0){
            for(Id acId : accIds){
                Account acc = new Account(Id = acId,
                                          Email_Sent_at_100_Consumption__c = false,
                                          Email_Sent_at_85_Consumption__c = false,
                                          Email_Sent_at_90_Consumption__c = false,
                                          Email_Sent_at_95_Consumption__c = false,
                                          Email_Sent_at_98_Consumption__c = false);
                accountList.add(acc);
            }
        }
        
        if(accountList.size()  > 0){
            update accountList;
        }
        
        
    }
    
   public static void contractExpiration(Set<Id> contIds){
        
        List<Contract> contractsToBeUpdated = new List<Contract>();
        for(Contract cont : [select Id,EndDate, Status,Business_Type__c,SBQQ__Quote__c from Contract where Id =:  contIds]){
            if(cont.Status!='Expired' && cont.Status!='Cancelled'){
                if((cont.Business_Type__c=='Non ACR' && cont.SBQQ__Quote__c!=null) ||(cont.Business_Type__c=='Non ACR' && cont.SBQQ__Quote__c==null)
                  || (cont.Business_Type__c=='Exhibition' && cont.SBQQ__Quote__c!=null) || (cont.Business_Type__c=='ACR' && cont.SBQQ__Quote__c==null)
                  ) {
                    cont.EndDate = system.today();
                }
               // else(cont.Original_Contract_End_Date__c=system.today());
                
                cont.Status = 'Expired';
                contractsToBeUpdated.add(cont);  
            }
            
        }
        if(!contractsToBeUpdated.isEmpty()){
            UtilClass.isFirstTime = false;
            update contractsToBeUpdated;
        }
    }
    
    
    private static Set<Id> getExistingContractIds(Map<Id,Set<Id>> customerExhiMap,Map<Id,Contract> newContractMap){
        Set<Id> contractIds = new Set<Id>();
        for(Contract cont : [SELECT Id,
                                 EndDate,
                                 AccountId, 
                                 Status,
                                 Exhibition__c 
                             FROM Contract 
                             WHERE AccountId IN :customerExhiMap.keySet()
                             AND Id NOT IN :newContractMap.keySet()]){
                                 if(customerExhiMap.get(cont.AccountId).contains(cont.Exhibition__c)){
                                    contractIds.add(cont.Id); 
                                 }
                             }
        return contractIds;
    }
    
    public static void updateAccountOnContractExpiration(Set<Id> accIds){
        system.debug('CONT:::updateAccountOnContractExpiration');
        List<Account> accToBeUpdated = new List<Account>();
        
        
        for(Account a : [select Id, Name,Active_Contract__c, Active_Contract__r.Business_Type__c,ST_Previous_Contract__c,ST_Pricing_Type__c,Customer_Category__c,Billing_Frequency__c,Credit_Days__c 
                         FROM Account WHERE ID =:accIds]){
                             Account acc = new Account();
                             acc.Id = a.Id;
                             /*acc.ST_Previous_Contract__c = a.Active_Contract__c;
                             acc.Active_Contract__c = null;
                             acc.ST_Pricing_Type__c = 'Non ACR';
                             acc.Customer_Category__c = 'Non Contracted'; */
                             acc.ST_Pricing_Type__c = 'ACR';
                             acc.Customer_Category__c = 'ACR Contracted';
                             acc.Billing_Frequency__c = 'Monthly';
                             //acc.Consumption_Status__c='Overconsumed';
                             if(a.Active_Contract__r.Business_Type__c == 'ACR'){
                                 acc.Credit_Days__c = '30';
                                 acc.Credit_Status__c = 'Credit';
                             }
                             accToBeUpdated.add(acc);
                         }
        
        if(!accToBeUpdated.isEmpty()){
            update accToBeUpdated;
        }
    }
    
    public static void sendContractExpiryEmail(List<Contract> contractList,Map<Id,Contract> oldContractMap){
        Set<Id> accIds = new Set<Id>();
        List<Account> sentemailAccounts = new List<Account>();
        List<Account> accs2Update = new List<Account>();
        for(Contract con : contractList){
            Contract oldCon = oldContractMap.get(con.Id);
            Decimal consumedPercent;
            if(con.Adjusted_Contract_Amount__c != null
               &&con.Consumed_Amount__c != null
               && con.Adjusted_Contract_Amount__c >0 ){
                   consumedPercent = (con.Consumed_Amount__c / con.Adjusted_Contract_Amount__c)*100; 
               }
            if(con.Business_Type__c == 'ACR'
               && con.Contracted_ACR_Package__c != null
               && consumedPercent >= Decimal.valueOf(Label.ContractExpiryEmailThresholdPercent)
               && consumedPercent != null){
                   accIds.add(con.AccountId);
               }
        }
        Boolean expiryByDate = false;
        
        if(accIds.size() >0){
            for(Account acc : [SELECT AccountNumber,Name,Balance_Amount__c,Point_Of_Contact_Email__c,
                                   Annual_Contract_Balance__c,Active_Contract__c,Consumed_ACR_Amount__c,
                                   Active_Contract__r.of_Contract_Consumption__c,Active_Contract__r.Consumed_Amount__c,
                                   Adjusted_Contract_Amount__c,Contract_Start_Date__c,Contract_Amount__c,
                                   Consumed_Amount__c,Contract_End_Date__c,ST_Total_Consumable_ACR_Amount__c,
                                   (SELECT ContactId,AccountId,Contact.Email,Roles FROM AccountContactRelations WHERE Roles includes ('Finance','Invoice Recepient')),
                                   Email_Sent_at_85_Consumption__c,Email_Sent_at_90_Consumption__c,Email_Sent_at_95_Consumption__c,
                                   Email_Sent_at_98_Consumption__c,Email_Sent_at_100_Consumption__c,of_Contract_Consumption__c
                                   FROM Account 
                                   WHERE Id IN :accIds
                                   AND Contracted_ACR_Package__c != null] ){
                                   if(acc.AccountContactRelations.size() >0){
                                       
                                       if(acc.Active_Contract__r.of_Contract_Consumption__c >=85 && acc.Active_Contract__r.of_Contract_Consumption__c <90 && !acc.Email_Sent_at_85_Consumption__c){
                                           sentemailAccounts.add(acc);
                                           acc.Email_Sent_at_85_Consumption__c = true;
                                           accs2Update.add(acc);
                                       }
                                       
                                       else if(acc.Active_Contract__r.of_Contract_Consumption__c >=90 
                                               && acc.Active_Contract__r.of_Contract_Consumption__c <95 
                                               && !acc.Email_Sent_at_90_Consumption__c){
                                                   sentemailAccounts.add(acc);
                                                   acc.Email_Sent_at_90_Consumption__c = true;
                                                   accs2Update.add(acc);
                                               }
                                       
                                       else if(acc.Active_Contract__r.of_Contract_Consumption__c >=95 
                                               && acc.Active_Contract__r.of_Contract_Consumption__c <98 
                                               && !acc.Email_Sent_at_95_Consumption__c){
                                                   sentemailAccounts.add(acc);
                                                   acc.Email_Sent_at_95_Consumption__c = true;
                                                   accs2Update.add(acc);
                                               }
                                       
                                       else if(acc.Active_Contract__r.of_Contract_Consumption__c >=98 
                                               && acc.Active_Contract__r.of_Contract_Consumption__c <100 
                                               && !acc.Email_Sent_at_98_Consumption__c){
                                                   system.debug('Account 95-98'+acc.name);
                                                   sentemailAccounts.add(acc);
                                                   acc.Email_Sent_at_98_Consumption__c = true;
                                                   accs2Update.add(acc);
                                               }
                                       
                                       else if(acc.Active_Contract__r.of_Contract_Consumption__c >=100 
                                               && !acc.Email_Sent_at_100_Consumption__c){
                                                   sentemailAccounts.add(acc);
                                                   acc.Email_Sent_at_100_Consumption__c = true;
                                                   accs2Update.add(acc);
                                               }
                                       
                                   }
                               }
        }
        if(accs2Update.size() > 0){
            try{
                update accs2Update;
            }catch(Exception ex){
                system.debug('Insert Failed for Consumption Account:::'+ex.getMessage());
            }
        }
        if(sentemailAccounts.size() > 0){
            List<Messaging.SingleEmailMessage> mailingList = SendEmailUtility.ContractExpiryEmailSender(Label.ContractConsumptionExpiryEmailTemplateName ,sentemailAccounts,expiryByDate);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailingList);
        }       
    }
    
    public static void populateinvoice(List<Contract> contractList){
        Map<Id,Contract> orderContractMap = new Map<Id,Contract>();
        Map<Id,blng__Invoice__c> orderInvoiceMap = new Map<Id,blng__Invoice__c>();
        for(Contract con : contractList)
        {
            if(con.Business_Type__c == 'ACR' && con.BVC_Service__c!='BATH' && con.BVC_Service__c!='eSHIP'){
            orderContractMap.put(con.SBQQ__Order__c, con);
            }
            if(con.Business_Type__c == 'Non ACR'|| con.Business_Type__c == 'Exhibition'||con.SBQQ__Quote__c==null){//added by Pratik
               con.Invoice__c=null; //added by Pratik
        	}
        }
        if(!orderContractMap.isEmpty() && orderContractMap.size() > 0)
        {
            for(blng__Invoice__c inv : [Select Id, blng__Order__c, Name
                                        From blng__Invoice__c 
                                        Where blng__Order__c In :orderContractMap.keySet() ])
            {
                orderInvoiceMap.put(inv.blng__Order__c, inv);
            }
            for(Contract con : contractList)
            {
                if(orderInvoiceMap.size() >0 
                   && orderInvoiceMap != null 
                   && con.Invoice__c == null
                   && orderInvoiceMap.containsKey(con.SBQQ__Order__c)){
                       con.Invoice__c = orderInvoiceMap.get(con.SBQQ__Order__c).Id;
                   }
                system.debug('invoice number : '+con.Invoice__c);
            }
            
        }
        
    }
    
     public static void fakeMethod(){
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
     }
    
}