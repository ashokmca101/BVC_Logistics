public without sharing class Indigo_CreateAWB {
    @AuraEnabled
    public static Linehaul__c getlinehaul(Id recordIdLinehaul){
        try{
            System.debug('Entered getlinehaul method');
       // fetch single linehaul record
            Linehaul__c objlinehaul = [SELECT Id,Name,Origin_Airport_Code__c,Destination_Airport_Code__c,Commodity_Code__c,Product_Type__c,
                                       Commodity_Description__c,Pcs_Int__c,Gross_Weight__c,Chargeable_Weight__c,Flight_Date__c,
                                       Flight_No_for_SpiceJet_Indigo__r.Name,UOM__c,Dimensions__c,Schedule_ID__c,Shipping_Coordinates__c,
                                       Consignee_Latitude__c,Shipper_EmailID__c,Consignee_EmailID__c,Unit__c,AWB_Number__c,Slac__c,
                                       Dv_Custom__c,Declared_Value__c,Payment_Mode__c,Packaging_Info__c,Volume__c,SHC_Code__c,Multi_Leg_Routes__c,
                                       Shipping_Account_Code_Picklist__c,Shipping_Agent_Code_Picklist__c,
                                       Consignee_Account_Code_Picklist__c,Consignee_Agent_Code_Picklist__c,Account_Name__c,Shipping_City_Picklist__c,
                                       Shipping_State__c,Shipping_Address__c,Shipping_Pincode__c,Shipping_Country_Code__c,Shipper_Contact_Number__c,
                                       Consignee_City_Picklist__c,Consignee_State__c,Consignee_Address__c,Consignee_Pincode__c,Consignee_Contact_Number__c,
                                       Flight_No_for_SpiceJet_Indigo__r.Airline_Name1__c,AirLine_Name__c,Shipper_Address_SpiceJet__c,Shipper_Name_SpiceJet__c,Shipper_City_SpiceJet__c,
                                       Shipper_State_Code_SpiceJet__c,Shipper_Country_Code_SpiceJet__c,Shipper_Pincode_SpiceJet__c,Shipper_Contact_No_SpiceJet__c,
                                       Shipper_Email_SpiceJet__c,Consignee_Address_SpiceJet__c,Consignee_Name_SpiceJet__c,Consignee_City_SpiceJet__c,
                                       Consignee_State_Code_SpiceJet__c,Consignee_Country_Code_SpiceJet__c,Consignee_Pincode_SpiceJet__c,Consignee_Contact_No_SpiceJet__c,Consignee_Email_SpiceJet__c
                                       from Linehaul__c where Id =: recordIdLinehaul limit 1];
            system.debug('Line Haul Record: '+objlinehaul);
            
            return objlinehaul;
        }
        catch(Exception e){
            return null;
        }
    }
    @AuraEnabled
    public static String indigoAWB(Id recordIdLinehaul){
        List<Flight_Schedule__c> getFlight = new List<Flight_Schedule__c>();
    // variables to store metadata field values. 
        String status = '';
        String token = '';
        String Endpoint = '';
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
        String sessionID = '';
        List<Linehaul__c> updateIndigoLinehaulList = new List<Linehaul__c>();
     //Fetch Airline API custom metadata type whose devloper name is 'indigo_token_generation' 
        List<Airline_API__mdt> indigoAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Token_Generation' LIMIT 1];
        
     // checking metadata is not empty and assigning metadata field values in variables created above.
        if(!indigoAirline.isEmpty()){
            Endpoint = indigoAirline[0].Endpoint__c;
            ClientUID = indigoAirline[0].ClientUID__c;
            Client_Key = indigoAirline[0].Client_Key__c;
            AppID = indigoAirline[0].AppID__c;
            Device_ID = indigoAirline[0].Device_ID__c;
        } 
     // sending API request using POST HTTP callout to indigo endpoint. and getting response 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
    //set the body as a JSON object
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        
        HttpResponse response = http.send(request);
        
      // check response status code 
     // parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
      //deserialize response
      //IndigoWrapperClass   apex class is deserializing this response body 
            IndigoWrapperClass responseWrapper = IndigoWrapperClass.parse(response.getBody());
            system.debug(responseWrapper);
            String d = '';
            
            if(String.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d; 
            }
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            IndigoWrapperTokenClass responseWrap = new IndigoWrapperTokenClass();
            
            if(String.isNotBlank(result)){
        //Deserialize substring between RESULT_START and RESULT_END stored in result variable
                responseWrap = IndigoWrapperTokenClass.parse(result);
            } 
            system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
        // insert token number in token variable
                    token =  responseWrap.Table[0].TokenNumber ;
                }
                
            }else{
                token ='';
            }
            
        }
        
        
        if(token != null && token != ''){
            
        // get Airline_API__mdt record whose DeveloperName is 'Indigo_Get_Session_ID' 
            List<Airline_API__mdt> indigoAirlinesessionId = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c FROM Airline_API__mdt
                                                             WHERE DeveloperName = 'Indigo_Get_Session_ID' LIMIT 1];
            
       // create varibale to  store metadata values 
            String Username = '';
            String Password = '';
            String Station = '';
            String session = '';
            String Endpoint1 = '';
            if(!indigoAirlinesessionId.isEmpty()){
       //stored metadata values in variables
                Username = indigoAirlinesessionId[0].Username__c;
                Password = indigoAirlinesessionId[0].Password__c;
       //Station = indigoAirlinesessionId[0].Station__c;
                AppID = indigoAirlinesessionId[0].AppID__c;
                Endpoint1 = indigoAirlinesessionId[0].Endpoint__c;
            }   
            system.debug('Endpoint===='+Endpoint1);
       // sending http POST request to the endpoint fetched by metadata stored in endpoint variable
            Http httpsession = new Http();
            HttpRequest requestsession = new HttpRequest();
            requestsession.setEndpoint(Endpoint1);
            requestsession.setMethod('POST');
            requestsession.setHeader('Content-type', 'application/json');
      // set body of request 
            requestsession.setBody('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
            
            HttpResponse responsesession = http.send(requestsession);
            System.debug('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
            if(responsesession.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + responsesession.getStatusCode() + ' ' + responsesession.getStatus());
            } else {
                system.debug(responsesession.getBody());
       // deserialize response body stored in responsesession variable
                IndigoWrapperSessionIdClass responseWrapper2 = IndigoWrapperSessionIdClass.parse(responsesession.getBody());
                system.debug(responseWrapper2);
                
                String d = responseWrapper2.d;
                String result2 = d.subStringBetween('RESULT_START:',':RESULT_END');
                system.debug(result2);
       // Deserialize result2 and stored deserialized session ID in  sessionID  varibale   
                IndigoWrapperSessionIdClass1 responseWrap2 = IndigoWrapperSessionIdClass1.parse(result2);
                system.debug(responseWrap2);
                sessionID = responseWrap2.Table[0].SessionID;
                system.debug('session Id'+sessionID);
            }
            
        }
        
        if(sessionID != null && sessionID != ''){
            system.debug('found the session id');
            
            String loginName = '';
            
            String origin = '';
            String desti = '';
            String commodityCode = '';
            String productType = '';
            String commodityDesc = '';
            String pcs = '';
            String grossWt = '';
            String chargeableWt = '';
            String fltDate = '';
            String fltNumber = '';
            String UOM = '';
            String Dimensions = '';
            String ScheduleID = '';
            String ShprLat = '';
            String ShprLong = '';
            String ConsLat = '';
            String ConsLong = '';
            String ShprEmailID = '';
            String ConsEmailID = '';
            String Unit = '';
            String awbNumber = '';
            String slac = ''; 
            String dvCustom = '';
            String declaredValue = '';
            String payMode = '';
            String packagingInfo = '';
            String volume = '';
            String shcCode = '';
            String multilegRoutes = '';
            String shippingAccountCode = '';
            String ShippingAgentCode = '';
            String ShippingAccountName = '';
            String consigneeAccountCode = '';
            String consigeeAgentCode = '';
            String consigneeAccountName = '';
            String shippingCity = '';
            String ShprState = '';
            String ShprAdd = '';
            String   ShprPincode= '';
            String   ShprCountryCode= '';
            String  ShprContactNo= '';
            String ConsCity = '';
            String ConsState ='';
            String ConsAdd ='';
            String ConsPincode ='';
            String ConsContactNo = '';
            String countryCode = '';
            String flightNo = '';  
            
      // Fetch lineHaul Record whose id is recordIdLinehaul
            List<Linehaul__c> linehaulRecord = [SELECT Id,Name,Origin_Airport_Code__c,Destination_Airport_Code__c,Commodity_Code__c,Product_Type__c,
                                                Commodity_Description__c,Pcs_Int__c,Gross_Weight__c,Chargeable_Weight__c,Flight_Date__c,
                                                Flight_No_for_SpiceJet_Indigo__r.Name,UOM__c,Dimensions__c,Schedule_ID__c,Shipping_Coordinates__c,
                                                Consignee_Latitude__c,Shipper_EmailID__c,Consignee_EmailID__c,Unit__c,AWB_Number__c,Slac__c,
                                                Dv_Custom__c,Declared_Value__c,Payment_Mode__c,Packaging_Info__c,Volume__c,SHC_Code__c,Multi_Leg_Routes__c,
                                                Shipping_Account_Code_Picklist__c,Shipping_Agent_Code_Picklist__c,
                                                Consignee_Account_Code_Picklist__c,Consignee_Agent_Code_Picklist__c,Account_Name__c,Shipping_City_Picklist__c,
                                                Shipping_State__c,Shipping_Address__c,Shipping_Pincode__c,Shipping_Country_Code__c,Shipper_Contact_Number__c,
                                                Consignee_City_Picklist__c,AirLine_Name__c,Consignee_State__c,Consignee_Address__c,Consignee_Pincode__c,Consignee_Contact_Number__c,
                                                Flight_No_for_SpiceJet_Indigo__r.Airline_Name1__c,Origin__c,Destination__c,Shipping_Account_Code_Text__c,Shipping_Agent_Code_Text__c,Shipping_City_Text__c,Shipper_Name__c,
                                                Consignee_Account_Code_Text__c,Consignee_City_Text__c,Consignee_Name__c,Booked_Flight_For_AWB__c
                                                FROM Linehaul__c 
                                                WHERE Id =: recordIdLinehaul LIMIT 1];
            if(linehaulRecord[0].AWB_Number__c != null){
                return 'awbNumberError';
            }
            
            
            system.debug('linehaulRecord '+linehaulRecord[0].Name);
            
            if(!linehaulRecord.isEmpty() && linehaulRecord[0].AirLine_Name__c == 'Indigo'){ //&& linehaulRecord[0].Flight_No_for_SpiceJet_Indigo__r.Airline_Name1__c == 'Indigo'
           // fetch custom metadata whose DeveloperName is 'Indigo_Create_AWB' 
                List<Airline_API__mdt> indigoAWBAirline = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c,loginName__c FROM Airline_API__mdt
                                                           WHERE DeveloperName = 'Indigo_Create_AWB' LIMIT 1];
                
            // assign Endpoint__c and loginName__c values in endpoint and loginName variables respectively.
                if(!indigoAWBAirline.isEmpty()){
                    endpoint = indigoAWBAirline[0].Endpoint__c;
                    loginName = indigoAWBAirline[0].loginName__c;
                }
                
                if(!linehaulRecord.isEmpty()){
                    origin = linehaulRecord[0].Origin__c;
                    desti = linehaulRecord[0].Destination__c;
                    commodityCode = linehaulRecord[0].Commodity_Code__c;
                    productType = linehaulRecord[0].Product_Type__c;
                    commodityDesc = linehaulRecord[0].Commodity_Description__c;
                    pcs = String.Valueof(linehaulRecord[0].Pcs_Int__c);	
                    grossWt = String.Valueof(linehaulRecord[0].Gross_Weight__c);
                    chargeableWt = String.Valueof(linehaulRecord[0].Chargeable_Weight__c);
                    fltDate = String.Valueof(linehaulRecord[0].Flight_Date__c);
                    //fltNumber = linehaulRecord[0].Flight_No_for_SpiceJet_Indigo__r.Name;
                    UOM = linehaulRecord[0].UOM__c;
                    Dimensions = linehaulRecord[0].Dimensions__c;
                    ScheduleID = linehaulRecord[0].Schedule_ID__c;
                    ShprLat = String.Valueof(linehaulRecord[0].Shipping_Coordinates__c);
                    ShprLong = String.Valueof(linehaulRecord[0].Shipping_Coordinates__c);
                    ConsLat = String.Valueof(linehaulRecord[0].Consignee_Latitude__c);
                    ConsLong = String.Valueof(linehaulRecord[0].Consignee_Latitude__c);
                    ShprEmailID = linehaulRecord[0].Shipper_EmailID__c;
                    ConsEmailID = linehaulRecord[0].Consignee_EmailID__c;
                    Unit = linehaulRecord[0].Unit__c;
                    awbNumber = linehaulRecord[0].AWB_Number__c;
                    slac = linehaulRecord[0].Slac__c;
                    dvCustom = String.Valueof(linehaulRecord[0].Dv_Custom__c);
                    declaredValue = String.Valueof(linehaulRecord[0].Declared_Value__c);
                    payMode = linehaulRecord[0].Payment_Mode__c;
                    packagingInfo = linehaulRecord[0].Packaging_Info__c;
                    volume = String.Valueof(linehaulRecord[0].Volume__c);
                    shcCode = linehaulRecord[0].SHC_Code__c;
                    multilegRoutes = linehaulRecord[0].Multi_Leg_Routes__c;
                    shippingAccountCode = linehaulRecord[0].Shipping_Account_Code_Picklist__c;
                    ShippingAgentCode = linehaulRecord[0].Shipping_Agent_Code_Picklist__c;
                    ShippingAccountName = linehaulRecord[0].Shipper_Name__c;
                    consigneeAccountCode = linehaulRecord[0].Consignee_Account_Code_Picklist__c;
                    //consigeeAgentCode = linehaulRecord[0].Consignee_Agent_Code_Picklist__c;
                    consigneeAccountName = linehaulRecord[0].Consignee_Name__c;
                    shippingCity = linehaulRecord[0].Shipping_City_Picklist__c;
                    ShprState = linehaulRecord[0].Shipping_State__c;
                    ShprAdd = linehaulRecord[0].Shipping_Address__c;
                    ShprPincode= linehaulRecord[0].Shipping_Pincode__c;
                    ShprCountryCode= linehaulRecord[0].Shipping_Country_Code__c;
                    ShprContactNo= linehaulRecord[0].Shipper_Contact_Number__c;
                    ConsCity = linehaulRecord[0].Consignee_City_Picklist__c;
                    ConsState =  linehaulRecord[0].Consignee_State__c;
                    ConsAdd =  linehaulRecord[0].Consignee_Address__c;
                    ConsPincode = linehaulRecord[0].Consignee_Pincode__c;
                    ConsContactNo = linehaulRecord[0].Consignee_Contact_Number__c;
                    countryCode = linehaulRecord[0].Shipping_Country_Code__c;
                }
            // send http request to the endpoint 
                Http https = new Http();
                HttpRequest requestFlight = new HttpRequest();
                requestFlight.setEndpoint(endpoint);
                requestFlight.setMethod('POST');
                requestFlight.setHeader('Content-type', 'application/json');
                //requestFlight.setBody('{"loginName":"'+loginName+'","sessionId":"'+sessionID+'","awbPrefix":"312","origin":"'+origin+'","destination":"'+desti+'","shippingAgentCode":"'+ShippingAgentCode+'","commodityCode":"'+commodityCode+'","productType":"'+productType+'","commodityDesc":"'+commodityDesc+'","pcs":"'+pcs+'","grossWt":"'+grossWt+'","chargeableWt":"'+chargeableWt+'","fltDate":"'+fltDate+'","fltNumber":"'+fltNumber+'","UOM":"'+UOM+'","Dimensions":"'+Dimensions+'","ShprAccountCode":"'+shippingAccountCode+'","ShprCity":"'+shippingCity+'","ShprState":"'+ShprState+'","ShprName":"'+ShippingAccountName+'","ShprAdd":"'+ShprAdd+'","ShprPincode":"'+ShprPincode+'","ShprCountryCode":"'+countryCode+'","ShprContactNo":"'+ShprContactNo+'","ConsAccountCode":"'+consigneeAccountCode+'","ConsCity":"'+ConsCity+'","ConsState":"'+ConsState+'","ConsName":"'+consigneeAccountName+'","ConsAdd":"'+ConsAdd+'","ConsPincode":"'+ConsPincode+'","ConsCountryCode":"'+countryCode+'","ConsContactNo":"'+ConsContactNo+'","ScheduleID":"'+ScheduleID+'","ShprLat":"'+ShprLat+'","ShprLong":"'+ShprLong+'","ConsLat":"'+ConsLat+'","ConsLong":"'+ConsLong+'","ShprEmailID":"'+ShprEmailID+'","ConsEmailID":"'+ConsEmailID+'","Unit":"'+Unit+'","awbNumber":"'+awbNumber+'","slac":"'+slac+'","dvCustom":"'+dvCustom+'","declaredValue":"'+declaredValue+'","payMode":"'+payMode+'","packagingInfo":"'+packagingInfo+'","TokenNumber":"'+token+'","volume":"'+volume+'","shcCode":"'+shcCode+'","multilegRoutes":"'+multilegRoutes+'"}');
                String replaceJSON = '{"loginName":"'+loginName+'","sessionId":"'+sessionID+'","awbPrefix":"312","origin":"'+origin+'","destination":"'+desti+'","shippingAgentCode":"'+ShippingAgentCode+'","commodityCode":"'+commodityCode+'","productType":"'+productType+'","commodityDesc":"'+commodityDesc+'","pcs":"'+pcs+'","grossWt":"'+grossWt+'","chargeableWt":"'+chargeableWt+'","fltDate":"'+fltDate+'","fltNumber":"'+fltNumber+'","UOM":"'+UOM+'","Dimensions":"'+Dimensions+'","ShprAccountCode":"'+shippingAccountCode+'","ShprCity":"'+shippingCity+'","ShprState":"'+ShprState+'","ShprName":"'+ShippingAccountName+'","ShprAdd":"'+ShprAdd+'","ShprPincode":"'+ShprPincode+'","ShprCountryCode":"'+countryCode+'","ShprContactNo":"'+ShprContactNo+'","ConsAccountCode":"'+consigneeAccountCode+'","ConsCity":"'+ConsCity+'","ConsState":"'+ConsState+'","ConsName":"'+consigneeAccountName+'","ConsAdd":"'+ConsAdd+'","ConsPincode":"'+ConsPincode+'","ConsCountryCode":"'+countryCode+'","ConsContactNo":"'+ConsContactNo+'","ScheduleID":"'+ScheduleID+'","ShprLat":"'+ShprLat+'","ShprLong":"'+ShprLong+'","ConsLat":"'+ConsLat+'","ConsLong":"'+ConsLong+'","ShprEmailID":"'+ShprEmailID+'","ConsEmailID":"'+ConsEmailID+'","Unit":"'+Unit+'","awbNumber":"'+awbNumber+'","slac":"'+slac+'","dvCustom":"'+dvCustom+'","declaredValue":"'+declaredValue+'","payMode":"'+payMode+'","packagingInfo":"'+packagingInfo+'","TokenNumber":"'+token+'","volume":"'+volume+'","shcCode":"'+shcCode+'","multilegRoutes":"'+multilegRoutes+'"}';
                // system.debug('replace JSON ==== '+replaceJSON);
                String finalJSON = replaceJSON.replaceALL('null','');
                system.debug('finalJSON ==== '+finalJSON);
           //set body to the request 
                requestFlight.setBody(finalJSON);
                requestFlight.setTimeout(120000);
                HttpResponse responseFlight = http.send(requestFlight);
                
                
                if(responseFlight.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + responseFlight.getStatusCode() + ' ' + responseFlight.getStatus());
                    status = responseFlight.getStatus();
                } 
                else {
                    system.debug(responseFlight.getBody());
              // deserialize response and stored in responseWrap variable
                    Indigo_AWBResponse_Wrapper responseWrap = Indigo_AWBResponse_Wrapper.parse(responseFlight.getBody());
                    system.debug(responseWrap);
                    
                    
                    String d = responseWrap.d;
                    String result = d.subStringBetween('RESULT_START:',':RESULT_END');
                    system.debug(result);
                 // deserialize response and stored in 'result' variable    
                    Indigo_AWBResponse_Wrapper2 createAWBresponse = Indigo_AWBResponse_Wrapper2.parse(result);
                    system.debug(createAWBresponse);
                    
                    if(createAWBresponse.Table6.size() > 0){
                        
                        if(createAWBresponse.Table6[0].AWBNumber != '' && createAWBresponse.Table6[0].AWBNumber != null){
                            status = 'Success';
                            String flight = '';
                 // get flight route and assigned into flightNo variable
                            for(Indigo_AWBResponse_Wrapper2.Table6 getflightNo: createAWBresponse.Table6){
                                system.debug('flightNo '+getflightNo.FlightRoute);
                                flightNo = getflightNo.FlightRoute.subStringBetween(',',',');
                                List<String> flightStringList = getflightNo.FlightRoute.split(',');
                                Date year = date.parse(flightStringList[4]);
                                system.debug('year '+year.year());
                                String Sdate = flightStringList[5];
                                
                                Datetime flightDate = Datetime.newInstanceGMT(year.year(),integer.valueof(Sdate.substringBetween('/', '/')),integer.valueof(Sdate.substringBefore('/')),integer.valueof(Sdate.substringBetween(' ',':')),integer.valueof(Sdate.substringAfter(':')),00);
                               
                                system.debug('flightDate '+flightDate);
                                 flight = 'Indigo '+flightStringList[1]+'-'+flightStringList[2]+'-'+flightStringList[3]+'-'+flightDate;
                                system.debug('flight no '+flight);
                               
                            }
                            
                            if(flightNo != null && flightNo != '' && flight != null && flight != ''){
                            //get flight schedule record whose Flight_Number__c  is equal to flightNo and Name  equals to flight
                                getFlight = [SELECT Id,Name,Flight_Number__c FROM Flight_Schedule__c WHERE Flight_Number__c =: flightNo AND Name =: flight];  
                              //  system.debug('flightNo '+getFlight[0].Name);
                            }
                            
                            for(Linehaul__c lineHaul : linehaulRecord){
                          // assign AWBNumber  value in linehaul record AWB_Number__c field,assign flight route in Booked_Flight_For_AWB__c field of linehaul
                                lineHaul.AWB_Number__c = createAWBresponse.Table6[0].AWBNumber;
                                if(getFlight.size() > 0){
                          //assign flight number in Flight_No_for_SpiceJet_Indigo__c  from flight schedule record getFlight.
                                    lineHaul.Flight_No_for_SpiceJet_Indigo__c = getFlight[0].Id;   
                                }
                         
                                lineHaul.Booked_Flight_For_AWB__c = createAWBresponse.Table6[0].FlightRoute;
                                updateIndigoLinehaulList.add(lineHaul);
                            }
                        }
                    }
                }
            }
        }
        if(!updateIndigoLinehaulList.isEmpty()){
       // update linehaul record by calling updateAwbHelper apex class
            updateAwbHelper.Indigo(updateIndigoLinehaulList);
        }
        return status;
    }
    @AuraEnabled
    public static String spiceJetAWB(Id recordIdLinehaul){
        String status = '';
        List<Linehaul__c> updateLinehaulList = new List<Linehaul__c>();
        String token = '';
      // get custom metadata whose DeveloperName  is 'Spice_Jet_Token_Generation'
        Airline_API__mdt[] spiceJetAirline = [SELECT Endpoint__c,Email__c,Password__c,Source__c,isSwagger__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Token_Generation'];
        String endpoint = '';
        String Email = '';
        String Password = '';
        Boolean isSwagger = false;
        String Source = '';
        
       // Assign metadata values in above variables
        if(!spiceJetAirline.isEmpty()){
            endpoint = spiceJetAirline[0].Endpoint__c;
            Email = spiceJetAirline[0].Email__c;
            Password = spiceJetAirline[0].Password__c;
            isSwagger = spiceJetAirline[0].isSwagger__c;
            Source = spiceJetAirline[0].Source__c;
        }
     //send http request to the endpoint fetched from metadata  and send body 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"email":"'+Email+'","password":"'+Password+'","source":"'+Source+'","isSwagger":"'+isSwagger+'"}');
        HttpResponse response = http.send(request);
        
        
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            
   // SpiceJetTokenResponseWrapper is a wrapper class as well as it is deserializing the response and assigne access_token's values in token varible,
   // access_token comes from response whch is deseriazed in this wrapper class.
            SpiceJetTokenResponseWrapper responseWrapper = SpiceJetTokenResponseWrapper.parse(response.getBody());
            if(responseWrapper.result!= null){
                if(String.isNotBlank(responseWrapper.result.access_token)){
                    token = responseWrapper.result.access_token; 
                }
            }
            system.debug('Token Generated ------ '+token);
            
        }
        if(token != null && token != ''){
      // fetch Linehaul__c  record where id of the record is recordIdLinehaul.
            List<Linehaul__c> linehaulRecord = [SELECT Id,Name,AWB_Number__c,Origin__c,Destination__c,Commodity_Code__c,Commodity_Description__c,
                                                Gross_Weight__c,Total_Pieces__c,Height_Dimension__c,Length_Dimension__c,Width_Dimension__c,Requested_Quantity__c,
                                                Weight_Dimension__c,Bag_Number__c,Dimension_Type__c,Type__c,Route_Type__c,Partner_Type__c,Partner_Code__c,
                                                Flight_Destination__c,Flight_Origin__c,From__c,Flight_Code__c,Flight_No_for_SpiceJet_Indigo__c,Mode__c,
                                                Flight_No_for_SpiceJet_Indigo__r.Airline_Name1__c,Shipper_Address_SpiceJet__c,Shipper_Name_SpiceJet__c,Shipper_City_SpiceJet__c,
                                                Shipper_State_Code_SpiceJet__c,Shipper_Country_Code_SpiceJet__c,Shipper_Pincode_SpiceJet__c,Shipper_Contact_No_SpiceJet__c,
                                                 Shipper_Email_SpiceJet__c,Consignee_Address_SpiceJet__c,Consignee_Name_SpiceJet__c,Consignee_City_SpiceJet__c,
                                                 Consignee_State_Code_SpiceJet__c,Consignee_Country_Code_SpiceJet__c,Consignee_Pincode_SpiceJet__c,Consignee_Contact_No_SpiceJet__c,Consignee_Email_SpiceJet__c
                                                 FROM Linehaul__c 
                                                WHERE Id =: recordIdLinehaul LIMIT 1];
            if(linehaulRecord[0].AWB_Number__c != null){
                return 'awbNumberError';
            }
            if(linehaulRecord[0].Flight_Origin__c == null){
                return 'flightoriginError';
            }
            
            if(linehaulRecord[0].Flight_Destination__c == null){
                return 'FlightDestinationError';
            }
            if(linehaulRecord[0].From__c == null){
                return 'FromError';  
            }
            if(linehaulRecord[0].Mode__c == null){
                return 'ModeError';  
            }
            if(linehaulRecord[0].Flight_Code__c == null){
                return 'FlightCodeError';  
            }
       // if Airline name is SPICEJET then assign values in below variables from that linehaul record     
            if(linehaulRecord[0].Flight_No_for_SpiceJet_Indigo__r.Airline_Name1__c == 'SPICEJET'){
                
                String AwbNumber = '';
                String Origin = '';
                String Destination = '';
                String CommodityCode = '';
                String CommodityDescription = '';
                String GrossWeight= '';
                String TotalPieces= '';
                String HeightDimension= '';
                String LengthDimension= '';
                String WidthDimension= '';
                String RequestedQuantity= '';
                String WeightDimension= '';
                String BagNumber= '';
                String DimensionType= '';
                String Type= '';
                String RouteType= '';
                String PartnerType= '';
                String PartnerCode= '';
                String FlightDestination= '';
                String FlightOrigin= '';
                String FromDate= '';
                String FlightCode= '';
                String FlightNoforSpiceJetIndigo= '';
                String Mode= '';
                String shipper_address = '';
                String shipper_name = '';
                String shipper_city = '';
                String shipper_state_code = '';
                String shipper_country_code = '';
                String shipper_postal_code = '';
                String shipper_contact_number = '';
                String shipper_email = '';
                String consignee_address = '';
                String consignee_name = '';
                String consignee_city = '';
                String consignee_state_code = '';
                String consignee_country_code = '';
                String consignee_postal_code = '';
                String consignee_contact_number = '';
                string consignee_email = '';
                
                if(!linehaulRecord.isEmpty()){     
                    AwbNumber= linehaulRecord[0].AWB_Number__c;
                    Origin= linehaulRecord[0].Origin__c;
                    Destination=linehaulRecord[0].Destination__c;
                    CommodityCode= linehaulRecord[0].Commodity_Code__c;
                    CommodityDescription= linehaulRecord[0].Commodity_Description__c;
                    GrossWeight= String.valueOf(linehaulRecord[0].Gross_Weight__c);
                    TotalPieces= String.valueOf(linehaulRecord[0].Total_Pieces__c);
                    HeightDimension= String.valueOf(linehaulRecord[0].Height_Dimension__c);
                    LengthDimension= String.valueOf(linehaulRecord[0].Length_Dimension__c);
                    WidthDimension= String.valueOf(linehaulRecord[0].Width_Dimension__c);
                    RequestedQuantity= String.valueOf(linehaulRecord[0].Requested_Quantity__c);
                    WeightDimension= String.valueOf(linehaulRecord[0].Weight_Dimension__c);
                    system.debug('Weight Dimension '+WeightDimension);
                    system.debug('String Weight Dimension '+String.valueOf(linehaulRecord[0].Weight_Dimension__c));
                    BagNumber= String.valueOf(linehaulRecord[0].Bag_Number__c);
                    DimensionType= linehaulRecord[0].Dimension_Type__c;
                    Type= linehaulRecord[0].Type__c;
                    RouteType= linehaulRecord[0].Route_Type__c;
                    PartnerType= linehaulRecord[0].Partner_Type__c;
                    PartnerCode= linehaulRecord[0].Partner_Code__c;
                    FlightDestination= linehaulRecord[0].Flight_Destination__c;
                    FlightOrigin= linehaulRecord[0].Flight_Origin__c;
                    FromDate= String.valueOf(linehaulRecord[0].From__c);
                    //FromDate = String.valueof(DateTime.newInstanceGMT(2022,08,12, 18,20,0));
                    FlightCode= linehaulRecord[0].Flight_Code__c.subStringBetween('SPICE ','-');
                    // FlightCode= '';
                    FlightNoforSpiceJetIndigo = '';
                    //FlightNoforSpiceJetIndigo= linehaulRecord[0].Flight_No_for_SpiceJet_Indigo__c;
                    Mode= linehaulRecord[0].Mode__c;
                 shipper_address = linehaulRecord[0].Shipper_Address_SpiceJet__c;
                 shipper_name = linehaulRecord[0].Shipper_Name_SpiceJet__c;
                 shipper_city = linehaulRecord[0].Shipper_City_SpiceJet__c;
                 shipper_state_code = linehaulRecord[0].Shipper_State_Code_SpiceJet__c;
                 shipper_country_code = linehaulRecord[0].Shipper_Country_Code_SpiceJet__c;
                 shipper_postal_code = linehaulRecord[0].Shipper_Pincode_SpiceJet__c;
                 shipper_contact_number = linehaulRecord[0].Shipper_Contact_No_SpiceJet__c;
                 shipper_email = linehaulRecord[0].Shipper_Email_SpiceJet__c;
                 consignee_address = linehaulRecord[0].Consignee_Address_SpiceJet__c;
                 consignee_name = linehaulRecord[0].Consignee_Name_SpiceJet__c;
                 consignee_city = linehaulRecord[0].Consignee_City_SpiceJet__c;
                 consignee_state_code = linehaulRecord[0].Consignee_State_Code_SpiceJet__c;
                 consignee_country_code = linehaulRecord[0].Consignee_Country_Code_SpiceJet__c;
                 consignee_postal_code = linehaulRecord[0].Consignee_Pincode_SpiceJet__c;
                 consignee_contact_number = linehaulRecord[0].Consignee_Contact_No_SpiceJet__c;
                 consignee_email = linehaulRecord[0].Consignee_Email_SpiceJet__c;
                
                    String customer = '';
           // get SpiceJet_Customer_Code__mdt custom metadata where Airport_Code__c is linehaul records origin.
                    SpiceJet_Customer_Code__mdt[] customerCode = [SELECT Agent_Code__c,Airport_Code__c FROM SpiceJet_Customer_Code__mdt WHERE Airport_Code__c =: linehaulRecord[0].Origin__c];
                    if(customerCode[0].Agent_Code__c != null && customerCode[0].Agent_Code__c != ''){
                        customer = customerCode[0].Agent_Code__c;
                    }
                    
           // get   Airline_API__mdt  custom metadata where DeveloperName  is Spice_Jet_Create_AWB'
                    Airline_API__mdt[] spiceJetAirlineAWB = [SELECT Endpoint__c,Email__c,Password__c,Source__c,isSwagger__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Create_AWB'];
                    String Endpoint2='';
                    
             // store Endpoint__c  value in Endpoint2  variable and send http request to this endpoint which get from airline api metadata, and send request.
                    Endpoint2 = spiceJetAirlineAWB[0].Endpoint__c;
                    Http httpawb = new Http();
                    HttpRequest requestAWB = new HttpRequest();
                    requestAWB.setEndpoint(Endpoint2);
                    requestAWB.setMethod('POST');
                    requestAWB.setHeader('Content-type', 'application/json');
                    requestAWB.setHeader('Authorization',token);
                    // requestAWB.setBody('{"awb_number":"'+AwbNumber+'","origin":"'+Origin+'","destination":"'+Destination+'","commodity_code":"'+CommodityCode+'","commodity_description":"'+CommodityDescription+'","total_pieces":"'+TotalPieces+'","gross_weight":"'+GrossWeight+'","products":[{"height_dimension":"'+HeightDimension+'","length_dimension":"'+LengthDimension+'","width_dimension":"'+WidthDimension+'","requested_quantity":"'+RequestedQuantity+'","weight_dimension":"'+WeightDimension+'","bag_number":"'+BagNumber+'","dimension_type":"'+DimensionType+'","type":"'+Type+'"}],"flight_route":[{"route_type":"'+RouteType+'","partner_type":"'+PartnerType+'","partner_code":"'+PartnerCode+'","flight_destination":"'+FlightDestination+'","flight_origin":"'+FlightOrigin+'","from":"'+FromDate+'","flight_code":"'+FlightCode+'","id":"'+FlightNoforSpiceJetIndigo+'"}],"mode":"'+Mode+'"}').replace('"null"',null);
                    system.debug('Weight Dimension1 '+WeightDimension);
                    system.debug('String Weight Dimension1 '+String.valueOf(linehaulRecord[0].Weight_Dimension__c));
                    String replaceJSON ='{"awb_number":"'+AwbNumber+'","origin":"'+Origin+'","destination":"'+Destination+'","customer":"'+customer+'","commodity_code":"'+CommodityCode+'","commodity_description":"'+CommodityDescription+'","gross_weight":"'+GrossWeight+'","total_pieces":"'+TotalPieces+'","shipper":{"shipper_address":"'+shipper_address+'","shipper_name":"'+shipper_name+'","shipper_city":"'+shipper_city+'","shipper_state_code":"'+shipper_state_code+'","shipper_country_code":"'+shipper_country_code+'","shipper_postal_code":"'+shipper_postal_code+'","shipper_contact_number":"'+shipper_contact_number+'","shipper_email":"'+shipper_email+'"},"consignee":{"consignee_address":"'+consignee_address+'","consignee_name":"'+consignee_name+'","consignee_city":"'+consignee_city+'","consignee_state_code":"'+consignee_state_code+'","consignee_country_code":"'+consignee_country_code+'","consignee_postal_code":"'+consignee_postal_code+'","consignee_contact_number":"'+consignee_contact_number+'","consignee_email":"'+consignee_email+'"},"products":[{"height_dimension":"'+HeightDimension+'","length_dimension":"'+LengthDimension+'","width_dimension":"'+WidthDimension+'","bag_number":"'+BagNumber+'","requested_quantity":"'+RequestedQuantity+'","weight_dimension":"'+WeightDimension+'","dimension_type":"'+DimensionType+'","type":"'+Type+'"}],"flight_route":[{"route_type":"'+RouteType+'","partner_type":"'+PartnerType+'","partner_code":"'+PartnerCode+'","flight_destination":"'+FlightDestination+'","flight_origin":"'+FlightOrigin+'","from":"'+FromDate+'","flight_code":"'+FlightCode+'"}],"mode":"'+Mode+'"}';                    
                    String finalJSON = replaceJSON.replaceALL('"null"','null');
                    system.debug('finalJSON ==== '+finalJSON);
                    requestAWB.setBody(finalJSON);
                    HttpResponse responseAWB = http.send(requestAWB);
                    
                    system.debug('Response of Spicejet===='+responseAWB.getBody());
                    if(responseAWB.getStatusCode() != 200) {
                        status = responseAWB.getStatus();
                        System.debug('The status code returned was not expected: ' + responseAWB.getStatusCode() + ' ' + responseAWB.getStatus());
                    } else {
                        system.debug('Response of Spicejet===='+responseAWB.getBody());
                  // deserialize the response body and store in awbResponseWrapper variable 
                        SpiceJet_CreateAWBresponse awbResponseWrapper =  SpiceJet_CreateAWBresponse.parse(responseAWB.getBody());
                        if(awbResponseWrapper.Result.awb_number != null && awbResponseWrapper.Result.awb_number != ''){
                            status = 'Success';
                        }
                        
                        for(Linehaul__c lineHaul : [SELECT id,Name FROM Linehaul__c WHERE id =: recordIdLinehaul]){
                            lineHaul.AWB_Number__c = awbResponseWrapper.Result.awb_number;
                            updateLinehaulList.add(lineHaul);
                        }
                    }
                }
            }
        }
        if(!updateLinehaulList.isEmpty()){
           // update Linehaual Record 
            updateAwbHelper.Spicejet(updateLinehaulList);
        } 
        return status;
    }
    
}