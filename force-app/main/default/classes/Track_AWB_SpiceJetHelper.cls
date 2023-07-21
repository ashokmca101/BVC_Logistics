public class Track_AWB_SpiceJetHelper {

    public static List<Linehaul_Tracking__c> trackAWBspicejet(List<Linehaul__c> awbList,Map<String,String> awbStatusMap){
         String status = '';
       
        List<Linehaul_Tracking__c> insertLinehaulTrack	= new List<Linehaul_Tracking__c>();
        
      //get Airline_API__mdt  custom metadata where DeveloperName  is Spice_Jet_Track_AWB
            Airline_API__mdt[] spiceJetAirlineTrack = [SELECT Endpoint__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Track_AWB'];
      //create variables to store metadata values
            String endpointtrack = spiceJetAirlineTrack[0].Endpoint__c;
            String body = '';
            String mode = 'BVC';
    // send http GET request to the endpoint containing  AWB_Number__c from linehaul record         
            for(Linehaul__c awblinehaul : awbList){
                Http http = new Http();
            Http httptrack = new Http();
        HttpRequest requesttrack = new HttpRequest();
        body = endpointtrack+awblinehaul.AWB_Number__c+'&mode='+mode;
        requesttrack.setEndpoint(body);
        requesttrack.setMethod('GET');
        system.debug('Body of Track AWB=== '+body);
       
        HttpResponse responsetrack= http.send(requesttrack);
            if(responsetrack.getStatusCode() != 200){
               System.debug('The status code returned was not expected: ' + responsetrack.getStatusCode() + ' ' + responsetrack.getStatus());

            }
            else{
        // deserialize response stored in  responsetrack  variable and store that deserialized data in trackwrapper  variable of wrapper class      
                SpicejetTrackAWBwrapper trackwrapper =  SpicejetTrackAWBwrapper.parse(responsetrack.getBody());
               system.debug('trackwrapper==='+trackwrapper);
                system.debug('trackwrapper==='+trackwrapper.Result.Task_tracker);
                for(SpicejetTrackAWBwrapper.Task_tracker getStatus :  trackwrapper.Result.Task_tracker){
        // create Linehaul_Tracking__c record from the repsonse 
                    Linehaul_Tracking__c lineTrackrecord = new Linehaul_Tracking__c();
                    
                    if(awbStatusMap.size() > 0 && awbStatusMap.containsKey(getStatus.status_detail)){
                    lineTrackrecord.Status__c = awbStatusMap.get(getStatus.status_detail);
                    }
                   
                    lineTrackrecord.Status_Id__c = string.valueOf(getStatus.status_id);
                    lineTrackrecord.Airport_Code__c = getStatus.airport_code;
             		lineTrackrecord.Flight_Detail__c = getStatus.flight_details;
        	      	 lineTrackrecord.Event_Datetime__c	=	DateTime.valueOf(string.valueof(getStatus.event_date_time));
                    lineTrackrecord.Weight__c = getStatus.weight;
                    system.debug('Linehaul record found'+awblinehaul.Id);
                  	lineTrackrecord.Linehaul_Name__c = awblinehaul.Id;
                    insertLinehaulTrack.add(lineTrackrecord);
                }
            }
        }
     
        return insertLinehaulTrack;
    }
}