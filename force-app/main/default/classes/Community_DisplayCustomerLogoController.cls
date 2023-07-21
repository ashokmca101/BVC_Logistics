public class Community_DisplayCustomerLogoController {
    @AuraEnabled 
    public static string fetchLogoURl(){
        
        String picUrl = '';
        List<ContentDocumentLink> toUpdate = new List<ContentDocumentLink>();    
		system.debug('Userinfo.getUserId():::'+Userinfo.getUserId());
        Set<String> imageExtensions = new Set<String>{'bmp', 'gif', 'jpeg', 'jpg', 'png', 'svg+xml', 'tiff', 'vnd.adobe.photoshop', 'vnd.dwg', 'x-photoshop'};
        User currentusr= [Select id,Name,Contact.Accountid,ContactId From User Where Id =:Userinfo.getUserId()];
        system.debug('currentusr::'+currentusr);
        String accid=currentusr.Contact.Accountid;
        system.debug('ContactId::'+currentusr.ContactId);
        system.debug('accid::'+accid);
        /*If(Test.isRunningTest()){
         for(ContentDocumentLink link : [select Id, Visibility from ContentDocumentLink where linkedentityid = :accid AND Visibility != 'AllUsers']) {
            link.Visibility = 'AllUsers';
            toUpdate.add(link);
        }
        update toUpdate;
    	}*/
        // Fetch current account logo
        List<ContentDocumentLink> cdl = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink where linkedentityid =:accid AND ContentDocument.FileType IN :imageExtensions AND ContentDocument.Title='Company_Logo'];
        integer recentlogoindex=cdl.size()-1;//to display latest uploaded logo
        system.debug('--= '+cdl+' Size= '+cdl.size());
        system.debug('+++++=cdl '+cdl);
        ContentVersion cv = [select id from contentversion where contentdocumentid = :cdl[recentlogoindex].contentdocument.id];
        system.debug('+++++=cv '+cv.Id);
        //Generating public URL
        ContentDistribution cd = new ContentDistribution();
        cd.Name = currentusr.Name;
        cd.ContentVersionId = cv.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        system.debug('+++++=cd '+cd.Id);
        ContentDistribution cDis = [Select Id, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl,ContentVersionId from ContentDistribution where Id=:cd.Id];
        System.debug(cDis);
        picUrl = cDis.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
        picUrl = picUrl.replace('&ids' , '&versionId');
        System.debug('URL = '+picUrl);
        return picUrl;
    }

}