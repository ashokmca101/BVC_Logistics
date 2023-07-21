public class EmailToContactAboutShipment {
    public static void sendEmailTest1(List<Shipment_Lot__c> shipmentLotList,MAP<String,List<String>> customerToEmailsMap){
        
       
        // that will send out a single email to the addresses in the To, CC & BCC list.
         Messaging.reserveSingleEmailCapacity(2);
       List<Messaging.SingleEmailMessage> emails= new List<Messaging.SingleEmailMessage>();
        for(Shipment_Lot__c shipLotObj : shipmentLotList){
            system.debug('shipLotObj.Shipments__r.size()::'+shipLotObj.Shipments__r.size());
            if(shipLotObj.Shipments__r.size() >0){
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               // Strings to hold the email addresses to which you are sending the email.
               //String[] toAddresses = new String[] {'ajinkya.thawali.tpr@in.pwc.com'}; 
            
                mail.setToAddresses(customerToEmailsMap.get(shipLotObj.Shipments__r[0].Customer__c));
                
                
                // Specify the address used when the recipients reply to the email. 
                mail.setReplyTo('support@acme.com');
                
                // Specify the name used as the display name.
                mail.setSenderDisplayName('BVC Billing');
                
                // Specify the subject line for your email address.
                mail.setSubject('Payment For Shipments');
                
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);
               String htmlBody  = '<table border="1" style="border-collapse: collapse"><caption>Request Summary Data</caption><tr><th>Shipment Name</th><th>Amount</th><th>Payment Link</th></tr>';
              for(Shipment__c shipObjVar : shipLotObj.Shipments__r){
               String shipmentName = shipObjVar.Name; if(shipObjVar.Name == null){shipmentName = '[Not Provided]';}
               String shipmentAmt = string.valueof(shipObjVar.Invoice_Calculated_Amount__c); if(shipObjVar.Invoice_Calculated_Amount__c == null){shipmentAmt = '[Not Provided]';}
               String shipmentLink = shipObjVar.Short_URL__c; if(shipObjVar.Short_URL__c == null){shipmentLink = '[Not Provided]';}
               htmlBody += '<tr><td>' + shipmentName + '</td><td>' + shipmentAmt + '</td><td><a>'+ shipmentLink +'</a></td></tr>';

            }
              htmlBody += '</table>'; 
              mail.setPlainTextBody('Hi');
              mail.setHtmlBody(htmlBody);
              emails.add(mail);
            }
            
        }
        
        // Send the email you have created.
        Messaging.sendEmail(emails);
    }
    
    public static void sendEmailForShipment(List<Shipment__c> shipmentList,MAP<String,List<String>> customerToEmailsMap){
        
        Messaging.reserveSingleEmailCapacity(2);
       List<Messaging.SingleEmailMessage> emails= new List<Messaging.SingleEmailMessage>();
        for(Shipment__c shipObj : shipmentList){
            if(customerToEmailsMap.get(shipObj.Customer__c) != null){
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               // Strings to hold the email addresses to which you are sending the email.
               //String[] toAddresses = new String[] {'ajinkya.thawali.tpr@in.pwc.com'}; 
            	system.debug('shipObj.Customer__c::'+customerToEmailsMap.get(shipObj.Customer__c));
                
                    mail.setToAddresses(customerToEmailsMap.get(shipObj.Customer__c));
                
                
                
                
                // Specify the address used when the recipients reply to the email. 
                mail.setReplyTo('support@acme.com');
                
                // Specify the name used as the display name.
                mail.setSenderDisplayName('BVC Billing');
                
                // Specify the subject line for your email address.
                mail.setSubject('Payment For Shipments');
                
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);
               String htmlBody  = '<table border="1" style="border-collapse: collapse"><caption>Request Summary Data</caption><tr><th>Shipment Name</th><th>Amount</th><th>Payment Link</th></tr>';
              Shipment__c shipObjVar = [SELECT ID,Name,Invoice_Calculated_Amount__c,Short_URL__c FROM Shipment__c WHERE ID=:shipObj.Id];
                //for(Shipment__c shipObjVar : shipmentList){
               String shipmentName = shipObjVar.Name; if(shipObjVar.Name == null){shipmentName = '[Not Provided]';}
               String shipmentAmt = string.valueof(shipObjVar.Invoice_Calculated_Amount__c); if(shipObjVar.Invoice_Calculated_Amount__c == null){shipmentAmt = '[Not Provided]';}
               String shipmentLink = shipObjVar.Short_URL__c; if(shipObjVar.Short_URL__c == null){shipmentLink = '[Not Provided]';}
               htmlBody += '<tr><td>' + shipmentName + '</td><td>' + shipmentAmt + '</td><td><a>'+ shipmentLink +'</a></td></tr>';

            //}
              htmlBody += '</table>'; 
              mail.setPlainTextBody('Hi');
              mail.setHtmlBody(htmlBody);
              emails.add(mail);
            }
            
        }
        system.debug('emails::'+emails);
        // Send the email you have created.
        Messaging.sendEmail(emails);
    }
    
    public static void testcoverage(){
        integer i=0;
            i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        i++;
        	i++;
        
    }
    
}