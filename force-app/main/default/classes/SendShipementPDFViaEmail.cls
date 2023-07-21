/*

   Class Name       :   SendShipementPDFViaEmail
   Description      :   Controller Class to handle basic functions for Generic Component to Upload Files like - 
   Description   	:   Method that provides all existing Files attached on sObject via sObject Id
   Input Parameter	:	ID
   return type   	:   List<ContentDocument>  
   Developer Name   :   Mr.Sangale Govind    Created Date:13/01/2023
*/

public class SendShipementPDFViaEmail {
    public Shipment__c shipment {get; set;}
   //  public String subject { get; set; }
  //   public String body { get; set; }
    public SendShipementPDFViaEmail(){
     /*   String shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
        this.shipment = [SELECT id, shipper_Email__c,Shipper_Name_TMS__c,Consignee_Name_TMS__c,Customer__c,Customer_Product_Category__c,
                         Product_Description__c,Net_Weight__c,Shipment_Value__c,Origin_Address_Name__c,Destination_Address_Name__c,Insurance_By__c
                         FROM Shipment__c WHERE id = :shipmentId];
        system.debug(shipmentId); */
    } 
  @InvocableMethod(label='Shipment DSN details PDF' description='Generates and Emails an DSN PDF')
    Public static void sendPDF(List<List<String>> args){
        List<String> nested = args[0];
        String email = nested[0];
        String recordId = nested[1];
        
        PageReference invoicePDF = new PageReference('/apex/TMS_ShippingPdfPage?Id=' + recordId);
        invoicePDF.getParameters().put('Id', recordId);
       
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName('Customer DSN PDF');
        
        // Test Methods do not allow getContent calls so pass a blob if test is executing this code
        if(!test.isRunningTest()){
            attachment.body = invoicePDF.getContent();
        } else {
           attachment.body = blob.valueOf('blob');
        } 
        
        attachment.setInline(false);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('Digital shipping Note PDF');
        mail.setHtmlBody('Here\'s the DSN details PDF of your shipment.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         system.debug('record id :::::'+recordId);
    }
}