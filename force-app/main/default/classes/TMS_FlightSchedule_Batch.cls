global class TMS_FlightSchedule_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
  public  List<Flight_Schedule__c> flightScheduleList = new List<Flight_Schedule__c>();
    global Database.QueryLocator Start(Database.BatchableContext bc){
          // String queryVar = 'SELECT Id, Name, CreatedDate, Actual_Flight_Arrival__c, Actual_Flight_Departure__c, Destination_Airport__c, Destination_Airport_Code__c, Direct_or_Via__c, Flight_No_2__c, Flight_Number_2__c, Flight_Number_3__c, Flight_Number__c, Is_Inactive__c, Origin_Airport_Code__c, Origin_Airport__c, Scheduled_Arrival_Time__c, Scheduled_Departure_Time__c, Scheduled_Flight_Duration__c, Valuable_Cargo_Acceptance__c, Vulnerable_Cargo_Acceptance__c, Airline_Name__c FROM Flight_Schedule__c';
      // String origin = 'DEL';
      // where Origin__c =: origin
     
  // get origin from City_Code__mdt cutom metadata.
        String mtCityCode =  'SELECT Origin__c FROM City_Code__mdt'+(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(mtCityCode);
        
    }
    
    global void execute(Database.BatchableContext bc,List<City_Code__mdt> originCode){
        //Test.startTest();
        List<Flight_Schedule__c> updateFlight = new List<Flight_Schedule__c>();
        List<Flight_Schedule__c> insertFlight = new List<Flight_Schedule__c>();
    // get Airline_API__mdt custom metadata record where developer name is Spice_Jet_Get_Fight_Details
        List<Airline_API__mdt> spiceJetAirline = [SELECT Endpoint__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Get_Fight_Details' LIMIT 1];
        String getFlightzENDPoint = spiceJetAirline[0].Endpoint__c;
    //get airline record where airline name is SPICEJET.     
        List<AirLine1__c> spiceJetAirlineName = [SELECT Airline_Name__c,Name,Id FROM AirLine1__c WHERE Airline_Name__c = 'SPICEJET' LIMIT 1];
        String spiceJetId = spiceJetAirlineName[0].Id;
    // TMS_FlightScheduleBatch_Helper this apex class generates access token and creates flight scheduels records    
        String access_token = TMS_FlightScheduleBatch_Helper.generateToken();
        system.debug('access_token from Batch Class------ '+access_token);
       
        if(access_token != null && access_token != '' && getFlightzENDPoint != null && getFlightzENDPoint != '' && spiceJetId != null && spiceJetId != '' && originCode.size() > 0){
            for(City_Code__mdt originCity : originCode){
                flightScheduleList.addall(TMS_FlightScheduleBatch_Helper.getFlightDetails(access_token,originCity.Origin__c,getFlightzENDPoint,spiceJetId));
                
            }
        }
        if(flightScheduleList.size() > 0){
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
            system.debug('List of Flight in Bqatch for Insertion------ '+flightScheduleList.size());
        }
            
       //Test.stopTest();
    }
     global void finish(Database.BatchableContext bc){
         system.debug('======SpiceJet batch compeleted=====');
          //if(!Test.isRunningTest())
         //Database.executeBatch(new FlightSchedule_Batch(),10);
    }
}