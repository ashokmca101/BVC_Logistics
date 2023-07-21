public class UpdatePickupUsingSB {
  @InvocableMethod(label='UpdatePickupUsingSB' description='Update Pickup Before Inserting SB.')
  public static void getAccountNames(List<ID> ids) {        
        Integer temp = 0; 
        Integer CountSB=0;      
	Shipment_Tracking__c tr = [select Id,Shipment__c,Location__c from Shipment_Tracking__c where Id=:ids[0]];
    Shipment__c sh = [select id,Tracking_Status__c from Shipment__c where Id=:tr.Shipment__c limit 1];      
      
                 List<Secure_Bag__c> SBList = [select Id,Current_Scan_Loction__c from Secure_Bag__c where Shipment__c =: sh.Id];
                 if(SBList.size()>0)
                 {
                     System.debug('11.SBList Size :'+SBList.size());
                     temp = SBList.size();
                     for(Secure_Bag__c sb : SBList)
                     {
                         System.debug('11.SBList Rec :'+sb);
                         System.debug('11.SBList Rec Current_Scan_Loction__c :'+sb.Current_Scan_Loction__c);
                         System.debug('22.Test st.Location__c :'+tr.Location__c);
                         if(sb.Current_Scan_Loction__c == tr.Location__c)
                         {
                             System.debug('11.Test sb.Current_Scan_Loction__c :'+sb.Current_Scan_Loction__c);
                             System.debug('11.Test st.Location__c :'+tr.Location__c);
                             CountSB = CountSB + 1;
                         }
                     }
                     if(CountSB == temp)
                     {
                         System.debug('11.Test  CountSB :'+CountSB);
                         System.debug('11.Test  temp :'+temp);
						 sh.Tracking_Status__c =tr.Location__c;  
                         update sh;
                     }
                 }                 
      
      
      /*
  Pickup__c pk = [SELECT Id,Pickup_Status__c FROM Pickup__c WHERE Id =:ids[0]];
      if(pk.Pickup_Status__c!='Completed')
      {
         pk.Pickup_Status__c='Completed ';
          update pk;
      }
      */
      
      
  }
}