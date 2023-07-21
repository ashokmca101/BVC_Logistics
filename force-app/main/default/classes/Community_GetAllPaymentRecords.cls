global without sharing class Community_GetAllPaymentRecords implements Database.Batchable<sObject>,Database.AllowsCallouts{
   
    String query = 'SELECT Id,Name,'
        +' Razorpay_Id__c,Short_URL__c'
        +' FROM Shipment__c'
        +' WHERE Razorpay_Id__c != null'
        +' AND  Short_URL__c != null AND Id !=:'+'a0A1m00000103o5EAA'+' AND Id !=:'+'a0A1m00000103nbEAA';
        //+' AND blng__InvoiceStatus__c = \'Posted\''
        //+' AND blng__PaymentStatus__c != \'Paid\' ';
    string endpoint = Label.Razorpay_Endpoint_getAllPayment;    //'https://api.razorpay.com/v1/payment_links/'; 
    string method = 'GET';  
    string username = Label.Razorpay_Username_Community;   //'rzp_test_L0SDLcmzd1ALse'; 
    string password = Label.Razorpay_Password_Community;   //'Xan2xYD0MaOwOwQtNMX2icKa';
    public Database.QueryLocator Start(Database.BatchableContext bc){
        //return Database.getQueryLocator(query);
        return Database.getQueryLocator([SELECT Id,Name, Razorpay_Id__c,Short_URL__c,Customer__r.Id FROM Shipment__c 
                                         WHERE Razorpay_Id__c != null AND  Short_URL__c != null 
                                         AND createddate = today]);
    }
    global void execute(Database.BatchableContext bc,List<Shipment__c> scope){
        List<Shipment_Payment__c> lstShipPay = [SELECT Id,Shipment__c FROM Shipment_Payment__c WHERE Shipment__c=:scope ];
        system.debug('lstShipPay::'+lstShipPay);
        if(lstShipPay.size()>0){
           delete lstShipPay; 
        }
        system.debug('Invoice List:::Batch:::'+scope);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
            system.debug('authorizationHeader:::'+authorizationHeader);
        	Community_PaymentBuilder.paymentLinkGenerator(endpoint,authorizationHeader,scope); 
           //PaymentBuilder.fetchAllPaymentsDoneByUser();
        
    }
    global void finish(Database.BatchableContext bc){
        
    }
}