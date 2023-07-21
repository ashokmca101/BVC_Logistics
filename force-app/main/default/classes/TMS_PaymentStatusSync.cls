/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 04-25-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TMS_PaymentStatusSync {  
    
    @InvocableMethod(label='Get Payment Status' description='Update Payment Status on Invoice')
    public static void SyncPayment(List<Shipment__c> shipmentList) {
        
        List<SyncWrapper> recordDataList = new List<SyncWrapper>();
        List<blng__Invoice__c> invoiceList = new List<blng__Invoice__c>();
        API_Integration_Credential__mdt razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');
        
        String endpoint = razorPayLoginCredentials.Server_URL__c+'/';     
        String username = razorPayLoginCredentials.UserName__c; 
        String password = razorPayLoginCredentials.Password__c;
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        
        for(Shipment__c shipment : shipmentList){
            recordDataList.add(currentInvoice(shipment));
        }    
        
        if(recordDataList.size() > 0 ){
            for(SyncWrapper data :recordDataList ){
                if(data.invoiceData != null){
                    invoiceList.add(data.invoiceData);
                }
            }
        }
        
        System.debug('======= Invoice List =======: '+invoiceList);  
        System.debug('======= endpoint =======: '+endpoint);  
        System.debug('======= authorizationHeader =======: '+authorizationHeader);  
        
        if(invoiceList.size()>0){
            PaymentBuilder.paymentLinkGenerator(endpoint,authorizationHeader,invoiceList); 
        }
    }
    
    public static syncWrapper currentInvoice(Shipment__c shipmentRecord){
       	System.debug('====== Shipment ======'+shipmentRecord);
        Set<id> orderIdSet = new Set<Id>();
        SyncWrapper syncRecord = new SyncWrapper();
        
        if(shipmentRecord != null){
            syncRecord.shipmentData = shipmentRecord;
            for(Order orderRcord : [SELECT Id, Shipment__C FROM Order WHERE Shipment__C =: shipmentRecord.Id AND Valid_Order__c = true ORDER BY CreatedDate DESC LIMIT 1]){
                orderIdSet.add(orderRcord.Id);
                syncRecord.orderData = orderRcord;
            }
            
        }
        
        
        
        if(orderIdSet.size() > 0){
            for(blng__Invoice__c  invoiceRecord : [ SELECT Id,Name,Razorpay_Id__c,Short_URL__c,blng__Account__c,blng__TotalAmount__c, (SELECT Id,Name,blng__Amount__c,blng__Invoice__c, blng__PaymentType__c FROM blng__Payments__r WHERE blng__PaymentType__c = 'Razorpay' Order By createdDate desc LIMIT 1), (SELECT id,blng__Payment__c,RazorPay_PaymentId__c from blng__PaymentInvoiceAllocations__r WHERE blng__Payment__r.blng__PaymentType__c = 'Razorpay' AND RazorPay_PaymentId__c != null)  FROM blng__Invoice__c  WHERE Razorpay_Id__c != null AND  Short_URL__c != null AND blng__InvoiceStatus__c = 'Posted' AND blng__PaymentStatus__c != 'Paid 'AND blng__Order__c IN: orderIdSet ORDER BY CreatedDate DESC]){
                syncRecord.invoiceData = invoiceRecord;
            }
        }
        System.debug('=======syncRecord ====: '+syncRecord);
        return  syncRecord;
    }
    
    
    
    Class syncWrapper{
        Shipment__C shipmentData;
        Order orderData;
        blng__Invoice__c invoiceData;
        
        public syncWrapper(){
            shipmentData = new Shipment__C();
            orderData = new Order();
            invoiceData = new blng__Invoice__c();
        }
    }
}