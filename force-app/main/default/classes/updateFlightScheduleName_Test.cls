@isTest
public class updateFlightScheduleName_Test {
    public static testmethod void test1(){
        Airline__c Airline = new Airline__c(name='Indigo');
        insert Airline;
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Transport__c Airport2 = BVCL_TestDataFactory.CreateAirport('Mumbai Airport',true);
        Flight_Schedule__c fs =BVCL_TestDataFactory.createFlight('del-mum', Airport.id, Airport2.id, false);
        fs.Airline_Name__c = Airline.id;
        fs.Scheduled_Departure_Time__c = system.now().time();
        insert fs;
    }
}