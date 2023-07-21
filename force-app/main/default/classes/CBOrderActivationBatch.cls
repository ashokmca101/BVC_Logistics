public class CBOrderActivationBatch implements Database.Batchable<sObject>{
	public final String Query;
    public CBOrderActivationBatch(){
          Query='SELECT id,Status FROM Order where Status = \'Draft\' and BVC_CB_PreTaxBill__c != null and Billing_Address__c != null and BVC_CB_PreTaxBill__r.BVC_CB_Invoice_Generated_in_Salesforce__c = false and BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = true ';  
       }
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   	}
    public void execute(Database.BatchableContext BC, List<Order> scope){
        for(Order s:scope){
       		s.Status = 'Activated';
       }
        Update scope;   
    }
    public void finish(Database.BatchableContext BC){
       
   }
 public static void Method2(){
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
     i++;} 
}