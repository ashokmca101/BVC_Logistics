public class CRM_QueueableCreditRatingAPI Implements Queueable,Database.AllowsCallouts{
    public String accId;
    public String PanNumberOfEntity;
    public CRM_QueueableCreditRatingAPI(String accountId,String PAN){
        accId= accountId;
        PanNumberOfEntity = PAN;
    }
    
   public void execute(QueueableContext qc){

      //Do Callout
       Account_TriggerHandlerServiceCtrl.doCreditRatingAPICallout(accId, PanNumberOfEntity);
       
   }
}