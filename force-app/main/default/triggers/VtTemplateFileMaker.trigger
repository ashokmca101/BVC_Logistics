trigger VtTemplateFileMaker on rsplus__RSP_Templates__c (before update) {
    
    set<string> fileIDvsTempId= new  set<string>();
    for(rsplus__RSP_Templates__c t : trigger.new){
        if(t.rsplus__File_Id__c!=null &&  t.rsplus__File_Id__c!=trigger.oldmap.get(t.id).rsplus__File_Id__c){
            fileIDvsTempId.add(t.rsplus__File_Id__c);    
        }
    }    
    
    map<string,ContentDistribution> urlVsContVer=new map<string,ContentDistribution>();
    
    if(fileIDvsTempId.size()>0){
        list<ContentDistribution> cdlist = new list<ContentDistribution>();
        for(ContentVersion testContentInsert : [select id, ContentDocumentId from ContentVersion WHERE ContentDocumentId =: fileIDvsTempId or id=: fileIDvsTempId order by createddate limit:fileIDvsTempId.size()]){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = testContentInsert.id;
            cd.ContentVersionId = testContentInsert.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            cd.PreferencesAllowPDFDownload=true;
            cdlist.add(cd); 
        }    
        
        list<Database.saveresult> ds= database.insert(cdlist,false);
        set<id> vcset=new set<id>();
        for(Database.saveresult d : ds){
            if(d.isSuccess()==true)
                vcset.add(d.getid());
            else{
                system.debug('Error '+d.getErrors() );
            }
       }
        
        if(vcset.size() > 0) {
            for(ContentDistribution cd: [select id,Name,DistributionPublicUrl,ContentDownloadUrl,PdfDownloadUrl,ContentVersion.ContentDocumentId,
                                         ContentVersion.Title,ContentVersion.ContentSize,ContentVersion.FileExtension, ContentVersion.id,
                                         ContentVersion.FileType from  ContentDistribution where id=:vcset]){
                                             
                                             urlVsContVer.put(cd.ContentVersion.ContentDocumentId,cd);
                                             urlVsContVer.put(cd.ContentVersion.id,cd);
                                             
                                         }    
        }
        
        
        
    }
    if(urlVsContVer.size() > 0){
      for(rsplus__RSP_Templates__c t : trigger.new){
        if(t.rsplus__File_Id__c!=null && trigger.oldmap.get(t.id).rsplus__File_Id__c!=t.rsplus__File_Id__c){
        if(urlVsContVer.get(t.rsplus__File_Id__c)!=null)   
         t.rsplus__Media_Json__c= '[{"viewfileurl":null,"url":"'+urlVsContVer.get(t.rsplus__File_Id__c).ContentDownloadUrl+'","internalUrl":null,"hid":null,"filesize":"'+string.valueof(urlVsContVer.get(t.rsplus__File_Id__c).ContentVersion.ContentSize)+'","filename":"'+urlVsContVer.get(t.rsplus__File_Id__c).ContentVersion.Title+'","eDmsId":null,"ContentType":"'+urlVsContVer.get(t.rsplus__File_Id__c).ContentVersion.FileExtension+'"}]';   
        }
    }    
    }
     integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
    
}