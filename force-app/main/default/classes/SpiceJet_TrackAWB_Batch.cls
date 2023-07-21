global class SpiceJet_TrackAWB_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public List<Linehaul_Tracking__c> insertLineTrack	= new List<Linehaul_Tracking__c>();
    global Database.QueryLocator Start(Database.BatchableContext bc){
        String spiceJet = 'SPICEJET';
     // get Linehaul record where airline name is spicejet
        String getAWB =  'SELECT id,Name,AWB_Number__c FROM Linehaul__c WHERE AWB_Number__c != null AND AirLine_Name__c =: spicejet';
        return Database.getQueryLocator(getAWB);
    }
    
    global void execute(Database.BatchableContext bc,List<Linehaul__c> awbList){
        
        Map<String,String> awbStatusMap = new Map<String,String>();
     //get AWB_Tracking_Status__mdt custom metadata record where developer names are mentioned below.
        AWB_Tracking_Status__mdt[] awbStatusList = [SELECT MasterLabel,SpiceJet_AWB_Status__c 
                                                    FROM AWB_Tracking_Status__mdt 
                                                    WHERE 
                                                    DeveloperName = 'AWB_Booked' OR DeveloperName = 'AWB_Finalized' OR DeveloperName = 'Airline_Deposited' OR 
                                                    DeveloperName = 'On_Route_Airport' OR DeveloperName = 'Pre_Flight_at_Airport' OR DeveloperName = 'Flight_Departed'OR
                                                    DeveloperName = 'Flight_Arrived' OR DeveloperName = 'Pre_Retrieval_at_Airport' OR DeveloperName = 'Retrieved'];
        for(AWB_Tracking_Status__mdt awbStatus : awbStatusList){
            if(awbStatus.SpiceJet_AWB_Status__c != null && awbStatus.SpiceJet_AWB_Status__c !=''){
                if(awbStatus.MasterLabel != null && awbStatus.MasterLabel != ''){
      //store SpiceJet_AWB_Status__c as a ID  and MasterLabel as a Value in awbStatusMap map 
                    awbStatusMap.put(awbStatus.SpiceJet_AWB_Status__c,awbStatus.MasterLabel);
                    
                }
            }
            
        }
        
        
        /*AWB_Tracking_Status__mdt[] awbBooked = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'AWB_Booked'];
AWB_Tracking_Status__mdt[] awbFinalized = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'AWB_Finalized'];
AWB_Tracking_Status__mdt[] AirlineDeposit = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'Airline_Deposited'];
AWB_Tracking_Status__mdt[] OnRouteAirport = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'On_Route_Airport'];
AWB_Tracking_Status__mdt[] PreFlightatAirport = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'Pre_Flight_at_Airport'];
AWB_Tracking_Status__mdt[] FlightDeparted = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'Flight_Departed'];
AWB_Tracking_Status__mdt[] FlightArrived = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'Flight_Arrived'];
AWB_Tracking_Status__mdt[] PreRetrievalAtAirport = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'Pre_Retrieval_at_Airport'];
AWB_Tracking_Status__mdt[] Retrieved = [SELECT MasterLabel,SpiceJet_AWB_Status__c FROM AWB_Tracking_Status__mdt WHERE DeveloperName = 'Retrieved'];
Map<String,String> awbStatusMap = new Map<String,String>();
if(awbBooked.size() > 0){
awbStatusMap.put(awbBooked[0].SpiceJet_AWB_Status__c,awbBooked[0].MasterLabel);
}
if(awbFinalized.size() > 0){
awbStatusMap.put(awbFinalized[0].SpiceJet_AWB_Status__c,awbFinalized[0].MasterLabel);
}
if(AirlineDeposit.size() > 0){
awbStatusMap.put(AirlineDeposit[0].SpiceJet_AWB_Status__c,AirlineDeposit[0].MasterLabel);
}
if(OnRouteAirport.size() > 0){
awbStatusMap.put(OnRouteAirport[0].SpiceJet_AWB_Status__c,OnRouteAirport[0].MasterLabel);
}
if(PreFlightatAirport.size() > 0){
awbStatusMap.put(PreFlightatAirport[0].SpiceJet_AWB_Status__c,PreFlightatAirport[0].MasterLabel);
}
if(FlightDeparted.size() > 0){
awbStatusMap.put(FlightDeparted[0].SpiceJet_AWB_Status__c,FlightDeparted[0].MasterLabel);
}
if(FlightArrived.size() > 0){
awbStatusMap.put(FlightArrived[0].SpiceJet_AWB_Status__c,FlightArrived[0].MasterLabel);
}
if(PreRetrievalAtAirport.size() > 0){
awbStatusMap.put(PreRetrievalAtAirport[0].SpiceJet_AWB_Status__c,PreRetrievalAtAirport[0].MasterLabel);
}
if(Retrieved.size() > 0){
awbStatusMap.put(Retrieved[0].SpiceJet_AWB_Status__c,Retrieved[0].MasterLabel);
}
*/
     // Track_AWB_SpiceJetHelper apex class is used to send http request and it deserialize the response adn created linehaul tracking record from that response
        insertLineTrack.addAll(Track_AWB_SpiceJetHelper.trackAWBspicejet(awbList,awbStatusMap));
        if(!insertLineTrack.isEmpty())
        {
            Database.insert(insertLineTrack);
        }
         Map<String,String> awbNumbers = new Map<String,String>();
        Map<Id,String> shipmentRecordMap = new Map<Id,String>();
        List<Shipment__c> updateShipmentList = new List<Shipment__c>();
        List<Shipment_Tracking__c> createTrackingList = new List<Shipment_Tracking__c>();
        Map<Id,String> previousTracking = new Map<Id,String>();
      // get Linehaul_Tracking__c record and store AWB_Number__c as a ID and Status__c as a Value
        for(Linehaul_Tracking__c linehaulTrackingRecord: [SELECT Id,Name,CreatedDate,Status__c,Linehaul_Name__c,AWB_Number__c FROM Linehaul_Tracking__c WHERE CreatedDate = today]){
            awbNumbers.put(linehaulTrackingRecord.AWB_Number__c,linehaulTrackingRecord.Status__c);
            
        }
        if(!awbNumbers.isEmpty()){
    // get AWB_Number__c record where AWB_Code__c in  awbNumbers map   
            for(AWB_Number__c awbNumberRecord : [SELECT Id,Name,AWB_Code__c,Linehaul_Tracking__c,Shipment__c,Shipment__r.Id FROM AWB_Number__c WHERE AWB_Code__c IN: awbNumbers.keySet()]){
                String status = awbNumbers.get(awbNumberRecord.AWB_Code__c);
                shipmentRecordMap.put(awbNumberRecord.Shipment__r.Id,status);
            }
            
        }
        for(Shipment_Tracking__c shipTracking : [SELECT Id,Name,Location__c,Shipment__c FROM Shipment_Tracking__c WHERE Shipment__c IN: shipmentRecordMap.keySet()]){
            previousTracking.put(shipTracking.Id,shipTracking.Location__c);
        }
        if(!shipmentRecordMap.isEmpty()){
      // featch shipment record where id in shipmentRecordMap map 
            for(Shipment__c shipmentRecord : [SELECT Id,Name,Tracking_Status__c,Origin_Hub__c FROM Shipment__c WHERE Id IN: shipmentRecordMap.keySet()]){
                
                if(previousTracking.get(shipmentRecord.Id) != shipmentRecordMap.get(shipmentRecord.Id)){
      // create Shipment_Tracking__c record  from shipment record 
                Shipment_Tracking__c  shipmentTracking = new Shipment_Tracking__c ();
                shipmentTracking.Shipment__c = shipmentRecord.Id;
                shipmentTracking.Hub__c = shipmentRecord.Origin_Hub__c;
                //shipmentTracking.Airport__c = shipmentRecord
                shipmentTracking.Location__c = shipmentRecordMap.get(shipmentRecord.Id);
                createTrackingList.add(shipmentTracking);
                }
            }
        }
        if(createTrackingList.size() > 0){
            Database.Insert(createTrackingList,false);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new Indigo_TrackAWB_Batch(),10);
    }
}