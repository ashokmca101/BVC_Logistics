/**********************************************************
 * Created By : Anamika Shinde
 * Created Date:19-08-2022
 * Purpose: send Contract Annexure File Email
**********************************************************************/
public with sharing  class SendContractAnnaxureEmail {

    @AuraEnabled
    public static string SendContractDetails(String ContractId){
         string message;
        try{
        
    
    //Get your document from document Object
        //Document doc = [Select Id, Name, Body, ContentType, DeveloperName, Type From Document Where DeveloperName = 'Your_Doucment_DeveloperName'];
        Attachment att =[SELECT Id,Name,CreatedDate, Body, ContentType FROM  Attachment where ParentId=:ContractId AND Name='Contract.csv' ORDER BY CreatedDate desc Limit 1];
        //Create Email file attachment from document
        if(att!=null){
             Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType(att.ContentType);
            attach.setFileName(att.Name+'.csv');
            attach.setInline(false);
            attach.Body = att.Body;
             List<Contract> conlist = [SELECT ContractNumber,AccountId,Account.Primary_Customer_Email__c,Account.Name,StartDate,EndDate,    Consumed_Amount__c FROM Contract WHERE Id=:ContractId];
            //Apex Single email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { conlist[0].Account.Primary_Customer_Email__c });//Set To Email Address
            mail.setSubject('Contract Details');//Set Subject
            mail.setHtmlBody('Dear '+conlist[0].Account.Name+'your contract number is '+conlist[0].ContractNumber+'\n\n Start Date'+conlist[0].StartDate+'\n End Date'+conlist[0].EndDate+'\n Consumed Amount'+conlist[0].  Consumed_Amount__c);//Set HTML Body
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachment
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
            
             message='Email Sended Succesfully';
               
        
        }else{
             message='please Create a Attachment';
            
        }
      
    }catch (Exception e) {
            System.debug('please please Create a Attachment  '+e.getMessage());
            throw new AuraHandledException(' Please Create a Attachment');
    }
     return message;
       
    }
    
    
     public static string sendConsumptionDetails(List<Contract> conList){
        string message;
        try{
    
       	   EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='Contract Consumption'];
       
             
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { conList[0].Primary_Customer_Email__c });//Set To Email Address
            //mail.setSubject('Contract Details');//Set Subject
           //mail.setHtmlBody('Hello Team  \n '+invList[0].blng__Account__r.Name+'\n\n We have attached Invoice' +invList[0].ST_Invoice_Series__c +'for   date '+ invList[0].Short_URL__c+'. Heres the link to pay via credit card, debit card, net banking or wallets: \n\n'+invList[0].blng__InvoiceDate__c+'\n\n Thank you!\n\n Best Regards, \n Team BVC \n\n NOTE – THIS IS SYSTEM GENERATED EMAIL KINDLY DO NOT REVERT ON THIS EMAIL ID');//Set HTML Body
              mail.setTemplateID(emailTemplate.Id);
            if(conList[0].CustomerSignedId!=null){
                mail.setTargetObjectId(conList[0].CustomerSignedId);
            }
             
            mail.setWhatId(conList[0].Id);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
            
             message='Email Sended Succesfully';
       
      }catch (Exception e) {
            System.debug('please please Create a Attachment  '+e.getMessage());
            throw new AuraHandledException(' Please Create a Invoice & Annaxure Attachment');
    }
       
            return message;
    
     }
    
    
         public static void contractRenewal(List<Contract> conlist){
       			List<Contract> conlist1=[SELECT ID,SBQQ__RenewalForecast__c FROM Contract WHERE ID=:conlist[0].ID];
                List<Contract> con1=new  List<Contract>();
                 for(Contract con : conlist1){
                        con.SBQQ__RenewalForecast__c =true;
                     con1.add(con);
                 }
                    
                    update con1;
      

        
    }
         
         
}