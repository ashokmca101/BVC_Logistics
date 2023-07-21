public class Indigo_TrackAWB_Helper {
    public static string generateToken(){
  // create variables to store metadata field values 
        String token = '';
        String Endpoint = '';
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
   // get Airline_API__mdt  custom metadata  whose DeveloperName is 'Indigo_Token_Generation'     
        List<Airline_API__mdt> indigoAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Token_Generation' LIMIT 1];
        
   // assign metadata values in variables     
        if(!indigoAirline.isEmpty()){
            Endpoint = indigoAirline[0].Endpoint__c;
            ClientUID = indigoAirline[0].ClientUID__c;
            Client_Key = indigoAirline[0].Client_Key__c;
            AppID = indigoAirline[0].AppID__c;
            Device_ID = indigoAirline[0].Device_ID__c;
        } 
   // send http post reuqest to the endpoint fetched  by metadata nd stored in endpoint variable, and send body in the request.   
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
   // get response of the request and store in response variable    
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
   //deserialize response         
            IndigoWrapperClass responseWrapper = IndigoWrapperClass.parse(response.getBody());
            system.debug(responseWrapper);
            String d = '';
            
            if(String.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d; 
            }
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
    // deserialize response stored in result variable
            IndigoWrapperTokenClass responseWrap = new IndigoWrapperTokenClass();
            
            if(String.isNotBlank(result)){
                responseWrap = IndigoWrapperTokenClass.parse(result);
            } 
            system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
      // assign token number value in token variable mentioned above, take TokenNumber  from IndigoWrapperTokenClass class.
                    token =  responseWrap.Table[0].TokenNumber ;
                }
                
            }else{
                token ='';
            }
            
        }
        return token;
    }
    public static List<Linehaul_Tracking__c> trackAWB(List<Linehaul__c> awblist, string token,Map<String,String> awbStatusMap){
        List<Linehaul_Tracking__c> insertLinehaulTrack	= new List<Linehaul_Tracking__c>();
        String status = '';
        
        String sessionID = '';
        List<Linehaul__c> updateIndigoLinehaulList = new List<Linehaul__c>();
        
    // check token is not null or empty in linehaul tracking record    
        if(token != null && token != ''){
    // create variables to store values of custom metadata
            String endpointtrack = '';
            String sessiontID = '';
            String loginNamet = '';
            String awbPrefix = '';
    // get Airline_API__mdt metadata whose developer name is Indigo_Track_AWB 
            List<Airline_API__mdt> indigoAirlineTrack = [SELECT  Endpoint__c,Session_Id__c,LoginName__c,AWB_Prefix__c FROM Airline_API__mdt
                                                         WHERE DeveloperName = 'Indigo_Track_AWB' LIMIT 1];
            if(indigoAirlineTrack[0].Endpoint__c != null && indigoAirlineTrack[0].Endpoint__c != ''){
     // assigned metadata values in variables 
                endpointtrack = indigoAirlineTrack[0].Endpoint__c;
                sessiontID = indigoAirlineTrack[0].Session_Id__c;
                loginNamet = indigoAirlineTrack[0].LoginName__c;
                awbPrefix  = indigoAirlineTrack[0].AWB_Prefix__c;
            }
    // Loop over linehaul record and store it awb number field in AwbNumber string variable
            for(Linehaul__c awbRecord : awbList){
                
                String awbNumber = awbRecord.AWB_Number__c;
    // send http POST request to the endpoint taken from metadata and stored in endpointtrack variable and send body in the request 
                Http httpt = new Http();
                HttpRequest requestTrack = new HttpRequest();
                requestTrack.setEndpoint(endpointtrack);
                requestTrack.setMethod('POST');
                requestTrack.setHeader('Content-type', 'application/json');
                requestTrack.setBody('{"loginName":"'+loginNamet+'","sessionId":"'+sessiontID+'", "awbPrefix":"'+awbPrefix+'","awbNumber":"'+awbNumber+'","station":"","TokenNumber":"'+token+'"}');
                system.debug('{"loginName":"'+loginNamet+'","sessionId":"'+sessiontID+'", "awbPrefix":"'+awbPrefix+'","awbNumber":"'+awbNumber+'","station":"","TokenNumber":"'+token+'"}');
                Http http = new Http();
    // get response of the reqeust and store in the responseTrack variable  
                HttpResponse responseTrack = http.send(requestTrack);
                if(responseTrack.getStatusCode() != 200) {
                    status = responseTrack.getStatus();
                    System.debug('The status code returned was not expected: ' + responseTrack.getStatusCode() + ' ' + responseTrack.getStatus());
                } else {
    // deserialize response body by using Indigo_TrackAWB_wrapper_class1 stored in responseTrack variable
                    Indigo_TrackAWB_wrapper_class1 responseWrapper = Indigo_TrackAWB_wrapper_class1.parse(responseTrack.getBody());
                    
                    system.debug(responseWrapper);
                    String d = '';
                    
                    if(String.isNotBlank(responseWrapper.d)){
                        d = responseWrapper.d; 
                    }
                    String result = d.subStringBetween('RESULT_START:',':RESULT_END');
                    system.debug(result);
       // deserialize response body by using Indigo_TrackAWB_wrapper_class2 store in result variable               
                    Indigo_TrackAWB_wrapper_class2 responseWrap1 =  Indigo_TrackAWB_wrapper_class2.parse(result);
                    if(responseWrap1.Table4.isEmpty()){
                        for(Indigo_TrackAWB_wrapper_class2.Table7 getAWBstatus : responseWrap1.Table7){
       // create linehaul tracking record from linehaul record 
                            Linehaul_Tracking__c lineTrackrecord = new Linehaul_Tracking__c();
                            lineTrackrecord.Linehaul_Name__c = awbRecord.Id;
                            lineTrackrecord.AWB_Number__c = awbRecord.AWB_Number__c;
                            if(awbStatusMap.size() > 0 && awbStatusMap.containsKey(getAWBstatus.LastActivity)){
                                lineTrackrecord.Status__c = awbStatusMap.get(getAWBstatus.LastActivity);
                            }
                            lineTrackrecord.Last_Activity__c = getAWBstatus.LastActivity;
                            lineTrackrecord.Description__c = getAWBstatus.Description;
                            insertLinehaulTrack.add(lineTrackrecord);
                        } 
                    }
                }
            }
        }
        return insertLinehaulTrack;
    }
    
}