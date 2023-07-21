public class ContentDocumentTriggerHelper 
{
    // method to update shipment Pod Link
    /*
    public static void UpdateShipPOD(List<ContentDocumentLink> ccList)
    {
        List<Delivery__c> DList = new List<Delivery__c>();
        List<Shipment__c> ShipList = new List<Shipment__c>();        
        if(ccList.size()>0)
        {
            for(ContentDocumentLink c : ccList)
            {
                System.debug('110. c.LinkedEntityId :'+c.LinkedEntityId);
                if(c.LinkedEntityId!=null && string.valueOf(c.LinkedEntityId).startsWithIgnoreCase('a2p') )
                {
                    System.debug('220. c.LinkedEntityId :'+c.LinkedEntityId);
                    Shipment__c ship = [select Id,SecurebagPhoto__c from Shipment__c where Id=:c.LinkedEntityId limit 1];
                    ship.SecurebagPhoto__c = true;
                    ShipList.add(ship);
                    System.debug('ContentDocumentTriggerHelper ship :'+ship);            
                }
            }
        }
        if(ShipList.size()>0)
        {
            System.debug('Before Update DList :'+ShipList);
            update ShipList;
        }
        
    }
    */
    // a method to unchek the PODCheckbo on Delivery Object
    public static void CD_Deletion(List<ContentDocumentLink> ccList)
    {
        List<Delivery__c> DList = new List<Delivery__c>();
        List<Shipment__c> ShipList = new List<Shipment__c>();
        System.debug('ContentDocumentTriggerHelper');                
        System.debug('ContentDocumentTriggerHelper ccList :'+ccList);
        if(ccList.size()>0)
        {
            for(ContentDocumentLink c : ccList)
            {
                System.debug('11. c.LinkedEntityId :'+c.LinkedEntityId);
                if(c.LinkedEntityId!=null && string.valueOf(c.LinkedEntityId).startsWithIgnoreCase('a5U') )
                {
                    System.debug('22. c.LinkedEntityId :'+c.LinkedEntityId);
                    List<ContentDocumentLink> cdlList =[select Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:c.LinkedEntityId ];
                    if(cdlList.size()>1)
                    {}
                    else
                    {
                        
                        Delivery__c d = [select Id,POD__c,POD_Link_Url__c,Shipment__c from Delivery__c where Id=:c.LinkedEntityId limit 1];
                       // Shipment__c ship = [select Id,POD__c,POD_Link_Url__c from Shipment__c where Id=:d.Shipment__c limit 1];
                        d.POD__c = false;
                        d.POD_Link_Url__c = '';
                       // ship.POD__c = false;
                       // ship.POD_Link_Url__c = '';                    
                        DList.add(d);                         
                        //ShipList.add(ship);
                        System.debug('ContentDocumentTriggerHelper D :'+d);            
                        // d.POD_Link_Url__c = '';
                    }
                }
            }
        }
        
        if(DList.size()>0)
        {
            System.debug('Before Update DList :'+DList);
            update DList;
        }   
        if(ShipList.size()>0)
        {
            System.debug('Before Update DList :'+ShipList);
           // update ShipList;
        }           
        
    }
    
    // a method to unchek the PODCheckbo on Secure Bag Object
    public static void CD_Deletion1(List<ContentDocumentLink> ccList)
    {
        List<Secure_Bag__c> SBList = new List<Secure_Bag__c>();
         List<Shipment__c> ShipList = new List<Shipment__c>();
        System.debug('ContentDocumentTriggerHelper');                
        System.debug('ContentDocumentTriggerHelper ccList :'+ccList);
        if(ccList.size()>0)
        {
            for(ContentDocumentLink c : ccList)
            {
                System.debug('11. c.LinkedEntityId :'+c.LinkedEntityId);
                if(c.LinkedEntityId!=null && string.valueOf(c.LinkedEntityId).startsWithIgnoreCase('a4D') )
                {
                    System.debug('22. c.LinkedEntityId :'+c.LinkedEntityId);
                    List<ContentDocumentLink> cdlList =[select Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:c.LinkedEntityId ];
                    if(cdlList.size()>1)
                    {}
                    else
                    {
                        
                        Secure_Bag__c sb = [select Id,POD__c,Shipment__c from Secure_Bag__c where Id=:c.LinkedEntityId limit 1];
                      //  Shipment__c ship = [select Id,SecurebagPhoto__c from Shipment__c where Id=:sb.Shipment__c limit 1];
                        sb.POD__c = false;
                       // ship.SecurebagPhoto__c = false;
                       // ShipList.add(ship);
                        SBList.add(sb);                         
                        System.debug('ContentDocumentTriggerHelper sb :'+sb);            
                    }
                }
            }
        }
        
        if(SBList.size()>0)
        {
            System.debug('Before Update DList :'+SBList);
            update SBList;
            //if(ShipList.size()>0){ update ShipList;}
        }        
    }
    
}