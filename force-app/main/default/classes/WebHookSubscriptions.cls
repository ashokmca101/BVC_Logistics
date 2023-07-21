@RestResource(urlMapping='/Pushnotification/*')
global without sharing class WebHookSubscriptions {
   @HttpPost
   global static void handleNotification(){

        try{
            	system.debug('test');
                RestRequest request = RestContext.request;
                //RestResponse response = RestContext.response;                
            	//System.debug('PRAM '+response);
            	//System.debug('request.requestBody '+request.requestBody);
             	System.debug('request.requestBody '+request.requestBody.toString()); 
                String jsonResponse = request.requestBody.toString();
            	system.debug(jsonResponse);
                Map<String, Object> m =(Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
            	String entityValue = (String)m.get('entity');
            	String account_id = (String)m.get('account_id');
            	String event = (String)m.get('event');
                Map<String, Object> payload = 
                   (Map<String, Object>)m.get('payload');
                Map<String, Object> payment = (Map<String, Object>)payload.get('payment');
                Map<String, Object> entity = (Map<String, Object>)payment.get('entity');
        		String id =(String)entity.get('id');
                Decimal amount = (Decimal)entity.get('amount');
            	String currencyValue = (String)entity.get('currency');
            	Decimal base_amount;
            	Decimal amount_transferred;
            	Decimal refund_amount;
            	String refund_id;
                if(event == 'refund.processed'){
                    
                	base_amount = (Decimal)entity.get('amount');
                    amount_transferred = (Decimal)entity.get('amount_transferred');
                    Map<String, Object> refund = (Map<String, Object>)payload.get('refund');
                    Map<String, Object> refundEntity = (Map<String, Object>)refund.get('entity');
                    refund_id = (String)refundEntity.get('id');
                    String refund_entity = (String)refundEntity.get('entity');
                    refund_amount = (Decimal)refundEntity.get('amount');
                    String refund_currency = (String)refundEntity.get('currency');
                    String refund_payment_id = (String)refundEntity.get('payment_id');
                    String refund_status = (String)refundEntity.get('status');
                    Integer refund_created_at = (Integer)refundEntity.get('created_at');
                }
            	String status = (String)entity.get('status');
            	String order_id = (String)entity.get('order_id');
            	//String custom_invoice_id = (String)entity.get('invoice_id');
            	Boolean international = (Boolean)entity.get('international');
                String method = (String)entity.get('method');
                Decimal amount_refunded = (Decimal)entity.get('amount_refunded');
            
                String refund_status = (String)entity.get('refund_status');
                Boolean captured = (Boolean)entity.get('captured');
                String description = (String)entity.get('description');
            	String type;
            	String last4;
            if(method == 'card'){
            	String card_id = (String)entity.get('card_id'); 
            	//Card Inner Details
                Map<String, Object> card = (Map<String, Object>)entity.get('card');
            	String c_id = (String)card.get('id');
            	String c_entity = (String)card.get('entity');
                String name = (String)card.get('name');
            	last4 = (String)card.get('last4');
            	String network = (String)card.get('network');
            	type = (String)card.get('type');
                String issuer = (String)card.get('issuer');
            	Boolean c_international = (Boolean)card.get('international');
            	Boolean emi = (Boolean)card.get('emi');
            	String sub_type = (String)card.get('sub_type');
            	String token_iin = (String)card.get('token_iin');
            }else if(method == 'netbanking'){
                type = 'Net Banking - '+(String)entity.get('bank');
            }else if(method == 'upi'){
                type = 'Upi Payment';        
            }else if(method == 'wallet'){
                type = 'Wallet Payment - ' +(String)entity.get('wallet');
            }
            	//notes
            	Map<String, Object> notes;
				String invoice_id;
            	String emailId; //email for paywithoutinvoice
            	String Phone; // phone for paywithoutinvoice
				System.debug(entity.get('notes'));
            	
                if(entity.get('notes')!=null){
            		notes= (Map<String, Object>)entity.get('notes');
            		invoice_id = (String)notes.get('invoice_number');
                    emailId = (String)notes.get('email');
                    Phone = (String)notes.get('phone');
                }
            
                String bank = (String)entity.get('bank');
                String wallet = (String)entity.get('wallet');
                String vpa = (String)entity.get('vpa');
                String email = (String)entity.get('email');
                String contact = (String)entity.get('contact');
                String token_id = (String)entity.get('token_id');
                Decimal fee = (Decimal)entity.get('fee');
                Decimal tax = (Decimal)entity.get('tax');
                String error_code = (String)entity.get('error_code');
                String error_description = (String)entity.get('error_description');
                String error_source = (String)entity.get('error_source');
                String error_step = (String)entity.get('error_step');
                String error_reason = (String)entity.get('error_reason');
            	
            	// Process Input and Create Payment Record If it not availble
            	// 
            	 
            System.debug('invoice_id'+invoice_id);         
            if(event == 'payment.captured'){
                if(!String.isBlank(invoice_id)){
                    blng__Payment__c paymentRec;
                    List<blng__Invoice__c> invoice = [select Id,blng__Balance__c,blng__TotalAmount__c,ST_Invoice_Series__c,blng__Account__c from blng__Invoice__c where ST_Invoice_Series__c = :invoice_id limit 1]; 
                    if(!invoice.isEmpty()){
                        List<blng__Payment__c> paymentRecList = [Select Id,blng__Amount__c,blng__Account__c,blng__Invoice__c,CurrencyIsoCode,blng__PaymentMode__c,
                                                      blng__PaymentType__c,blng__RequestCreditCardNumber__c,blng__Status__c,blng__Notes__c,RazorPayment_ID__c from blng__Payment__c where blng__Invoice__c = :invoice[0].Id AND blng__PaymentType__c = 'Razorpay'];
                        if(paymentRecList.size() < 1){
                            paymentRec = new blng__Payment__c();
                            paymentRec.blng__Account__c = invoice[0].blng__Account__c;
                            //blng__AllocationStatus__c
                            //paymentRec.blng__Amount__c = amount/100;
                            paymentRec.blng__Amount__c = invoice[0].blng__TotalAmount__c;
                            paymentRec.blng__Invoice__c =invoice[0].Id;
                            paymentRec.blng__PaymentDate__c = System.today();
                            //blng__PaymentDescription__c
                            //blng__PaymentGateway__c 
                            paymentRec.CurrencyIsoCode = currencyValue;
                            //blng__PaymentMethod__c
                            //paymentRec.blng__PaymentMode__c = method;                           
                            paymentRec.blng__RequestCreditCardNumber__c=last4;
                            paymentRec.blng__PaymentType__c = 'Razorpay';
                            paymentRec.blng__Status__c = 'Posted';
                            paymentRec.blng__Notes__c='Payment Successful with RazorPay';
                            paymentRec.RazorPayment_ID__c = id;
                            system.debug(paymentRec);
                        	//insert paymentRec;
                            
                        }
                        else{                    
                        	paymentRec = paymentRecList[0];
                            system.debug(paymentRec+ 'from else');
                        }
                        upsert paymentRec;
                        //
                        //
                        blng__PaymentAllocationInvoice__c paymentAllocation = new blng__PaymentAllocationInvoice__c();
                        paymentAllocation.blng__Amount__c = amount/100;
                        paymentAllocation.blng__Invoice__c = invoice[0].Id;
                        paymentAllocation.blng__Payment__c = paymentRec.Id;
                        paymentAllocation.blng__Type__c = 'Allocation';//Unallocation?
                        paymentAllocation.blng__Unallocated__c = false;//true? 
                        paymentAllocation.CurrencyIsoCode = currencyValue;
                        paymentAllocation.Payment_Type__c = type;
                        paymentAllocation.RazorPay_PaymentId__c = id;
                        insert paymentAllocation;
                        
                    } 
                    else{// There is no invoice found
                    PayWithoutInvoice__c paydata = new PayWithoutInvoice__c(); 
                    paydata.Currency__c = 'INR';
                    paydata.CurrencyIsoCode = currencyValue;
                    paydata.Email__c = emailId!=null?emailId:email;
                    paydata.Method__c = method;
                    paydata.Description__c = description;
                    paydata.Order_ID__c = order_id;
                    paydata.Fee__c = fee;
                    paydata.Tax__c =tax;
                    paydata.Created_At__c = system.today();
                    paydata.Payment_Id__c = id;
                    paydata.Notes__c = invoice_id;                   
                    paydata.Contact__c = Phone!=null?Phone:Contact;
                    paydata.amount__c = amount/100;
                    paydata.Status__c = status;
                    insert paydata;  
                }
                }
                else{// There is no invoice found
                    PayWithoutInvoice__c paydata = new PayWithoutInvoice__c(); 
                    paydata.Currency__c = 'INR';
                    paydata.CurrencyIsoCode = currencyValue;
                    paydata.Email__c = emailId!=null?emailId:email;
                    paydata.Method__c = method;
                    paydata.Description__c = description;
                    paydata.Order_ID__c = order_id;
                    paydata.Fee__c = fee;
                    paydata.Tax__c =tax; 
                    paydata.Created_At__c = system.today();
                    paydata.Payment_Id__c = id;
                    paydata.Notes__c = invoice_id;                   
                    paydata.Contact__c = Phone!=null?Phone:Contact;
                    paydata.amount__c = amount/100;
                    paydata.Status__c = status;
                    insert paydata; 
                }
                
            }
            if(event == 'refund.processed'){
                if(!String.isBlank(invoice_id)){                    
                    List<blng__Invoice__c> invoice = [select Id,ST_Invoice_Series__c,blng__Account__c from blng__Invoice__c where ST_Invoice_Series__c = :invoice_id]; 
                    if(!invoice.isEmpty()){
                        List<blng__Refund__c> refundList = [select Id,blng__Account__c,blng__Status__c,blng__RefundMode__c from blng__Refund__c where blng__Account__c = :invoice[0].blng__Account__c];
                        blng__Payment__c paymentRec = [Select Id from blng__Payment__c where blng__Invoice__c = :invoice[0].Id AND blng__PaymentType__c = 'Razorpay'];
                        blng__Refund__c refund = new blng__Refund__c ();
                        system.debug(refundList);
                        if(refundList.isEmpty()){                        
                            refund.blng__Account__c = invoice[0].blng__Account__c;                        
                            refund.blng__Status__c='Posted';
                            refund.blng__RefundMode__c = 'External';
                            insert refund;
                            system.debug('refund inserted');
                        } 
                        else{
                        	refund = refundList[0];
                            system.debug('refund not inserted');
                            }
                        blng__PaymentAllocationInvoice__c paymentAllocation = new blng__PaymentAllocationInvoice__c();
                        paymentAllocation.blng__Amount__c = refund_amount/100;
                        paymentAllocation.blng__Invoice__c = invoice[0].Id;
                        paymentAllocation.blng__Payment__c = paymentRec.Id;
                        paymentAllocation.blng__Type__c = 'Unallocation';//Unallocation?
                        paymentAllocation.blng__Unallocated__c = true;//true? 
                        paymentAllocation.CurrencyIsoCode = currencyValue;
                        paymentAllocation.Payment_Type__c = type;
                        paymentAllocation.RazorPay_PaymentId__c = refund_id;
                        insert paymentAllocation;
                        system.debug('paymentallocation created');
                        //
                        blng__RefundLinePayment__c refundLineItem = new blng__RefundLinePayment__c();
                        refundLineItem.blng__Amount__c = refund_amount/100;
                        system.debug(refund_amount);
                        refundLineItem.blng__Payment__c = paymentRec.Id;
                        refundLineItem.blng__Refund__c = refund.Id;
                        //refundLineItem.blng__Status__c	='Posted';
                        refundLineItem.blng__RefundLineDate__c = system.today();
                        refundLineItem.blng__Type__c = 'Unallocation';
                        //blng__Unallocated__c
                        insert refundLineItem;
                        system.debug('refundlineitem created');
                    }  
                    else{// There is no invoice found
                    PayWithoutInvoice__c paydata = new PayWithoutInvoice__c(); 
                    paydata.Currency__c = 'INR';
                    paydata.CurrencyIsoCode = currencyValue;
                    paydata.Email__c = emailId!=null?emailId:email;
                    paydata.Method__c = method;
                    paydata.Description__c = description;
                    paydata.Order_ID__c = order_id;
                    paydata.Fee__c = fee;
                    paydata.Tax__c =tax;
                    paydata.Created_At__c = system.today(); 
                    paydata.Payment_Id__c = id;
                    paydata.Notes__c = invoice_id;                   
                    paydata.Contact__c = Phone!=null?Phone:Contact;
                    paydata.amount__c = amount/100;
                    paydata.Status__c = status;
                    insert paydata;   
                }
                    
                }
                else{// There is no invoice found
                    PayWithoutInvoice__c paydata = new PayWithoutInvoice__c(); 
                    paydata.Currency__c = 'INR';
                    paydata.CurrencyIsoCode = currencyValue;
                    paydata.Email__c = emailId!=null?emailId:email;
                    paydata.Method__c = method;
                    paydata.Description__c = description;
                    paydata.Order_ID__c = order_id;
                    paydata.Fee__c = fee;
                    paydata.Tax__c =tax; 
                    paydata.Created_At__c = system.today();
                    paydata.Payment_Id__c = id;
                    paydata.Notes__c = invoice_id;                   
                    paydata.Contact__c = Phone!=null?Phone:Contact;
                    paydata.amount__c = amount/100;
                    paydata.Status__c = status;
                    insert paydata;    
                }
                
                
            }
            	
        }
        catch(exception e){  
            system.debug('Exception happened is:'+e.getmessage());
        }
    }
   
}