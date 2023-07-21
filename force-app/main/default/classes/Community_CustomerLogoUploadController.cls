public class Community_CustomerLogoUploadController {
    @AuraEnabled 
    public static string getCurrentUserAccountId(){
        User currentusr= [Select id,Name,Contact.Accountid From User Where Id =:Userinfo.getUserId()];
        return currentusr.Contact.Accountid;
    }
    @AuraEnabled 
    public static void logoAccessToallUser(String logoId) {
        List<ContentDocumentLink> toUpdateCDL = new List<ContentDocumentLink>(); 
        List<ContentDocument> toUpdateCD = new List<ContentDocument>();
        
        for(ContentDocument doc : [select Id, Title from ContentDocument where Id = :logoId]) {
            doc.Title ='Company_Logo';
            toUpdateCD.add(doc);
            system.debug('updated title='+toUpdateCD);
        }
        
        for(ContentDocumentLink link : [select Id, Visibility from ContentDocumentLink where ContentDocumentId = :logoId]) {
            link.Visibility = 'AllUsers';
            toUpdateCDL.add(link);
            system.debug('updated visibility='+toUpdateCDL);
        }
        Try {
            update toUpdateCDL;
            update toUpdateCD;
        }
        Catch(Exception ex) {
            system.debug(ex.getMessage());
        }
        
    }
}