trigger QuoteTriggerBVC on SBQQ__Quote__c (after insert,After update,before update) {

    
    if(Trigger.isAfter && Trigger.isInsert){
        for ( SBQQ__Quote__c QT: Trigger.new ){
            if(QT.Is_Uploaded__c==false && QT.Shipment__c!=null && (QT.BVC_Service__c=='eSHIP' || QT.BVC_Service__c=='BATH')){
              //Quote trigger  create Quote line items 
              QuoteTriggerBVCHelper.insertRecord(trigger.new);  
            }
            if(QT.Shipment__c==null){
               QuoteTriggerBVCHelper.StoreAnnetureFileinQuote(trigger.new);  
            }
        }     
       
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
         for ( SBQQ__Quote__c QT: Trigger.new ){         
                if ( QT.SBQQ__Status__c != Trigger.oldMap.get( QT.Id ).SBQQ__Status__c && QT.Is_Shipment__c==true){                    
                    QuoteTriggerBVCHelper.UpdateQuoteStatus(trigger.newMap);
                    if(QT.SBQQ__Status__c.contains('Ordered')){
                        // Mapp Customer with bath custize price after ordered
                      QuoteTriggerBVCHelper.createBathEshipStandardPrice(trigger.new);   
                    }  
                }
           }
    
    }
     //Quote trigger  create Order 
    if(Trigger.isAfter && Trigger.isUpdate){      
       set<id> quoteid = new set<id>();     
       for ( SBQQ__Quote__c QT: Trigger.new ){    
           quoteid.add(QT.id); 
           if(quoteid.size() > 0 &&  QuoteTriggerBVCHelper.stopitration){
               QuoteTriggerBVCHelper.stopitration = false;
               QuoteTriggerBVCHelper.createOrder(quoteid );
           } 
       }       
    }
}