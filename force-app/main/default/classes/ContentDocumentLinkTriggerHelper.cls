public class ContentDocumentLinkTriggerHelper 
{
    public static void Perform(List<ContentDocumentLink> cdlList)
    {
        System.debug('<====== Inside ContentDocumentLinkTriggerHelper ======>');
        List<Delivery__c> DList = new List<Delivery__c>();
        List<Shipment__c> ShipList = new List<Shipment__c>();
        for(ContentDocumentLink cdl :cdlList)
        {             
            System.debug('cdl.ContentDocumentId :'+cdl.ContentDocumentId);        
            Delivery__c d = [select Id,POD__c,POD_Link_Url__c,Shipment__c from Delivery__c where Id=:cdl.LinkedEntityId limit 1];
            //Shipment__c ship = [select Id,POD__c from Shipment__c where Id=:d.Shipment__c limit 1];
            //ContentVersion cv = [select ContentDocumentId,Versiondataurl from ContentVersion where ContentDocumentId =: cdl.ContentDocumentId limit 1]  ;
			//System.debug('CV :'+cv.Versiondataurl); 
            //ContentDistribution cd = [select ContentDownloadUrl, DistributionPublicUrl from ContentDistribution where ContentDocumentId=:cv.ContentDocumentId limit 1];                       
           // System.debug('ContentDownloadUrl  :'+cd.ContentDownloadUrl);            
           // System.debug('DistributionPublicUrl :'+cd.DistributionPublicUrl);            
            System.debug('ContentDocumentLinkTriggerHelper D :'+d);            
           // d.POD_Link_Url__c = cd.ContentDownloadurl;
          // d.POD_Link_Url__c = cv.Versiondataurl;
            d.POD__c = true; 
           // ship.POD__c = true;
            DList.add(d);
            //ShipList.add(ship);
        }
        if(DList.size()>0)
        {
            System.debug('Update Ddelivery ob 11');
            update DList;
            System.debug('Update Ddelivery ob 11');
        }
        if(ShipList.size()>0)
        {
           // update ShipList;
        }
    }
    public static void updateSBPod(List<ContentDocumentLink> cdlList)
    {
        System.debug('<====== Inside ContentDocumentLinkTriggerHelper ======>');
        List<Secure_Bag__c> SBList = new List<Secure_Bag__c>();
        List<Shipment__c> ShipList1 = new List<Shipment__c>();
        for(ContentDocumentLink cdl :cdlList)
        {            
            //ContentDistribution cd = [select ContentDownloadurl from ContentDistribution where ContentDocumentId=: cdl.ContentDocumentId limit 1];
            //System.debug('ContentDocumentLinkTriggerHelper CD :'+cd);    
            System.debug('cdl.ContentDocumentId :'+cdl.ContentDocumentId);        
            Secure_Bag__c sb = [select Id,POD__c,Shipment__c from Secure_Bag__c where Id=:cdl.LinkedEntityId limit 1];
            Shipment__c ship = [select Id,SecurebagPhoto__c from Shipment__c where Id=:sb.Shipment__c limit 1];
            System.debug('ContentDocumentLinkTriggerHelper D :'+sb); 
            System.debug('ContentDocumentLinkTriggerHelper ship :'+ship); 
            // d.POD_Link_Url__c = cd.ContentDownloadurl;
            sb.POD__c = true; 
            SBList.add(sb);
            ship.SecurebagPhoto__c = true;
            ShipList1.add(ship);
            
        }
        if(SBList.size()>0)
        {
            update SBList;
            if(ShipList1.size()>0)
            {
                System.debug('SHIPMENT UPLOAD');
                //update ShipList1;
            } 
        }
        
    }  
    
    public static void updateShip(List<ContentDocumentLink> cdlList)
    {
        System.debug('<====== Inside updateShip ======>');
         System.debug('<====== Inside updateShip ======> cdlList :'+cdlList);
        List<Shipment__c> ShipList1 = new List<Shipment__c>();
        for(ContentDocumentLink cdl :cdlList)
        {   
            System.debug('cdl.ContentDocumentId :'+cdl.ContentDocumentId);             
            ContentDocument cdoc = [select Title from ContentDocument where Id=:cdl.ContentDocumentId limit 1];
            System.debug('cdl.cdoc :'+cdoc);
            if(cdoc.title.contains('Signature'))
            {
                System.debug('Signature Matches Here');                
                Shipment__c ship = [select Id,SignaturePhoto__c from Shipment__c where Id=:cdl.LinkedEntityId limit 1];
                System.debug('ContentDocumentLinkTriggerHelper ship :'+ship); 
                ship.SignaturePhoto__c = true;
                ShipList1.add(ship);                
            }
        }
        if(ShipList1.size()>0)
        {
            System.debug('SHIPMENT UPLOAD');
            update ShipList1;
        }        
    }      
}