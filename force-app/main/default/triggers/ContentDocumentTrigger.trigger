trigger ContentDocumentTrigger on ContentDocument (before delete,after insert) 
{
    List<String> cdList =new List<String>();
    /*
    List<String> cdList1 =new List<String>();
    
    if(trigger.isInsert && trigger.isAfter)
    {
        System.debug('Before Insert Content Document');
        for(ContentDocument cd: trigger.new)
        {
            System.debug('cd.title :'+cd.title);
            if(cd.title.contains('Signature'))
            {
                System.debug('Signature Matches Here');
                System.debug('CD :'+cd.Id);
                cdList1.add(cd.Id);                            
            }
            else
            {
                System.debug('Signature Dont Matches Here');
            }
        }
        if(cdList1.size()>0)
        {
            List<ContentDocumentLink> cdl = [select Id,ContentDocumentId,LinkedEntityId,LinkedEntity.Name,ContentDocument.Title from ContentDocumentLink where ContentDocumentId IN :cdList1];
            //List<ContentDistribution> cdd = [select Id from ContentDistribution where ];
            System.debug('Update Shipment 55. cdl :'+cdl);        
             ContentDocumentTriggerHelper.UpdateShipPOD(cdl);
            //ContentDocumentTriggerHelper.CD_Deletion1(cdl);
        }
        
    }
    */
    if(trigger.isDelete && trigger.isBefore)
    {
        System.debug('ContentDocumentTrigger');
        for(ContentDocument cd: trigger.old)
        {
            System.debug('CD :'+cd.Id);
            cdList.add(cd.Id);
        }
        if(cdList.size()>0)
        {
            List<ContentDocumentLink> cdl = [select Id,ContentDocumentId,LinkedEntityId,LinkedEntity.Name,ContentDocument.Title from ContentDocumentLink where ContentDocumentId IN :cdList];
            //List<ContentDistribution> cdd = [select Id from ContentDistribution where ];
            System.debug('55. cdl :'+cdl);        
            ContentDocumentTriggerHelper.CD_Deletion(cdl);
            ContentDocumentTriggerHelper.CD_Deletion1(cdl);
        }
        
    }
}