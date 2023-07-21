global class CBOrderActivation implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CBOrderActivationBatch(), 50);
    }
}