public class callFlightScheduleBatch {
	@InvocableMethod
    //this apex class executes TMS_FlightSchedule_Batch apex class by apex action 
    public static void callBatch(){
        database.executeBatch(new TMS_FlightSchedule_Batch(),10);
    }
}