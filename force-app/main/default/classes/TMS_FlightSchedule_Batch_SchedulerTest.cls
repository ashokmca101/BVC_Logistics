@isTest(SeeAllData=false)
public with sharing class TMS_FlightSchedule_Batch_SchedulerTest {
   @isTest
    public static void testschedule() {
		
		TMS_FlightSchedule_Batch_Scheduler testsched = new TMS_FlightSchedule_Batch_Scheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		
	}
    }