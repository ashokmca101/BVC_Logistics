global class FlightSchedule_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public  List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        
        String mtCityCode =  'SELECT Origin__c FROM City_Code__mdt'+(Test.isRunningTest()?' LIMIT 10':'');
        return Database.getQueryLocator(mtCityCode);
    }
    global void execute(Database.BatchableContext bc,List<City_Code__mdt> originCode){
        List<Flight_Schedule__c> updateFlight = new List<Flight_Schedule__c>();
         List<Flight_Schedule__c> insertFlight = new List<Flight_Schedule__c>();
        system.debug('originCode =='+originCode.size());
        String indigoID = '';
        String LoginName = '';
        String airlineCode = '';
        String endpoint = '';
     //get airline record where airline name is 'Indigo' 
        List<AirLine1__c> indigoAirlineName = [SELECT Airline_Name__c,Name,Id FROM AirLine1__c WHERE Airline_Name__c = 'Indigo' LIMIT 1];
        if(!indigoAirlineName.isEmpty()){
            indigoID = indigoAirlineName[0].Id;
        }
        
     // get  Airline_API__mdt  metadata where developer name is Indigo_Get_Flight_Details  
        List<Airline_API__mdt> indigoAirline = [SELECT Endpoint__c,loginName__c, airLine_Code__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Get_Flight_Details' LIMIT 1];
        if(!indigoAirline.isEmpty()){
             LoginName = indigoAirline[0].loginName__c;
             airlineCode = indigoAirline[0].airLine_Code__c;
            endpoint = indigoAirline[0].Endpoint__c;
        }
       
      // generate tpoken by this apex class : FlightScheduleBatch_Helper  
        String TokenNumber = FlightScheduleBatch_Helper.generateToken();
        
        system.debug('access_token from Batch Class------ '+TokenNumber);
        if(TokenNumber != null && TokenNumber != ''){
      // generate session ID      
            String sessionIdNum = FlightScheduleBatch_Helper.generateSessionId();
            system.debug('access_token from Batch Class------ '+sessionIdNum);
            system.debug('Indigo ID------ '+indigoID);
            system.debug('LoginName------ '+LoginName);
            system.debug('airlineCode------ '+airlineCode);
            system.debug('endpoint------ '+endpoint);
            system.debug('originCode.size() ------ '+originCode.size());
       // check session ID and flight details from FlightScheduleBatch_Helper (flight schedule record is created in this class)      
            if(sessionIdNum != null && sessionIdNum != '' && indigoID != null && indigoID != '' && originCode.size() > 0 && (LoginName != null && LoginName != '' && airlineCode != '' && airlineCode != null && endpoint != null && endpoint != '')){
                for(City_Code__mdt originCity : originCode){
                    FlightScheduleList.addAll(FlightScheduleBatch_Helper.getFlightDetails(originCity.Origin__c,indigoID,LoginName,airlineCode,endpoint));
                }
            }
            if(!FlightScheduleList.isEmpty() && FlightScheduleList.size() > 0){
                for(Flight_Schedule__c getflight : flightScheduleList){
                    if(getflight.id == null){
                       insertFlight.add(getflight); 
                    }
                    else{
                         updateFlight.add(getflight);
                    }
                                   
            }
            if(updateFlight.size() > 0){
                update updateFlight;
            }
            Database.insert(insertFlight);
            system.debug('List of Flight in Batch for Insertion------ '+flightScheduleList.size());
        }
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
}