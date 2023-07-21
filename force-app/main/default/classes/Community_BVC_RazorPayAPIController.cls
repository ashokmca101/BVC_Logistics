global class Community_BVC_RazorPayAPIController {
    global static void  authurl(List<Id> shipIds) {  
        String outcomeMsg;
        string response;
        //string endpoint = 'https://api.razorpay.com/v1/payment_links'; 
        //string method = 'POST';  
        //string username = 'rzp_test_eETVnQaLB4bLvU'; 
        //string password = '8hDgw6RonhLtpXeepILVLQXa';
        //string username = 'rzp_test_ZpPRbarpSrLTNP'; 
        //string password = 'utXPnPEv51b7JINlboz4y16c';
        
        List<Shipment__c> shipments = [SELECT Id,Name,Invoice_Paid_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,Total_Invoice_Value__c,Customer__c,Customer__r.Name,
                                          Customer__r.Phone,Customer__r.Primary_Customer_Email__c FROM Shipment__c 
                                           WHERE Id IN :shipIds];
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
            List<Community_CreatePaymentLink> linkWrapperList = new List<Community_CreatePaymentLink>();
            for(Shipment__c shipObj : shipments){
                Community_CreatePaymentLink CreatePaymentLink1 = new Community_CreatePaymentLink() ;
                CreatePaymentLink1.amount =  shipObj.Invoice_Calculated_Amount__c < rpayLimit ? shipObj.Invoice_Calculated_Amount__c.intValue()*100 : rpayLimit*100; 
                system.debug('Amount+++'+shipObj.Invoice_Calculated_Amount__c);
                //CreatePaymentLink1.currency = 'INR';
                //CreatePaymentLink1.view_less = 1;
                CreatePaymentLink1.description = 'Payment for the Invoice : '+shipObj.Name;
                //CreatePaymentLink1.type = 'link';
                CreatePaymentLink1.reference_id = shipObj.Id;
                
                //CreatePaymentLink1.sms_notify =  con.size() > 0 && con[0].MobilePhone !=  null ? 1 : 0;
                CreatePaymentLink1.expire_by = Integer.valueOf(system.now().addDays(10).getTime()/1000) ;
                //CreatePaymentLink1.email_notify = con.size() > 0 &&  con[0].Email !=  null ? 1 : 0;
                CreatePaymentLink1.accept_partial = false;
                
                Community_CreatePaymentLink.customer customer = new Community_CreatePaymentLink.customer ();
                customer.name = shipObj.Customer__r.Name;
                customer.contact = shipObj.Customer__r.Phone !=  null ? shipObj.Customer__r.Phone : '';  
                customer.email = shipObj.Customer__r.Primary_Customer_Email__c !=  null ? shipObj.Customer__r.Primary_Customer_Email__c : '';
                CreatePaymentLink1.customer = customer;
                
                //CreatePaymentLink.notify notify = new CreatePaymentLink.notify();
                //notify.email = shipObj.blng__BillToContact__r.Email !=  null ? true : false;
                //notify.sms =  shipObj.blng__BillToContact__r.MobilePhone !=  null ? true : false;
                //CreatePaymentLink1.notify = notify;
                linkWrapperList.add(CreatePaymentLink1);
            }
           razorpayLinkGenerator(linkWrapperList) ;
            
        //}
        
        
        system.debug ('outcomeMsg '+response );
        //return response;
    }
    public static void razorpayLinkGenerator(List<Community_CreatePaymentLink> wrapperList){
        //List<Integration_Log__c> insertLogList = new List<Integration_Log__c>();
        List<Shipment__c> invoiceUpdateList = new List<Shipment__c>();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        Map<String, Object> untypedMap = new  Map<String, Object>();
        
        String outcomeMsg;
        string response;
        string endpoint = Label.Razorpay_Endpoint_Community_Payment_Links; //'https://api.razorpay.com/v1/payment_links'; 
        string method = 'POST';  
        //string username = 'rzp_test_eETVnQaLB4bLvU'; 
        //string password = '8hDgw6RonhLtpXeepILVLQXa';
        string username = Label.Razorpay_Username_Community; //'rzp_test_L0SDLcmzd1ALse'; 
        string password = Label.Razorpay_Password_Community; //'Xan2xYD0MaOwOwQtNMX2icKa'; 
        
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
                for(Community_CreatePaymentLink link : wrapperList){
                    Community_CreatePaymentLink CreatePaymentLink1 = new Community_CreatePaymentLink();
                    String reqBody = JSON.serialize(link);
                    
                    req.setBody(reqBody);
                    system.debug('RazorPay  Request Body >>>'+req.getBody());
                    res = h.send(req); if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
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
                        /*Integration_Log__c log = new Integration_Log__c();
                        log.Integration_Server__c = 'Razorpay';
                        log.Status_Code__c = string.valueOf(res.getStatusCode());
                        log.Request_JSON__c = req.getBody();
                        log.Response_JSON__c = res.getBody();
                        log.Error_Reason__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error'));
                        log.Invoice__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('reference_id'));
                        insertLogList.add(log);*/
                    } else {
                        // callout failed
                        outcomeMsg = 'Error: Callout failed. Please review the debug log for additional details.';
                        Exception_Log__c apiException = new Exception_Log__c();
                        apiException.API_Status__c = 'failed';
                        apiException.Exception_Message__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error'));
                        insert apiException;
                        /*Integration_Log__c log = new Integration_Log__c();
                        log.Integration_Server__c = 'Razorpay';
                        log.Status_Code__c = string.valueOf(res.getStatusCode());
                        log.Request_JSON__c = req.getBody();
                        log.Response_JSON__c = res.getBody();
                        log.Error_Reason__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error'));
                        log.Invoice__c = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('reference_id'));
                        insertLogList.add(log);*/
                    }
                    
                }
               /* if(insertLogList != null && !insertLogList.isEmpty()){
                    insert insertLogList;
                }*/
                if(invoiceUpdateList != null && !invoiceUpdateList.isEmpty()){
                    update invoiceUpdateList;
                }
            }catch (exception e){
                // Unexpected exceptions will be caught here, like a deserialization error.
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                Exception_Log__c apiException = new Exception_Log__c();
                apiException.API_Status__c = 'failed';
                apiException.Exception_Message__c =  e.getMessage();
                insert apiException;
            }
        }  
    }
    public static Shipment__c  paymentCreator(HttpResponse response){
        Map<String,Object> paymentJsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String invName = (String)paymentJsonMap.get('reference_id');
        System.debug('***Invoice name from Response***'+invName);
        Shipment__c inv = [SELECT Id,Name,Short_URL__c,Razorpay_Id__c FROM Shipment__c WHERE Id = :invName LIMIT 1];
        system.debug('Invoice ');
        inv.Short_URL__c = (String)paymentJsonMap.get('short_url');
        inv.Razorpay_Id__c = (String)paymentJsonMap.get('id');
        return inv;
                
    }   
}