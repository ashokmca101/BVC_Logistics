global class pickupAndDeliveryAssigned implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Delivery_Route_Assigned_To__c,CreatedDate, Name,Pickup_Route_Assigned_To__c From Pickup_Delivery_Route__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Pickup_Delivery_Route__c> pickupRecList) {
        List<Pickup_Delivery_Route__c> pickupList = new List<Pickup_Delivery_Route__c>();
        for(Pickup_Delivery_Route__c pickUpIteration : pickupRecList)
        {
           
            if(pickUpIteration.Pickup_Route_Assigned_To__c != Null || pickUpIteration.Delivery_Route_Assigned_To__c != null)
            {
                if(pickUpIteration.CreatedDate < System.today())
                {
                    pickUpIteration.Pickup_Route_Assigned_To__c = null;
                    pickUpIteration.Delivery_Route_Assigned_To__c= null;
                    pickupList.add(pickUpIteration);
                }
      
            }
            
            if(pickupList.size() > 0)
            {
                List<Database.SaveResult> updateResults = Database.update(pickupList, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (updateResults.get(i).isSuccess()){
                        updateResults.get(i).getId();
                        System.debug('Success Results:'+ updateResults.get(i).getId());
                    }else if (!updateResults.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        System.debug('Message::'+failedDML);
                        system.debug('Failed ID'+pickupList.get(i).Id);
                    }
                }
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}