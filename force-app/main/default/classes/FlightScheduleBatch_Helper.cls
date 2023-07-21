public class FlightScheduleBatch_Helper {
    
    public static string generateToken(){
   // get Airline_API__mdt custom metadata where developer name is 'Indigo_Token_Generation'
        List<Airline_API__mdt> indigoAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Token_Generation'];
        String Endpoint = '';
        //String endpoint = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GenerateToken';
   // create variables to store the values of metadata.
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
        String token = '';
  // assign metadata values in variables.
        for(Airline_API__mdt indigoData : indigoAirline){
            Endpoint = indigoData.Endpoint__c;
            ClientUID = indigoData.ClientUID__c;
            Client_Key = indigoData.Client_Key__c;
            AppID = indigoData.AppID__c;
            Device_ID = indigoData.Device_ID__c;
        }
  //send Http request to the endpoint get from metadata for token number generation.   
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        system.debug('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug('response body 35 '+response.getBody());
    // deserialize the response         
            IndigoWrapperClass responseWrapper = IndigoWrapperClass.parse(response.getBody());
            system.debug(responseWrapper);
            String d = '';
			            
            if(String.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d; 
            }
           /* if(Test.isRunningTest()){
               d =  'RESULT_START:{"Table":[{"TokenNumber":"6BAEAB24-2000-4465-9E9B-C243D8BAFF08"}]}:RESULT_END';
            }*/
            //String d = RESULT_START:{"Table":[{"TokenNumber":"6BAEAB24-2000-4465-9E9B-C243D8BAFF08"}]}:RESULT_END;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            IndigoWrapperTokenClass responseWrap = new IndigoWrapperTokenClass();
  // deserialize the data stored in result variable and get token number          
            if(String.isNotBlank(result)){
                responseWrap = IndigoWrapperTokenClass.parse(result);
            } 
            system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
                    token =  responseWrap.Table[0].TokenNumber ;
                }
                
            }else{
                token ='';
            }
          
        }
        return token;
    }
    
    public static string generateSessionId(){
     //get Airline_API__mdt metadata where developer name is 'Indigo_Get_Session_ID'
        List<Airline_API__mdt> indigoAirline = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Get_Session_ID'];
     // variable to store metadata values 
        String Endpoint = '';
        //String endpoint = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GetUserDetails';
        String Username = '';
        String Password = '';
        String Station = '';
        String AppID = '';
        String session = '';
        String token = FlightScheduleBatch_Helper.generateToken();
        for(Airline_API__mdt indigoData : indigoAirline){
            Endpoint = indigoData.Endpoint__c;
            Username = indigoData.Username__c;
            Password = indigoData.Password__c;
            Station = indigoData.Station__c;
            AppID = indigoData.AppID__c;
        }
   // send http post request      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        //request.setHeader('Authorization', 'Bearer '+ token);
        system.debug('{"Username":"'+Username+'", "Password":"'+Password+'", "Station":"'+Station+'", "AppID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
    // deserialize the response         
            IndigoWrapperSessionIdClass responseWrapper = IndigoWrapperSessionIdClass.parse(response.getBody());
            system.debug(responseWrapper);
            
            String d = responseWrapper.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            
            IndigoWrapperSessionIdClass1 responseWrap = IndigoWrapperSessionIdClass1.parse(result);
            system.debug(responseWrap);
            session = responseWrap.Table[0].SessionID;
            system.debug('session ' + session);
        }
        return session;
    }
    
    public static List<Flight_Schedule__c> getFlightDetails(String originFlightCode,String IndigoAirlineID,String indigoLoginName,String indigoAirlineCode,String indigoEndpoint){
        
        List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();
       
        String session = FlightScheduleBatch_Helper.generateSessionId();
        String token = FlightScheduleBatch_Helper.generateToken();
        Date todayDate = system.today()+1;
        String origin = originFlightCode;
        
        Id airportId = Schema.SObjectType.Transport__c.getRecordTypeInfosByDeveloperName().get('Airport').getRecordTypeId();
        Set<String> originSet = new Set<String>();
        Set<String> destinSet = new Set<String>();
        //Map<String,Id> transPObjMap = new Map<String,Id>();
        Map<String,String> shippingAccCodeMap = new Map<String,String>();
        Map<String,String> shippingAgentMap = new Map<String,String>();
        Map<String,String> shippingCityMap = new Map<String,String>();
       
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(indigoEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        
        system.debug('{"loginName":"'+indigoLoginName+'", "airlineCode":"'+indigoAirlineCode+'", "sessionId":"'+session+'", "origin":"'+origin+'", "dest":"", "fltDate":"'+todayDate+'", "currentStation":"", "flightNo":"", "TokenNumber":"'+token+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"loginName":"'+indigoLoginName+'", "airlineCode":"'+indigoAirlineCode+'", "sessionId":"'+session+'", "origin":"'+origin+'", "dest":"", "fltDate":"'+todayDate+'","currentStation":"", "flightNo":"", "TokenNumber":"'+token+'"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
            
            IndigoWrapperGetFlgtDetailsClass responseWrap = IndigoWrapperGetFlgtDetailsClass.parse(response.getBody());
            system.debug(responseWrap);
            
           
            String d = responseWrap.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            string error = 'Schedule Not Available for selected criteria.';
            Boolean checkError =  result.contains(error);
            system.debug('checkError'+checkError);
            if(checkError == false){
                
            //if(getFlightResp.Table.FltNumber != null){
            IndigoWrapGetFlgtDetailsClass1 getFlightResp = IndigoWrapGetFlgtDetailsClass1.parse(result);
            system.debug(getFlightResp);
            
             for(IndigoWrapGetFlgtDetailsClass1.Table route : getFlightResp.Table){
                       originSet.add(route.FltOrigin);
                       destinSet.add(route.FltDestination);
                 }
     // get Shipper_Consignee_Indigo_AWB__mdt custom metadata            
            for(Shipper_Consignee_Indigo_AWB__mdt shipCon : [SELECT ACCOUNT_CODE__c,ACCOUNT_NAME__c,AGENT_CODE__c,Airport_Code__c,CITY__c,COUNTRY__c,PARTICIPATION_TYPE__c 
                                                             FROM Shipper_Consignee_Indigo_AWB__mdt
                                                            WHERE (Airport_Code__c IN : originSet OR Airport_Code__c IN: destinSet)
                                                            ]){
                                                                
                                                                if(shipCon.Airport_Code__c != null && shipCon.Airport_Code__c != ''){
                                    shippingAccCodeMap.put(shipCon.Airport_Code__c,shipCon.ACCOUNT_CODE__c); 
                                    shippingAgentMap.put(shipCon.Airport_Code__c,shipCon.AGENT_CODE__c);                           
                                    shippingCityMap.put(shipCon.Airport_Code__c,shipCon.CITY__c);      
                                                                }
            }
             /* for(Transport__c airport :[Select Id,Name,Airport_Code__c from Transport__c where RecordTypeId =: airportId AND (Airport_Code__c IN:originSet OR Airport_Code__c IN:destinSet)]){
	                             transPObjMap.put(airport.Airport_Code__c,airport.Id);
                   }
            */
            if(getFlightResp.table.size() > 0){
      // Create flight schedule record from response           
                for(IndigoWrapGetFlgtDetailsClass1.table flight : getFlightResp.table){
                    Flight_Schedule__c flightSchedule = new Flight_Schedule__c();
                    flightSchedule.Flight_ID__c = flight.ScheduleID;
                    flightSchedule.Name = 'Indigo '+ flight.FltNumber +'-'+ flight.FltOrigin +'-'+flight.FltDestination+'-'+flight.DepDateTime;
                    system.debug('Name of flight '+flightSchedule.Name);
                    system.debug('ID of flight '+flightSchedule.Id);
                    system.debug('Name of flight Number '+flight.FltNumber);
                    flightSchedule.Flight_Number__c = flight.FltNumber;
                    flightSchedule.LegSequence__c = flight.LegSequence;
                    flightSchedule.Actual_Flight_Departure__c = flight.DepDateTime;
                    flightSchedule.Actual_Flight_Arrival__c = flight.ArrDateTime;
                    flightSchedule.Operational_Status__c = flight.STATUS;
                    flightSchedule.Scheduled_Arrival_Time__c = flight.ArrTime;
					flightSchedule.Scheduled_Departure_Time__c = flight.DeptTime;
                    if(flight.FltDate != null){
                        flightSchedule.Departure_Date__c = Date.valueOf(string.valueof(flight.FltDate));
                    }
                    
                    /*List<Transport__c> originAirport = [select id,name,Airport_Code__c,RecordTypeId from Transport__c where RecordTypeId =: airportId  and Airport_Code__c =: flight.FltOrigin LIMIT 1];
                    List<Transport__c> destinationAirport = [select id,name,Airport_Code__c,RecordTypeId from Transport__c where RecordTypeId =: airportId  and Airport_Code__c =: flight.FltDestination LIMIT 1];
                        if(transPObjMap.size()>0 && transPObjMap.containsKey(flight.FltOrigin)){
                            flightSchedule.Origin_Airport__c = transPObjMap.get(flight.FltOrigin);
                        }
                        if(transPObjMap.size()>0 && transPObjMap.containsKey(flight.FltDestination)){
                            flightSchedule.Destination_Airport__c = transPObjMap.get(flight.FltDestination);
                        }
                   */
                    flightSchedule.Origin__c = flight.FltOrigin;
                    flightSchedule.Destination__c = flight.FltDestination;
                    flightSchedule.AirLine1__c = IndigoAirlineID;  
                    if((!shippingAccCodeMap.isEmpty() && shippingAccCodeMap.containsKey(flight.FltOrigin)) && (!shippingAgentMap.isEmpty() && shippingAgentMap.containsKey(flight.FltOrigin)) && (!shippingCityMap.isEmpty() && shippingCityMap.containsKey(flight.FltOrigin))){
                        flightSchedule.Shipping_Account_Code__c = shippingAccCodeMap.get(flight.FltOrigin);
                        flightSchedule.Shipping_Agent_Code__c = shippingAgentMap.get(flight.FltOrigin);
                        flightSchedule.Shipping_City__c = shippingCityMap.get(flight.FltOrigin);
                    }
                    if((!shippingAccCodeMap.isEmpty() && shippingAccCodeMap.containsKey(flight.FltDestination)) && (!shippingCityMap.isEmpty() && shippingCityMap.containsKey(flight.FltDestination))){
                        flightSchedule.Consignee_Account_Code__c = shippingAccCodeMap.get(flight.FltDestination);
                        flightSchedule.Consignee_City__c = shippingCityMap.get(flight.FltDestination);
                    }
                    FlightScheduleList.add(flightSchedule);
                    system.debug('FlightSchedule ==== '+flightSchedule);
                    
                    //Database.insert(FlightScheduleList); 
                    system.debug('FlightScheduleList ==== '+FlightScheduleList.size());
                }
            }
            }
        }
        return FlightScheduleList;
    }
}