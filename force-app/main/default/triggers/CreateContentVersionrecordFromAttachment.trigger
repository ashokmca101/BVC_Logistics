trigger CreateContentVersionrecordFromAttachment on Attachment (after insert) {
   
    List<blng__Invoice__c> invoiceList = new List<blng__Invoice__c>();
    set<Id> AttachId = new set<Id>();
    
    for(Attachment attach : Trigger.New){
        //Check if added attachment is related to Invoice or not
        if(attach.ParentId.getSobjectType() == blng__Invoice__c.SobjectType){
            AttachId.add(attach.ParentId);
        }
    }
       
      Map<string,contentVersion> contVerMap = new Map<string,contentVersion>();
    
     if(AttachId.size()>0){
        List<ContentVersion> contVersionList = new List<ContentVersion>();
         For(Attachment att : [SELECT Id,ParentId,Name,Body,OwnerId,Description FROM Attachment where ParentId=:AttachId LIMIT 1]){
            ContentVersion objCntVersion = new ContentVersion();
             objCntVersion.Title = att.Name;
             objCntVersion.PathOnClient =  att.Name;
             objCntVersion.VersionData = att.Body;
             objCntVersion.Description = att.Description;
             objCntVersion.SharingPrivacy = 'N'; // Can be always public.
             objCntVersion.FirstPublishLocationId = att.ParentId; // Parent Id             
             // To avoid "Documents in a user's private library must always be owned by that user" error.             
          //   objCntVersion.FirstPublishLocationId = att.OwnerId;
             contVersionList.add(objCntVersion);
         }
         insert contVersionList ;
    }
}