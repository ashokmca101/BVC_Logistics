@isTest
public class CreateContentVersionRecordFrAttachTest {
 
    testmethod static void TestOne(){
          
        Account Acc = New Account();
            Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
            Acc.BVC_Company_Type__c = 'Domestic';
            Acc.Customer_Status__c = 'Active';
            Acc.Category__c = 'Manufacturer';
            Acc.Type_Of_Customer__c = 'Both';
            Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
            Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
            Acc.Phone = '94746367837';
            Acc.First_Name__c = 'billing firstname';               
            Acc.Last_Name__c = 'billing lst name';
         // Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
            Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
            Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';      
            Insert Acc;
                  
        blng__Invoice__c invRec = new blng__Invoice__c();           
            invRec.Short_URL__c = 'www.google.com';
            invRec.Invoice_Type__c = 'Tax Invoice';
            invRec.blng__Account__c = Acc.Id;
            insert invRec;
        
        Attachment attach = new Attachment();
           attach.Name = 'Invoice Pdf';
           attach.Description = 'This is attachment of invoice record';
           attach.ContentType = 'Pdf';
           Blob c=Blob.valueOf('Unit Test Attachment Bodys');
           attach.Body =EncodingUtil.base64Decode('Unit Test Attachment Body');
           attach.ParentId = invRec.id;
           insert attach;
                    
        ContentVersion cv= new Contentversion();
          cv.title= attach.name;
          cv.PathOnClient =attach.name;         
          cv.versiondata=attach.Body; 
          cv.SharingPrivacy = 'N';
          cv.FirstPublishLocationId = attach.ParentId;
          insert cv; 
    }
}