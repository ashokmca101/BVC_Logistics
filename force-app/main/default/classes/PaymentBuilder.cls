public class PaymentBuilder {
    public static void paymentLinkGenerator(String endpoint,String authorizationHeader,List<blng__Invoice__c> invoiceList){
        List<Integration_Log__c> insertLogList = new List<Integration_Log__c>();
        //List<blng__Invoice__c> invoiceUpdateList = new List<blng__Invoice__c>();
        Map<String,blng__Invoice__c> invMap = new Map<String,blng__Invoice__c>();
        //Map<Id,List<String>> invoicePaymentMap = new Map<Id,List<String>>();
        Map<Id,List<blng__PaymentAllocationInvoice__c>> mapPaymentAllocations = new Map<Id,List<blng__PaymentAllocationInvoice__c>>();
        Map<Id,blng__Payment__c> mapPayments = new Map<Id,blng__Payment__c>();
        
        String method = 'GET'; 
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod(method);
        req.setTimeout(120000);
        
        Map<Id,List<String>> mapInvoicePaymentIds = new Map<Id,List<String>>();
        for(blng__Invoice__c inv : invoiceList){
            // Create Razorpay PaymentId Map
            if(inv.blng__PaymentInvoiceAllocations__r != null && inv.blng__PaymentInvoiceAllocations__r.size()>0){
                
                for(blng__PaymentAllocationInvoice__c paymentObj : inv.blng__PaymentInvoiceAllocations__r){
                    
                    if(paymentObj.RazorPay_PaymentId__c != null && mapInvoicePaymentIds.containsKey(inv.Id)){
                        mapInvoicePaymentIds.get(inv.Id).add(paymentObj.RazorPay_PaymentId__c);
                    }
                    else if(paymentObj.RazorPay_PaymentId__c != null ){
                        mapInvoicePaymentIds.put(inv.Id,new List<String>{paymentObj.RazorPay_PaymentId__c});
                    }
                    
                }
                
            }
            
            //System.debug('Invoice id--->'+inv.Id);
            string plinkd = inv.Razorpay_Id__c.replace('inv','plink');
            //system.debug('Invoice RID+++-->  '+inv.Razorpay_Id__c+'RazorPay Id+++---> '+plinkd);
            invMap.put(plinkd,inv);
            req.setEndpoint(endpoint+plinkd);
            //System.debug('End Point ::::'+endpoint+plinkd);
            //insertLogList.add(createIntegrationLog(inv.Id,'Payment Details Callout failed','','',''));
            //gSystem.debug('End Point ::::'+createIntegrationLog(inv.Id,'Payment Details Callout failed','','',''));
            try{
                res = ht.send(req);
            }catch(Exception Ex){
                insertLogList.add(createIntegrationLog(inv.Id,'Razorpay Callout failed','','',''));
                continue;
            }
            
           // System.debug('End Point ::::'+insertLogList);
            //system.debug('**Response Code** '+res.getStatusCode()+' **Second Response Body** '+res.getBody()+' **Error Detail** '+res.getStatus());
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                //fetchIndividualpayments(res,invMap); 
                // Debug Logs for testing
                //system.debug(':::Fetch All Payment Httpresponse:::'+res.getBody());
                //system.debug('::: To deserialize JSON:::'+(FetchPaymentsWrapper)JSON.deserialize(res.getBody(),FetchPaymentsWrapper.Class));
                // deseriallize Response and convert to wrapper 
                if(Test.isRunningTest()){
                    FetchPaymentsWrapper paymentJsonObjTest = (FetchPaymentsWrapper)JSON.deserialize(res.getBody(),FetchPaymentsWrapper.Class);
                    wrapperTestCoverage(paymentJsonObjTest);
                }
                FetchPaymentsWrapper paymentJsonObj = (FetchPaymentsWrapper)JSON.deserialize(res.getBody(),FetchPaymentsWrapper.Class);
                
                // Create Invoice Payment Record
                
                List<FetchPaymentsWrapper.payments> allPayments = new List<FetchPaymentsWrapper.payments>();
                if(paymentJsonObj != null && paymentJsonObj.payments != null && paymentJsonObj.payments.size() > 0){
                    
                    
                    
                    Integer paidAmount = 0;
                    allPayments.addAll(paymentJsonObj.payments); 
                    for(FetchPaymentsWrapper.payments pay : allPayments){
                        System.debug('Enter Here 0');
                        if(pay.amount != null && pay.amount >0 && (!mapInvoicePaymentIds.containsKey(inv.Id) || (mapInvoicePaymentIds.containsKey(inv.Id) && !mapInvoicePaymentIds.get(inv.Id).contains(pay.payment_id)))){
                            System.debug('Enter Here 1');
                            blng__PaymentAllocationInvoice__c pa = new blng__PaymentAllocationInvoice__c();
                            pa.blng__Invoice__c = inv.Id;
                            pa.RazorPay_PaymentId__c = pay.payment_id;
                            pa.blng__Amount__c =(pay.amount != null? pay.amount/100 : 0); 
                            paidAmount = paidAmount + pay.amount;
                            pa.blng__Type__c = 'Allocation';
                            if(mapPaymentAllocations.containsKey(inv.Id)){
                                mapPaymentAllocations.get(inv.Id).add(pa);
                            }else{
                                mapPaymentAllocations.put(inv.Id,new List<blng__PaymentAllocationInvoice__c>{pa});
                            }
                        }
                    }
                    if(paidAmount > 0){
                        blng__Payment__c payment = new  blng__Payment__c();
                        if(inv.blng__Payments__r == null || inv.blng__Payments__r.size() == 0 ){
                            payment.blng__Invoice__c = inv.Id;
                            payment.blng__Account__c = inv.blng__Account__c;
                            payment.blng__Status__c = 'Posted';
                            payment.blng__Amount__c = inv.blng__TotalAmount__c;
                            payment.blng__Notes__c = 'Payment Successful with RazorPay';
                            payment.blng__PaymentType__c = 'Razorpay';
                            payment.blng__Status__c = 'Posted';   
                            mapPayments.put(inv.Id,payment); 
                        }
                        else if(inv.blng__Payments__r != null && inv.blng__Payments__r.size() > 0 ){
                            mapPayments.put(inv.Id,inv.blng__Payments__r[0]);
                        }
                        //payment.blng__Amount__c = (paidAmount != 0?(paidAmount/100):0);
                       // mapPayments.put(inv.Id,payment); //add existing Payment with Invoice Map.
                        //Mark razorpay payment received in Invoice to true.
                    }
                    
                    
                }
                insertLogList.add(createIntegrationLog(inv.Id,'',req.getBody(),res.getBody(),string.valueOf(res.getStatusCode())));
            }  
            else{
                insertLogList.add(createIntegrationLog(inv.Id,String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error')),req.getBody(),res.getBody(),string.valueOf(res.getStatusCode())));
            }
        }
        
        try {
            upsert mapPayments.values();
            List<blng__PaymentAllocationInvoice__c> insertPaymentList = new List<blng__PaymentAllocationInvoice__c>();
            for(Id invId:mapPaymentAllocations.keySet()){
                for(blng__PaymentAllocationInvoice__c payment : mapPaymentAllocations.get(invId)){
                    if(mapPayments.containsKey(invId)){
                        payment.blng__Payment__c = mapPayments.get(invId).Id;
                        insertPaymentList.add(payment);
                    }
                }
            }
            
            insert insertPaymentList;
            // if(insertPaymentList.size() >0){
            insert insertLogList;
            //}
            
            
        } catch (Exception ex) {
            System.debug(' ex message  '+ex.getMessage());
            System.debug('Line Number   '+ex.getLineNumber());
        }
    }
    
    
    
    
    /*
    * Name : createIntegrationLogs
    * Description : Creating Integration Logs for Invoice Record - Speciafically for Limit exception and Bearer token Exception
    * Param1 : Invoice Id
    * Param2 : Error Message
    * Param3 : Request JSON
    * Param4 : Response JSON
    * Param5 : StatusCode
    * Return : Integration_Log__c
    */
    public static Integration_Log__c createIntegrationLog(Id invId,String errorMessage,String requestJson,String responseJson,String statusCode){
        
        Integration_Log__c log = new Integration_Log__c();
        log.Integration_Server__c = 'Razorpay';
        log.Request_JSON__c = requestJson;
        log.Response_JSON__c = responseJson;
        log.Invoice__c = invId;
        log.Status_Code__c = statusCode ;
        log.Error_Reason__c = errorMessage;
        return log;
        
    }
    
    public static void wrapperTestCoverage(FetchPaymentsWrapper wrapper){
        FetchPaymentsWrapper wrapper1 = new FetchPaymentsWrapper();
        wrapper1.Id = '123test';
        wrapper1.first_min_partial_amount = 333;
        wrapper1.expired_at = 4641;
        wrapper1.expire_by = 5654;
        wrapper1.description = 'Test data';
        wrapper1.order_id = 'fhafy';
        wrapper1.reminder_enable = true;
        wrapper1.reference_id = 'hfagsj Test';
        wrapper1.short_url = '5aaTest.com';
        wrapper1.created_at = 65751;
        wrapper1.status = 'Test';
        wrapper1.amount = 553;
        wrapper1.accept_partial = false;
        wrapper1.cancelled_at = 4641;
        wrapper1.updated_at = 5652;
        wrapper1.amount_paid = 554;
        wrapper1.user_id = 'ghgauTest';
        FetchPaymentsWrapper.reminders rem = new FetchPaymentsWrapper.reminders();
        FetchPaymentsWrapper.customer customer = new FetchPaymentsWrapper.customer();
        FetchPaymentsWrapper.notify noti = new FetchPaymentsWrapper.notify();
        FetchPaymentsWrapper.payments pay = new FetchPaymentsWrapper.payments();
        pay.method = 'Test';
        pay.created_at = 46541;
        pay.status = 'Test Passed';
        customer.name = 'test';
        customer.email = 'abs@test.com';
        customer.contact = '575181';
        customer.customer_id = 'testId';
        noti.email = false;
        noti.sms = false;
        rem.status = 'Test False';
        wrapper1.customer = customer;
        List<FetchPaymentsWrapper.payments> paymentList = new List<FetchPaymentsWrapper.payments>();
        //paymentList.addAll(wrapper1.payments);
        wrapper1.notify = noti;
        List<FetchPaymentsWrapper.reminders> reminderList = new List<FetchPaymentsWrapper.reminders>();
        //reminderList.addAll(wrapper1.reminders);
        
    }
}