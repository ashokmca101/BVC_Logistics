public class updateShipment 
{
    @AuraEnabled
  public static void updateShip(String rId,string DStatus)
  {
      Shipment__c  sh = [select Id,Flag__c,Delivery_Remarks__c  from Shipment__c where Id=:rId limit 1];
      System.debug('11SH  :'+sh);      
      sh.Flag__c = 0;
      sh.Delivery_Remarks__c = DStatus;
      System.debug('SH :'+sh);
      update sh;
  }
    
  @AuraEnabled
  public static Shipment__c getRecord(String rId)
  {
      return [select Id,Flag__c from Shipment__c where Id=:rId limit 1];
  }
}