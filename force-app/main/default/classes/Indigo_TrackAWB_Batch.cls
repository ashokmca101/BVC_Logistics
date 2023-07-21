global class Indigo_TrackAWB_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
public List<Linehaul_Tracking__c> insertLineTrack	= new List<Linehaul_Tracking__c>();
    global Database.QueryLocator Start(Database.BatchableContext bc){
      // get LineHaul record whose AWB number is not null, ACR consumed is true and AirLine_Name__c  is 'Indigo'
        String indigoJet = 'Indigo';
         String getAWB =  'SELECT id,Name,AWB_Number__c,AWB_Consumed__c FROM Linehaul__c WHERE AWB_Number__c != null AND AWB_Consumed__c = true AND AirLine_Name__c =: indigoJet';
        return Database.getQueryLocator(getAWB);
    }
    
    global void execute(Database.BatchableContext bc,List<Linehaul__c> awbList){
        system.debug('awbList  ==='+awbList);
        system.debug('awbList  ==='+awbList.size());
         Map<String,String> awbStatusMap = new Map<String,String>();
     // get data from AWB_Tracking_Status__mdt custom metadata based on mentioned developer name
         AWB_Tracking_Status__mdt[] awbStatusList = [SELECT MasterLabel,Indigo_AWB_Status__c 
                                                 FROM AWB_Tracking_Status__mdt 
                                                 WHERE 
                                                 DeveloperName = 'AWB_Booked' OR DeveloperName = 'AWB_Finalized' OR DeveloperName = 'Airline_Deposited' OR 
                                                 DeveloperName = 'On_Route_Airport' OR DeveloperName = 'Pre_Flight_at_Airport' OR DeveloperName = 'Flight_Departed'OR
                                                 DeveloperName = 'Flight_Arrived' OR DeveloperName = 'Pre_Retrieval_at_Airport' OR DeveloperName = 'Retrieved'];
        for(AWB_Tracking_Status__mdt awbStatus : awbStatusList){
            if(awbStatus.Indigo_AWB_Status__c != null && awbStatus.Indigo_AWB_Status__c !=''){
                if(awbStatus.MasterLabel != null && awbStatus.MasterLabel != ''){
     //store meatadata Indigo_AWB_Status__c as ID  and MasterLabel as Value in Map 'awbStatusMap'
                    awbStatusMap.put(awbStatus.Indigo_AWB_Status__c,awbStatus.MasterLabel);
                }
                
            }
            
        }
       /* if(awbBooked.size() > 0){
            awbStatusMap.put(awbBooked[0].Indigo_AWB_Status__c,awbBooked[0].MasterLabel);
        }
        if(awbFinalized.size() > 0){
            awbStatusMap.put(awbFinalized[0].Indigo_AWB_Status__c,awbFinalized[0].MasterLabel);
        }
        if(AirlineDeposit.size() > 0){
            awbStatusMap.put(AirlineDeposit[0].Indigo_AWB_Status__c,AirlineDeposit[0].MasterLabel);
        }
        if(OnRouteAirport.size() > 0){
            awbStatusMap.put(OnRouteAirport[0].Indigo_AWB_Status__c,OnRouteAirport[0].MasterLabel);
        }
        if(PreFlightatAirport.size() > 0){
            awbStatusMap.put(PreFlightatAirport[0].Indigo_AWB_Status__c,PreFlightatAirport[0].MasterLabel);
        }
        if(FlightDeparted.size() > 0){
            awbStatusMap.put(FlightDeparted[0].Indigo_AWB_Status__c,FlightDeparted[0].MasterLabel);
        }
        if(FlightArrived.size() > 0){
            awbStatusMap.put(FlightArrived[0].Indigo_AWB_Status__c,FlightArrived[0].MasterLabel);
        }
        if(PreRetrievalAtAirport.size() > 0){
            awbStatusMap.put(PreRetrievalAtAirport[0].Indigo_AWB_Status__c,PreRetrievalAtAirport[0].MasterLabel);
        }
         if(Retrieved.size() > 0){
            awbStatusMap.put(Retrieved[0].Indigo_AWB_Status__c,Retrieved[0].MasterLabel);
        }

        */
       String TokenNumber = Indigo_TrackAWB_Helper.generateToken();
        if(TokenNumber != '' && TokenNumber != null){
      // if token numnber is not null or empty  then create linehaul record
            insertLineTrack.addALL(Indigo_TrackAWB_Helper.trackAWB(awbList,TokenNumber,awbStatusMap));
        }
        
         if(!insertLineTrack.isEmpty()){
            Database.insert(insertLineTrack,false);
        }
         Map<String,String> awbNumbers = new Map<String,String>();
        Map<Id,String> shipmentRecordMap = new Map<Id,String>();
        List<Shipment__c> updateShipmentList = new List<Shipment__c>();
        List<Shipment_Tracking__c> createTrackingList = new List<Shipment_Tracking__c>();
        Map<Id,String> previousTracking = new Map<Id,String>();
        
       // get Linehaul_Tracking__c record whose CreatedDate is today.
        for(Linehaul_Tracking__c linehaulTrackingRecord: [SELECT Id,Name,CreatedDate,Status__c,Linehaul_Name__c,AWB_Number__c FROM Linehaul_Tracking__c WHERE CreatedDate = today]){
       // store line Linehaul_Tracking__c record's AWB_Number__c as ID and Status__c is Values in awbNumbers map
            awbNumbers.put(linehaulTrackingRecord.AWB_Number__c,linehaulTrackingRecord.Status__c);
            
        }
        if(!awbNumbers.isEmpty()){
      // get AWB_Number__c record where AWB_Code__c is in  awbNumbers map keyset     
            for(AWB_Number__c awbNumberRecord : [SELECT Id,Name,AWB_Code__c,Linehaul_Tracking__c,Shipment__c,Shipment__r.Id FROM AWB_Number__c WHERE AWB_Code__c IN: awbNumbers.keySet()]){
      // get AWB code from awbNumbers map and store in status variable
                String status = awbNumbers.get(awbNumberRecord.AWB_Code__c);
     // add ABW number record shipment as id and status in shipmentRecordMap variable  
                shipmentRecordMap.put(awbNumberRecord.Shipment__r.Id,status);
            }
            
        }
    // get shipment tracking record where id of shipment tracking record in shipmentRecordMap map and add put this shipment tracking record id and location in previousTracking map
        for(Shipment_Tracking__c shipTracking : [SELECT Id,Name,Location__c,Shipment__c FROM Shipment_Tracking__c WHERE Shipment__c IN: shipmentRecordMap.keySet()]){
            previousTracking.put(shipTracking.Id,shipTracking.Location__c);
        }
        if(!shipmentRecordMap.isEmpty()){
    //get shipment record  whose id in shipmentRecordMap map
            for(Shipment__c shipmentRecord : [SELECT Id,Name,Tracking_Status__c,Origin_Hub__c FROM Shipment__c WHERE Id IN: shipmentRecordMap.keySet()]){
    // check previousTracking map shipment id is not equal to the shipmentRecordMap shipmentRecord shipment id if not same then create shipment tracking record     
                if(previousTracking.get(shipmentRecord.Id) != shipmentRecordMap.get(shipmentRecord.Id)){
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
    
    global void finish(Database.BatchableContext bc){}
}