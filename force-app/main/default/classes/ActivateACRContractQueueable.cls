public class ActivateACRContractQueueable implements Queueable{
    
	Map<Id,Id> invoiceOrderMap = new Map<Id,Id>();
    
    public ActivateACRContractQueueable (Map<Id,Id> invOrderMap )
    {
        invoiceOrderMap = invOrderMap;
    }    
        public void execute(QueueableContext qc){
                    List<Contract> contracts2Update = new List<Contract>();
                    for(Contract c : [SELECT Id,SBQQ__Order__c,Status,SBQQ__Order__r.Business_Type__c, StartDate 
                                      FROM Contract 
                                      WHERE SBQQ__Order__c IN :invoiceOrderMap.values()
                                      AND Status != 'Activated' AND StartDate <= today]){
                                          if(c.SBQQ__Order__r.Business_Type__c == 'ACR' ){
                                              c.Status = 'Activated';
                                              contracts2Update.add(c); 
                                          }
                                          
                                      }
                    if(contracts2Update.size()>0){
                        try{
                            update contracts2Update;
                        }catch(exception Ex){
                            system.debug(ex.getStackTraceString()+'contracts were not Activated :::'+Ex.getMessage());
                        }
                    }
        }
       
    }