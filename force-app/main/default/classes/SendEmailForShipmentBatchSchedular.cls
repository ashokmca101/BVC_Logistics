global class SendEmailForShipmentBatchSchedular implements Schedulable{
    global void execute(SchedulableContext ctx) {
        SendEmailForShipmentBatch obj = new SendEmailForShipmentBatch();
        Database.executeBatch(obj);
    }
}