public with sharing class CreateQuoteController {
    
   
    
    @AuraEnabled
    public static string CreateBVCQuote(SBQQ__Quote__c quote){
        system.debug('method executed'+quote);
        try {
            String quoteId;
            if(quote.Business_Type__c == null || String.isBlank(quote.Business_Type__c)){
                throw new applicationException('Required Field Missing : Business Type');
            }
            else if(quote.BVC_Branch__c == null || String.isBlank(quote.BVC_Branch__c)){
                throw new applicationException('Required Field Missing : BVC Branch');
            }
            else if(quote.SBQQ__StartDate__c == null ){
                throw new applicationException('Required Field Missing : Start Date');
            }
            
            if(quote.Business_Type__c == 'ACR' || quote.Business_Type__c == 'Exhibition' ){
                if(quote.Business_Type__c == 'ACR' && !String.isBlank(quote.Exhibition__c)){
                    throw new applicationException('Exhibition Details Should be blank for ACR Quotes');
                }
                else  if(quote.Business_Type__c == 'Exhibition' && String.isBlank(quote.Exhibition__c)){
                    throw new applicationException('Exhibition Details Should be filled for Exhibition Quotes');
                }
                
                insert quote;

                quoteId =  quote.Id; 
                
                
                
            }else if(quote.Business_Type__c == 'Non ACR'){
                if(!String.isBlank(quote.Exhibition__c)){
                    throw new applicationException('Exhibition Details Should be blank for Non ACR Quotes');
                }
                
                Base_Quote_Settings__c baseQuote = Base_Quote_Settings__c.getValues('Non ACR');
                system.debug('base quote'+baseQuote);
                if(baseQuote != null && baseQuote.Base_QuoteId__c != null){
                    Id QuoteToClone = baseQuote.Base_QuoteId__c;
                    QuoteCloneWithLine cloner = new QuoteCloneWithLine( QuoteToClone, 'SBQQ__LineItems__r');
                    SBQQ__QUOTE__C beforeClone = (SBQQ__QUOTE__C ) cloner.clone;
                    beforeClone.SBQQ__Primary__c = quote.SBQQ__Primary__c;
                    beforeClone.SBQQ__Status__c = 'draft';
                    beforeClone.RecordTypeId =  Schema.SObjectType.SBQQ__QUOTE__C.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
                    beforeClone.SBQQ__Ordered__c = false;
                    beforeClone.SBQQ__EndDate__c = null;
                    beforeClone.Base_Quote__c = false;
                    beforeClone.Contract_Start_Date__c = null;
                    beforeClone.BVC_Branch__c = quote.BVC_Branch__c;
                    beforeClone.BVC_Billing_Entity__c = null;
                    beforeClone.BVC_Entity__c = null;
                    beforeClone.SBQQ__StartDate__c  = quote.SBQQ__StartDate__c;
                    beforeClone.OwnerId = Id.valueOf(Userinfo.getUserId());
                    beforeClone.SBQQ__SalesRep__c = Id.valueOf(Userinfo.getUserId());
                    beforeClone.SBQQ__Account__c = quote.SBQQ__Account__c;
                    beforeClone.SBQQ__Opportunity2__c = quote.SBQQ__Opportunity2__c;
                    system.debug('clonedQuoteId Non ACR'+beforeClone);
                    Id clonedQuoteId = cloner.save();
                    
                    quoteId =  clonedQuoteId;
                }else{
                    
                    insert quote;
                    quoteId =  quote.Id;
                    
                }
                
            }
            if(quote.Business_Type__c == 'Exhibition' ){
               
                system.debug('business type'+quote.Business_Type__c);
                Base_Quote_Settings__c baseQuote=new Base_Quote_Settings__c();
             Map<String,Base_Quote_Settings__c> baseQuoteSettingsMap = Base_Quote_Settings__c.getAll();
                
			    system.debug('baseQuoteSettingsMap:(quote.Exhibition__r.Name'+baseQuoteSettingsMap);
                system.debug('quote.Exhibition__r.Name '+quote.Exhibition__c);
                
                 if(baseQuoteSettingsMap.containsKey(quote.Exhibition__c )){
                     baseQuote = baseQuoteSettingsMap.get(quote.Exhibition__c);
                     system.debug(baseQuote);
                 
                system.debug('base quote id is::::'+baseQuote.Base_QuoteId__c); 
                system.debug('base quote'+baseQuote);
                if(baseQuote != null && baseQuote.Base_QuoteId__c != null){
                    Id QuoteToClone = baseQuote.Base_QuoteId__c;
                    QuoteCloneWithLine cloner = new QuoteCloneWithLine( QuoteToClone, 'SBQQ__LineItems__r');
                    SBQQ__QUOTE__C beforeClone = (SBQQ__QUOTE__C ) cloner.clone;
                    beforeClone.SBQQ__Primary__c = quote.SBQQ__Primary__c;
                    beforeClone.SBQQ__Status__c = 'draft';
                    beforeClone.RecordTypeId =  Schema.SObjectType.SBQQ__QUOTE__C.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
                    beforeClone.SBQQ__Ordered__c = false;
                    beforeClone.SBQQ__EndDate__c = null;
                    beforeClone.Base_Quote__c = false;
                    beforeClone.Contract_Start_Date__c = null;
                    beforeClone.BVC_Branch__c = quote.BVC_Branch__c;
                    beforeClone.BVC_Billing_Entity__c = null;
                    beforeClone.BVC_Entity__c = null;
                    beforeClone.SBQQ__StartDate__c  = quote.SBQQ__StartDate__c;
                    beforeClone.OwnerId = Id.valueOf(Userinfo.getUserId());
                    beforeClone.SBQQ__SalesRep__c = Id.valueOf(Userinfo.getUserId());
                    beforeClone.SBQQ__Account__c = quote.SBQQ__Account__c;
                    beforeClone.SBQQ__Opportunity2__c = quote.SBQQ__Opportunity2__c;
                    system.debug('clonedQuoteId Exhibition'+beforeClone);
                    Id clonedQuoteId = cloner.save();
                    
                    quoteId =  clonedQuoteId;
                }
                 }else{
                    insert quote;
                    quoteId =  quote.Id;
                }
             }
           return quoteId;
            
        } catch (Exception e) {
            system.debug('Exception : '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }   
    }
}