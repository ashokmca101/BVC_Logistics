public class CRM_QueuableFinancialSummaryAPI Implements Queueable,Database.AllowsCallouts {
    @testVisible
    private static Boolean doChainJob = true;
    
    public String accId;
    public String EntityId;
    public String PanOfEntity;
    public CRM_QueuableFinancialSummaryAPI(String accountId,String entity,String PanNumberOfEntity){
        accId= accountId;
        EntityId = entity;
        PanOfEntity = PanNumberOfEntity;
    }
    
     public void execute(QueueableContext qc){
         Account_TriggerHandlerServiceCtrl.doFinancialSummaryAPICallout(accId,EntityId);
         if(doChainJob ) {
         	System.enqueueJob(new CRM_QueueableCreditRatingAPI(accId,PanOfEntity));
         }
     }
}