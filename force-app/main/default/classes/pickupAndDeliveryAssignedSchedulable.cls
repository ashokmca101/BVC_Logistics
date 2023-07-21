global class pickupAndDeliveryAssignedSchedulable implements Schedulable {
    
     global void execute(SchedulableContext sc) {
        try{
           pickupAndDeliveryAssigned Rec = new pickupAndDeliveryAssigned();
           Database.executeBatch(Rec);
        } catch(Exception e)
        {}
    }


}