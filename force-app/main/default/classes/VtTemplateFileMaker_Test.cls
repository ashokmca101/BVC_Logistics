@isTest
public class VtTemplateFileMaker_Test {

    testmethod static void TestOne(){
        rsplus__RSP_Templates__c t = new rsplus__RSP_Templates__c();
        t.rsplus__Template_name__c='Test';
        t.rsplus__Message_Body__c='Hi {!name}';
        t.rsplus__File_Id__c=null;
        insert t;
            
        ContentVersion cv=new Contentversion();
        cv.title='ABCd';
        cv.PathOnClient ='tests';
        Blob b=Blob.valueOf('Unit Test Attachment Bodys');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv; 
      

         
        string dsid =[select id,ContentDocumentId from contentversion where id=:cv.id limit 1].ContentDocumentId;
     
             
        rsplus__RSP_Templates__c td = new rsplus__RSP_Templates__c();
        td.id=t.id;
        td.rsplus__File_Id__c=dsid;       
        update td;
        system.assertnotEquals(t.id, null);
            
         
                
    }

}