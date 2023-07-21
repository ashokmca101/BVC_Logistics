public class callFlightScheduleBatch2 {
	@InvocableMethod
    //this apex class executes TMS_FlightSchedule_ButtonBatch apex class by apex action 
    public static void callBatch(){
        database.executeBatch(new TMS_FlightSchedule_ButtonBatch(),20);
    }
}