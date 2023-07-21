@isTest(SeeAllData=true)
public class IndigoFlightSchedule_Button_Batch_Test {
 @isTest 
    public static void generateToken_TestUnit() { 
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());  
        String response = FlightScheduleBatch_Button_Helper.generateToken();
        String response2 = FlightScheduleBatch_Button_Helper.generateSessionId();
        String originFlightCode = 'HYD';
        String indigoLoginName = 'BVCLBOM';
        String indigoAirlineCode = '6E';
        String indigoEndpoint = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GetFlightListV2';
        AirLine1__c airline= new AirLine1__c();
        airline.Airline_Name__c= 'Indigo';
        
        Test.startTest();
        
        List<Flight_Schedule__c> response3 = FlightScheduleBatch_Button_Helper.getFlightDetails(originFlightCode, airline.Id, indigoLoginName, indigoAirlineCode, indigoEndpoint);
        
        Database.executeBatch(new IndigoFlightSchedule_Button_Batch(),1);
        Test.stopTest();
    }
}