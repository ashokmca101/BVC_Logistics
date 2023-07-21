public class BVC_LeadTriggerHandler {
    
    // Method to convert Lead to Multiple Opportunities based on the Lead Product Records
    // Added By: PWC
    // Added on: 16-Feb-2021
    public void convertLeadToOpps(List<Lead> LeadList){
        set<Id> convLeadIds = new set<Id>();
        set<Id> OppIdSet = new set<Id>();
        Map<Id,Id> oppIdLeadIdMap = new Map<Id,Id>();
        List<Opportunity> OppRecordsToUpsert = new List<Opportunity>();
        for(lead convertedLead : LeadList){
            if(convertedLead.IsConverted == true && convertedLead.Product__c!=Null){
                convLeadIds.add(convertedLead.Id);
                oppIdLeadIdMap.put(convertedLead.ConvertedOpportunityId,convertedLead.Id);
            }
        }
        Map<Id,List<Opportunity>> LeadtoOpptyMap = new Map<Id,List<Opportunity>>();
        Map<Id,List<LeadLineItem__c>> LeadtoProductsMap = new Map<Id,List<LeadLineItem__c>>();
        Map<Id,Product2> ProductMap = new Map<Id,Product2>([Select Id, Name from Product2]);
        
        
        for(Lead ld : [Select Id,isConverted,ConvertedOpportunityId, (select Id, Product__c, Lead__c from Lead_Products__r) from Lead where Id in :convLeadIds]){
            List<LeadLineItem__c> LPList = new List<LeadLineItem__c>();
            LpList = ld.Lead_Products__r;
            LeadtoProductsMap.put(Ld.Id,LpList);
        }
        for(Opportunity opp: [Select Id,bvc_product__c, AccountId, StageName,LeadSource, Name from Opportunity where Id in :oppIdLeadIdMap.keySet()]){
            List<Opportunity> oppList = new List<Opportunity>();
            Boolean firstProd = true;
            string OppName = opp.Name;
            for(LeadLineItem__c LeadProduct : LeadtoProductsMap.get(oppIdLeadIdMap.get(opp.Id))){                
                if(firstProd){
                    firstProd = false;
                    opp.bvc_product__c = leadProduct.Product__c;
                    opp.Name = opp.Name + ' ' + ProductMap.get(leadProduct.Product__c).Name;
                    Opp.CloseDate = system.today().AddDays(14);
                    opp.Lead__c = leadProduct.Lead__c;
                    oppList.add(opp);
                }else{
                    Opportunity newOpp = opp.clone(false,true,false,false);
                    newOpp.bvc_product__c = leadProduct.Product__c;
                    newOpp.Name = OppName + ' ' + ProductMap.get(leadProduct.Product__c).Name;
                    newOpp.Lead__c = leadProduct.Lead__c;
                    newOpp.CloseDate = system.today().AddDays(14);
                    oppList.add(newOpp);
                    system.debug(''+ newOpp.bvc_product__c +' '  +newOpp.Name);
                }                
            }
            
            OppRecordsToUpsert.addAll(oppList);
            LeadtoOpptyMap.put(oppIdLeadIdMap.get(opp.Id),oppList);
        }
        
        
        upsert OppRecordsToUpsert;
    }
    
    // Method to Sync Products Picklist to Product Lead Records
    // Added By: PWC
    // Added on: 16-Feb-2021
    public void ProducttoLPSync(Map<id,Lead> oldLeadList, Map<Id,Lead> newLeadList, Boolean isInsert, Boolean isUpdate){
        Map<string,Product2> productMAp = new Map<string,Product2>();
        for(Product2 prod: [Select Id,Name from Product2 where IsActive = true]){
            productMap.put(prod.Name,prod);
        }
        List<LeadLineItem__c> newLPList = new List<LeadLineItem__c>();
        List<LeadLineItem__c> LPListtoDelete = new List<LeadLineItem__c>();
        if(isInsert){
            
            for(Lead ld: newLeadList.values()){
                Set<String> prodValueSet = new Set<String>();
                if(ld.Product__c!=Null) {
                    prodValueSet.addAll(ld.Product__c.split(';'));     
                }
                if(prodValueSet!=null) {
                    for(string ProdString: prodValueSet){
                        LeadLineItem__c LP = new LeadLineItem__c();
                        LP.Lead__c = ld.Id;
                        LP.Product__c = productMap.get(ProdString).Id;
                        newLPList.add(LP);
                    }  
                }
                
                
            }
            
        }
        
        if(isUpdate){
            Map<Id,List<LeadLineItem__c>> MapLeadIdtoLeadProduct = new Map<Id,List<LeadLineItem__c>>();
            for(Lead ld : [Select Id, (select Id, Product__c,Product__r.Name, Lead__c from Lead_Products__r) from Lead where id in :newLeadList.keySet()]){
                List<LeadLineItem__c> LPList = new List<LeadLineItem__c>();
                LPList = ld.Lead_Products__r;
                MapLeadIdtoLeadProduct.put(ld.Id,LPList);
            }
            for(Lead ld: newLeadList.values()){
                Set<String> newprodValueSet = new Set<String>();
                Set<String> oldprodValueSet = new Set<String>();
                if(ld.Product__c!=null){
                    newprodValueSet.addAll(ld.Product__c.split(';'));
                }else{
                    for(LeadLineItem__c LP: MapLeadIdtoLeadProduct.get(ld.Id)){
                        LPListtoDelete.add(LP);
                    }
                }
                if(oldLeadList.get(ld.Id).Product__c!=null){
                    oldprodValueSet.addAll(oldLeadList.get(ld.Id).Product__c.split(';'));
                }                
                for(string newProd: newprodValueSet){
                    if(!newprodValueSet.equals(oldprodValueSet)){
                        if(!oldprodValueSet.contains(newProd)){
                            LeadLineItem__c newLp = new LeadLineItem__c();
                            newLp.Lead__c = ld.Id;
                            newLp.Product__c = productMap.get(newProd).Id;
                            newLPList.add(newLp);
                        }
                    }
                }
                if(!newprodValueSet.equals(oldprodValueSet) && ld.Product__c!=null){
                    for(LeadLineItem__c LP: MapLeadIdtoLeadProduct.get(ld.Id)){
                        if(!newprodValueSet.contains(LP.Product__r.Name)){
                            LPListtoDelete.add(LP);
                        }
                    }
                }
            }
            
        }
 
        insert newLPList;
        
        delete LPListtoDelete;
    }
    
    
}