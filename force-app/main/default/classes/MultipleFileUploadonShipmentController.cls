/*

   Class Name       :   MultipleFileUploadonShipmentController
   Description      :   Controller Class to handle basic functions for Generic Component to Upload Files like - 
   Description   	:   Method that provides all existing Files attached on sObject via sObject Id
   Input Parameter	:	ID
   return type   	:   List<ContentDocument>  
   Developer Name   :   Mr.Sangale Govind    Created Date:13/01/2023
*/
public class MultipleFileUploadonShipmentController {
      
  @AuraEnabled
    public static List<ContentDocument> getAllFilesOnsObjectRecord(Id sObjectId){
        List<ContentDocument> contentDocumentListToReturn = new List<ContentDocument>();
        List<ContentDocumentLink> contentDocLinkOnsObjectList = new List<ContentDocumentLink>();

    //query for the ContentDocumentLink for provided sObject ID
        contentDocLinkOnsObjectList = [Select id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId =: sObjectId];
        Set<Id> contentDocIdSet = new Set<Id>();

    //check if the ContentDocumentLinks for provided sObject Id is found
        if(contentDocLinkOnsObjectList != null && !contentDocLinkOnsObjectList.isEmpty()){
            for(ContentDocumentLink conDocLink : contentDocLinkOnsObjectList){
                //get contentDocument Ids from the ContentDocumentLinks found on the sObject record
                contentDocIdSet.add(conDocLink.ContentDocumentId);
            }
        }

    //check contentDocumentIds Set is not empty
        if(contentDocIdSet != null && !contentDocIdSet.isEmpty()){
    //get all ContentDocuments on the sObject record
            contentDocumentListToReturn = [Select id, Title From ContentDocument Where ID IN :contentDocIdSet];
        }

   //check if the contentDocument List that needs to be returned is not Empty
        if(contentDocumentListToReturn != null && !contentDocumentListToReturn.isEmpty()){
            return contentDocumentListToReturn;
        } else{
            return null;
        }
}
}