@isTest
public class MultipleFileUploadonShipmentContTest {
    
    private static testmethod void testcreate(){
     test.startTest();
        
        Shipment__c shipments = new Shipment__c();
        shipments.Customer_Product_Category__c = 'SilverSHIP';

        insert shipments;
        
        ContentVersion content=new ContentVersion(); 
        
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.origin = 'H';
        
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        
        contentlink.LinkedEntityId = shipments.id;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
               
        insert contentlink;
       
       
        try{
            MultipleFileUploadonShipmentController.getAllFilesOnsObjectRecord(shipments.Id);
        //    system.assert(false, 'an insertion is happen successfully ');
        }catch (exception e){
           system.assertEquals('you cannot use null as paramater',e.getMessage() ,'incorrect exception message return');
        }
    Test.stopTest();
    }

}