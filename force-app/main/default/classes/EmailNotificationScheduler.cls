public class EmailNotificationScheduler implements Schedulable{

    public void execute(SchedulableContext sc) {
        //if(!Test.isRunningTest()){
            EmailNotificationBatch emailBatch = new EmailNotificationBatch(); 
        database.executebatch(emailBatch);
        //}
        
    }

}