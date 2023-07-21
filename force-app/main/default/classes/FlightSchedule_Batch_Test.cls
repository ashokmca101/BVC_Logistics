@isTest(SeeAllData=true)
public class FlightSchedule_Batch_Test {
   
    @isTest 
    public static void generateToken_TestUnit() { 
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());  
        //String response = FlightScheduleBatch_Helper.generateToken();
        //String response2 = FlightScheduleBatch_Helper.generateSessionId();
        String originFlightCode = 'BOM';
        String indigoLoginName = 'BVCLBOM';
        String indigoAirlineCode = '6E';
        String indigoEndpoint = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GetFlightListV2';
        AirLine1__c airline= new AirLine1__c();
        airline.Airline_Name__c= 'Indigo';
        
        Test.startTest();
        
        List<Flight_Schedule__c> response3 = FlightScheduleBatch_Helper.getFlightDetails(originFlightCode, airline.Id, indigoLoginName, indigoAirlineCode, indigoEndpoint);
        
        Database.executeBatch(new FlightSchedule_Batch(),10);
        Test.stopTest();
    }
}