trigger updateFlightScheduleName on Flight_Schedule__c (before insert, before update) {
    
    Set<Id>airlineId=new Set<Id>();
    for(Flight_Schedule__c fs:trigger.new){
        if(fs.Airline_Name__c!=null && fs.Scheduled_Departure_Time__c!=null ){
            airlineId.add(fs.Airline_Name__c);
        }
    }
    Map<Id,String>mapofAirlineVsName=new Map<Id,String>();
    for(Airline__c air:[Select Id,name FROM Airline__c WHERE Id IN:airlineId]){
        if(!mapofAirlineVsName.containskey(air.id)){
            mapofAirlineVsName.put(air.id,air.name);
        }
        //system.debug('==Airline==='+mapofAirlineVsName.values());
    }
    for(Flight_Schedule__c fls:trigger.new){
        if(fls.Scheduled_Departure_Time__c != null && fls.Airline_Name__c !=null && mapofAirlineVsName.containsKey(fls.Airline_Name__c)){
            String newHour=String.valueOf(fls.Scheduled_Departure_Time__c.hour());
            //system.debug('==Hour==='+newHour);
            String newMinute=String.valueOf(fls.Scheduled_Departure_Time__c.minute());
            //system.debug('==Min==='+newMinute);
            fls.Name=mapofAirlineVsName.get(fls.Airline_Name__c)+' '+ '-' + ' ' + newHour + ':' + newMinute;
            //system.debug('==Name==='+fls.Name);
        }
    }
}