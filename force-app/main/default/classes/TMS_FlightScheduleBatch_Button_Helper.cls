public class TMS_FlightScheduleBatch_Button_Helper {

     public static String generateToken(){
        String token = '';
  //get Airline_API__mdt metadata record where developer name is Spice_Jet_Token_Generation.
        Airline_API__mdt[] spiceJetAirline = [SELECT Endpoint__c,Email__c,Password__c,Source__c,isSwagger__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Token_Generation'];
  //assign metadata values in this variables and used this endpoint variable to send request.
        String endpoint = '';
        String Email = '';
        String Password = '';
        Boolean isSwagger = false;
        String Source = '';
        
        for(Airline_API__mdt spicemtData : spiceJetAirline){
            endpoint = spicemtData.Endpoint__c;
            Email = spicemtData.Email__c;
            Password = spicemtData.Password__c;
            isSwagger = spicemtData.isSwagger__c;
            Source = spicemtData.Source__c;
        }
  // send http request to the endpoint and send body to token generation      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"email":"'+Email+'","password":"'+Password+'","source":"'+Source+'","isSwagger":"'+isSwagger+'"}');
   // get response; response contains access token and other info.
        HttpResponse response = http.send(request);
        
        system.debug('Request Body ---- '+request.getBody());
        system.debug('Request Body ---- '+'{"email":"'+Email+'","password":"'+Password+'","source":"'+Source+'","isSwagger":"'+isSwagger+'"}');
        
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.Debug('response.getBody() 35 '+response.getBody());
   // deserialize the response and store in responseWrapper variable
            SpiceJetTokenResponseWrapper responseWrapper = SpiceJetTokenResponseWrapper.parse(response.getBody());
            system.Debug('responseWrapper 36 '+responseWrapper);
            if(responseWrapper.result!= null){
            if(String.isNotBlank(responseWrapper.result.access_token)){
     // assign access token value in token variable 
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
        Date todayDate = system.today()+1;
        
        Id airportId = Schema.SObjectType.Transport__c.getRecordTypeInfosByDeveloperName().get('Airport').getRecordTypeId();
        Set<String> uniqueSet = new Set<String>();
        Map<String,Id> flightMap = new Map<String,Id>();
        List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();
        //Set<String> sourceSet = new Set<String>();
        //Set<String> destinSet = new Set<String>();
        //Map<String,Id> transPObjMap = new Map<String,Id>();
        
        if(accessToken !=null && origin != null && origin != ''){
  // send request to the endpoint for flight schedule      
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-type', 'application/json');
            request.setHeader('Authorization',accessToken);  
            request.setBody('{"search": {"source": "'+origin+'","destination": "","to": "'+todayDate+'","from": "'+todayDate+'"},"mode": "BGT"}');
    //get response        
            HttpResponse response = http.send(request);
            
            if(response.getBody() != null && response.getStatusCode() == 200){
                system.debug('response----'+response.getBody());
   // deserialize the response              
                SpiceJetGetFlightResponseWrapper getflightResponse = SpiceJetGetFlightResponseWrapper.parse(response.getBody());
                
                for(SpiceJetGetFlightResponseWrapper.Result flightRecord : getflightResponse.result){
                    //uniqueSet.add('SPICE '+ flightRecord.flight_no+'-'+flightRecord.source+'-'+flightRecord.destination  +String.valueof(flightRecord.departure_date)+);
                uniqueSet.add('SPICE '+flightRecord.flight_no +'-'+ flightRecord.source +'-'+ flightRecord.destination +'-'+ string.valueof(flightRecord.std));
                }
                //
                
                List<Flight_Schedule__c> duplicateflightList = [SELECT Id,Name,Unique_Record_for_Batch__c,Departure_Date__c FROM Flight_Schedule__c WHERE Unique_Record_for_Batch__c IN: uniqueSet];
                
                for(Flight_Schedule__c flight : duplicateflightList){
                   
                    if(flight.Name != null && flight.Unique_Record_for_Batch__c != null){
                        system.debug('Unique Set ==== '+flight.Unique_Record_for_Batch__c);
                        flightMap.put(flight.Unique_Record_for_Batch__c,flight.Id);
                       }
                 }
                if(getflightResponse.result.size() > 0){
   // create flight schedule record from the deserialized response 
                for(SpiceJetGetFlightResponseWrapper.Result getflightRecord : getflightResponse.result){
                    Flight_Schedule__c flightSchedule = new Flight_Schedule__c();
                    //'SPICE '+flightRecord.flight_no +'-'+ flightRecord.source +'-'+ flightRecord.destination +'-'+ string.valueof(flightRecord.std)
                    //getflightRecord.flight_no+'-'+String.valueof(getflightRecord.departure_date)+'-'+getflightRecord.source+'-'+getflightRecord.destination)
                    if(flightMap.containsKey('SPICE '+getflightRecord.flight_no +'-'+ getflightRecord.source +'-'+ getflightRecord.destination +'-'+ string.valueof(getflightRecord.std))){
                       system.debug('Matching Formula in code ===== '+getflightRecord.flight_no+'-'+String.valueof(getflightRecord.departure_date)+'-'+getflightRecord.source+'-'+getflightRecord.destination);
                        flightSchedule.id = flightMap.get('SPICE '+getflightRecord.flight_no +'-'+ getflightRecord.source +'-'+ getflightRecord.destination +'-'+ string.valueof(getflightRecord.std));
                       flightSchedule.Schedule_Time_To_Arrival__c = DateTime.valueOf(string.valueof(getflightRecord.sta));
                       flightSchedule.Schedule_Time_To_Departure__c = DateTime.valueOf(string.valueof(getflightRecord.sta));
                        system.debug('Existing flight=== '+flightSchedule.Name);
                    }
                    else{
                        flightSchedule.Flight_ID__c = getflightRecord.flight_id;
                        flightSchedule.Name = 'SPICE '+getflightRecord.flight_no +'-'+ getflightRecord.source +'-'+ getflightRecord.destination +'-'+ string.valueof(getflightRecord.std);
                        flightSchedule.Flight_Number__c = getflightRecord.flight_no;
                        flightSchedule.Departure_Date__c = getflightRecord.departure_date;
                        flightSchedule.Registration_Number__c = getflightRecord.registration_no;
                        flightSchedule.Aircraft_Type__c = getflightRecord.aircraft_type;
                        flightSchedule.Operational_Status__c = getflightRecord.operational_status;
                        if(getflightRecord.is_active != '1'){
                         flightSchedule.Is_Inactive__c = true;
                        }
                        else{
                            flightSchedule.Is_Inactive__c = false;
                        }
                        flightSchedule.Manufacturer__c = getflightRecord.manufacturer;
                        flightSchedule.CMS_Value__c = getflightRecord.cms_value;
                        flightSchedule.Departure_Bay_Number__c = getflightRecord.dep_bay_no;
                        flightSchedule.Arrival_Bay_Number__c = getflightRecord.arr_bay_no;
                         flightSchedule.Estimated_Time_To_Arrival__c = getflightRecord.eta != null ? DateTime.valueOf(string.valueof(getflightRecord.eta)) : null;
                        flightSchedule.Estimated_Time_To_Departure__c = getflightRecord.etd != null ? DateTime.valueOf(string.valueof(getflightRecord.etd)) : null;
                        flightSchedule.Schedule_Time_To_Arrival__c = getflightRecord.sta != null ? DateTime.valueOf(string.valueof(getflightRecord.sta)) : null;
                        flightSchedule.Schedule_Time_To_Departure__c = getflightRecord.std != null ? DateTime.valueOf(string.valueof(getflightRecord.std)) : null;
                       flightSchedule.Delay_Code__c = getflightRecord.delay_code;
                        flightSchedule.Delay_Reason__c = getflightRecord.delay_reason;
                        flightSchedule.Departure_Delay__c = getflightRecord.dep_delay;
                        flightSchedule.DOM__c = getflightRecord.dom;
                        flightSchedule.External_ID__c = getflightRecord.id;
                        flightSchedule.Created_In_SpiceJet_System__c = getflightRecord.created_at;
                        flightSchedule.Updated_In_SpiceJet_System__c = getflightRecord.updated_at;
                        flightSchedule.Origin__c = getflightRecord.source;
                        flightSchedule.Destination__c = getflightRecord.destination;
                         flightSchedule.AirLine1__c = spiceJetID;  
                           system.debug(''+flightSchedule.Name);                        
                    }
                    FlightScheduleList.add(flightSchedule);
                }
                }
                /*for(SpiceJetGetFlightResponseWrapper.Result route : getflightResponse.result){
                       sourceSet.add(route.source);
                       destinSet.add(route.destination);
                 }
                */
                /*for(Transport__c airport :[Select Id,Name,Airport_Code__c from Transport__c where RecordTypeId =: airportId AND (Airport_Code__c IN:sourceSet OR Airport_Code__c IN:destinSet)]){
	                             transPObjMap.put(airport.Airport_Code__c,airport.Id);
                   }
                */
                
                    
                 /*  for(SpiceJetGetFlightResponseWrapper.Result flight : getflightResponse.result){
                        Flight_Schedule__c flightSchedule = new Flight_Schedule__c();
                        flightSchedule.Flight_ID__c = flight.flight_id;
                        flightSchedule.Name = flight.flight_no;
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
                        flightSchedule.Estimated_Time_To_Arrival__c = DateTime.valueOf(string.valueof(flight.eta));
                        flightSchedule.Estimated_Time_To_Departure__c = DateTime.valueOf(string.valueof(flight.etd));
                        flightSchedule.Schedule_Time_To_Arrival__c = DateTime.valueOf(string.valueof(flight.sta));
                        flightSchedule.Schedule_Time_To_Departure__c = DateTime.valueOf(string.valueof(flight.std));
                        flightSchedule.Delay_Code__c = flight.delay_code;
                        flightSchedule.Delay_Reason__c = flight.delay_reason;
                        flightSchedule.Departure_Delay__c = flight.dep_delay;
                        flightSchedule.DOM__c = flight.dom;
                        flightSchedule.External_ID__c = flight.id;
                        flightSchedule.Created_In_SpiceJet_System__c = flight.created_at;
                        flightSchedule.Updated_In_SpiceJet_System__c = flight.updated_at;
                        flightSchedule.Origin__c = flight.source;
                        flightSchedule.Destination__c = flight.destination;
                       if(transPObjMap.size()>0 && transPObjMap.containsKey(flight.source)){
                            flightSchedule.Origin_Airport__c = transPObjMap.get(flight.source);
                        }
                       
                        if(transPObjMap.size()>0 && transPObjMap.containsKey(flight.destination)){
                            flightSchedule.Destination_Airport__c = transPObjMap.get(flight.destination);
                        }
                        
                        flightSchedule.AirLine1__c = spiceJetID;  
                        FlightScheduleList.add(flightSchedule);
                        system.debug('FlightSchedule ==== '+flightSchedule);
                    } */
                    
                   // Database.insert(FlightScheduleList); 
                    system.debug('FlightScheduleList ==== '+FlightScheduleList.size());
               // }
            }
        }
        return FlightScheduleList;
    }
 
}