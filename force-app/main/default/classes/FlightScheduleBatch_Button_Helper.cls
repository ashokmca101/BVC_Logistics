public class FlightScheduleBatch_Button_Helper {

      public static string generateToken(){
    //get  airline custom metadata where developer name is 'Indigo_Token_Generation'
        List<Airline_API__mdt> indigoAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Token_Generation'];
   // create varibles to store metadata values
        String Endpoint = '';
        //String endpoint = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GenerateToken';
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
        String token = '';
    // get metadata and store in this variables
        for(Airline_API__mdt indigoData : indigoAirline){
            Endpoint = indigoData.Endpoint__c;
            ClientUID = indigoData.ClientUID__c;
            Client_Key = indigoData.Client_Key__c;
            AppID = indigoData.AppID__c;
            Device_ID = indigoData.Device_ID__c;
        }
  // send http post request to the endpoint get from airline custom metadata.    
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
   // Deserialize the response body 'response'        
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
    // Deserialize the reponse stored  in 'result'
            IndigoWrapperTokenClass responseWrap = new IndigoWrapperTokenClass();
            
            if(String.isNotBlank(result)){
                responseWrap = IndigoWrapperTokenClass.parse(result);
            } 
            system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
   // get token number from the deserialized reponse
                    token =  responseWrap.Table[0].TokenNumber ;
                }
                
            }else{
                token ='';
            }
          
        }
        return token;
    }
    
    public static string generateSessionId(){
   // get Airline_API__mdt custom metadata where  developer name is 'Indigo_Get_Session_ID'
        List<Airline_API__mdt> indigoAirline = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Get_Session_ID'];
  // create variables to store values of airline custom metadata and stored.
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
   // send http post request to the endpoint     
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
    // Deserialize the response stored in response         
            IndigoWrapperSessionIdClass responseWrapper = IndigoWrapperSessionIdClass.parse(response.getBody());
            system.debug(responseWrapper);
            
            String d = responseWrapper.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
   // Deserialize the response stored in result           
            IndigoWrapperSessionIdClass1 responseWrap = IndigoWrapperSessionIdClass1.parse(result);
            system.debug(responseWrap);
            session = responseWrap.Table[0].SessionID;
            system.debug('session ' + session);
        }
        return session;
    }
    
    public static List<Flight_Schedule__c> getFlightDetails(String originFlightCode,String IndigoAirlineID,String indigoLoginName,String indigoAirlineCode,String indigoEndpoint){
        
        List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();
     //get sessionID and token   
        String session = FlightScheduleBatch_Helper.generateSessionId();
        String token = FlightScheduleBatch_Helper.generateToken();
        Date todayDate = system.today()+1;
        String origin = originFlightCode;
        Set<String> uniqueSet = new Set<String>();
        Map<String,Id> flightMap = new Map<String,Id>();
        Id airportId = Schema.SObjectType.Transport__c.getRecordTypeInfosByDeveloperName().get('Airport').getRecordTypeId();
        //Set<String> originSet = new Set<String>();
        //Set<String> destinSet = new Set<String>();
        //Map<String,Id> transPObjMap = new Map<String,Id>();
        //added
        Set<String> originSet = new Set<String>();
        Set<String> destinSet = new Set<String>();
        //Map<String,Id> transPObjMap = new Map<String,Id>();
        Map<String,String> shippingAccCodeMap = new Map<String,String>();
        Map<String,String> shippingAgentMap = new Map<String,String>();
        Map<String,String> shippingCityMap = new Map<String,String>();
        //ended
   // send http post request to the endpoint     
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(indigoEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        
        system.debug('{"loginName":"'+indigoLoginName+'", "airlineCode":"'+indigoAirlineCode+'", "sessionId":"'+session+'", "origin":"'+origin+'", "dest":"", "fltDate":"'+todayDate+'", "currentStation":"", "flightNo":"", "TokenNumber":"'+token+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"loginName":"'+indigoLoginName+'", "airlineCode":"'+indigoAirlineCode+'", "sessionId":"'+session+'", "origin":"'+origin+'", "dest":"", "fltDate":"'+todayDate+'", "currentStation":"", "flightNo":"", "TokenNumber":"'+token+'"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
       // deserialize the response stored in response varibale    
            IndigoWrapperGetFlgtDetailsClass responseWrap = IndigoWrapperGetFlgtDetailsClass.parse(response.getBody());
            system.debug(responseWrap);
            
           
            String d = responseWrap.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            string error = 'Schedule Not Available for selected criteria.';
            Boolean checkError =  result.contains(error);
            system.debug('checkError'+checkError);
            if(checkError == false){
     // deserialize the response stored in response result  this wrapper class stored flight details 
            IndigoWrapGetFlgtDetailsClass1 getFlightResp = IndigoWrapGetFlgtDetailsClass1.parse(result);
            system.debug(getFlightResp);
          
            
            for(IndigoWrapGetFlgtDetailsClass1.Table route : getFlightResp.Table){
               // system.debug('Date time === '+(route.FltDate.substringbefore('T')));
               // uniqueSet.add('Indigo '+route.flight_no +'-'+ route.source +'-'+ route.destination +'-'+ string.valueof(route.std));
                  uniqueSet.add('Indigo '+ route.FltNumber +'-'+ route.FltOrigin +'-'+route.FltDestination+'-'+route.DepDateTime);
                 //added
                    originSet.add(route.FltOrigin);
                       destinSet.add(route.FltDestination);
                 }
                //get Shipper_Consignee_Indigo_AWB__mdt metadata
            for(Shipper_Consignee_Indigo_AWB__mdt shipCon : [SELECT ACCOUNT_CODE__c,ACCOUNT_NAME__c,AGENT_CODE__c,Airport_Code__c,CITY__c,COUNTRY__c,PARTICIPATION_TYPE__c 
                                                             FROM Shipper_Consignee_Indigo_AWB__mdt
                                                            WHERE (Airport_Code__c IN : originSet OR Airport_Code__c IN: destinSet)
                                                            ]){
                                                                
                                                                if(shipCon.Airport_Code__c != null && shipCon.Airport_Code__c != ''){
                                    shippingAccCodeMap.put(shipCon.Airport_Code__c,shipCon.ACCOUNT_CODE__c); 
                                    shippingAgentMap.put(shipCon.Airport_Code__c,shipCon.AGENT_CODE__c);                           
                                    shippingCityMap.put(shipCon.Airport_Code__c,shipCon.CITY__c);      
                                                                }
                    //ended
              }
            system.debug('uniqueSet ===='+uniqueSet);
            system.debug('uniqueSet ===='+uniqueSet.size());
       //get flight schedule record
            List<Flight_Schedule__c> duplicateflightList = [SELECT Id,Name,Unique_Record_for_Batch__c,Departure_Date__c FROM Flight_Schedule__c WHERE Unique_Record_for_Batch__c IN: uniqueSet];
                system.debug('duplicateflightList ===='+duplicateflightList.size());
                for(Flight_Schedule__c flight : duplicateflightList){
                   
                    if(flight.Name != null && flight.Unique_Record_for_Batch__c != null){
                        flightMap.put(flight.Unique_Record_for_Batch__c,flight.Id);
                       }
                 }
            system.debug('flightMap ===='+flightMap.size());
    // create flight schedule record from data stored in IndigoWrapGetFlgtDetailsClass1 wrapper class.
            if(getFlightResp.table.size() > 0){
                for(IndigoWrapGetFlgtDetailsClass1.Table getflightRecord : getFlightResp.Table){
                    Flight_Schedule__c flightSchedule = new Flight_Schedule__c();
                    //getflightRecord.FltNumber+'-'+getflightRecord.FltDate.substringbefore('T')+'-'+getflightRecord.FltOrigin+'-'+getflightRecord.FltDestination)
                    if(flightMap.containsKey('Indigo '+ getflightRecord.FltNumber +'-'+ getflightRecord.FltOrigin +'-'+getflightRecord.FltDestination+'-'+getflightRecord.DepDateTime)){
                       // system.debug('Formula value in the code=== '+getflightRecord.FltNumber+'-'+getflightRecord.FltDate.substringbefore('T')+'-'+getflightRecord.FltOrigin+'-'+getflightRecord.FltDestination);
                        flightSchedule.id = flightMap.get('Indigo '+ getflightRecord.FltNumber +'-'+ getflightRecord.FltOrigin +'-'+getflightRecord.FltDestination+'-'+getflightRecord.DepDateTime);
                        flightSchedule.Scheduled_Arrival_Time__c = getflightRecord.ArrTime;
                        flightSchedule.Scheduled_Departure_Time__c = getflightRecord.DeptTime;
                    }
                    else{
                        flightSchedule.Flight_ID__c = getflightRecord.ScheduleID;
                    flightSchedule.Name = 'Indigo '+ getflightRecord.FltNumber +'-'+ getflightRecord.FltOrigin +'-'+getflightRecord.FltDestination+'-'+getflightRecord.DepDateTime;
                    flightSchedule.Flight_Number__c = getflightRecord.FltNumber;
                    flightSchedule.LegSequence__c = getflightRecord.LegSequence;
                    flightSchedule.Actual_Flight_Departure__c = getflightRecord.DepDateTime;
                    flightSchedule.Actual_Flight_Arrival__c = getflightRecord.ArrDateTime;
                    flightSchedule.Operational_Status__c = getflightRecord.STATUS;
                    flightSchedule.Scheduled_Arrival_Time__c = getflightRecord.ArrTime;
					flightSchedule.Scheduled_Departure_Time__c = getflightRecord.DeptTime;
                    flightSchedule.Departure_Date__c =  Date.valueOf(string.valueof(getflightRecord.FltDate));
                    flightSchedule.Origin__c = getflightRecord.FltOrigin;
                    flightSchedule.Destination__c = getflightRecord.FltDestination;
                    flightSchedule.AirLine1__c = IndigoAirlineID;  
                    system.debug('flightSchedule Name==== '+flightSchedule.Name);
                    }
                    //added
                    if((!shippingAccCodeMap.isEmpty() && shippingAccCodeMap.containsKey(getflightRecord.FltOrigin)) && (!shippingAgentMap.isEmpty() && shippingAgentMap.containsKey(getflightRecord.FltOrigin)) && (!shippingCityMap.isEmpty() && shippingCityMap.containsKey(getflightRecord.FltOrigin))){
                        flightSchedule.Shipping_Account_Code__c = shippingAccCodeMap.get(getflightRecord.FltOrigin);
                        flightSchedule.Shipping_Agent_Code__c = shippingAgentMap.get(getflightRecord.FltOrigin);
                        flightSchedule.Shipping_City__c = shippingCityMap.get(getflightRecord.FltOrigin);
                    }
                    if((!shippingAccCodeMap.isEmpty() && shippingAccCodeMap.containsKey(getflightRecord.FltDestination)) && (!shippingCityMap.isEmpty() && shippingCityMap.containsKey(getflightRecord.FltDestination))){
                        flightSchedule.Consignee_Account_Code__c = shippingAccCodeMap.get(getflightRecord.FltDestination);
                        flightSchedule.Consignee_City__c = shippingCityMap.get(getflightRecord.FltDestination);
                    }
                    //ended
                 FlightScheduleList.add(flightSchedule);
                }
                system.debug('FlightScheduleList ===='+FlightScheduleList.size());
        }
               
              
    }
        }
        return FlightScheduleList; 
    }
}