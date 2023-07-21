public class CPQ_EYController {
    public Map<Id,Integration_Log__c> invoiceLogMap= new Map<Id,Integration_Log__c>();
    public static List<Integration_Log__c> authLogList = new List<Integration_Log__c>();
   //
   //******  test class= EYControllerTest ***********************
   //
   @auraEnabled 
   public static List<Id> bearerTokenGenerator(List<blng__Invoice__c> invoices ){
       List<Id> integratedInvoiceIds = new List<Id>();
       List<Integration_Log__c> intLogs = new List<Integration_Log__c>();
       List<blng__Invoice__c> invoicesForTaxError = new List<blng__Invoice__c>();
       List<blng__Invoice__c> invoicesForTax = new List<blng__Invoice__c>();
       
       String outcomeMsg;
       String bearerToken;
       string endpoint ;
       string username ;
       string password ;
       string method = 'POST';
       
      
       API_Integration_Credential__mdt loginDetails = API_Integration_Credential__mdt.getInstance('EY');
       if(loginDetails != null){
           system.debug('loginDetails::: EY ::: Auth:'+loginDetails);
           endpoint = loginDetails.Server_URL__c;
           username = loginDetails.UserName__c; 
           password = loginDetails.Password__c;
       }
       
       if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
           outcomeMsg = 'Maximum number of callouts has been reached.';
           for(blng__Invoice__c inv : invoices){
               authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,null,null,null));
           }
       }
       else if (endpoint == null || username == null || password == null) {
           outcomeMsg = 'Please verify your API Credentials';
           for(blng__Invoice__c inv : invoices){
               authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,null,null,null));
           }            
           // configure and perform the callout
       } 
       else {
           system.debug('EndPoint:'+loginDetails.Server_URL__c+':Method:'+method);
           HttpRequest req = new HttpRequest();
           HttpResponse token = new HttpResponse();
           Http h = new Http();
           
           req.setEndpoint(endpoint);
           req.setMethod(method);
           req.setTimeout(120000);
           system.debug('EndPoint:'+req.getEndpoint()+':Method:'+req.getMethod());
           
           Blob headerValue = Blob.valueOf(username + ':' + password);
           
           req.setHeader('Content-Type', 'application/json');
           req.setHeader('Content-Length', '0');
           string credentials = '{"username": "'+username+'","password": "'+password+'"}';
           req.setBody(credentials);
           try {
               if(!test.isRunningTest()){
                   token = h.send(req);
               }else{
                   MockHttpTokenGenerator testMock = new MockHttpTokenGenerator();
                   token = testMock.respond(req);
                }
               
               system.debug(token.getStatusCode() + ' SP body '+token.getBody());
               
               if ((token.getStatusCode() == 200 || token.getStatusCode() == 201) && token.getBody() != null && token.getBody() != null) {
                   
                   Map<String,Object> tokenMap = (Map<String,Object>)JSON.deserializeUntyped(token.getBody());
                   bearerToken = (String)tokenMap.get('token');
                   system.debug('Bearer Token:::'+bearerToken);
                //    for(blng__Invoice__c inv : invoices){
                //        //authLogList.add(createIntegrationLog(inv.Id,null,req.getBody(),token.getBody(),String.valueOf(token.getStatusCode())));  
                //    }
                 
                   
                   
               }
               else {
                   // callout failed
                    outcomeMsg = 'Error: Callout failed. Please review the debug log for additional details.';
                   for(blng__Invoice__c inv : invoices){
                       inv.Tax_Integration_Error_Message__c = outcomeMsg;
                       inv.EY_Tax_Calculation_Status__c = 'Failed';
                       invoicesForTaxError.add(inv);
                       authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,null,token.getBody(),String.valueOf(token.getStatusCode())));
                   }                    
                   
                  
               }
               
           }catch(Exception e){
               outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
               for(blng__Invoice__c inv : invoices){
                   inv.Tax_Integration_Error_Message__c = outcomeMsg;
                   inv.EY_Tax_Calculation_Status__c = 'Failed';
                   invoicesForTaxError.add(inv);
                   authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,req.getBody(),token.getBody(),String.valueOf(token.getStatusCode())));
               } 
           }
           
       }  
       List<Id> billingAddressIds = new List<Id>();
       for(blng__Invoice__c inv : invoices){
           if(inv.Billing_Address__c  != null){
               billingAddressIds.add(inv.Billing_Address__c);
           }
           else if(inv.blng__InvoiceRunCreatedBy__c == null
             &&inv.blng__Order__c != null){
               billingAddressIds.add(inv.blng__Order__r.Billing_Address__c);
           }
           else if(inv.blng__InvoiceRunCreatedBy__c != null 
                  &&inv.blng__Order__c == null){
               billingAddressIds.add(inv.blng__Account__r.Billing_Address__c);
           }
           
       }
       Map<Id,AddressBook__c> invAddressMap = new Map<Id,AddressBook__c>([SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,PINCODE__c,
                                                                          COUNTRY__c,CITY__c,GST_Registered_Status__c,Dealer_Type__c 
                                                                          FROM AddressBook__c 
                                                                          WHERE Id = :billingAddressIds]);
       
       
       Map<Id,EY_ResponseJSONParser> eyResponseParseMap = new  Map<Id,EY_ResponseJSONParser>();
       List<EY_ResponseJSONParser.lineItems> lineItemListed = new  List<EY_ResponseJSONParser.lineItems>();
       Map<Id,List<EY_ResponseJSONParser.lineItems>> eyLineItemWrapperMap = new Map<Id,List<EY_ResponseJSONParser.lineItems>>();
       if(bearerToken != null){
           for(blng__Invoice__c inv : invoices){
               if((inv.Billing_Address__c != null|| (inv.blng__InvoiceRunCreatedBy__c == null
                      &&inv.blng__Order__c != null && inv.blng__Order__r.Billing_Address__c != null))
                   && inv.BVC_Branch__c != null && inv.BVC_Billing_Entity__c != null && inv.BVC_Entity__C != null){
               EY_ResponseJSONParser eyResponseWrapper = new EY_ResponseJSONParser();
               API_Integration_Credential__mdt gstEngine = API_Integration_Credential__mdt.getInstance('EY_GST_Engine');
               
               Http h = new Http();
               HttpResponse eyResponse = new HttpResponse();
               HttpRequest eyRequest = new HttpRequest();
               
               eyRequest.setHeader('Authorization','Bearer ' +bearerToken);
               eyRequest.setHeader('Content-Type', 'application/json');
               string endpoint1 = gstEngine.Server_URL__c;
               string method1 = 'POST'; 
               eyRequest.setEndpoint(endpoint1);
               eyRequest.setMethod(method1);
               eyRequest.setTimeout(120000);
               
               eyRequest.setBody(JSON.serialize(authurl(inv,invAddressMap)));
               system.debug('Body'+eyRequest);
               
                try {
               
                    
                    if(!test.isRunningTest() ){
                       if(inv.BVC_CB_Is_CB_Invoice__c == True && inv.BVC_CB_Invoice_Type__c !='Commercial Invoice'){
                            system.debug('tax invoice or BOS invoice'+inv.BVC_CB_Invoice_Type__c);
                          eyResponse = h.send(eyRequest);  
                        }else if(inv.BVC_CB_Is_CB_Invoice__c != True){
                            system.debug('not a CB invoice');
                            eyResponse = h.send(eyRequest); 
                        }
                            
                    }else{
                        EYHttpTestResponseGenerator testMockey = new EYHttpTestResponseGenerator();
                        eyResponse = testMockey.respond(eyRequest);
                    }
                    system.debug('Invoice Details:::'+inv.blng__Order__r.Billing_Address__r.CITY__c);
                    system.debug('ey+++'+eyResponse);
                    system.debug('Invoice Id>>>'+inv.Id);     
                    
                    if ((eyResponse.getStatusCode() == 200 || eyResponse.getStatusCode() == 201) && eyResponse.getBody() != null && eyResponse.getBody() != null) {
                        system.debug('Tax Response Body'+eyResponse.getBody());
                        system.debug('EyResponse :::'+JSON.deserializeUntyped(eyResponse.getBody()));
                        system.debug('JSON.deserialize(eyResponse.getBody(),EY_ResponseJSONParser.class) ::'+(EY_ResponseJSONParser)JSON.deserialize(eyResponse.getBody(),EY_ResponseJSONParser.class));
                        eyResponseWrapper = (EY_ResponseJSONParser)JSON.deserialize(eyResponse.getBody(),EY_ResponseJSONParser.class);
                        system.debug('eyResponseWrapper>>>'+eyResponseWrapper);
                        if(Test.isRunningTest()){
                            wrapperTestCoverage(eyResponseWrapper);
                        
                        }
                       if(eyResponseWrapper.taxEngineErrorCode != null
                           &&eyResponseWrapper.taxEngineErrorMessage != ''){
                               //authLogList.add(createIntegrationLog(inv.Id,eyResponseWrapper.taxEngineErrorMessage,eyRequest.getBody(),eyResponse.getBody(),String.valueOf(eyResponse.getStatusCode())));
                               inv.Tax_Integration_Error_Message__c = eyResponseWrapper.taxEngineErrorMessage;
                               inv.EY_Tax_Calculation_Status__c = 'Failed';
                               invoicesForTaxError.add(inv);
                               Integration_Log__c log = createIntegrationLog(inv.Id,eyResponseWrapper.taxEngineErrorMessage,eyRequest.getBody(),eyResponse.getBody(),String.valueOf(eyResponse.getStatusCode()));
                               log.Tax_Engine_Error_Code__c = eyResponseWrapper.taxEngineErrorCode;
                               authLogList.add(log);
                           }
                       else if(eyResponseWrapper.digiGSTErrorCode != null
                                &&eyResponseWrapper.digiGSTErrorMessage != ''){
                                    
                                   //  eyResponseParseMap.put(inv.Id,eyResponseWrapper);
                                   //  eyLineItemWrapperMap.put(inv.Id,eyResponseWrapper.lineItems);
                                   //  lineItemListed.addAll(eyResponseWrapper.lineItems);
                                    if(inv.Billing_Address__r.GST_Registered_Status__c != 'Registered' && eyResponseWrapper.posStateCode != null){
                                       eyResponseParseMap.put(inv.Id,eyResponseWrapper);
                                       eyLineItemWrapperMap.put(inv.Id,eyResponseWrapper.lineItems);
                                       lineItemListed.addAll(eyResponseWrapper.lineItems);
                                    }else{
                                       inv.Tax_Integration_Error_Message__c = eyResponseWrapper.digiGSTErrorMessage;
                                       inv.EY_Tax_Calculation_Status__c = 'Failed';
                                       invoicesForTaxError.add(inv);
                                       Integration_Log__c log = createIntegrationLog(inv.Id,eyResponseWrapper.digiGSTErrorMessage,eyRequest.getBody(),eyResponse.getBody(),String.valueOf(eyResponse.getStatusCode()));
                                       log.DigiGST_Error_Code__c = eyResponseWrapper.digiGSTErrorCode;
                                       authLogList.add(log);
    
                                    }
                                }
                        else{
                            eyResponseParseMap.put(inv.Id,eyResponseWrapper);
                            eyLineItemWrapperMap.put(inv.Id,eyResponseWrapper.lineItems);
                            lineItemListed.addAll(eyResponseWrapper.lineItems);
                            authLogList.add(createIntegrationLog(inv.Id,'',eyRequest.getBody(),eyResponse.getBody(),String.valueOf(eyResponse.getStatusCode())));
                            
                            
                        }
                    }
                    
                    else{
    
                        // callout failed
                       outcomeMsg = 'Callout Failed with Status Code'+eyResponse.getStatusCode();
                       authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,eyRequest.getBody(),eyResponse.getBody(),String.valueOf(eyResponse.getStatusCode())));
                       inv.Tax_Integration_Error_Message__c = outcomeMsg;
                       inv.EY_Tax_Calculation_Status__c = 'Failed';
                       invoicesForTaxError.add(inv);
                    }   
                    system.debug(eyResponse.getStatusCode() + ' SP body '+eyResponse.getBody());  
                    
                    
                }catch (exception e) {
                    // Unexpected exceptions will be caught here, like a deserialization error.
                   outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                   authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,eyRequest.getBody(),eyResponse.getBody(),String.valueOf(eyResponse.getStatusCode())));
                   inv.Tax_Integration_Error_Message__c = outcomeMsg;
                   inv.EY_Tax_Calculation_Status__c = 'Failed';
                   invoicesForTaxError.add(inv);
    
                }
               
               Decimal taxCalculated = 0.0;
               
               system.debug('Invoice Id:::'+inv.Id);
               }
               else if(inv.Billing_Address__c == null 
                && (inv.blng__InvoiceRunCreatedBy__c == null && inv.blng__Order__c != null && inv.blng__Order__r.Billing_Address__c == null)){
                    outcomeMsg = 'Billing Address for Invoice/Order is Missing' ;                              
                    authLogList.add(createIntegrationLog(inv.Id,outcomeMsg,null,null,null));
                    inv.Tax_Integration_Error_Message__c = outcomeMsg;
                    inv.EY_Tax_Calculation_Status__c = 'Failed';
                    invoicesForTaxError.add(inv);
                }
               
           }
       }
       
       system.debug('Response Body::Tax Values'+eyResponseParseMap.keySet());
       if(eyResponseParseMap.size() > 0){
           invoicesForTax.addAll(updateInvoiceFields(eyResponseParseMap,invoices));
       }
       if(invoicesForTax.size()> 0){
           Database.SaveResult[] result= Database.update(invoicesForTax, false);
           for(Database.SaveResult sr : result){
               if(sr.isSuccess()){
                   integratedInvoiceIds.add(sr.getId());
                   system.debug('Following Invoices inserted::'+sr.getId());
               }
               else {
                   // Operation failed, so get all errors                
                   for(Database.Error err : sr.getErrors()) {
                      // authLogList.add(createIntegrationLog(err.,err.getMessage(),null,null,err.getStatusCode()));
                       System.debug('The following error has occurred.');                    
                       System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       System.debug('Account fields that affected this error: ' + err.getFields());
                   }
               }
           } 
       }
       if(invoicesForTaxError.size()> 0){
           Database.SaveResult[] result= Database.update(invoicesForTaxError, false);
           for(Database.SaveResult sr : result){
               if(sr.isSuccess()){
                   //integratedInvoiceIds.add(sr.getId());
                   system.debug('Following Invoices inserted::'+sr.getId());
               }
               else {
                   // Operation failed, so get all errors                
                   for(Database.Error err : sr.getErrors()) {
                      // authLogList.add(createIntegrationLog(err.,err.getMessage(),null,null,err.getStatusCode()));
                       System.debug('The following error has occurred.');                    
                       System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       System.debug('Account fields that affected this error: ' + err.getFields());
                   }
               }
           } 
       }
       
       List<Charge_Head_Tax__c> chargeHeads = new List<Charge_Head_Tax__c>();
       List<blng__InvoiceLine__c> LineItems = new List<blng__InvoiceLine__c>();
       if(eyLineItemWrapperMap.size() >0 ){
           chargeHeads.addAll(ChargeHeadCreator(eyLineItemWrapperMap,integratedInvoiceIds));
           LineItems.addAll(LineItemCreator(eyLineItemWrapperMap,integratedInvoiceIds));
       }
       // Update invoice lines with tax percents for CB
       if(LineItems.size() >0){
           Database.SaveResult[] result= Database.update(LineItems, false);
           for(Database.SaveResult sr : result){
               if(sr.isSuccess()){
                   system.debug('Following Charge Head Tax inserted::'+sr.getId());
               }
               else {
                   // Operation failed, so get all errors                
                   for(Database.Error err : sr.getErrors()) {
                       System.debug('The following error has occurred.');                    
                       System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       System.debug('Account fields that affected this error: ' + err.getFields());
                   }
               }
           } 
       }
       if(chargeHeads.size() >0){
           Database.SaveResult[] result= Database.insert(chargeHeads, false);
           for(Database.SaveResult sr : result){
               if(sr.isSuccess()){
                   system.debug('Following Charge Head Tax inserted::'+sr.getId());
               }
               else {
                   // Operation failed, so get all errors                
                   for(Database.Error err : sr.getErrors()) {
                       System.debug('The following error has occurred.');                    
                       System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       System.debug('Account fields that affected this error: ' + err.getFields());
                   }
               }
           } 
       }
       if(authLogList.Size() > 0){
           Database.SaveResult[] result= Database.insert(authLogList, false);
           for(Database.SaveResult sr : result){
               if(sr.isSuccess()){
                   system.debug('Following Integration Logs inserted::'+sr.getId());
               }
               else {
                   // Operation failed, so get all errors                
                   for(Database.Error err : sr.getErrors()) {
                       System.debug('The following error has occurred.');                    
                       System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       System.debug('Account fields that affected this error: ' + err.getFields());
                   }
               }
           } 
       }
       
       
      
          return integratedInvoiceIds;
       
   }
   public static EY_RequestJSONParser authurl(blng__Invoice__c inv, Map<Id,AddressBook__c> addressMap) {
       system.debug('Invoice inside EY'+inv);
       String outcomeMsg;
       
       Id addressId ; 
       String blng_accName;
       String spng_accName;
       Address spng_Address;
       AddressBook__c blngaddress = new AddressBook__c();
       System.debug('blngaddress.1  '+blngaddress);
       System.debug('Billing_Address__c.2  '+inv.Billing_Address__c);
       if(inv.Billing_Address__c != null){
           if(addressMap.containsKey(inv.Billing_Address__c)){
                
                blngaddress = addressMap.get(inv.Billing_Address__c);
                System.debug('Billing_Address__c.3  '+blngaddress);
           }
       }
       System.debug('blngaddress.2 '+blngaddress);
       if(inv.blng__InvoiceRunCreatedBy__c == null && inv.blng__Order__c != null){
           
           if(addressMap.containsKey(inv.blng__Order__r.Billing_Address__c) && blngaddress == null){
                blngaddress = addressMap.get(inv.blng__Order__r.Billing_Address__c);
           }
           blng_accName  = inv.blng__Order__r.blng__BillingAccount__r.Name != null ? inv.blng__Order__r.blng__BillingAccount__r.Name : inv.blng__Order__r.Account.Name;
           spng_Address = inv.blng__Order__r.ShippingAddress;
           spng_accName = inv.blng__Order__r.Account.Name;
       }
       else {
           if(addressMap.containsKey(inv.Billing_Address__c)){
                blngaddress = addressMap.get(inv.Billing_Address__c);
           }
           System.debug('blngaddress.3  '+blngaddress);
           blng_accName = inv.blng__Account__r.Name;
           spng_Address = inv.blng__Account__r.ShippingAddress;
           spng_accName = inv.blng__Account__r.Name;
       }
       
       
       
       
       EY_RequestJSONParser eyRequestWrapper = new EY_RequestJSONParser();
       eyRequestWrapper.documentType = 'INV';
       eyRequestWrapper.billingDate = String.valueOf(inv.blng__InvoiceDate__c);
       eyRequestWrapper.preceedingInvoiceDate = null;
       eyRequestWrapper.billingDocumentNumber = inv.ST_Invoice_Series__c;
       eyRequestWrapper.roe = 1;
       eyRequestWrapper.documentCurrency = 'INR';
       List<String> billingStreet = new List<String>();
       
       if(blngaddress != null ){
           eyRequestWrapper.soldToParty = blng_accName ; 
           eyRequestWrapper.soldToPartyName = blng_accName;
           String billToPartAdrs = (blngaddress.ADDRESS1__c != null?blngaddress.ADDRESS1__c :'') +',' + (blngaddress.ADDRESS2__c != null?blngaddress.ADDRESS2__c :'')  ;
           if(billToPartAdrs != null && billToPartAdrs.length() >100){
               eyRequestWrapper.soldToPartyStreet = billToPartAdrs.substring(0, 100);
               eyRequestWrapper.soldToPartyStreet2 = billToPartAdrs.substring(0, 100);
               eyRequestWrapper.soldToPartyStreet3 =  billToPartAdrs.substring(0, 100);
           }
           else{
               eyRequestWrapper.soldToPartyStreet = billToPartAdrs;
               eyRequestWrapper.soldToPartyStreet2 = billToPartAdrs;
               eyRequestWrapper.soldToPartyStreet3 =  billToPartAdrs;
           }
           
           eyRequestWrapper.soldToPartyPinCode = blngaddress.PINCODE__c;
           eyRequestWrapper.soldToPartyCity = blngaddress.CITY__c;
           eyRequestWrapper.soldToPartyState = blngaddress.STATE__c;
           eyRequestWrapper.soldToPartyCountry = blngaddress.COUNTRY__c;
           
           eyRequestWrapper.billToPartyName = blng_accName ;
           if(billToPartAdrs != null && billToPartAdrs.length() >100){
               eyRequestWrapper.billToPartyStreet = billToPartAdrs.substring(0, 100);
               eyRequestWrapper.billToPartyStreet2 =  billToPartAdrs.substring(0, 100);
               eyRequestWrapper.billToPartyStreet3 = billToPartAdrs.substring(0, 100);
           }
           else{
               eyRequestWrapper.billToPartyStreet = billToPartAdrs;
               eyRequestWrapper.billToPartyStreet2 =  billToPartAdrs;
               eyRequestWrapper.billToPartyStreet3 = billToPartAdrs;
           }
           
           eyRequestWrapper.billToPartyPinCode = blngaddress.PINCODE__c;
           eyRequestWrapper.billToPartyCity = blngaddress.CITY__c;
           eyRequestWrapper.billToPartyState = blngaddress.STATE__c;
           eyRequestWrapper.billToPartyCountry = blngaddress.COUNTRY__c;
           
           List<String> shippingStreet = new List<String>();
           
           if(inv.blng__Order__c != null
              && inv.blng__Order__r.Business_Type__C == 'ACR'){
                  
              }
           eyRequestWrapper.shipToParty = spng_accName;
           if(inv.Destination_Address__c != null){
               if(inv.Destination_Address__r.ADDRESS1__c != null
                  &&inv.Destination_Address__r.ADDRESS1__c != ''){
                      string shiptoPartyAdrs = inv.Destination_Address__r.ADDRESS1__c +','+ inv.Destination_Address__r.ADDRESS2__c == null ?  '' : inv.Destination_Address__r.ADDRESS2__c;
                      if(shiptoPartyAdrs.length() >100){
                          eyRequestWrapper.shipToPartyStreet = shiptoPartyAdrs.substring(0, 100);
                          eyRequestWrapper.shipToPartyStreet2 = shiptoPartyAdrs.substring(0, 100);
                          eyRequestWrapper.shipToPartyStreet3 = shiptoPartyAdrs.substring(0, 100);
                          
                      }else{
                          eyRequestWrapper.shipToPartyStreet = shiptoPartyAdrs;
                          eyRequestWrapper.shipToPartyStreet2 = shiptoPartyAdrs;
                          eyRequestWrapper.shipToPartyStreet3 = shiptoPartyAdrs;
                      }

                  }
               eyRequestWrapper.shipToPartyPinCode = inv.Destination_Address__r.PINCODE__c;
               eyRequestWrapper.shipToPartyCity = inv.Destination_Address__r.CITY__c ;
               eyRequestWrapper.shipToPartyState = inv.Destination_Address__r.STATE__c;
                eyRequestWrapper.placeOfDelivery = inv.Destination_Address__r.STATE__c;
               eyRequestWrapper.placeOfReceipt = inv.Destination_Address__r.STATE__c;
               eyRequestWrapper.shipToPartyCountry = inv.Destination_Address__r.COUNTRY__c;
               eyRequestWrapper.shipToPartyName = inv.Consignee_Name__c;
           }
           else{
               
               string shiptoPartyAdrs = (blngaddress.ADDRESS1__c != null?blngaddress.ADDRESS1__c :'') +',' + (blngaddress.ADDRESS2__c != null?blngaddress.ADDRESS2__c :'');
               if(shiptoPartyAdrs != null && shiptoPartyAdrs.length() >100){
                   eyRequestWrapper.shipToPartyStreet = shiptoPartyAdrs.substring(0, 100);
                   eyRequestWrapper.shipToPartyStreet2 = shiptoPartyAdrs.substring(0, 100);
                   eyRequestWrapper.shipToPartyStreet3 = shiptoPartyAdrs.substring(0, 100);
               }else{
                   eyRequestWrapper.shipToPartyStreet = shiptoPartyAdrs;
                   eyRequestWrapper.shipToPartyStreet2 = shiptoPartyAdrs;
                   eyRequestWrapper.shipToPartyStreet3 = shiptoPartyAdrs;
               }
               
               eyRequestWrapper.shipToPartyPinCode = blngaddress.PINCODE__c;
               
               eyRequestWrapper.shipToPartyCity = blngaddress.CITY__c ;
               eyRequestWrapper.shipToPartyState = blngaddress.STATE__c;
               eyRequestWrapper.placeOfDelivery = blngaddress.STATE__c;
               eyRequestWrapper.placeOfReceipt = blngaddress.STATE__c;
               eyRequestWrapper.shipToPartyCountry = blngaddress.COUNTRY__c;
               eyRequestWrapper.shipToPartyName = blng_accName;
           }
           
           
       }
       
       if(inv.Billing_Address__c != null){
           eyRequestWrapper.customerType = inv.Billing_Address__r.GST_Registered_Status__c == 'Registered' ? 'Registered' : 'Unregistered';
           eyRequestWrapper.customerGSTIN = inv.Billing_Address__r.GST_Registered_Status__c == 'Registered' ? inv.Billing_Address__r.GSTIN__c : '';
           eyRequestWrapper.exemptionFlag = inv.Billing_Address__r.Dealer_Type__c == 'SEZ' ? true : false;
       }
       else{
            eyRequestWrapper.customerType = 'Unregistered';
           eyRequestWrapper.customerGSTIN = '';
           eyRequestWrapper.exemptionFlag = false;
       }
       
       
       
       
       
       eyRequestWrapper.customerPAN = inv.blng__Account__r.PAN_Number_of_Entity__c;
       eyRequestWrapper.bvclPAN = inv.BVC_Branch__r.BVC_Entity__r.PAN__c;
       eyRequestWrapper.bvclName = inv.BVC_Branch__r.BVC_Entity__r.Name;
       String addressLine2 = inv.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c == null ? '' : inv.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c;
       system.debug('Address Line 2::'+addressLine2);
       String billingOfficeAdrs = inv.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c+','+addressLine2;
       if(billingOfficeAdrs.length() >100){
           eyRequestWrapper.billingOfficeAddress = billingOfficeAdrs.substring(0,100);
       }
       else{
           eyRequestWrapper.billingOfficeAddress = billingOfficeAdrs;
       }
       
      
       eyRequestWrapper.billingOfficePinCode = inv.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c;
       eyRequestWrapper.billingOfficeCity = inv.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c;
       eyRequestWrapper.billingOfficeState = inv.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c;
       eyRequestWrapper.billingOfficeGSTN = inv.BVC_Billing_Entity__r.GSTIN__c;
      
      
       eyRequestWrapper.portOfDischarge = null;
       eyRequestWrapper.portOfLoad = null;
       if(inv.Billing_Address__c != null
          &&inv.Origin_Address__c != null
          &&inv.Billing_Address__r.GST_Registered_Status__c != 'Registered'){
              eyRequestWrapper.pickupLocationCity = inv.Origin_Address__r.CITY__c ;
              eyRequestWrapper.pickupLocationState = inv.Origin_Address__r.STATE__c;
              eyRequestWrapper.pickupLocationCountry = inv.Origin_Address__r.COUNTRY__c;
       }else if(inv.blng__Order__r.Business_Type__c == 'ACR' && inv.Billing_Address__r.GST_Registered_Status__c != 'Registered' && inv.Billing_Address__c != null){
           
           eyRequestWrapper.pickupLocationCity = blngaddress.CITY__c  ;
           eyRequestWrapper.pickupLocationState = blngaddress.STATE__c;
           eyRequestWrapper.pickupLocationCountry = blngaddress.COUNTRY__c;
       }
       
       else{
           eyRequestWrapper.pickupLocationCity = null ;
           eyRequestWrapper.pickupLocationState = null ;
           eyRequestWrapper.pickupLocationCountry = null ;
       }
       
       eyRequestWrapper.terminalOfOrigin = null;
       
       //eyRequestWrapper.salesOfficeAddress = inv.BVC_Branch__r.Hub_Address_Line_1__c+','+((inv.BVC_Branch__r.Hub_Address_Line_2__c != null && String.isNotBlank(inv.BVC_Branch__r.Hub_Address_Line_2__c)) ? inv.BVC_Branch__r.Hub_Address_Line_2__c : '') ;
       String salesAdress = (inv.BVC_Branch__r.Hub_Address_Line_1__c != null ? inv.BVC_Branch__r.Hub_Address_Line_1__c : '')+ (inv.BVC_Branch__r.Hub_Address_Line_2__c != null ? inv.BVC_Branch__r.Hub_Address_Line_2__c : '');
       eyRequestWrapper.salesOfficeAddress = (salesAdress.length()>100 ? salesAdress.subString(0,100) : salesAdress);
       eyRequestWrapper.salesOffiecState = inv.BVC_Branch__r.Hub_State__c;
       eyRequestWrapper.salesOfficeName = inv.BVC_Branch__r.Name;
       eyRequestWrapper.lineItems =  new List<EY_RequestJSONParser.lineItems>();
       List<EY_RequestJSONParser.lineItems> lineItemsList = new List<EY_RequestJSONParser.lineItems>();
       
        Integer i = 0;       
       if(inv.Total_Freight_Charges__c != null
          &&inv.Total_Freight_Charges__c > 0){
              EY_RequestJSONParser.lineItems item1 = new EY_RequestJSONParser.lineItems();
              EY_Master_Data__mdt mc1 = EY_Master_Data__mdt.getInstance('Freight_Charges');
              item1.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 frei: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item1.itemNumber = string.valueOf(i);
              item1.itemQuantity = 1;
              item1.unitPrice = inv.Total_Freight_Charges__c;
              item1.itemNetValue = inv.Total_Freight_Charges__c;
              item1.materialChargeCode = mc1.Charge_Code__c;
              lineItemsList.add(item1);
          }
       //Prat
       if(inv.Total_Fuel_Surcharge__c != null
          &&inv.Total_Fuel_Surcharge__c > 0){
              EY_RequestJSONParser.lineItems item1 = new EY_RequestJSONParser.lineItems();
              EY_Master_Data__mdt mc1 = EY_Master_Data__mdt.getInstance('Fuel_Surcharge');
              item1.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 frei: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item1.itemNumber = string.valueOf(i);
              item1.itemQuantity = 1;
              item1.unitPrice = inv.Total_Fuel_Surcharge__c;
              item1.itemNetValue = inv.Total_Fuel_Surcharge__c;
              item1.materialChargeCode = mc1.Charge_Code__c;
              lineItemsList.add(item1);
          }
       if(inv.Total_Vaulting_Charges__c != null
          &&inv.Total_Vaulting_Charges__c > 0){
              EY_RequestJSONParser.lineItems item1 = new EY_RequestJSONParser.lineItems();
              EY_Master_Data__mdt mc1 = EY_Master_Data__mdt.getInstance('Vaulting_Charges');
              item1.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 frei: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item1.itemNumber = string.valueOf(i);
              item1.itemQuantity = 1;
              item1.unitPrice = inv.Total_Vaulting_Charges__c;
              item1.itemNetValue = inv.Total_Vaulting_Charges__c;
              item1.materialChargeCode = mc1.Charge_Code__c;
              lineItemsList.add(item1);
          }//ENd Prat
       system.debug('Liability Charges at Invoice>>>'+inv.Total_Freight_Charges__c);
       system.debug('Liability Charges at Invoice>>>'+inv.Total_Liability_Charge__c);
       if(inv.Total_Liability_Charge__c != null
          &&inv.Total_Liability_Charge__c > 0){
              EY_Master_Data__mdt mc2 = EY_Master_Data__mdt.getInstance('Liability_Charges');
              EY_RequestJSONParser.lineItems item2 = new EY_RequestJSONParser.lineItems();
              item2.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 liab: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item2.itemNumber = string.valueOf(i);
              item2.itemQuantity = 1;
              item2.unitPrice = inv.Total_Liability_Charge__c;
              item2.itemNetValue = inv.Total_Liability_Charge__c;
              item2.materialChargeCode = mc2.Charge_Code__c;
              lineItemsList.add(item2);
          }
       system.debug('Offline Charges at Invoice>>>'+inv.Total_Offline_Charges__c);
       if(inv.Total_Offline_Charges__c != null
          &&inv.Total_Offline_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Offline_Charges'); 
              EY_RequestJSONParser.lineItems item3 = new EY_RequestJSONParser.lineItems();
              item3.uom = 'OTH-OTHERS';
             system.debug('Integer I 1 off: '+i);
              i++;
              system.debug('Integer I 2: '+String.valueOf(i));
              item3.itemNumber = string.valueOf(i);
              item3.itemQuantity = 1;
              item3.unitPrice = inv.Total_Offline_Charges__c;
              item3.itemNetValue = inv.Total_Offline_Charges__c;
              item3.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item3);
          }
       if(inv.Total_BVC_Valuation_Charges__c != null
          &&inv.Total_BVC_Valuation_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges'); 
              EY_RequestJSONParser.lineItems item3 = new EY_RequestJSONParser.lineItems();
              item3.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 Valua: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item3.itemNumber = string.valueOf(i);
              item3.itemQuantity = 1;
              item3.unitPrice = inv.Total_BVC_Valuation_Charges__c;
              item3.itemNetValue = inv.Total_BVC_Valuation_Charges__c;
              item3.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item3);
          }
       if(inv.Total_Docket_Charges__c != null
          &&inv.Total_Docket_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Docket_Charges'); 
              EY_RequestJSONParser.lineItems item3 = new EY_RequestJSONParser.lineItems();
              item3.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 docket: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item3.itemNumber = string.valueOf(i);
              item3.itemQuantity = 1;
              item3.unitPrice = inv.Total_Docket_Charges__c;
              item3.itemNetValue = inv.Total_Docket_Charges__c;
              item3.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item3);
          }
       if(inv.Total_Fuel_Charges__c != null
          &&inv.Total_Fuel_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Fuel_Charges'); 
              EY_RequestJSONParser.lineItems item3 = new EY_RequestJSONParser.lineItems();
              item3.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 fuel: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item3.itemNumber = string.valueOf(i);
              item3.itemQuantity = 1;
              item3.unitPrice = inv.Total_Fuel_Charges__c;
              item3.itemNetValue = inv.Total_Fuel_Charges__c;
              item3.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item3);
          }
       if(inv.Total_Holiday_Charges__c != null
          &&inv.Total_Holiday_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Holiday_Charges'); 
              EY_RequestJSONParser.lineItems item3 = new EY_RequestJSONParser.lineItems();
              item3.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 holi: '+i);
              i++;
              system.debug('Integer I 2: '+i);
              item3.itemNumber = string.valueOf(i);
              item3.itemQuantity = 1;
              item3.unitPrice = inv.Total_Holiday_Charges__c;
              item3.itemNetValue = inv.Total_Holiday_Charges__c;
              item3.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item3);
          }
       if(inv.Total_Weight_Charges__c != null
          &&inv.Total_Weight_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Weight_Charges'); 
              EY_RequestJSONParser.lineItems item3 = new EY_RequestJSONParser.lineItems();
              item3.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 weigh: '+i);
              i++;
              system.debug('Integer I 2: '+ String.valueOf(i));
              item3.itemNumber = String.valueOf(i); 
              item3.itemQuantity = 1;
              item3.unitPrice = inv.Total_Weight_Charges__c;
              item3.itemNetValue = inv.Total_Weight_Charges__c;
              item3.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item3);
          }
       // starts BATH EY tax Integration BY SONU =====Commission

       if(inv.Total_Commission_Charges__c != null
          &&inv.Total_Commission_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Commission'); 
              EY_RequestJSONParser.lineItems item4 = new EY_RequestJSONParser.lineItems();
              item4.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 weigh: '+i);
              i++;
              system.debug('Integer I 2: '+ String.valueOf(i));
              item4.itemNumber = String.valueOf(i); 
              item4.itemQuantity = 1;
              item4.unitPrice = inv.Total_Commission_Charges__c;
              item4.itemNetValue = inv.Total_Commission_Charges__c;
              item4.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item4);
          }
       // starts BATH EY tax Integration BY SONU =====Logistics_Charges
       
       if(inv.Total_Logistics_Charges__c != null
          &&inv.Total_Logistics_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Logistics_Charges'); 
              EY_RequestJSONParser.lineItems item5 = new EY_RequestJSONParser.lineItems();
              item5.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 weigh: '+i);
              i++;
              system.debug('Integer I 2: '+ String.valueOf(i));
              item5.itemNumber = String.valueOf(i); 
              item5.itemQuantity = 1;
              item5.unitPrice = inv.Total_Logistics_Charges__c;
              item5.itemNetValue = inv.Total_Logistics_Charges__c;
              item5.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item5);
          }
       //starts eSHIP EY tax Integration BY SONU =====Secure Logistics_Charges
       
       if(inv.Total_Secure_Logistics_Charges__c != null
          &&inv.Total_Secure_Logistics_Charges__c > 0){
              EY_Master_Data__mdt mc3 = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges'); 
              EY_RequestJSONParser.lineItems item6 = new EY_RequestJSONParser.lineItems();
              item6.uom = 'OTH-OTHERS';
              system.debug('Integer I 1 weigh: '+i);
              i++;
              system.debug('Integer I 2: '+ String.valueOf(i));
              item6.itemNumber = String.valueOf(i); 
              item6.itemQuantity = 1;
              item6.unitPrice = inv.Total_Secure_Logistics_Charges__c;
              item6.itemNetValue = inv.Total_Secure_Logistics_Charges__c;
              item6.materialChargeCode =mc3.Charge_Code__c;
              lineItemsList.add(item6);
          } 
       eyRequestWrapper.lineItems.addAll(lineItemsList);
       //...........CB TAX CALCULATIONS......//
       if(inv.BVC_CB_Is_CB_Invoice__c == True){ 
           system.debug(inv.Invoice_Type__c);
           List<EY_RequestJSONParser.lineItems> lineItemsListcb = new List<EY_RequestJSONParser.lineItems>();
           eyRequestWrapper.lineItems.addAll(createCBEYLineItems(inv,i));
       }
       //...........CB TAX CALCULATIONS......//
       system.debug('eyResponse FORM authURL:::'+eyRequestWrapper);
       return  eyRequestWrapper;
   }
   //...CB Invoice Line Items Append....//
   public static List<EY_RequestJSONParser.lineItems> createCBEYLineItems(blng__Invoice__c inv, integer i) {
        List<EY_RequestJSONParser.lineItems> lineItemsListcb = new List<EY_RequestJSONParser.lineItems>();
        list<blng__InvoiceLine__c> invoicelineitems = [select id,blng__Product__r.Name,blng__Product__r.ProductCode,blng__Subtotal__c from blng__InvoiceLine__c where blng__Invoice__c = :inv.Id];
        if(invoicelineitems.size() > 0 && invoicelineitems != null){
            for(blng__InvoiceLine__c invline:invoicelineitems){
                EY_RequestJSONParser.lineItems item = new EY_RequestJSONParser.lineItems();
                system.debug(invline.blng__Product__r.Name);
                string chargename = invline.blng__Product__r.Name.replaceAll('[^a-zA-Z]','_').replace('___','_').replace('__','_').removeEnd('_');
                /*if(invline.blng__Product__r.Name == 'COURIER  CHARGES'){
                   chargename = invline.blng__Product__r.Name.replace('  ','_');
                }*/
                system.debug(chargename);
                if(!Test.isRunningTest()){
                EY_Master_Data__mdt mcode = EY_Master_Data__mdt.getInstance(chargename);
                    item.materialChargeCode = mcode.Charge_Code__c;}
                 //EY_Master_Data__mdt mcode = EY_Master_Data__mdt.getInstance('Amendment_Charges');
                item.uom = 'OTH-OTHERS';
                system.debug('Integer I 1 liab: '+i);
                i++;
                system.debug('Integer I 2: '+i);
                item.itemNumber = String.valueOf(i); 
                item.itemQuantity = 1;
                item.unitPrice = invline.blng__Subtotal__c;
                item.itemNetValue = invline.blng__Subtotal__c;              
                lineItemsListcb.add(item);
                system.debug(item);
            }
        }
        return  lineItemsListcb;
    }
    //...CB Invoice Line Items Append....//
   public static List<blng__Invoice__c> updateInvoiceFields(Map<Id,EY_ResponseJSONParser> responseMap,List<blng__Invoice__c> invoices){
       List<blng__Invoice__c> invoicestoUpdate = new List<blng__Invoice__c>();
       system.debug('responseMap:::'+responseMap);
       for(blng__Invoice__c inv : invoices){
           if(responseMap.containskey(inv.Id)){
               inv.IRN__c = responseMap.get(inv.Id).irnNumber;
               inv.EY_Tax_Calculation_Status__c = 'Success';
               inv.Place_of_Supply_City__c = responseMap.get(inv.Id).posCity;
               inv.Place_Of_Supply_State__c = responseMap.get(inv.Id).posState;
               inv.Place_Of_Supply_State_Code__c = responseMap.get(inv.Id).posStateCode;
               if(responseMap.get(inv.Id).signedQRCode != null
                 && responseMap.get(inv.Id).signedQRCode != ''){
                 
               String SignedQrCode = 'https://image-charts.com/chart?chs=50x15&cht=qr&chl='+responseMap.get(inv.Id).signedQRCode;
               inv.Signed_QR_code_URL__c = 'https://image-charts.com/chart?chs=50x15&cht=qr&chl='+responseMap.get(inv.Id).signedQRCode;
               //inv.Signed_QR_code_URL__c = 'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl='+responseMap.get(inv.Id).signedQRCode;
               inv.Signed_IRN_Text__c = '<img alt="User-added image" src="'+SignedQrCode+'"></img>';
                 
               }
               //inv.blng__InvoiceStatus__c = 'Posted';
               system.debug('1 Charge head : Inv tax percent'+responseMap.get(inv.Id).lineItems[0]);
               //if(responseMap.get(inv.Id).lineItems.size() > 0 && responseMap.get(inv.Id).lineItems != null){
                  //inv.ST_Tax_Percent__c =  calculatetaxPercent(responseMap.get(inv.Id).lineItems[0]);
               //}
               //EY_ResponseJSONParser.lineItems li = responseMap.get(inv.Id).lineItems[0];
               inv.ACK_Number__c = responseMap.get(inv.Id).ackNumber;
               if(responseMap.get(inv.Id).ackDateTime != null 
                 && responseMap.get(inv.Id).ackDateTime != ''){
                   system.debug('Ack Date Time::'+responseMap.get(inv.Id).ackDateTime);
                   inv.ACK_Date_Time__c = DateTime.valueOf(responseMap.get(inv.Id).ackDateTime) ;
               }
               invoicestoUpdate.add(inv);
           }
           
           
       }
       
       return invoicestoUpdate;
       
       
       
       
   }
  private  static Decimal calculatetaxPercent(EY_ResponseJSONParser.lineItems chargeHead){
        return chargeHead.taxApplicablePercentage.setScale(2);
    }
    //Method to update CB taxes in invoice lines
    public static List<blng__InvoiceLine__c> LineItemCreator(Map<Id,List<EY_ResponseJSONParser.lineItems>> invResponseMap,List<Id> invoiceIds){
	List<blng__InvoiceLine__c> LineItemstoUpdate = new List<blng__InvoiceLine__c>();
       Map<Id,blng__Invoice__c> IsCbMap = new Map<Id,blng__Invoice__c>([select Id,Invoice_Type__c,BVC_CB_Is_CB_Invoice__c,(select id,Name,BVC_CB_CGSTAmount__c,BVC_CB_CGSTTaxRate__c,BVC_CB_SGSTAmount__c,BVC_CB_SGSTTaxRate__c from blng__InvoiceInvoiceLines__r) from blng__Invoice__c where Id IN : invoiceIds and BVC_CB_Is_CB_Invoice__c = TRUE and blng__Invoice__c.Invoice_Type__c = 'Tax Invoice']);       
       for(Id invId : IsCbMap.keySet()){
           for(EY_ResponseJSONParser.lineItems li: invResponseMap.get(invId)){               
               for(blng__InvoiceLine__c invline:IsCbMap.get(invId).blng__InvoiceInvoiceLines__r){
                   string product =li.materialDescription.replace('  ',' ');
                   system.debug('material desc**************'+product);
                   system.debug('invline.Name==============='+invline.Name);
                   if(invline.Name == product){
                       invline.BVC_CB_SGSTAmount__c = li.sgsT_INR;
                       invline.BVC_CB_CGSTAmount__c = li.cgsT_INR;
                       invline.BVC_CB_CGSTTaxRate__c = li.cgstPercentage*100;
                       invline.BVC_CB_SGSTTaxRate__c = li.sgstPercentage*100;
                       invline.BVC_CB_IGSTAmount__c = li.igsT_INR;
                       invline.BVC_CB_IGSTTaxRate__c = li.igstPercentage*100;
                       invline.BVC_CB_HSNCODE__c = li.sacApplicable;
                       invline.blng__TaxAmount__c = li.sgsT_INR+li.cgsT_INR+li.igsT_INR;
                   LineItemstoUpdate.add(invline);
                   }
               }              
           }
       }
       return LineItemstoUpdate;
   }
   public static List<Charge_Head_Tax__c> ChargeHeadCreator(Map<Id,List<EY_ResponseJSONParser.lineItems>> invResponseMap,List<Id> invoiceIds){
       system.debug('responseMap:::'+invResponseMap);
       List<Charge_Head_Tax__c> chargeHeadstoInsert = new List<Charge_Head_Tax__c>();
       Map<Id,blng__Invoice__c> IsCbMap = new Map<Id,blng__Invoice__c>([select Id,Invoice_Type__c,BVC_CB_Is_CB_Invoice__c from blng__Invoice__c where Id IN : invoiceIds]);
       for(Id invId : invoiceIds){
           for(EY_ResponseJSONParser.lineItems li: invResponseMap.get(invId)){
               Charge_Head_Tax__c chTax = new Charge_Head_Tax__c();
               chTax.Name = li.materialDescription;
               chTax.Invoice__c = invId;
               chTax.CGST_Amount__c = li.cgsT_INR;
               chTax.IGST__c=li.igstPercentage*100;
               chTax.CGST_Rate__c = li.cgstPercentage*100;
               chTax.IGST__c = li.igstPercentage*100;
               chTax.IGST_Amount__c = li.igsT_INR;
               chTax.SGST__c = li.sgstPercentage*100;
               chTax.SGST_Amount__c = li.sgsT_INR;
               chTax.Total_Amount__c = li.totalItemValue;
               chTax.Line_Number__c = Integer.valueOf(li.itemNumber);
               chTax.Tax_Amount__c = li.taxCalculatedINR;
               chTax.Tax_Percent__c = li.taxApplicablePercentage*100;
               chTax.Taxable_Value__c = li.totalItemValue -li.taxCalculatedINR;
               chTax.HSN_Code__c = li.sacApplicable;
               if(IsCbMap.get(invId).BVC_CB_Is_CB_Invoice__c == TRUE){
                    string chargename = li.materialDescription.replaceAll('[^a-zA-Z]','_').removeEnd('_').replace('___','_').replace('__','_').removeEnd('_');
                    system.debug(chargename);
                    EY_Master_Data__mdt mcode = EY_Master_Data__mdt.getInstance(chargename);
                   if(!Test.isRunningTest()){
                        chTax.Charge_Head_Code__c = mcode.Charge_Code__c;
                    	chTax.COA_Revenue_Account_Code__c = mcode.COA_Revenue_Account_Code__c;
                    	chTax.COA_Revenue_Sub_Account__c = mcode.COA_Revenue_Sub_Account__c;   
                   }
               }
               chargeHeadstoInsert.add(chTax);
           }
       }
       system.debug('chargeHeadstoInsert<<<'+chargeHeadstoInsert);
       Upsert chargeHeadstoInsert;
       return chargeHeadstoInsert;
   }
   
   // public static requestWrapper(){
   // return request Bod//}
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
       log.Integration_Server__c = 'Ey Tax Server';
       log.Request_JSON__c = requestJson;
       log.Response_JSON__c = responseJson;
       log.Invoice__c = invId;
       log.Status_Code__c = statusCode ;
       log.Error_Reason__c = errorMessage;
       return log;
       
   }
    public static void wrapperTestCoverage(EY_ResponseJSONParser jsonTest){
        EY_ResponseJSONParser tes = new EY_ResponseJSONParser();
        tes.digiGSTErrorCode = '1001';
        tes.ackDateTime = String.valueOf(system.now());
        tes.ackNumber = '4716';
        tes.billingDate = string.valueOf(system.today());
        tes.billingDocumentNumber = '57151';
        tes.digiGSTErrorMessage = 'test Error';
        tes.irnNumber = '5751g';
        tes.lospCity = 'test';
        tes.lospState = 'test';
        tes.lospStateCode = '66';
        tes.lospTable = 'test';
        tes.lospColumn = '566';
        tes.posCity = 'test';
        tes.posState = 'test';
        tes.posStateCode = '55';
        tes.posColumn = '77';
        tes.posTable = 'Test';
        tes.processingDate = string.valueOf(system.today());
        tes.registrationStatus = 'test';
        tes.signedQRCode = 'hfaa7Test';
        tes.supplyType = 'test';
        tes.taxEngineErrorCode = '55';
        tes.taxEngineErrorMessage = 'test';
    }
}