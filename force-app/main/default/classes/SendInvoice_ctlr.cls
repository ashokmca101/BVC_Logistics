public class SendInvoice_ctlr {
    @InvocableMethod(label='Send Email with Shipment Invoice')
    public static void sendEmailwithAttachment(List<flowParameters> params){
        try{
            List<shipment_invoice__c> shipmentInvoice= [select id,name, Invoice_Number__c,shipment__r.Billing_Account__r.Name,Balance_Amount2__c, Invoice_Doc_URL__c, Invoice_Date__c, shipment__r.Shipment_Number__c, shipment__r.Shipping_Note_Number__c, Payment_Link__c from shipment_Invoice__c where Shipment__c=: params[0].recIds]; //AND Invoice_Status__c='Active'];
            List<blng__Invoice__c> invoiceList= [select id, ST_Invoice_Series__c from blng__Invoice__c where name=: shipmentInvoice[0].Invoice_Number__c];
            system.debug('Invoice List'+invoiceList);
            system.debug('shipmentInvoice List'+shipmentInvoice);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             system.debug('Invoice List'+invoiceList[0].ST_Invoice_Series__c);
            mail.setSubject('BVC Logistics Invoice-'+invoiceList[0].ST_Invoice_Series__c);
            
            Datetime da= shipmentInvoice[0].Invoice_Date__c;
            String body=  '<p> Hello Team '+shipmentInvoice[0].shipment__r.Billing_Account__r.Name+ '<br/>';
            body = body+' <br/>';
            body = body+'We’ve attached Invoice ' +invoiceList[0].ST_Invoice_Series__c+ ' for date '+da.format('dd-MM-yyyy')+ '. Here is the Link to pay via credit card, debit card, net banking, or wallets.<br/>';
            body = body+' <br/>';
            body = body+'<a href="'+shipmentInvoice[0].Payment_Link__c+'">'+shipmentInvoice[0].Payment_Link__c+'</a><br/>';
            
            body = body+' <br/>';
            body = body+'Thank you! <br/>';
            body = body+' <br/>';
            body=body+'Best Regards <br/>';
            body=body+'Team BVC';
            mail.setHtmlBody(body);
            system.debug('Body'+body);
            mail.setToAddresses(new List<String>{params[0].email}); 
            mail.setUseSignature(false);
            //OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'bvclinvoicesubmission@bvclogistics.com' Limit 1];
            //mail.setOrgWideEmailAddressId(owea.id);
           List<Messaging.EmailFileAttachment> fileAttachment = new List<Messaging.EmailFileAttachment>();
            List<Attachment> a= [select id, name, body from Attachment where parentId=: shipmentInvoice[0].Id ORDER BY createdDate DESC LIMIT 1];
             if(a.size()>0){
                Messaging.EmailfileAttachment efa = new Messaging.EmailfileAttachment(); 
                efa.setFileName(a[0].Name);
                efa.setBody(a[0].Body);
                fileAttachment.add(efa);
                mail.setFileAttachments(fileAttachment); 
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }catch(exception e){
            system.debug(e+'***********'+e.getLineNumber());
        }
    }


    public class flowParameters {
        @InvocableVariable(required=true)
        public String email;
        @InvocableVariable(required=true)
        public Id recIds; 
        @InvocableVariable(required=true)
        public String firstName;
    }   
}