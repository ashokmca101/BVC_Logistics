public class ConsolidatedTaxRazorpayScheduler implements schedulable{
    public void execute(System.SchedulableContext ctx){
        ConsolidateTaxCalBatch sched = new ConsolidateTaxCalBatch();
        Database.executeBatch(sched);
    }
}