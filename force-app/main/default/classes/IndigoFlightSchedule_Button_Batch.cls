global class IndigoFlightSchedule_Button_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public  List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        
        String mtCityCode =  'SELECT Origin__c FROM City_Code__mdt'+(Test.isRunningTest()?' LIMIT 1':'');
        return Database.getQueryLocator(mtCityCode);
    }
    global void execute(Database.BatchableContext bc,List<City_Code__mdt> originCode){
        String indigoID = '';
        String LoginName = '';
        String airlineCode = '';
        String endpoint = '';
        List<AirLine1__c> indigoAirlineName = [SELECT Airline_Name__c,Name,Id FROM AirLine1__c WHERE Airline_Name__c = 'Indigo' LIMIT 1];
        if(!indigoAirlineName.isEmpty()){
            indigoID = indigoAirlineName[0].Id;
        }
        
        
        List<Airline_API__mdt> indigoAirline = [SELECT Endpoint__c,loginName__c, airLine_Code__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Get_Flight_Details' LIMIT 1];
        if(!indigoAirline.isEmpty()){
             LoginName = indigoAirline[0].loginName__c;
             airlineCode = indigoAirline[0].airLine_Code__c;
            endpoint = indigoAirline[0].Endpoint__c;
        }
       
        
        String TokenNumber = FlightScheduleBatch_Helper.generateToken();
        
        system.debug('access_token from Batch Class------ '+TokenNumber);
        if(TokenNumber != null && TokenNumber != ''){
            
            String sessionIdNum = FlightScheduleBatch_Helper.generateSessionId();
            system.debug('access_token from Batch Class------ '+sessionIdNum);
            if(sessionIdNum != null && sessionIdNum != '' && indigoID != null && indigoID != '' && originCode.size() > 0 && (LoginName != null && LoginName != '' && airlineCode != '' && airlineCode != null && endpoint != null && endpoint != '')){
                for(City_Code__mdt originCity : originCode){
                    FlightScheduleList.addAll(FlightScheduleBatch_Button_Helper.getFlightDetails(originCity.Origin__c,indigoID,LoginName,airlineCode,endpoint));
                }
            }
            if(!FlightScheduleList.isEmpty() && FlightScheduleList.size() > 0){
            Database.upsert(FlightScheduleList);
            system.debug('List of Flight in Batch for Insertion------ '+flightScheduleList.size());
        }
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
}