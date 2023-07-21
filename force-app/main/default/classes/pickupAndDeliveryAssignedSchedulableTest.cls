@isTest(seeAllData = false)
public class pickupAndDeliveryAssignedSchedulableTest 
{
    
 public static testmethod void testScheduleMethod()
    {
        Test.startTest();
 		pickupAndDeliveryAssignedSchedulable schedule = new pickupAndDeliveryAssignedSchedulable();
        string sch = '0 0 20 * * ?';
        System.schedule('Test Class Schedule',sch,schedule);
        Test.stopTest();
    }
}