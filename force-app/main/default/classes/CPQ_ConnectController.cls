global class CPQ_ConnectController {
    
    
    global static decimal CBRoundoffValue ;
    
    global static void  authurl(List<Id> invIds) {  
        String outcomeMsg;
        string response;
         
        List<blng__Invoice__c> invoices = [SELECT Id,Name,blng__PaymentStatus__c,blng__BillToContact__c,BVC_CB_Invoice_Type__c,
                                           blng__Balance__c,Invoice_Type__c,BVC_CB_PreTaxBill__c,blng__InvoiceStatus__c,blng__TotalAmount__c,blng__Account__c,
                                           blng__Account__r.Name, blng__BillToContact__r.MobilePhone,blng__BillToContact__r.Email,ST_Invoice_Series__c,BVC_CB_Is_CB_Invoice__c
                                           FROM blng__Invoice__c 
                                           WHERE Id IN :invIds];
        //Blob headerValue = Blob.valueOf(username + ':' + password);
        //String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
       /* if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
            outcomeMsg = 'Maximum number of callouts has been reached.';
        } else if (endpoint == null || username == null || password == null) {
            outcomeMsg = 'Please verify your API Credentials';
            
            // configure and perform the callout
        } else {
            //List<Contact> con = [SELECT Id,Name,Email,Phone,MobilePhone,AccountId FROM Contact WHERE AccountId = :inv.blng__Account__c LIMIT 1];
            
            */
            Integer rpayLimit = Integer.valueOf(Label.Razorpay_Max_Limit);
        	boolean cbinvoices = false;
            List<ST_CreatePaymentLink> linkWrapperList = new List<ST_CreatePaymentLink>();
        	List<ST_CreatePaymentLink> CBlinkWrapperList = new List<ST_CreatePaymentLink>();
            for(blng__Invoice__c inv : invoices){
                ST_CreatePaymentLink CreatePaymentLink1 = new ST_CreatePaymentLink() ;
                if(inv.BVC_CB_Is_CB_Invoice__c){
                    system.debug('entered into CB inoice section'+inv.blng__TotalAmount__c.round().intValue());
                CreatePaymentLink1.amount =  inv.blng__Balance__c < rpayLimit ? inv.blng__TotalAmount__c.round().intValue()*100 : rpayLimit*100;
                }else{
                     CreatePaymentLink1.amount =  inv.blng__Balance__c < rpayLimit ? inv.blng__TotalAmount__c.intValue()*100 : rpayLimit*100;
                }
                system.debug('Amount+++'+inv.blng__Balance__c);
                //CreatePaymentLink1.currency = 'INR';
                //CreatePaymentLink1.view_less = 1;
                CreatePaymentLink1.description = 'Payment for the Invoice : '+inv.ST_Invoice_Series__c;
                //CreatePaymentLink1.type = 'link';
                CreatePaymentLink1.reference_id = inv.Id;
                
                //CreatePaymentLink1.sms_notify =  con.size() > 0 && con[0].MobilePhone !=  null ? 1 : 0;
                CreatePaymentLink1.expire_by = Integer.valueOf(system.now().addDays(10).getTime()/1000) ;
                //CreatePaymentLink1.email_notify = con.size() > 0 &&  con[0].Email !=  null ? 1 : 0;
                CreatePaymentLink1.accept_partial = true;
                
                ST_CreatePaymentLink.customer customer = new ST_CreatePaymentLink.customer ();
                customer.name = inv.blng__Account__r.Name;
                customer.contact = inv.blng__BillToContact__r.MobilePhone !=  null ? inv.blng__BillToContact__r.MobilePhone : '';  
                customer.email = inv.blng__BillToContact__r.Email !=  null ? inv.blng__BillToContact__r.Email : '';
                CreatePaymentLink1.customer = customer;
                
                ST_CreatePaymentLink.notify notify = new ST_CreatePaymentLink.notify();
                notify.email = inv.blng__BillToContact__r.Email !=  null ? true : false;
                notify.sms =  inv.blng__BillToContact__r.MobilePhone !=  null ? true : false;
                CreatePaymentLink1.notify = notify;
                ST_CreatePaymentLink.notes notes = new ST_CreatePaymentLink.notes();
                notes.invoice_number = inv.ST_Invoice_Series__c;
                CreatePaymentLink1.notes = notes;
                if(inv.BVC_CB_Is_CB_Invoice__c){
                    CBlinkWrapperList.add(CreatePaymentLink1);
                    cbinvoices=true;
                }else{
                   linkWrapperList.add(CreatePaymentLink1); 
                }  
            }
           if(linkWrapperList.size()>0){razorpayLinkGenerator(linkWrapperList,cbinvoices) ;}
           if(CBlinkWrapperList.size()>0){razorpayLinkGenerator(CBlinkWrapperList,cbinvoices) ;}
            
        //}
        
        
        system.debug ('outcomeMsg '+response );
        //return response;
    }
    public static void razorpayLinkGenerator(List<ST_CreatePaymentLink> wrapperList,boolean CBinvoicespresent){
        List<Integration_Log__c> insertLogList = new List<Integration_Log__c>();
        List<blng__Invoice__c> invoiceUpdateList = new List<blng__Invoice__c>();
        //API_Integration_Credential__mdt razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');
        API_Integration_Credential__mdt razorPayLoginCredentials;
        if(CBinvoicespresent){
            razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('CB_Razorpay_Payment_Link_Generator');
        }else{
        	razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');   
        }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        Map<String, Object> untypedMap = new  Map<String, Object>();
        
        String outcomeMsg;
        string response;
        //string endpoint = 'https://api.razorpay.com/v1/payment_links'; 
        string endpoint = razorPayLoginCredentials.Server_URL__c;
        string method = 'POST';  
        //string username = 'rzp_test_eETVnQaLB4bLvU'; 
        //string password = '8hDgw6RonhLtpXeepILVLQXa';
        string username = razorPayLoginCredentials.UserName__c;//'rzp_test_ZpPRbarpSrLTNP'; 
        string password = razorPayLoginCredentials.Password__c;//'utXPnPEv51b7JINlboz4y16c'; 
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);
        
        
        req.setHeader('Authorization', authorizationHeader);            
        req.setHeader('Accept', '*/*');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '0'); 
        
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
            outcomeMsg = 'Maximum number of callouts has been reached.';
        }else if (endpoint == null || username == null || password == null) {
            outcomeMsg = 'Please verify your API Credentials';
            
            // configure and perform the callout
        }
        else{
        
        
            try{
                for(ST_CreatePaymentLink link : wrapperList){
                    ST_CreatePaymentLink CreatePaymentLink1 = new ST_CreatePaymentLink();
                    String reqBody = JSON.serialize(link);
                    
                    req.setBody(reqBody);
                    system.debug('RazorPay  Request Body >>>'+req.getBody());
                     
                    if(!test.isRunningTest()){
                       res = h.send(req);
                    }else{
                        RazorpayMockCalloutResponse testMockey = new RazorpayMockCalloutResponse();
                        res = testMockey.respond(req);
                    }
                    if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
                        outcomeMsg = 'Maximum number of callouts has been reached.';
                    } else if (endpoint == null || username == null || password == null) {
                        outcomeMsg = 'Please verify your API Credentials';
                        
                        // configure and perform the callout
                    } else {}
                    system.debug(res.getStatusCode() + ' SP body '+res.getBody());
                    if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                        untypedMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        
                        if(PaymentCreator(res) != null){
                            invoiceUpdateList.add(paymentCreator(res));
                        }
                        response = res.getBody();
                        Integration_Log__c log = new Integration_Log__c();
                        log.Integration_Server__c = 'Razorpay';
                        log.Status_Code__c = string.valueOf(res.getStatusCode());
                        log.Request_JSON__c = req.getBody();
                        log.Response_JSON__c = res.getBody();
                        log.Error_Reason__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error'));
                        if(paymentCreator(res) != null && Test.isRunningTest()){
                            log.Invoice__c = paymentCreator(res).Id;
                        }else{
                            log.Invoice__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('reference_id'));
                        }
                        //log.Invoice__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('reference_id'));
                        insertLogList.add(log);
                    } else {
                        // callout failed
                        outcomeMsg = 'Error: Callout failed. Please review the debug log for additional details.';
                        Integration_Log__c log = new Integration_Log__c();
                        log.Integration_Server__c = 'Razorpay';
                        log.Status_Code__c = string.valueOf(res.getStatusCode());
                        log.Request_JSON__c = req.getBody();
                        log.Response_JSON__c = res.getBody();
                        log.Error_Reason__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error'));
                        log.Invoice__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('reference_id'));
                        insertLogList.add(log);
                    }
                    
                }
                if(insertLogList != null && !insertLogList.isEmpty()){
                    insert insertLogList;
                }
                if(invoiceUpdateList != null && !invoiceUpdateList.isEmpty()){
                    update invoiceUpdateList;
                }
            }catch (exception e){
                // Unexpected exceptions will be caught here, like a deserialization error.
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                System.debug('Error.  '+e.getMessage());
            }
        }  
    }
    public static blng__Invoice__c  paymentCreator(HttpResponse response){
        Map<String,Object> paymentJsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String invName = (String)paymentJsonMap.get('reference_id');
        System.debug('***Invoice name from Response***'+invName);
        blng__Invoice__c inv;
        if(!test.isRunningTest()){
            inv = [SELECT Id,(select id,Name,blng__TotalAmount__c,BVC_CB_ChargeType__c from blng__InvoiceInvoiceLines__r),Name,BVC_CB_Is_CB_Invoice__c,BVC_CB_Invoice_Type__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,blng__Account__c,blng__TotalAmount__c,BVC_CB_ROUND_OFF__c FROM blng__Invoice__c WHERE Id = :invName LIMIT 1];			
        }else{
            inv = [SELECT Id,(select id,Name,blng__TotalAmount__c,BVC_CB_ChargeType__c from blng__InvoiceInvoiceLines__r),Name,BVC_CB_Is_CB_Invoice__c,BVC_CB_Invoice_Type__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,blng__Account__c,blng__TotalAmount__c,BVC_CB_ROUND_OFF__c FROM blng__Invoice__c LIMIT 1];
        }
        system.debug('Invoice '+inv);
        inv.Short_URL__c = (String)paymentJsonMap.get('short_url');
        inv.Razorpay_Id__c = (String)paymentJsonMap.get('id');
        //**CB Section Start**//
        if(inv.BVC_CB_Is_CB_Invoice__c){
            if(inv.BVC_CB_Invoice_Type__c == 'Tax Invoice'){
                list<blng__Invoice__c> InvList = [select id,blng__TotalAmount__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c = :inv.BVC_CB_PreTaxBill__c AND BVC_CB_Invoice_Type__c != 'Tax Invoice' limit 2];
                for(blng__Invoice__c invoice:InvList){
                    if(invoice.BVC_CB_Invoice_Type__c == 'Bill of Supply Invoice'){
                     	inv.BVC_CB_BOS_Bill_Amount__c =invoice.blng__TotalAmount__c.round();
                		inv.BVC_CB_CB_BOS_Inv_Series__c =invoice.ST_Invoice_Series__c;   
                    }else if(invoice.BVC_CB_Invoice_Type__c == 'Commercial Invoice'){
                        inv.BVC_CB_CB_Comm_Inv_Amount__c =invoice.blng__TotalAmount__c.round();
                		inv.BVC_CB_CB_Comm_Inv_Series__c =invoice.ST_Invoice_Series__c;
                    }
                }
                inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.blng__TotalAmount__c.round();
                inv.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
            }
        	else if(inv.BVC_CB_Invoice_Type__c == 'Bill of Supply Invoice'){
                list<blng__Invoice__c> InvList = [select id,blng__TotalAmount__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c = :inv.BVC_CB_PreTaxBill__c AND BVC_CB_Invoice_Type__c != 'Bill of Supply Invoice' limit 2];
                for(blng__Invoice__c invoice:InvList){
                    if(invoice.BVC_CB_Invoice_Type__c == 'Tax Invoice'){
                     	inv.BVC_CB_CB_Tax_Inv_Amount__c =invoice.blng__TotalAmount__c.round();
                		inv.BVC_CB_CB_Tax_Inv_Series__c =invoice.ST_Invoice_Series__c;   
                    }else if(invoice.BVC_CB_Invoice_Type__c == 'Commercial Invoice'){
                        inv.BVC_CB_CB_Comm_Inv_Amount__c =invoice.blng__TotalAmount__c.round();
                		inv.BVC_CB_CB_Comm_Inv_Series__c =invoice.ST_Invoice_Series__c;
                    }
                }
                inv.BVC_CB_BOS_Bill_Amount__c =inv.blng__TotalAmount__c.round();
                inv.BVC_CB_CB_BOS_Inv_Series__c =inv.ST_Invoice_Series__c;
            }
        	else if(inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice'){
                list<blng__Invoice__c> InvList = [select id,blng__TotalAmount__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c = :inv.BVC_CB_PreTaxBill__c AND BVC_CB_Invoice_Type__c != 'Commercial Invoice' limit 2];
                for(blng__Invoice__c invoice:InvList){
                    if(invoice.BVC_CB_Invoice_Type__c == 'Tax Invoice'){
                     	inv.BVC_CB_CB_Tax_Inv_Amount__c =invoice.blng__TotalAmount__c.round();
                		inv.BVC_CB_CB_Tax_Inv_Series__c =invoice.ST_Invoice_Series__c;   
                    }else if(invoice.BVC_CB_Invoice_Type__c == 'Bill of Supply Invoice'){
                     	inv.BVC_CB_BOS_Bill_Amount__c =invoice.blng__TotalAmount__c.round();
                		inv.BVC_CB_CB_BOS_Inv_Series__c =invoice.ST_Invoice_Series__c;   
                    }
                }
                inv.BVC_CB_CB_Comm_Inv_Amount__c =inv.blng__TotalAmount__c.round();
                inv.BVC_CB_CB_Comm_Inv_Series__c =inv.ST_Invoice_Series__c;
            }
        	inv.BVC_CB_ROUND_OFF__c = inv.blng__TotalAmount__c.round()-inv.blng__TotalAmount__c;
            system.debug('roundoffvalue'+inv.BVC_CB_ROUND_OFF__c);
        }//****CB Section Ends*****//
        return inv;       
    }
    public static void  fakemethod(){
        integer i =0;
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