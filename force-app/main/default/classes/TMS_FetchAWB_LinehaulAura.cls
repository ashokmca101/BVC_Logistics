// This class is used for Fetch AWB button on custom Linehaul Aura component
public class TMS_FetchAWB_LinehaulAura {

    public static void getcreatedAWB(String origin, String destination, Datetime flightDate){
        List<Linehaul__c> linehaulList = new List<Linehaul__c>();
  //get Linehaul record with origin,destination and airline name.
        for(Linehaul__c existingAWB : [SELECT Id,Name,Origin__c,AirLine_Name__c,Destination__c,From__c FROM Linehaul__c WHERE Origin__c =:origin AND Destination__c =: destination AND From__c =: flightDate]){
            linehaulList.add(existingAWB);
        }
        if(linehaulList.isEmpty()){
            TMS_FetchAWB_LinehaulAura.createAWB(origin,destination,flightDate);
        }
    }
    
    public static void createAWB(String origin, String destination, Datetime flightDate){
        
    }
  
}