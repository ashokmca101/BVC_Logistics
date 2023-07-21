/*
 String CRON_EXP = '0 0 * * * ?'; 
SendEmailForLotBatchSchedular sch = new SendEmailForLotBatchSchedular(); 
system.schedule('Hourly Example Batch Schedule job', CRON_EXP, sch);
 */ 
 

global class SendEmailForLotBatchSchedular implements Schedulable{
    global void execute(SchedulableContext ctx) {
        SendEmailForLotBatch obj = new SendEmailForLotBatch();
        Database.executeBatch(obj);
    }
}