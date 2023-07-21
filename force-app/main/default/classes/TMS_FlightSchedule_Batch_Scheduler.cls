global class TMS_FlightSchedule_Batch_Scheduler implements Schedulable{
global void execute(SchedulableContext sc) { 
  // this scheduler class schedules TMS_FlightSchedule_Batch batch class and batch size is 10.  
        TMS_FlightSchedule_Batch flightSchedule = new TMS_FlightSchedule_Batch();
        database.executebatch(flightSchedule,10);
    }
}