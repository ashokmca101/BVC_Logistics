public class RazorpayAllocationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    String query = 'SELECT Id,Name,'
        +' Razorpay_Id__c,Short_URL__c,blng__Account__c,ST_Invoice_Series__c,blng__TotalAmount__c,'
        +' (SELECT Id,Name,blng__Amount__c,blng__Invoice__c,'
        +' blng__PaymentType__c FROM blng__Payments__r WHERE blng__PaymentType__c = \'Razorpay\' Order By createdDate desc LIMIT 1),'
        +' (SELECT id,blng__Payment__c,RazorPay_PaymentId__c from blng__PaymentInvoiceAllocations__r WHERE '
        +' blng__Payment__r.blng__PaymentType__c = \'Razorpay\' AND RazorPay_PaymentId__c != null)'
        +' FROM blng__Invoice__c'
        +' WHERE Razorpay_Id__c != null'
        +' AND  Short_URL__c != null'
        +' AND blng__InvoiceStatus__c = \'Posted\''
        +' AND blng__PaymentStatus__c != \'Paid\''
        +' AND CreatedDate <= LAST_N_DAYS:10 ';   
    API_Integration_Credential__mdt razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');
    string endpoint = razorPayLoginCredentials.Server_URL__c+'/';
    //string method = 'GET';  
    //
    string username = razorPayLoginCredentials.UserName__c; 
    string password = razorPayLoginCredentials.Password__c;
   
    public Database.QueryLocator Start(Database.BatchableContext bc){
        /*String str = 'abc-xyz-123';
        List < String > strList = str.split( '-' );
        System.debug( 'List String is ' + strList );*/
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<blng__Invoice__c> scope){
        List<String> rpayIds = new List<String>();        
        //system.debug('Invoice List:::Batch:::' +scope);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        PaymentBuilder.paymentLinkGenerator(endpoint,authorizationHeader,scope); 
        // PaymentBuilder.paymentLinkGenerator(endpoint+'?type=link',authorizationHeader,true); 
        
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}