public class createAWB_linehaul_customPage {
    
    @AuraEnabled
    public static List<String> getAvailableAwb(string origin, string destination, dateTime flightDate){
        List<String> linehaulList = new List<String>();
        Date indigoDate = date.valueOf(flightDate);
        for(Linehaul__c getAWB : [SELECT Id, Name, origin__c, destination__c, Flight_Date__c, From__c,AWB_Number__c FROM Linehaul__c 
                                  where origin__c =: origin and destination__c =: destination 
                                  AND (Flight_Date__c =: indigoDate OR From__c =: flightDate)]){
            linehaulList.add(getAWB.AWB_Number__c);
        }
            return linehaulList;
    }
    
    
}