public class ClearInvalidIntegrationLogsScheduler implements schedulable{
       
    public void execute(System.SchedulableContext ctx){
        ClearInvalidIntegrationLogBatch clearLogBatch = new ClearInvalidIntegrationLogBatch();
        Database.executeBatch(clearLogBatch,100);
    }
}