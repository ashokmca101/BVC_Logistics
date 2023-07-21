public without sharing class Community_PaymentBuilder {
    public static void paymentLinkGenerator(String endpoint,String authorizationHeader,List<Shipment__c> lstShipments){
        Map<Id,Shipment_Payment__c> mapPayments = new Map<Id,Shipment_Payment__c>();
        List<Shipment_Payment__c> lstShipPay = new List<Shipment_Payment__c>();
        String method = 'GET'; 
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        //req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);
        
        req.setHeader('Authorization', authorizationHeader);
        for(Shipment__c shipObj : lstShipments){
            
            
            System.debug('Invoice id--->'+shipObj.Id);
            string plinkd = shipObj.Razorpay_Id__c.replace('inv','plink');
            system.debug('Invoice RID+++-->  '+shipObj.Razorpay_Id__c+'RazorPay Id+++---> '+plinkd);
            //invMap.put(plinkd,inv);
            req.setEndpoint(endpoint+plinkd);
            System.debug('End Point ::::'+endpoint+plinkd);
            try{
                res = ht.send(req);
            }catch(Exception Ex){
                system.debug('Payment Details Callout failed'+ex.getMessage());
                Exception_Log__c apiException = new Exception_Log__c();
                apiException.API_Status__c = 'failed';
                apiException.Exception_Message__c = ex.getMessage();
                insert apiException;
            }
            
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                
                system.debug(':::Fetch All Payment Httpresponse:::'+res.getBody());
                //FetchPaymentWrapperShipment wrap = FetchPaymentWrapperShipment.parse(res.getBody());
                //system.debug('wrap:::'+wrap);
                Community_FetchPaymentWrapperShipment paymentJsonObj = (Community_FetchPaymentWrapperShipment)System.JSON.deserialize(res.getBody(),Community_FetchPaymentWrapperShipment.Class);
                //system.debug('Customer'+paymentJsonObj.customer.name);
                    
                
                system.debug('paymentJsonObj::'+paymentJsonObj);
                //system.debug('::: To deserialize JSON:::'+(FetchPaymentWrapperShipment)JSON.deserialize(res.getBody(),FetchPaymentWrapperShipment.Class));
               
                
                List<Community_FetchPaymentWrapperShipment.payments> allPayments = new List<Community_FetchPaymentWrapperShipment.payments>();
                system.debug('allPayments::'+allPayments);
                allPayments.addAll(paymentJsonObj.payments); 
                
                for(Community_FetchPaymentWrapperShipment.payments pay : allPayments){
                    Shipment_Payment__c shipPay = new  Shipment_Payment__c();
                    shipPay.Shipment__c = shipObj.Id;
                    shipPay.Customer__c = shipObj.Customer__c;
                    shipPay.Invoice_Id__c = shipObj.Id;
                    shipPay.Payment_Id__c = pay.payment_id;
                    shipPay.Amount__c =(pay.amount != null? pay.amount/100 : 0); 
                    shipPay.Payment_Mode__c = 'Electronic';
                    shipPay.Payment_Type__c = 'Credit Card';
                    String createdDate = string.valueOf(pay.created_at)+'000';
                    DateTime dt = Datetime.newInstance( Long.valueOf( createdDate ) );
                    Date myDate = date.newinstance(dt.year(), dt.month(), dt.day());
                    System.debug('My date is-----'+myDate);
                    shipPay.Payment_Date__c = myDate;
                    system.debug('shipPay::'+shipPay);
                    lstShipPay.add(shipPay);
                    mapPayments.put(shipObj.Id,shipPay);
                }
                //insert lstShipPay;
                if(paymentJsonObj != null && paymentJsonObj.payments != null && paymentJsonObj.payments.size() > 0){
                    //Shipment_Payment__c shipPay = new  Shipment_Payment__c();
                    //shipPay.Invoice_Id__c = shipObj.Id;
                    //shipPay.Amount__c = shipObj.;
                    //payment.blng__Amount__c = pay.amount;
                    //shipPay.blng__Status__c = 'Posted';
                    //shipPay.blng__Notes__c = 'Payment Successful with RazorPay';
                    //shipPay.blng__PaymentType__c = 'Razorpay';
                    //shipPay.blng__Status__c = 'Posted';
                    
                }
                
                
                
                
              
                //system.debug('**Response Code**'+res.getStatusCode()+'**Second Response Body**'+res.getBody()+'**Error Detail**'+res.getStatus());
            } 
        }  
        
        try {
            insert lstShipPay;
            //insert mapPayments.values();
            /*List<Shipment_Payment__c> insertPaymentList = new List<Shipment_Payment__c>();
            for(Id invId:mapPaymentAllocations.keySet()){
                for(Shipment_Payment__c payment : mapPaymentAllocations.get(invId)){
                    if(mapPayments.containsKey(invId)){
                        payment.blng__Payment__c = mapPayments.get(invId).Id;
                        insertPaymentList.add(payment);
                    }
                }
            }

            insert insertPaymentList;

            */

        } catch (Exception ex) {
            System.debug(' ex message  '+ex.getMessage());
            System.debug('Line Number   '+ex.getLineNumber());
        }
        
    }
   /* @future
    public static void updateShipmentRecords(String wraplist)
    {   
        List<PaymentBuilder.Wrapper> shipmentWrapList = (List<PaymentBuilder.Wrapper>)Json.deserialize(wraplist,List<PaymentBuilder.Wrapper>.class);
        List<Shipment__c> shipmentList = new  List<Shipment__c> ();
        for(PaymentBuilder.Wrapper wrap: shipmentWrapList){
            Shipment__c shipmentObj = new Shipment__c(Id=wrap.shipmentId,Short_URL__c = wrap.URL);
            shipmentList.add(shipmentObj);
            
        }
        update shipmentList;
    }
    //Map<Id,Shipment__c> mapToUpdateShipment = new Map<Id,Shipment__c>();
    public static List<Shipment__c> paymentCreator(HttpResponse response){
        Map<String,Object> paymentJsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        system.debug('paymentJsonMap::'+paymentJsonMap);
        String invName = (String)paymentJsonMap.get('receipt');
        System.debug('***Invoice name from Response***'+invName);
        Shipment__c shipObj = [SELECT Id,Name,Invoice_Paid_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,Total_Invoice_Value__c,Customer__c,Customer__r.Name FROM Shipment__c WHERE Id = :invName LIMIT 1];
        //blng__Invoice__c inv = [SELECT Id,Name,blng__Account__c,blng__TotalAmount__c FROM blng__Invoice__c WHERE Name = :invName LIMIT 1];
        system.debug('Invoice ');
        shipObj.Short_URL__c = (String)paymentJsonMap.get('short_url');
        shipObj.Razorpay_Id__c = (String)paymentJsonMap.get('id');
        //mapToUpdateShipment.put(shipObj.Id, shipObj);
        List<Shipment__c> lstShipToUpdate = new List<Shipment__c>();
        lstShipToUpdate.add(shipObj);
        try{
            
            update shipObj;
        }catch(Exception Ex){
            system.debug('Invoice Update From Response failed ::: '+Ex.getMessage());
        }
        Shipment_Payment__c payment = new Shipment_Payment__c();
        payment.Customer__c = shipObj.Customer__c;
        payment.Amount__c = shipObj.Invoice_Calculated_Amount__c;
        payment.Shipment__c = shipObj.Id;
        payment.Payment_Date__c = System.today();
        payment.Short_URL__c = (String)paymentJsonMap.get('short_url');
        payment.Razorpay_Id__c = (String)paymentJsonMap.get('id');
        try{
            //insert payment;
        }catch(Exception Ex){
            system.debug('Payment Insert From Response failed ::: '+Ex.getMessage());
        }
        return lstShipToUpdate;
    }
    
    
    

    public static void fetchAllPaymentsDoneByUser(){
        Date today = Date.today().addDays(-1);
        Datetime todayDateTime = today; // Implicit cast
        System.debug('Today is ' + todayDateTime);
        System.debug('Today is also ' + (Datetime) today); // Explicit cast
        Long timestamp = todayDateTime.getTime();
        system.debug(timestamp/1000 );
        
        Long foo = timestamp/1000;
        //system.debug( DateTime.newInstance(foo));
        //1624406400
        String method = 'GET'; 
        String endpoint = 'https://api.razorpay.com/v1/payments?count=100&from='+foo; 
        string username = 'rzp_test_L0SDLcmzd1ALse'; 
        string password = 'Xan2xYD0MaOwOwQtNMX2icKa';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);
        
        
        req.setHeader('Authorization', authorizationHeader);
        try{
            res = ht.send(req);
            createPaymentRecords(res);
        }catch(Exception Ex){
            system.debug('Payment Details Callout failed'+ex.getMessage());
        }
        system.debug('**Response Code**'+res.getStatusCode()+'**Second Response Body**'+res.getBody()+'**Error Detail**'+res.getStatus());
    }
    
    public static void createPaymentRecords(HttpResponse response){
        
        system.debug(':::Fetch All Payment Httpresponse:::'+response.getBody());
        system.debug('::: To deserialize JSON:::'+(PaymentResponseJSONParser)JSON.deserialize(response.getBody(),PaymentResponseJSONParser.Class));
        PaymentResponseJSONParser paymentJsonMap = (PaymentResponseJSONParser)JSON.deserialize(response.getBody(),PaymentResponseJSONParser.Class);
        system.debug('<<Deserialized JSON>>'+paymentJsonMap);
        List<PaymentResponseJSONParser.items> allPayments = new List<PaymentResponseJSONParser.items>();
        allPayments.addAll(paymentJsonMap.items);
        system.debug('allPayments::'+allPayments);
        Set<String> invoiceIds = new Set<String>();
        for(PaymentResponseJSONParser.items obj : allPayments){
            invoiceIds.add(obj.id);
        }
        system.debug('invoiceIds::'+invoiceIds);
        List<Shipment__c> lstShipment = [SELECT Id,Name,Invoice_Paid_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,
                                         Total_Invoice_Value__c,Customer__c,Customer__r.Name,Razorpay_Id__c,
                                         (SELECT Invoice_Id__c,Name,Payment_Id__c FROM Shipment_Payments__r)
                                         FROM Shipment__c 
                                         WHERE Razorpay_Id__c IN :invoiceIds];
        system.debug('lstShipment::'+lstShipment);
        system.debug('lstShipment::'+lstShipment.size());
        //List<Shipment_Payment__c> lstShipmentPayment = [SELECT Invoice_Id__c,Name FROM Shipment_Payment__c ];
        Map<String,List<Shipment_Payment__c>> invPaymentmap = new Map<String,List<Shipment_Payment__c>>();
        Map<String,Shipment__c> shipPaymentmap = new Map<String,Shipment__c>();
        for(Shipment__c inv : lstShipment){
            //system.debug('Invoice Name:::'+inv.Name);
            //system.debug('Payments Related:::'+inv.Shipment_Payments__r);
            if(inv.Shipment_Payments__r != null && inv.Razorpay_Id__c!= null){
                //system.debug('Payments Related:::'+inv.Shipment_Payments__r);
                //invPaymentmap.put(inv.Razorpay_Id__c,new List<Shipment_Payment__c>{inv.Shipment_Payments__r});
                shipPaymentmap.put(inv.Razorpay_Id__c,inv);
            }   
        }
        List<Shipment_Payment__c> lstShipToInsert = new List<Shipment_Payment__c>();
        system.debug('lstShipment::'+lstShipment);
        for(PaymentResponseJSONParser.items obj : allPayments){            
            if(shipPaymentmap.containskey(obj.invoice_id)){
                system.debug('shipPaymentmap.get(obj.invoice_id):::'+shipPaymentmap.get(obj.invoice_id));
                system.debug('found Id');
                Shipment_Payment__c payment = new Shipment_Payment__c();
                payment.Amount__c = (decimal.valueOf(obj.amount))*0.01;
                payment.Amount_Refunded__c = decimal.valueOf(obj.amount_refunded);
                payment.Bank__c = obj.bank;
                payment.Customer__c = shipPaymentmap.get(obj.invoice_id).Customer__c;
                payment.Card_Id__c = obj.card_id;
                payment.Shipment__c = shipPaymentmap.get(obj.invoice_id).Id;
                payment.Customer_Id_RazorPay__c = obj.customer_id;
                payment.Error_Code__c = obj.error_code;
                payment.Error_Description__c = obj.error_description;
                payment.Error_Reason__c = obj.error_reason;
                payment.Invoice_Id__c = obj.invoice_id;
                payment.Order_Id__c = obj.order_id;
                payment.Payment_Id__c = obj.Id;
                payment.Payment_Mode__c = 'Electronic';
                payment.Payment_Type__c = 'Credit Card';
                String createdDate = string.valueOf(obj.created_at)+'000';
                DateTime dt = Datetime.newInstance( Long.valueOf( createdDate ) );
                Date myDate = date.newinstance(dt.year(), dt.month(), dt.day());
                System.debug('My date is-----'+myDate);
                payment.Payment_Date__c = myDate;
                lstShipToInsert.add(payment);   
            }
            else{
                system.debug('Not found');
            }  
        }
        system.debug('lstShipToInsert:::'+lstShipToInsert);
        system.debug('lstShipToInsert:::'+lstShipToInsert.size());
        insert lstShipToInsert;
    }
    
    public class Wrapper{
        public Id shipmentId;
        public String URL;
    }*/
    
}