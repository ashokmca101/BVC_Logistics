public class RazorpayQueueable implements Queueable,Database.AllowsCallouts{
     List<Id> razorpayIds = new  List<Id>();
    public RazorpayQueueable (List<Id> invList )
    {
        razorpayIds.addall(invList );
       
    }
    public void execute(QueueableContext ctx){
       
    
        if(razorpayIds.size() >0){
            system.debug('invoiceids'+razorpayIds);
              CPQ_ConnectController.authurl(razorpayIds);
        }
      
    }
}