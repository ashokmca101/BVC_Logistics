/*
  Author: Dipak Rakh
  Description : Class Handler to generate file public link
*/
public class TMS_ContentTriggerHandler {
    
	public static void createPublicLinkForFile(List<ContentVersion> contentVersions){
        ContentDistribution[] distributionsToInsert = new List<ContentDistribution>();
       	for(ContentVersion objContentVersion : contentVersions){
            //if image uploaded then only create public link
            /*if(objContentVersion.FileType.toLowerCase()=='jpg'){
                system.debug('objContentVersion.FileExtension.toLowerCase():' + objContentVersion.FileType);
                
                distributionsToInsert.add(createContentDistribution(objContentVersion.Id));
            }*/
            system.debug('objContentVersion.FileExtension.toLowerCase():' + objContentVersion.FileType);
            distributionsToInsert.add(createContentDistribution(objContentVersion.Id));
        }
        if(!distributionsToInsert.isEmpty())
        {
        	insert distributionsToInsert;
        }
    }
    
    public static ContentDistribution createContentDistribution(Id contentVersionId){
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = contentVersionId;
        newDist.Name = 'External Link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        newDist.PreferencesAllowOriginalDownload=true;
        system.debug('createContentDistribution creted');
        return newDist;
    }
    public static void createContentDocumentLink(List<ContentVersion> contentVersionList){
        	list<ContentDocumentLink> ContentDocumentLinkList = new list<ContentDocumentLink> ();
        	list<id> Idlist = new list<id>();
        list<Account> acclist = new list<Account>();
        for(ContentVersion CL:contentVersionList){
            if(CL.Customer__c!=null){
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = CL.Customer__c; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = CL.ContentDocumentId;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            account a = new account(id=CL.Customer__c);
            a.docLinkId__c= CL.ContentDocumentId;
            acclist.add(a);
             Idlist.add(CL.ContentDocumentId);
            ContentDocumentLinkList.add(conDocLink);
            
            }
        }
            insert ContentDocumentLinkList;
        	update acclist;
        
     /*   list<ContentDocument> ContentDocumentList = [select id from ContentDocument where id IN: Idlist];
        map<id,ContentDocument> mapCd = new map<id,ContentDocument>(ContentDocumentList);
        list<contentDistribution> condList = [select id, ContentDownloadUrl from contentDistribution where id IN: mapCd.keySet()];
        map<id,String> mapIDURL = new map<id,String>();
        for(contentDistribution cd:condList){
            mapIDURL.put(cd.ContentDocumentId,cd.ContentDownloadUrl);
            system.debug('map of ContentDocumentId__________ '+cd.ContentDocumentId);
            system.debug('map of ContentDownloadUrl+++++++++++++ '+cd.ContentDownloadUrl);
        }
        list<Account> acclist = new list<Account>();
        for(ContentVersion CL:contentVersionList){
            account a = new account(id=CL.Customer__c);
           // a.Description= mapIDURL.get(CL.ContentDocumentId);
            a.Description= CL.ContentDocumentId;
            a.link_generated_date__c= system.today();
            acclist.add(a);
            system.debug('CL ContentDocumentId========== '+CL.ContentDocumentId);
        }
        update acclist;*/
    }
}