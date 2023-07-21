public class QuoteTriggerHandler {
    public static void  UpdateQuoteLineExhibitionLookup(List<SBQQ__Quote__c> newQuotes,Map<Id,SBQQ__Quote__c> oldQuotes){
        Set<Id> quoteIds = new Set<Id>();
        for(SBQQ__Quote__c q : newQuotes ){
            if(q.Business_Type__c == 'Exhibition' 
               && (q.SBQQ__LineItemCount__c > 0 && q.SBQQ__LineItemCount__c <> oldQuotes.get(q.Id).SBQQ__LineItemCount__c 
                   || q.Exhibition__c != null && q.Exhibition__c <> oldQuotes.get(q.Id).Exhibition__c)){
                       quoteIds.add(q.Id);
                   }
        }
        if(quoteIds != null  && quoteIds.size() > 0){
            List<SBQQ__QuoteLine__c> updateLines = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c li : [SELECT Id,ST_Exhibition__c,
                                         SBQQ__Quote__c,
                                         SBQQ__Quote__r.Exhibition__c 
                                         FROM SBQQ__QuoteLine__c
                                         WHERE SBQQ__Quote__c IN :quoteIds]){
                                             if(li.ST_Exhibition__c != li.SBQQ__Quote__r.Exhibition__c){
                                                 li.ST_Exhibition__c = li.SBQQ__Quote__r.Exhibition__c;
                                                 updateLines.add(li);
                                             }
                                             
                                         }
            if(updateLines != null && updateLines.size() > 0){
                Database.SaveResult[] results = Database.update(updateLines, false);
                for(Database.SaveResult lsr : results){
                    if(lsr.isSuccess()){
                        system.debug('Quote Line with ' +lsr.getId()+' is Successfully Inserted.');
                    }
                    else{
                        for(Database.Error err : lsr.getErrors()){
                            system.debug('The following errors Occured on Saving : '+lsr.getId());
                            system.debug('Error Message is :'+ err.getMessage());
                            system.debug('Error causing Fields are :'+err.getFields());
                        }
                    }
                }
            }
            
        }
    }
    public static void submitForApproval(Map<Id,SBQQ__Quote__c> newQuotes,Map<Id,SBQQ__Quote__c> oldMap){
        Set<Id> ids = new Set<Id>();
        List<Approval.ProcessSubmitRequest> submitRequest = new List<Approval.ProcessSubmitRequest>();
        for(SBQQ__Quote__c q : newQuotes.values()){
            if(q.Max_Discount_on_QuoteLine__c >10 
               && q.Max_Discount_on_QuoteLine__c <> oldMap.get(q.Id).Max_Discount_on_QuoteLine__c){
                   Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                   request.setProcessDefinitionNameOrId('ST_Quote_Approvals');
                   request.setObjectId(q.Id);
                   request.setComments('Submitted For Approval');
                   submitRequest.add(request);
                   
               }
            else if(q.Max_Discount_on_QuoteLine__c!= null
                    &&q.Max_Discount_on_QuoteLine__c <=10
                    && q.SBQQ__Status__c == 'Draft'){
                        system.debug('Auto Approval:');
                        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                        request.setProcessDefinitionNameOrId('ST_Auto_Approval_Quote');
                        request.setObjectId(q.Id);
                        request.setComments('Submitted For Auto Approval');
                        submitRequest.add(request);
                        
                    }
            
        }
        if(!submitRequest.isEmpty()){
            Approval.ProcessResult[] results = Approval.process(submitRequest, False);
            for(Approval.ProcessResult r : results){
                if(r.isSuccess()){
                    system.debug('Successfully Submitted for Approval:'+r.getEntityId());
                    ids.add(r.getEntityId()); 
                }
            }
        }
        List<SBQQ__Quote__c> unlockQuotes = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q: newQuotes.values()){
            if(ids.contains(q.Id)){
                unlockQuotes.add(q); 
            }
        }
        Approval.UnlockResult[] unlockedList = Approval.unlock(unlockQuotes, false);
        for(Approval.UnlockResult ur : unlockedList){
            if(ur.isSuccess()){
                system.debug('Successfully Unlocked Quote : '+ur.getId());
            }
            else{
                for(Database.Error err : ur.getErrors()){
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Quote fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    public static void lockQuoteAfterQuoteSent(Map<Id,SBQQ__Quote__c> newQuotes,Map<Id,SBQQ__Quote__c> oldQuotes){
        String[] profs = Label.Quote_Edit_Profiles.split(',');
        List<String> editProfiles = new List<String>();
        for(Profile p :[SELECT Id,Name FROM Profile WHERE Name IN :profs]){
            editProfiles.add(p.Id); 
        }
        for(SBQQ__Quote__c q : newQuotes.values()){
            if(!editProfiles.contains(userInfo.getProfileId()) 
               &&(q.SBQQ__Status__c == 'Ordered' 
                  || q.SBQQ__Status__c == 'Contract Sent' 
                  || (q.SBQQ__Status__c == 'Contract Signed' && !q.SBQQ__Ordered__c  ))){
                      q.addError('Quote Cannot Be Edited after the Quote has been Sent to the Customer');
                  }
        }
    }
}