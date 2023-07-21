public class RazorpayPaymentAllocationScheduler implements schedulable{
    public void execute(System.SchedulableContext ctx){
        RazorpayAllocationBatch rpay = new RazorpayAllocationBatch();
        Database.executeBatch(rpay,10);
    }
}