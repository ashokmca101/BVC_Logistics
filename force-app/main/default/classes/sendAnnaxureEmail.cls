/**********************************************************
 * Created By : Anamika Shinde
 * Created Date:19-08-2022
 * Purpose: send Invoice Annexure File Email
**********************************************************************/
public with sharing  class sendAnnaxureEmail {

     @AuraEnabled
    public static string SendContractDetails(String InvoiceId){
         string message;
        try{
    //Get your document from document Object
        //Document doc = [Select Id, Name, Body, ContentType, DeveloperName, Type From Document Where DeveloperName = 'Your_Doucment_DeveloperName'];
        Attachment att =[SELECT Id,Name, Body, ContentType FROM  Attachment where ParentId=:InvoiceId AND Name='Annexure.csv'  ORDER BY CreatedDate DESC LIMIT 1];
        Attachment att1 =[SELECT Id,Name, Body, ContentType FROM  Attachment where ParentId=:InvoiceId AND (Name='Bath Invoice.pdf' OR Name='Eship Invoice.pdf')  ORDER BY CreatedDate DESC LIMIT 1];
        //Create Email file attachment from document
        List<blng__Invoice__c> invList=[SELECT ID,ST_Invoice_Series__c,blng__BillToContact__c,blng__InvoiceDate__c,Short_URL__c,blng__Account__r.Primary_Customer_Email__c,blng__Account__r.Name FROM blng__Invoice__c WHERE ID=:InvoiceId];
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='Invoice PDF Template'];
        if(att!=null && att1!=null){
             Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType(att.ContentType);
            attach.setFileName(att.Name);
            attach.setInline(false);
            attach.Body = att.Body;
            
            Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
            attach1.setContentType(att1.ContentType);
            attach1.setFileName(att1.Name);
            attach1.setInline(false);
            attach1.Body = att1.Body;
             //List<Contract> conlist = [SELECT ContractNumber,AccountId,Account.Primary_Customer_Email__c,Account.Name,StartDate,EndDate,eSHIP_BATH__c,Remaining_Contract_Amount__c FROM Contract WHERE Id=:ContractId];
            
            //Apex Single email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { invList[0].blng__Account__r.Primary_Customer_Email__c });//Set To Email Address
            //mail.setSubject('Contract Details');//Set Subject
           //mail.setHtmlBody('Hello Team  \n '+invList[0].blng__Account__r.Name+'\n\n We have attached Invoice' +invList[0].ST_Invoice_Series__c +'for   date '+ invList[0].Short_URL__c+'. Heres the link to pay via credit card, debit card, net banking or wallets: \n\n'+invList[0].blng__InvoiceDate__c+'\n\n Thank you!\n\n Best Regards, \n Team BVC \n\n NOTE – THIS IS SYSTEM GENERATED EMAIL KINDLY DO NOT REVERT ON THIS EMAIL ID');//Set HTML Body
              mail.setTemplateID(emailTemplate.Id);
             mail.setTargetObjectId(invList[0].blng__BillToContact__c);
            mail.setWhatId(InvoiceId);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach,attach1 });//Set File Attachment
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
            
             message='Email Sended Succesfully';
        }else{
             message='please Create a Attachment';
            
        }
      }catch (Exception e) {
            System.debug('please please Create a Attachment  '+e.getMessage());
            throw new AuraHandledException(' Please Create a Invoice & Annaxure Attachment');
    }
       
            return message;
    
    }
    
      @AuraEnabled
    public static string SendACRInvoice(String InvoiceId){
         string message;
       // try{
    //Get your document from document Object
        //Document doc = [Select Id, Name, Body, ContentType, DeveloperName, Type From Document Where DeveloperName = 'Your_Doucment_DeveloperName'];
        //Attachment att =[SELECT Id,Name, Body, ContentType FROM  Attachment where ParentId=:InvoiceId AND Name='Annexure.csv'  ORDER BY CreatedDate DESC LIMIT 1];
        Attachment att1 =[SELECT Id,Name, Body, ContentType FROM  Attachment where ParentId=:InvoiceId AND (Name='Bath Invoice.pdf' OR Name='Eship Invoice.pdf')  ORDER BY CreatedDate DESC LIMIT 1];
        //Create Email file attachment from document
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='Invoice PDF Template'];
        if(att1!=null){
             
            
            Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
            attach1.setContentType(att1.ContentType);
            attach1.setFileName(att1.Name);
            attach1.setInline(false);
            attach1.Body = att1.Body;
             //List<Contract> conlist = [SELECT ContractNumber,AccountId,Account.Primary_Customer_Email__c,Account.Name,StartDate,EndDate,eSHIP_BATH__c,Remaining_Contract_Amount__c FROM Contract WHERE Id=:ContractId];
            List<blng__Invoice__c> invList=[SELECT ID,ST_Invoice_Series__c,blng__BillToContact__c,blng__InvoiceDate__c,Short_URL__c,blng__Account__r.Primary_Customer_Email__c,blng__Account__r.Name FROM blng__Invoice__c WHERE ID=:InvoiceId];
            //Apex Single email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { invList[0].blng__Account__r.Primary_Customer_Email__c });//Set To Email Address
            //mail.setSubject('Contract Details');//Set Subject
           //mail.setHtmlBody('Hello Team  \n '+invList[0].blng__Account__r.Name+'\n\n We have attached Invoice' +invList[0].ST_Invoice_Series__c +'for   date '+ invList[0].Short_URL__c+'. Heres the link to pay via credit card, debit card, net banking or wallets: \n\n'+invList[0].blng__InvoiceDate__c+'\n\n Thank you!\n\n Best Regards, \n Team BVC \n\n NOTE – THIS IS SYSTEM GENERATED EMAIL KINDLY DO NOT REVERT ON THIS EMAIL ID');//Set HTML Body
              mail.setTemplateID(emailTemplate.Id);
            if(invList[0].blng__BillToContact__c != null){
                 mail.setTargetObjectId(invList[0].blng__BillToContact__c);
                 mail.setWhatId(InvoiceId);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach1 });//Set File Attachment
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
                
                 message='Email Sended Succesfully';
            }
            
           
        }else{
             message='please Create a Attachment';
            
        }
      /*}catch (Exception e) {
            System.debug('please please Create a Attachment  '+e.getMessage());
            throw new AuraHandledException(' Please Create a Invoice & Annaxure Attachment');
    }*/
       
            return message;
    
    }
        
        
}