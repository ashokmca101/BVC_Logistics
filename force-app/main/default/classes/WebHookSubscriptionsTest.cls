@isTest
Public class WebHookSubscriptionsTest {
    @testSetup
    static void testSetup(){
        Entity__c ent = TestUtility.createBVCEntity();
        insert ent;
        
        Active_Pincode__c pin = TestUtility.createPinCode();
        insert pin;
        
        blng__LegalEntity__c legEntity = TestUtility.createLegalEntity(ent);
        insert legEntity;
        
        List<Hub__c> branches = new  List<Hub__c>();
        Hub__c bvcBranch = TestUtility.createBVCBranch(legEntity, pin);
        insert bvcBranch;
        
        List<Account> accList = new List<Account>();
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonAcrNonContractedAccount.Billing_Frequency__c = 'Weekly';
        nonAcrNonContractedAccount.Last_Name__c = 'Test';
        accList.add(nonAcrNonContractedAccount);
        insert accList;
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        insert blngAddress;
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        update accList[0];
        
        blng__InvoiceScheduler__c scheduler = TestUtility.createInvoiceScheduler();
        insert scheduler;
        blng__InvoiceRun__c invRun  = testUtility.createInvoiceRun(scheduler);
        insert invRun;
        blng__Invoice__c inv = TestUtility.createConsolidatedInvoice(accList[0],invRun.Id,bvcBranch);
        inv.BVC_Branch__c  = bvcBranch.Id;
        inv.BVC_Billing_Entity__c = bvcBranch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = bvcBranch.BVC_Entity__c;
        inv.Billing_Address__c = blngAddress[0].Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = TestUtility.createConsolidatedInvoiceLine(inv);
        invLine.ST_Offline_Charge__c = 2000;
        invLine.Freight_Charges__c = 15000;
        invLine.Liability_Charges__c = 3000;
        insert invLine;
    }
    @isTest
    public static void testhandleNotification(){
        test.startTest();
        blng__Invoice__c inv = [SELECT Id,blng__TotalAmount__c,blng__InvoiceStatus__c,blng__Account__c,blng__PaymentStatus__c,Razorpay_Id__c,Short_URL__c FROM blng__Invoice__c LIMIT 1];
        system.debug(inv);
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.ST_Invoice_Series__c = '27TI19523';
        update inv;
        // test payment capture
        webHookSubscriptions test1 = new webHookSubscriptions();
        String JsonMsg='{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"payment.captured","contains":["payment"],'
             +'"payload":{"payment":{"entity":{"id":"pay_JyHJj5DLxRqUzR","entity":"payment","amount":100000,"currency":"INR","status":"captured","order_id":"order_JyHIgSnXFxBRb9",'
             +'"invoice_id":null,"international":false,"method":"card","amount_refunded":0,"refund_status":null,"captured":true,"description":"#JyHHj4qEDpnRx6","card_id":"card_JqQ0DmdCJsRmp3",'
             +'"card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test","last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer",'
             +'"token_iin":null},"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK","notes":{"invoice_number":"27TI19523"},'
             +'"fee":10620,"tax":1620,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"262733"},"created_at":1658900439}}},'
             +'"created_at":1658900444}';
	RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/Pushnotification';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    req.requestBody = Blob.valueof(JsonMsg);
    RestContext.request = req;
    RestContext.response= res;
    webHookSubscriptions.handleNotification();
    /// test Refund Call
    String JsonRefundMsg= '{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"refund.processed","contains":["refund","payment"],'
			 +'"payload":{"refund":{"entity":{"id":"rfnd_Jyjl5OmuGYpSjf","entity":"refund","amount":500000,"currency":"INR","payment_id":"pay_JyHJj5DLxRqUzR","notes":{"comment":""},"receipt":null,'
			 +'"acquirer_data":{"arn":null},"created_at":1659000598,"batch_id":null,"status":"processed","speed_processed":"normal","speed_requested":"normal"}},'
			 +'"payment":{"entity":{"id":"pay_JyHJj5DLxRqUzR","entity":"payment","amount":1000000,"currency":"INR","base_amount":1000000,"status":"captured","order_id":"order_JyHIgSnXFxBRb9","invoice_id":null,'
			 +'"international":false,"method":"card","amount_refunded":500000,"amount_transferred":0,"refund_status":"partial","captured":true,"description":"#JyHHj4qEDpnRx6","card_id":"card_JqQ0DmdCJsRmp3",'
			 +'"card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test","last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer","token_iin":null},'
			 +'"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK","notes":{"invoice_number":"27TI19523"},"fee":10620,"tax":1620,"error_code":null,'
			 +'"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"262733"},"created_at":1658900439}}},"created_at":1659000598}';        
    RestRequest reqRefund = new RestRequest(); 
    RestResponse resRefund = new RestResponse();
    reqRefund.requestURI = '/services/apexrest/Pushnotification';  //Request URL
    reqRefund.httpMethod = 'POST';//HTTP Request Type
    reqRefund.requestBody = Blob.valueof(JsonRefundMsg);
    RestContext.request = reqRefund;
    RestContext.response= resRefund;
    webHookSubscriptions.handleNotification();
    // test Pay without invoice
    string JsonWithoutInvoice = '{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"payment.captured","contains":["payment"],'
        +'"payload":{"payment":{"entity":{"id":"pay_Jyo1AKwsB2nX3f","entity":"payment","amount":200000,"currency":"INR","status":"captured",'
        +'"order_id":"order_Jyo142AKFb208I","invoice_id":null,"international":false,"method":"card","amount_refunded":0,"refund_status":null,'
        +'"captured":true,"description":null,"card_id":"card_JqQ0DmdCJsRmp3","card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test",'
        +'"last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer","token_iin":null},'
        +'"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK",'
        +'"notes":{"invoice_number":"123","email":"test@gmail.com","phone":"1234567890"},"fee":100,"tax":0,"error_code":null,"error_description":null,'
        +'"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"726866"},"created_at":1659015598}}},"created_at":1659015602}';
    RestRequest reqpay = new RestRequest(); 
    RestResponse respay = new RestResponse();
    reqRefund.requestURI = '/services/apexrest/Pushnotification';  //Request URL
    reqpay.httpMethod = 'POST';//HTTP Request Type
    reqpay.requestBody = Blob.valueof(JsonWithoutInvoice);
    RestContext.request = reqpay;
    RestContext.response= respay;
    system.debug(inv);
    webHookSubscriptions.handleNotification();
    // test invoice series as blank
    string JsonEmptyInvoice = '{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"refund.processed","contains":["refund","payment"],'
			 +'"payload":{"refund":{"entity":{"id":"rfnd_Jyjl5OmuGYpSjf","entity":"refund","amount":500000,"currency":"INR","payment_id":"pay_JyHJj5DLxRqUzR","notes":{"comment":""},"receipt":null,'
			 +'"acquirer_data":{"arn":null},"created_at":1659000598,"batch_id":null,"status":"processed","speed_processed":"normal","speed_requested":"normal"}},'
			 +'"payment":{"entity":{"id":"pay_JyHJj5DLxRqUzR","entity":"payment","amount":1000000,"currency":"INR","base_amount":1000000,"status":"captured","order_id":"order_JyHIgSnXFxBRb9","invoice_id":null,'
			 +'"international":false,"method":"card","amount_refunded":500000,"amount_transferred":0,"refund_status":"partial","captured":true,"description":"#JyHHj4qEDpnRx6","card_id":"card_JqQ0DmdCJsRmp3",'
			 +'"card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test","last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer","token_iin":null},'
			 +'"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK","notes":{"invoice_number":""},"fee":10620,"tax":1620,"error_code":null,'
			 +'"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"262733"},"created_at":1658900439}}},"created_at":1659000598}';
    RestRequest reqEmptyInv = new RestRequest(); 
    RestResponse resEmptyInv = new RestResponse();
    reqRefund.requestURI = '/services/apexrest/Pushnotification';  //Request URL
    reqEmptyInv.httpMethod = 'POST';//HTTP Request Type
    reqEmptyInv.requestBody = Blob.valueof(JsonEmptyInvoice);
    RestContext.request = reqEmptyInv;
    RestContext.response= resEmptyInv;
    system.debug(inv);
    webHookSubscriptions.handleNotification();
    Test.stopTest();
    }
}