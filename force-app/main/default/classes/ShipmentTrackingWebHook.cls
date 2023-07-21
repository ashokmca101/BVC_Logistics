//@RestResource(urlMapping='/BVCWebhook/rest/BVC/*')
global with sharing class ShipmentTrackingWebHook {
    public class PayloadBody {
        // Shipment__c
       // public String Id;
        public String Shipment_Note_No;
        public String Scan_Time;
        public String City;
        public String Location;
        public String HubName;
        public String Estimated_Delivery_Date;    
        public String Actual_Delivery_Date;
        public String POD;     
    }    
    public static string jsonContent(List<Shipment_Tracking__c> st)
    {
        PayloadBody pl = new PayloadBody(); 
       // pl.Id = st[0].Shipment__c;
        pl.Shipment_Note_No = st[0].Shipping_Note_No__c;
        pl.Scan_Time = string.valueOf(st[0].Scan_Time__c);
       // pl.Scan_Time = '';
        pl.City = st[0].Scanned_City__c;
        pl.Location = st[0].Location__c;
        System.debug('Hub Id :'+st[0].Hub__c);
        if(st[0].Hub__c!=null)
        {
            System.debug('Null');
        }        
        
        if(st[0].Hub__c!=null)
        {
            Hub__c h = [select Name from Hub__c where Id =: st[0].Hub__c limit 1];
            pl.HubName = h.Name;  // st[0].Hub__r.Name;            
        }
        
        pl.Estimated_Delivery_Date = string.valueOf(st[0].Est_Delivery_Date__c);
       // pl.Actual_Delivery_Date = string.valueOf(st[0].Act_Delivery_Date__c);
        DateTime dT = st[0].Act_Delivery_Date__c;
        //Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        //pl.Actual_Delivery_Date = string.valueOf(myDate);
        pl.POD ='';   
        String jsonstring = Json.serialize(pl);
       // jsonstring = jsonstring.replace('{','[{');
       // jsonstring = jsonstring.replace('}','}]');                
        System.debug('11. jsonstring :'+jsonstring);
        return jsonstring;
    }
   // @HttpPost
     @future(callout=true)   
    global static void sendRequest(String jsonstring){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        // req.setEndpoint('');               
        API_Integration_Credential__mdt Tracking_Webhook_url = API_Integration_Credential__mdt.getInstance('Tracking_Webhook_url');        
       // API_Integration_Credential__mdt Tracking_Webhook_url = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');        // it is kept here for testing
        String endpoint = Tracking_Webhook_url.Server_URL__c;
       /* endpoint = endpoint +'/'; 
        string username = Tracking_Webhook_url.UserName__c; 
        string password = Tracking_Webhook_url.Password__c;
		Blob headerValue = Blob.valueOf(username + ':' + password);
        Blob headerValue = Blob.valueOf(headerValue);
        System.debug('12.headerValue :'+headerValue); 
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		*/
        req.setEndpoint(endpoint);
        req.setMethod('POST');        
        req.setHeader('Username', 'Ravindra');
        req.setHeader('Password', 'bvc@123');
        req.setHeader('Content-Type','application/json');
        req.setBody(jsonstring);      
       // req.setBody('{"ID":0}');
        
        req.setTimeout(120000);        
        String printUrl = req.toString();
        System.debug(' printUrl :'+printUrl);
        System.debug(' getBody :'+req.getBody());
        System.debug(' getEndpoint :'+req.getEndpoint());
        //System.debug(' authorizationHeader :'+req.getHeader('Authorization'));
        System.debug(' req :'+req);
        //req.setCompressed(true);                        
        try {
            resp = http.send(req);
            System.debug('Response :'+resp);
            System.debug('Response getStatusCode:'+resp.getStatusCode());
            System.debug('Response getStatus:'+resp.getStatus());
           // System.debug('Response getBodyDocument:'+resp.getBodyDocument());
            System.debug('Response Body :'+resp.getBody());
        }  catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(resp.toString());
        }        
    }
}