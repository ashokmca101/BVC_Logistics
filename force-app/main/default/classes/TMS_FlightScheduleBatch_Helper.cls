public class TMS_FlightScheduleBatch_Helper{
    
    public static String generateToken(){
        String token = '';
     // get Airline_API__mdt custom metadata record where developer name is Spice_Jet_Token_Generation
        Airline_API__mdt[] spiceJetAirline = [SELECT Endpoint__c,Email__c,Password__c,Source__c,isSwagger__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Token_Generation'];
    // create variables to store metadata field values to send http request.   
        String endpoint = '';
        String Email = '';
        String Password = '';
        Boolean isSwagger = false;
        String Source = '';
  // assign matadata values in the variables.      
        for(Airline_API__mdt spicemtData : spiceJetAirline){
            endpoint = spicemtData.Endpoint__c;
            Email = spicemtData.Email__c;
            Password = spicemtData.Password__c;
            isSwagger = spicemtData.isSwagger__c;
            Source = spicemtData.Source__c;
        }
  // send http post request to the endpoint stored in endpoint variable, and send body.      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"email":"'+Email+'","password":"'+Password+'","source":"'+Source+'","isSwagger":"'+isSwagger+'"}');
   // store api response in 'response ' variable.
        HttpResponse response = http.send(request);
        
        system.debug('Request Body ---- '+request.getBody());
        system.debug('Request Body ---- '+'{"email":"'+Email+'","password":"'+Password+'","source":"'+Source+'","isSwagger":"'+isSwagger+'"}');
        
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.Debug('response.getBody() 35 '+response.getBody());
   // deserialize the api response and store into the responseWrapper variable.
            SpiceJetTokenResponseWrapper responseWrapper = SpiceJetTokenResponseWrapper.parse(response.getBody());
            system.Debug('responseWrapper 36 '+responseWrapper);
            if(responseWrapper.result!= null){
            if(String.isNotBlank(responseWrapper.result.access_token)){
   // store access token value from response in string  token variable.
                token = responseWrapper.result.access_token; 
            }
            }
            system.debug('Token Generated ------ '+token);
            
        }
        return token;
    }
    
    public static List<Flight_Schedule__c> getFlightDetails(String accessToken,String originFlightCode,String endpoint,String spiceJetID){
        system.debug('Token in Flight Schedule Method----'+accessToken);
        system.debug('Origin in Flight Schedule Method----'+originFlightCode);
        
        String origin = originFlightCode;
        Date todayDate = system.today();
        Date tomDate = system.today()+1;
        Id airportId = Schema.SObjectType.Transport__c.getRecordTypeInfosByDeveloperName().get('Airport').getRecordTypeId();
        
        List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();
        Set<String> sourceSet = new Set<String>();
        Set<String> destinSet = new Set<String>();
        Map<String,Id> transPObjMap = new Map<String,Id>();
        
        if(accessToken !=null && origin != null && origin != ''){
   // send http request to the endpoint to schedule the flight.          
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-type', 'application/json');
            request.setHeader('Authorization',accessToken);  
            request.setBody('{"search": {"source": "'+origin+'","destination": "","to": "'+tomDate+'","from": "'+todayDate+'"},"mode": "BGT"}');
            HttpResponse response = http.send(request);
            
            if(response.getBody() != null && response.getStatusCode() == 200){
                system.debug('response----'+response.getBody());
   // deserialize the response and store this in getflightResponse variable 
                SpiceJetGetFlightResponseWrapper getflightResponse = SpiceJetGetFlightResponseWrapper.parse(response.getBody());
                
                for(SpiceJetGetFlightResponseWrapper.Result route : getflightResponse.result){
                       sourceSet.add(route.source);
                       destinSet.add(route.destination);
                 }
 //get Transport__c record where RecordTypeId is Airport                
                for(Transport__c airport :[Select Id,Name,Airport_Code__c from Transport__c where RecordTypeId =: airportId AND (Airport_Code__c IN:sourceSet OR Airport_Code__c IN:destinSet)]){
	                             transPObjMap.put(airport.Airport_Code__c,airport.Id);
                   }
                
                if(getflightResponse.result.size() > 0){
  // create flight schedule record from the response                
                    for(SpiceJetGetFlightResponseWrapper.Result flight : getflightResponse.result){
                        Flight_Schedule__c flightSchedule = new Flight_Schedule__c();
                        flightSchedule.Flight_ID__c = flight.flight_id;
                       // flightSchedule.Name = flight.flight_no;
                        flightSchedule.Flight_Number__c = flight.flight_no;
                        flightSchedule.Name = 'SPICE '+flight.flight_no +'-'+ flight.source +'-'+ flight.destination +'-'+ string.valueof(flight.std);
                        flightSchedule.Departure_Date__c = flight.departure_date;
                        flightSchedule.Registration_Number__c = flight.registration_no;
                        flightSchedule.Aircraft_Type__c = flight.aircraft_type;
                        flightSchedule.Operational_Status__c = flight.operational_status;
                        if(flight.is_active != '1'){
                         flightSchedule.Is_Inactive__c = true;
                        }
                        else{
                            flightSchedule.Is_Inactive__c = false;
                        }
                        flightSchedule.Manufacturer__c = flight.manufacturer;
                        flightSchedule.CMS_Value__c = flight.cms_value;
                        flightSchedule.Departure_Bay_Number__c = flight.dep_bay_no;
                        flightSchedule.Arrival_Bay_Number__c = flight.arr_bay_no;
                        flightSchedule.Estimated_Time_To_Arrival__c = flight.eta != null ? DateTime.valueOf(string.valueof(flight.eta)) : null;
                        flightSchedule.Estimated_Time_To_Departure__c = flight.etd != null ? DateTime.valueOf(string.valueof(flight.etd)) : null;
                        flightSchedule.Schedule_Time_To_Arrival__c = flight.sta != null ? DateTime.valueOf(string.valueof(flight.sta)) : null;
                        flightSchedule.Schedule_Time_To_Departure__c = flight.std != null ? DateTime.valueOf(string.valueof(flight.std)) : null;
                        flightSchedule.Delay_Code__c = flight.delay_code;
                        flightSchedule.Delay_Reason__c = flight.delay_reason;
                        flightSchedule.Departure_Delay__c = flight.dep_delay;
                        flightSchedule.DOM__c = flight.dom;
                        flightSchedule.External_ID__c = flight.id;
                        flightSchedule.Created_In_SpiceJet_System__c = flight.created_at;
                        flightSchedule.Updated_In_SpiceJet_System__c = flight.updated_at;
                        flightSchedule.Origin__c = flight.source;
                        flightSchedule.Destination__c = flight.destination;
                       /* if(transPObjMap.size()>0 && transPObjMap.containsKey(flight.source)){
                            flightSchedule.Origin_Airport__c = transPObjMap.get(flight.source);
                        }
                       
                        if(transPObjMap.size()>0 && transPObjMap.containsKey(flight.destination)){
                            flightSchedule.Destination_Airport__c = transPObjMap.get(flight.destination);
                        }*/
                        
                        flightSchedule.AirLine1__c = spiceJetID;  
                        FlightScheduleList.add(flightSchedule);
                        system.debug('FlightSchedule ==== '+flightSchedule);
                    }
                    
                   // Database.insert(FlightScheduleList); 
                    system.debug('FlightScheduleList ==== '+FlightScheduleList.size());
                }
            }
        }
        return FlightScheduleList;
    }
    
}