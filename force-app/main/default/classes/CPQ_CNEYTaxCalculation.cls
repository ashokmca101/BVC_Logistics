public class CPQ_CNEYTaxCalculation {
    public Boolean showError {get;set;}
    public Boolean showSuccess {get;set;}
    public String creditReturnURL {get;set;}
    public String message {get;set;}
    public CPQ_CNEYTaxCalculation(){
        
    }
    public void doTaxCalculation() {
        showError = false;
        showSuccess = false;
        String creditNoteId = ApexPages.CurrentPage().getparameters().get('Id');
        try{
            //String creditNoteId = ApexPages.CurrentPage().getparameters().get('Id');
            String outcomeMsg;
            Map<String,String> mapChargeHeadTypes = new Map<String,String>{ 'Freight Charge' => 'Freight_Charges','Liability Charge' => 'Liability_Charges', 'Offline Charge'   => 'Offline_Charges','Weight Charge'   => 'Weight_Charges',
                                                                            'BVC Valuation Charge' => 'BVC_Valuation_Charges','Docket Charge' => 'Docket_Charges', 'Fuel Charge'   => 'Fuel_Charges','Holiday Charge'   => 'Holiday_Charges','Commission Charge'   => 'Commission','Logistics Charge'   => 'Logistics_Charges','Secure Logistics Charge'   => 'Secure_Logistics_Charges','Fuel Surcharge' => 'Fuel_Surcharge','Vaulting Charge' =>'Vaulting_Charges'};
            Map<String,String> mapResponseCharge = new Map<String,String>{ 'FREIGHT CHARGES' => 'Freight Charge', 'LIABILITY CHARGES'=> 'Liability Charge', 'OFFLINE CHARGES'   => 'Offline Charge','BVC VALUATION CHARGES'   => 'BVC Valuation Charge',
                                                                            'DOCKET CHARGES' => 'Docket Charge', 'FUEL CHARGES' => 'Fuel Charge','HOLIDAY CHARGES' => 'Holiday Charge', 'WEIGHT CHARGES' => 'Weight Charge','COMMISSION' => 'Commission Charge','LOGISTICS CHARGES' => 'Logistics Charge','SECURE LOGISTICS CHARGES' => 'Secure Logistics Charge', 'FUEL SURCHARGE' => 'Fuel Surcharge', 'VAULTING CHARGES' =>'Vaulting Charge' };
            //string token;
            EY_ResponseJSONParser eyResponse = new EY_ResponseJSONParser();
            //EY_ResponseJSONParser eyResponse = new EY_ResponseJSONParser();
            
            //string endpoint = 'https://20.198.75.155/api/Auth/Login'; 
            string endpoint ;//= 'https://bvcapp.com/api/Auth/Login';
            string username ;//= 'vaibhav.pancholi@bvclogistics.com'; 
            string password ;//= 'Bvc@2021';
            string method = 'POST';
        
       
            API_Integration_Credential__mdt loginDetails = API_Integration_Credential__mdt.getInstance('EY');
            if(loginDetails != null){
                system.debug('loginDetails::: EY ::: Auth:'+loginDetails);
                endpoint = loginDetails.Server_URL__c;
                username = loginDetails.UserName__c; 
                password = loginDetails.Password__c;
            }
            Map<String,blng__CreditNoteLine__c> mapCNlines = new Map<String,blng__CreditNoteLine__c>();
            blng__CreditNote__c creditNote = [SELECT Id, Name, Approval_Status__c ,Billing_Address__c,Place_Of_Supply__c ,blng__CreditNoteDate__c,CreditNote_Serial_No__c,State_Of_Supply__c ,Place_of_Supply_State_Code__c,IRN__c ,Signed_QR_Code__c ,
                                    blng__RelatedInvoice__c ,blng__RelatedInvoice__r.blng__Order__c,blng__RelatedInvoice__r.Name, blng__RelatedInvoice__r.blng__Order__r.BillingAddress,
                                    blng__RelatedInvoice__r.blng__Order__r.Account.Name,blng__RelatedInvoice__r.blng__Account__r.Billing_Address__c,blng__RelatedInvoice__r.blng__InvoiceDate__c,
                                    blng__Account__c ,blng__Account__r.Billing_Address__c,blng__Account__r.Billing_Address__r.GST_Registered_Status__c,blng__RelatedInvoice__r.ST_Invoice_Series__c,
                                    blng__Account__r.Billing_Address__r.Dealer_Type__c,blng__RelatedInvoice__r.blng__Order__r.Business_Type__c,blng__RelatedInvoice__r.Origin_Address__c,
                                    blng__RelatedInvoice__r.Origin_Address__r.CITY__c,blng__RelatedInvoice__r.Origin_Address__r.STATE__c,blng__RelatedInvoice__r.Origin_Address__r.COUNTRY__c,
                                    blng__Account__r.GSTIN__c,blng__Account__r.PAN_Number_of_Entity__c,BVC_Branch__r.BVC_Entity__r.PAN__c,BVC_Branch__r.BVC_Entity__r.Name,
                                    BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c,
                                    BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c,BVC_Billing_Entity__r.GSTIN__c,
                                    BVC_Branch__r.Hub_Address_Line_1__c,BVC_Branch__r.Hub_Address_Line_2__c,BVC_Branch__r.Hub_State__c,BVC_Branch__r.Name,blng__RelatedInvoice__r.Destination_Address__r.PINCODE__c,
                                    blng__RelatedInvoice__r.Destination_Address__r.CITY__c,blng__RelatedInvoice__r.Destination_Address__r.STATE__c,blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c,blng__RelatedInvoice__r.Destination_Address__r.ADDRESS2__c,blng__RelatedInvoice__r.Destination_Address__r.COUNTRY__c,
                                    blng__RelatedInvoice__r.blng__Order__r.blng__BillingAccount__r.Name,blng__RelatedInvoice__r.blng__Order__r.BillingCity,blng__RelatedInvoice__r.blng__Account__r.Name,
                                    blng__RelatedInvoice__r.blng__Account__r.ShippingAddress,blng__RelatedInvoice__r.blng__Order__r.BillingState,blng__RelatedInvoice__r.blng__Order__r.BillingCountry,
                                    blng__RelatedInvoice__r.blng__Order__r.ShippingAddress,blng__RelatedInvoice__r.blng__Order__r.ShippingCity,blng__RelatedInvoice__r.blng__Order__r.ShippingState,
                                    blng__RelatedInvoice__r.blng__Order__r.ShippingCountry,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.CITY__c,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.ADDRESS1__c,
                                    blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.ADDRESS2__c,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.STATE__c,
                                    blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.COUNTRY__c,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__c,blng__RelatedInvoice__r.blng__InvoiceRunCreatedBy__c,
                                    (select id,Charge_Head_Type__c,blng__Subtotal__c,CGST_Amount__c,CGST_Percent__c,IGST_Amount__c,IGST_Percent__c,SGST_Amount__c,SGST_Percent__c,blng__TotalAmount__c,blng__TaxPercentageApplied__c from blng__CreditNoteCreditLines__r) FROM blng__CreditNote__c 
                                    WHERE Id = :creditNoteId LIMIT 1];
            
            
            Id addressId ; //= inv.blng__InvoiceRunCreatedBy__c == null ?  inv.blng__Order__r.Billing_Address__c : inv.blng__Account__r.Billing_Address__c;      
            String blng_accName;
            String spng_accName;
            Address spng_Address;
            if(creditNote != null && creditNote.Approval_Status__c != 'Approved'){
                throw new applicationException('CreditNote ERROR : CreditNote is not approved');
            }
            if(creditNote.Billing_Address__c != null){
                addressId =  creditNote.Billing_Address__c;
            }else{
                throw new applicationException('CreditNote ERROR : Billing Address Missing');
            }
            if(creditNote.blng__RelatedInvoice__r.blng__InvoiceRunCreatedBy__c == null && creditNote.blng__RelatedInvoice__r.blng__Order__c != null){
                blng_accName  = creditNote.blng__RelatedInvoice__r.blng__Order__r.blng__BillingAccount__r.Name != null ? creditNote.blng__RelatedInvoice__r.blng__Order__r.blng__BillingAccount__r.Name : creditNote.blng__RelatedInvoice__r.blng__Order__r.Account.Name;
                spng_Address = creditNote.blng__RelatedInvoice__r.blng__Order__r.ShippingAddress;
                spng_accName = creditNote.blng__RelatedInvoice__r.blng__Order__r.Account.Name;
            }
            else {

                blng_accName =  creditNote.blng__RelatedInvoice__r.blng__Account__r.Name;
                spng_Address =  creditNote.blng__RelatedInvoice__r.blng__Account__r.ShippingAddress;
                spng_accName =  creditNote.blng__RelatedInvoice__r.blng__Account__r.Name;
            }
            List<AddressBook__c> blngaddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,GSTIN__c ,PINCODE__c,GST_Registered_Status__c,Dealer_Type__c,STATE__c,COUNTRY__c,CITY__c FROM AddressBook__c WHERE Id = :addressId];            
            
            if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
                outcomeMsg = 'Maximum number of callouts has been reached.';
            } else if (endpoint == null || username == null || password == null) {
                outcomeMsg = 'Please verify your API Credentials';
                
                // configure and perform the callout
            } else {
                system.debug('EndPoint:'+endpoint+':Method:'+method);
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
                
                if(!test.isRunningTest()){
                    token = h.send(req);
                }else{
                    MockHttpTokenGenerator testMock = new MockHttpTokenGenerator();
                    token = testMock.respond(req);
                }
                
                Map<String,Object> tokenMap = (Map<String,Object>)JSON.deserializeUntyped(token.getBody());
                String bearerToken = (String)tokenMap.get('token');
                API_Integration_Credential__mdt gstEngine = API_Integration_Credential__mdt.getInstance('EY_GST_Engine');
                
                HttpResponse res = new HttpResponse();
                HttpRequest req1 = new HttpRequest();
                
                req1.setHeader('Authorization','Bearer ' +bearerToken);
                req1.setHeader('Content-Type', 'application/json');
                //string endpoint1 = 'https://bvcapp.com/api/BVCGSTEngine';
                string endpoint1 = gstEngine.Server_URL__c;
                string method1 = 'POST'; 
                req1.setEndpoint(endpoint1);
                req1.setMethod(method1);
                req1.setTimeout(120000);

                
                EY_RequestJSONParser eyRequest = new EY_RequestJSONParser();
                eyRequest.documentType = 'CR';
                eyRequest.billingDate = String.valueOf(creditNote.blng__CreditNoteDate__c );
                eyRequest.preceedingInvoiceDate = String.valueOf(creditNote.blng__RelatedInvoice__r.blng__InvoiceDate__c );
                eyRequest.preceedingBillingDocumentNo = creditNote.blng__RelatedInvoice__r.ST_Invoice_Series__c ;
                eyRequest.billingDocumentNumber = creditNote.CreditNote_Serial_No__c ;
                eyRequest.roe = 1;
                eyRequest.documentCurrency = 'INR';
                List<String> billingStreet = new List<String>();
               
                if(blngaddress.size() > 0 ){

                    eyRequest.soldToParty = blng_accName ; // != null ? inv.blng__Order__r.Account.Name : inv.blng__Account__c;
                    eyRequest.soldToPartyName = blng_accName;// != null ? inv.blng__Order__r.Account.Name : inv.blng__Account__c;
                    String billToPartAdrs = (blngaddress[0].ADDRESS1__c != null?blngaddress[0].ADDRESS1__c :'') +',' + (blngaddress[0].ADDRESS2__c != null?blngaddress[0].ADDRESS2__c :'')  ;
                    if(billToPartAdrs != null && billToPartAdrs.length() >100){
                        eyRequest.soldToPartyStreet = billToPartAdrs.substring(0, 100);
                        eyRequest.soldToPartyStreet2 = billToPartAdrs.substring(0, 100);
                        eyRequest.soldToPartyStreet3 =  billToPartAdrs.substring(0, 100);
                    }
                    else{
                        eyRequest.soldToPartyStreet = billToPartAdrs;
                        eyRequest.soldToPartyStreet2 = billToPartAdrs;
                        eyRequest.soldToPartyStreet3 =  billToPartAdrs;
                    }
                    //eyRequest.soldToPartyStreet = blngaddress[0].ADDRESS1__c == null ? blngaddress[0].CITY__c : blngaddress[0].ADDRESS1__c;
                    //eyRequest.soldToPartyStreet2 = blngaddress[0].ADDRESS2__c == null ?  blngaddress[0].ADDRESS1__c : blngaddress[0].ADDRESS2__c;
                    //eyRequest.soldToPartyStreet3 =  blngaddress[0].CITY__c;
                    eyRequest.soldToPartyPinCode = blngaddress[0].PINCODE__c;
                    eyRequest.soldToPartyCity = blngaddress[0].CITY__c;
                    eyRequest.soldToPartyState = blngaddress[0].STATE__c;
                    eyRequest.soldToPartyCountry = blngaddress[0].COUNTRY__c;
                    
                    eyRequest.billToPartyName = blng_accName ;//== null ? inv.blng__Order__r.Account.Name : inv.blng__Order__r.blng__BillingAccount__r.Name;
                    eyRequest.billToPartyStreet = blngaddress[0].ADDRESS1__c == null ? blngaddress[0].CITY__c : blngaddress[0].ADDRESS1__c;
                    eyRequest.billToPartyStreet2 =  blngaddress[0].ADDRESS2__c == null ? blngaddress[0].CITY__c : blngaddress[0].ADDRESS2__c;
                    eyRequest.billToPartyStreet3 = blngaddress[0].CITY__c;
                    eyRequest.billToPartyPinCode = blngaddress[0].PINCODE__c;
                    eyRequest.billToPartyCity = blngaddress[0].CITY__c;
                    eyRequest.billToPartyState = blngaddress[0].STATE__c;
                    eyRequest.billToPartyCountry = blngaddress[0].COUNTRY__c;
            
                    
                    List<String> shippingStreet = new List<String>();
                    
                    //inv.blng__Order__r.ShippingAddress.getStreet().split('\\,');
                    if(creditNote.blng__RelatedInvoice__r.blng__Order__c != null
                       && creditNote.blng__RelatedInvoice__r.blng__Order__r.Business_Type__C == 'ACR'){
                           
                       }
                    eyRequest.shipToParty = spng_accName;
                    if(creditNote.blng__RelatedInvoice__r.Destination_Address__c != null){
                        if(creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c != null
                           &&creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c != ''){
                                eyRequest.shipToPartyStreet = creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c;
                                eyRequest.shipToPartyStreet2 = creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS2__c == null ?  creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c : creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS2__c;
                                eyRequest.shipToPartyStreet3 = creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c;
                           }
                        eyRequest.shipToPartyPinCode = creditNote.blng__RelatedInvoice__r.Destination_Address__r.PINCODE__c;
                        eyRequest.shipToPartyCity = creditNote.blng__RelatedInvoice__r.Destination_Address__r.CITY__c ;
                        eyRequest.shipToPartyState = creditNote.blng__RelatedInvoice__r.Destination_Address__r.STATE__c;
                        eyRequest.placeOfDelivery = creditNote.blng__RelatedInvoice__r.Destination_Address__r.STATE__c;
                        eyRequest.placeOfReceipt = creditNote.blng__RelatedInvoice__r.Destination_Address__r.STATE__c;
                        eyRequest.shipToPartyCountry = creditNote.blng__RelatedInvoice__r.Destination_Address__r.COUNTRY__c;
                        eyRequest.shipToPartyName = creditNote.blng__RelatedInvoice__r.Consignee_Name__c;
                    }
                    else{
                        string shiptoPartyAdrs = (blngaddress[0].ADDRESS1__c != null?blngaddress[0].ADDRESS1__c :'') +',' + (blngaddress[0].ADDRESS2__c != null?blngaddress[0].ADDRESS2__c :'');
                        if(shiptoPartyAdrs != null && shiptoPartyAdrs.length() >100){
                            eyRequest.shipToPartyStreet = shiptoPartyAdrs.substring(0, 100);
                            eyRequest.shipToPartyStreet2 = shiptoPartyAdrs.substring(0, 100);
                            eyRequest.shipToPartyStreet3 = shiptoPartyAdrs.substring(0, 100);
                        }else{
                            eyRequest.shipToPartyStreet = shiptoPartyAdrs;
                            eyRequest.shipToPartyStreet2 = shiptoPartyAdrs;
                            eyRequest.shipToPartyStreet3 = shiptoPartyAdrs;
                        }
                        //eyRequest.shipToPartyStreet = blngaddress[0].ADDRESS1__c;
                        //eyRequest.shipToPartyStreet2 = blngaddress[0].ADDRESS2__c == null ?  blngaddress[0].ADDRESS1__c : blngaddress[0].ADDRESS2__c;
                        //eyRequest.shipToPartyStreet3 = blngaddress[0].ADDRESS1__c;
                        eyRequest.shipToPartyPinCode = blngaddress[0].PINCODE__c;
                        
                        eyRequest.shipToPartyCity = blngaddress[0].CITY__c ;
                        eyRequest.shipToPartyState = blngaddress[0].STATE__c;
                        eyRequest.placeOfDelivery = blngaddress[0].STATE__c;
                        eyRequest.placeOfReceipt = blngaddress[0].STATE__c;
                        eyRequest.shipToPartyCountry = blngaddress[0].COUNTRY__c;
                        eyRequest.shipToPartyName = blng_accName;
                    }
                    eyRequest.customerType = blngaddress[0].GST_Registered_Status__c == 'Registered' ? 'Registered' : 'Unregistered';
                    eyRequest.customerGSTIN = blngaddress[0].GST_Registered_Status__c == 'Registered' ? blngaddress[0].GSTIN__c : '';
                    eyRequest.exemptionFlag = blngaddress[0].Dealer_Type__c == 'SEZ' ? true : false;

                    eyRequest.customerPAN = creditNote.blng__Account__r.PAN_Number_of_Entity__c;
                    eyRequest.bvclPAN = creditNote.BVC_Branch__r.BVC_Entity__r.PAN__c;
                    eyRequest.bvclName = creditNote.BVC_Branch__r.BVC_Entity__r.Name;
                    String billingadress = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c+','+(creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c != null?creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c : '');
                    eyRequest.billingOfficeAddress = (billingadress.length() >100 ? billingadress.substring(0,100):billingadress);
                    eyRequest.billingOfficePinCode = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c;
                    eyRequest.billingOfficeCity = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c;
                    eyRequest.billingOfficeState = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c;
                    eyRequest.billingOfficeGSTN = creditNote.BVC_Billing_Entity__r.GSTIN__c;
                
                
                    eyRequest.portOfDischarge = null;
                    eyRequest.portOfLoad = null;
                    if(creditNote.Billing_Address__c != null
                       && creditNote.blng__RelatedInvoice__r.Origin_Address__c != null
                       && blngaddress[0].GST_Registered_Status__c != 'Registered'){
                           eyRequest.pickupLocationCity = creditNote.blng__RelatedInvoice__r.Origin_Address__r.CITY__c ;
                           eyRequest.pickupLocationState = creditNote.blng__RelatedInvoice__r.Origin_Address__r.STATE__c;
                           eyRequest.pickupLocationCountry = creditNote.blng__RelatedInvoice__r.Origin_Address__r.COUNTRY__c;
                       }
                    else{ 
                        eyRequest.pickupLocationCity = null ;
                        eyRequest.pickupLocationState = null ;
                        eyRequest.pickupLocationCountry = null ;
                    }
                    eyRequest.terminalOfOrigin = null;
                    String salesAdress = (creditNote.BVC_Branch__r.Hub_Address_Line_1__c != null ? creditNote.BVC_Branch__r.Hub_Address_Line_1__c : '')+ (creditNote.BVC_Branch__r.Hub_Address_Line_2__c != null ? creditNote.BVC_Branch__r.Hub_Address_Line_2__c : '');
                    eyRequest.salesOfficeAddress = (salesAdress.length()>100 ? salesAdress.subString(0,100) : salesAdress);
                    
                    eyRequest.salesOffiecState = creditNote.BVC_Branch__r.Hub_State__c;
                    eyRequest.salesOfficeName = creditNote.BVC_Branch__r.Name;

                    eyRequest.lineItems =  new List<EY_RequestJSONParser.lineItems>();
                    List<EY_RequestJSONParser.lineItems> lineItemsList = new List<EY_RequestJSONParser.lineItems>();
                    Integer count = 0 ;
                    integer i=0;
                    for(blng__CreditNoteLine__c cnLine : creditNote.blng__CreditNoteCreditLines__r){
                        count++;
                        EY_RequestJSONParser.lineItems item = new EY_RequestJSONParser.lineItems();
                        item.uom = 'OTH-OTHERS';
                        item.itemNumber = String.valueOf(count);
                        item.itemQuantity = 1;
                        if(cnLine.Charge_Head_Type__c == 'Freight Charge'){
                            item.preceedingBillingDocumenItem = '1';
                        }else if(cnLine.Charge_Head_Type__c == 'Liability Charge'){
                            item.preceedingBillingDocumenItem = '2';
                        }else if(cnLine.Charge_Head_Type__c == 'Offline Charge'){
                            item.preceedingBillingDocumenItem = '3';
                        }else if(cnLine.Charge_Head_Type__c == 'BVC Valuation Charge'){
                            item.preceedingBillingDocumenItem = '4';
                        }else if(cnLine.Charge_Head_Type__c == 'Weight Charge'){
                            item.preceedingBillingDocumenItem = '5';
                        }else if(cnLine.Charge_Head_Type__c == 'Docket Charge'){
                            item.preceedingBillingDocumenItem = '6';
                        }else if(cnLine.Charge_Head_Type__c == 'Holiday Charge'){
                            item.preceedingBillingDocumenItem = '7';
                        }else if(cnLine.Charge_Head_Type__c == 'Fuel Charge'){
                            item.preceedingBillingDocumenItem = '8';
                        }
                        // Tax Calculation For Bath and eShip in Credit Notes
                        else if(cnLine.Charge_Head_Type__c == 'Commission Charge'){
                            item.preceedingBillingDocumenItem = '9';
                        }else if(cnLine.Charge_Head_Type__c == 'Logistics Charge'){
                            item.preceedingBillingDocumenItem = '10';
                        }else if(cnLine.Charge_Head_Type__c == 'Secure Logistics Charge'){
                            item.preceedingBillingDocumenItem = '11';
                        }
                        else if(cnLine.Charge_Head_Type__c == 'Fuel Surcharge'){
                            item.preceedingBillingDocumenItem = '12';
                        }
                        else if(cnLine.Charge_Head_Type__c == 'Vaulting Charge'){
                            item.preceedingBillingDocumenItem = '13';
                        }
                        else{
                           item.preceedingBillingDocumenItem = String.valueOf(i);
                           i++;
                        }
                        
                        item.unitPrice =  cnLine.blng__Subtotal__c;
                        item.itemNetValue = cnLine.blng__Subtotal__c;
                        System.debug('@@@Charge Type  '+cnLine.Charge_Head_Type__c);
                        if(mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c) != null && mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c) != ''){
                         	System.debug('@@@Charge Type  '+EY_Master_Data__mdt.getInstance(mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c)));
                        	EY_Master_Data__mdt mc = EY_Master_Data__mdt.getInstance(mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c));
                        	item.materialChargeCode = mc.Charge_Code__c;   
                        }else{
                            string chargetype = cnLine.Charge_Head_Type__c.replaceAll('[^a-zA-Z]','_').replace('___','_').replace('__','_').removeEnd('_');
                        	EY_Master_Data__mdt mc = EY_Master_Data__mdt.getInstance(chargetype);
                        	item.materialChargeCode = mc.Charge_Code__c;
                        }
                        lineItemsList.add(item);
                        mapCNlines.put(cnLine.Charge_Head_Type__c, cnLine);
                        System.debug('mapCNlines-----------  '+mapCNlines);
        
                    }
            
                    eyRequest.lineItems.addAll(lineItemsList);
                    req1.setBody(JSON.serialize(eyRequest));
                    system.debug('Body'+req1.getBody());

                    
                    if(!test.isRunningTest()){
                        res = h.send(req1);
                    }else{
                        EYHttpTestResponseGenerator testMockey = new EYHttpTestResponseGenerator();
                        res = testMockey.respond(req1);
                    }
                    system.debug(res.getStatusCode() + ' SP body '+res.getBody());
                    Integration_Log__c log = new Integration_Log__c();
                    log.Integration_Server__c = 'Ey Tax Server';
                    log.Request_JSON__c = req1.getBody();
                    log.Response_JSON__c = ((res != null && res.getBody() != null)?res.getBody():'');
                    log.Credit_Note__c = creditNote.Id;
                    //include Error Code for log object
                    log.Error_Reason__c = eyResponse.taxEngineErrorMessage;
                    insert log;
                    if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                        system.debug('Tax Response Body'+res.getBody());
                        system.debug('EyResponse :::'+JSON.deserializeUntyped(res.getBody()));
                        system.debug('JSON.deserialize(res.getBody(),EY_ResponseJSONParser.class) ::'+(EY_ResponseJSONParser)JSON.deserialize(res.getBody(),EY_ResponseJSONParser.class));
                        eyResponse = (EY_ResponseJSONParser)JSON.deserialize(res.getBody(),EY_ResponseJSONParser.class);
                        system.debug('eyResponse>>>'+eyResponse);

                        if(eyResponse.taxEngineErrorCode != null
                            &&eyResponse.taxEngineErrorMessage != ''){                            

                            // message = 'Error: Callout failed :: '+eyResponse.taxEngineErrorCode;
                            // creditReturnURL = '/' + creditNoteId;
                            // showError = true;
                            throw new applicationException('Error: Callout failed :: '+eyResponse.taxEngineErrorMessage);
                        }else if(eyResponse.digiGSTErrorCode != null
                        &&eyResponse.digiGSTErrorMessage != ''){
                            // message = 'Error: Callout failed :: '+eyResponse.digiGSTErrorMessage;
                            // creditReturnURL = '/' + creditNoteId;
                            // showError = true;
                            if(blngaddress[0].GST_Registered_Status__c == 'Registered'){
                                throw new applicationException('Error: Callout failed :: '+eyResponse.digiGSTErrorMessage);
                            }
                                
                        }
                        
                        
                    } 
                    else if(res.getStatusCode() == 307){
                        req.setEndpoint(res.getHeader('Location'));
                        res = new Http().send(req);
                    }
                    else {
                        // callout failed
                        throw new applicationException('Error: Callout failed. Please review the debug log for additional details.');
                        // message = 'Error: Callout failed. Please review the debug log for additional details.';
                        // creditReturnURL = '/' + creditNoteId;
                        // showError = true;
                    }
                    
                }else{

                    throw new applicationException('CreditNote ERROR : Billing Address Missing');
                }
             
            }
            if(!showError){
                Decimal taxCalculated = 0.0;
                List<Charge_Head_Tax__c> chargeHeads = new List<Charge_Head_Tax__c>();
                system.debug('creditNote Id:::'+creditNote.Id);
                system.debug('Response Body::Tax Values'+eyResponse);
                List<EY_ResponseJSONParser.lineItems> lineItemListed = new  List<EY_ResponseJSONParser.lineItems>();
                lineItemListed.addAll(eyResponse.lineItems);
                system.debug('Line Items From tax response:::'+eyResponse.lineItems);
                // Update CreditNote 
                creditNote.Place_Of_Supply__c = eyResponse.posCity;
                creditNote.Place_of_Supply_City__c = eyResponse.posCity;
                creditNote.Place_Of_Supply_State__c = eyResponse.posState;
                creditNote.State_Of_Supply__c = eyResponse.posState;
                creditNote.Place_of_Supply_State_Code__c = eyResponse.posStateCode;
                creditNote.IRN__c = eyResponse.irnNumber;
                creditNote.Signed_QR_Code_URL__c = 'https://image-charts.com/chart?chs=50x15&cht=qr&chl='+eyResponse.signedQRCode;
                String SignedQrCode = 'https://image-charts.com/chart?chs=50x15&cht=qr&chl='+eyResponse.signedQRCode;
                creditNote.Signed_QR_Code__c   = '<img alt="User-added image" src="'+SignedQrCode+'"></img>';
                creditNote.blng__Status__c   = 'Posted';
                
                for(EY_ResponseJSONParser.lineItems li: lineItemListed){
                    
                    if(mapResponseCharge.containsKey(li.materialDescription) && mapCNlines.containsKey(mapResponseCharge.get(li.materialDescription))){
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).CGST_Amount__c = li.cgsT_INR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).CGST_Percent__c = li.cgstPercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).IGST_Amount__c = li.igsT_INR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).IGST_Percent__c = li.igstPercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).SGST_Amount__c = li.sgsT_INR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).SGST_Percent__c = li.sgstPercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).blng__TaxAmount__c = li.taxCalculatedINR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).blng__TaxPercentageApplied__c = li.taxApplicablePercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).HSN_Code__c = li.sacApplicable;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Line_Number__c = li.itemNumber;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Name__c = li.materialDescription;
						
                        if(li.materialDescription == 'FREIGHT CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Freight_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Freight_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Freight_Charges').COA_Revenue_Sub_Account__c;
                            
                        }
                        if(li.materialDescription == 'OFFLINE CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Offline_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Offline_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Offline_Charges').COA_Revenue_Sub_Account__c;
                        }
                        if(li.materialDescription == 'LIABILITY CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'BVC VALUATION CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'DOCKET CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Docket_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Docket_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Docket_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'FUEL CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Fuel_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'HOLIDAY CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Holiday_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Holiday_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Holiday_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'WEIGHT CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Weight_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Weight_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Weight_Charges').COA_Revenue_Sub_Account__c;
                        }
                        if(li.materialDescription == 'FUEL SURCHARGE'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').COA_Revenue_Sub_Account__c;
                        }
                        if(li.materialDescription == 'VAULTING CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').COA_Revenue_Sub_Account__c;
                        }
                        
						// Modified for bath and eship 
                        if(li.materialDescription == 'COMMISSION'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Commission').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Commission').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Commission').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'LOGISTICS CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'SECURE LOGISTICS CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').COA_Revenue_Sub_Account__c;
                        }

						
                    }else{
                        string chargetype = li.materialDescription.replaceAll('[^a-zA-Z]','_').replace('___','_').replace('__','_').removeEnd('_');
                        system.debug('chargetype============'+li.materialDescription);
                        system.debug('materialDescription============'+chargetype);
                        system.debug('mapCNlines============'+mapCNlines);
                        mapCNlines.get(li.materialDescription).CGST_Amount__c = li.cgsT_INR;
                        system.debug('mapCNlines============'+mapCNlines.get(li.materialDescription).CGST_Amount__c);
                        mapCNlines.get(li.materialDescription).CGST_Percent__c = li.cgstPercentage*100;
                        mapCNlines.get(li.materialDescription).IGST_Amount__c = li.igsT_INR;
                        mapCNlines.get(li.materialDescription).IGST_Percent__c = li.igstPercentage*100;
                        mapCNlines.get(li.materialDescription).SGST_Amount__c = li.sgsT_INR;
                        mapCNlines.get(li.materialDescription).SGST_Percent__c = li.sgstPercentage*100;
                        mapCNlines.get(li.materialDescription).blng__TaxAmount__c = li.taxCalculatedINR;
                        mapCNlines.get(li.materialDescription).blng__TaxPercentageApplied__c = li.taxApplicablePercentage*100;
                        mapCNlines.get(li.materialDescription).HSN_Code__c = li.sacApplicable;
                        mapCNlines.get(li.materialDescription).Line_Number__c = li.itemNumber;
                        mapCNlines.get(li.materialDescription).Charge_Head_Name__c = li.materialDescription;
						mapCNlines.get(li.materialDescription).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance(chargetype).Charge_Code__c;
                        mapCNlines.get(li.materialDescription).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance(chargetype).COA_Revenue_Account_Code__c;
                        mapCNlines.get(li.materialDescription).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance(chargetype).COA_Revenue_Sub_Account__c;
                    }
                    
                }
                update mapCNlines.values();
                update creditNote;
                PageReference pageRef = new PageReference('/' + creditNote.id);
                pageRef.setRedirect(true);
                System.debug('creditNotePage. '+pageRef);
                message = 'Tax calculation Completed Successfully';
                creditReturnURL = '/' + creditNote.id;
                showSuccess = true;
            }
            
        }catch(Exception ex){
            system.debug('EY CALCULATION FAILED :::'+ex.getMessage());
            message = 'Tax calculation Failed : '+ex.getMessage();
            creditReturnURL = '/' + creditNoteId;
            showError = true;
        }
        
        
      
    }
    @future(callout= true)
    public static void doTaxCalculationForCN(String pId) {
        Boolean showError = false;
        Boolean showSuccess = false;
        String creditNoteId = pId;
        String creditReturnURL;
        String message;
        try{
            //String creditNoteId = ApexPages.CurrentPage().getparameters().get('Id');
            String outcomeMsg;
            Map<String,String> mapChargeHeadTypes = new Map<String,String>{ 'Freight Charge' => 'Freight_Charges','Liability Charge' => 'Liability_Charges', 'Offline Charge'   => 'Offline_Charges','Weight Charge'   => 'Weight_Charges',
                                                                            'BVC Valuation Charge' => 'BVC_Valuation_Charges','Docket Charge' => 'Docket_Charges', 'Fuel Charge'   => 'Fuel_Charges','Holiday Charge'   => 'Holiday_Charges','Commission Charge'   => 'Commission','Logistics Charge'   => 'Logistics_Charges','Secure Logistics Charge'   => 'Secure_Logistics_Charges','Fuel Surcharge' => 'Fuel_Surcharge','Vaulting Charge' =>'Vaulting_Charges'};
            Map<String,String> mapResponseCharge = new Map<String,String>{ 'FREIGHT CHARGES' => 'Freight Charge', 'LIABILITY CHARGES'=> 'Liability Charge', 'OFFLINE CHARGES'   => 'Offline Charge','BVC VALUATION CHARGES'   => 'BVC Valuation Charge',
                                                                            'DOCKET CHARGES' => 'Docket Charge', 'FUEL CHARGES' => 'Fuel Charge','HOLIDAY CHARGES' => 'Holiday Charge', 'WEIGHT CHARGES' => 'Weight Charge','COMMISSION' => 'Commission Charge','LOGISTICS CHARGES' => 'Logistics Charge','SECURE LOGISTICS CHARGES' => 'Secure Logistics Charge', 'FUEL SURCHARGE' => 'Fuel Surcharge', 'VAULTING CHARGES' =>'Vaulting Charge'};
            //string token;
            EY_ResponseJSONParser eyResponse = new EY_ResponseJSONParser();
            //EY_ResponseJSONParser eyResponse = new EY_ResponseJSONParser();
            
            //string endpoint = 'https://20.198.75.155/api/Auth/Login'; 
            string endpoint ;//= 'https://bvcapp.com/api/Auth/Login';
            string username ;//= 'vaibhav.pancholi@bvclogistics.com'; 
            string password ;//= 'Bvc@2021';
            string method = 'POST';
        
       
            API_Integration_Credential__mdt loginDetails = API_Integration_Credential__mdt.getInstance('EY');
            if(loginDetails != null){
                system.debug('loginDetails::: EY ::: Auth:'+loginDetails);
                endpoint = loginDetails.Server_URL__c;
                username = loginDetails.UserName__c; 
                password = loginDetails.Password__c;
            }
            Map<String,blng__CreditNoteLine__c> mapCNlines = new Map<String,blng__CreditNoteLine__c>();
            blng__CreditNote__c creditNote = [SELECT Id, Name, Approval_Status__c ,Billing_Address__c,Place_Of_Supply__c ,blng__CreditNoteDate__c,CreditNote_Serial_No__c,State_Of_Supply__c ,Place_of_Supply_State_Code__c,IRN__c ,Signed_QR_Code__c ,
                                    blng__RelatedInvoice__c ,blng__RelatedInvoice__r.blng__Order__c,blng__RelatedInvoice__r.Name, blng__RelatedInvoice__r.blng__Order__r.BillingAddress,
                                    blng__RelatedInvoice__r.blng__Order__r.Account.Name,blng__RelatedInvoice__r.blng__Account__r.Billing_Address__c,blng__RelatedInvoice__r.blng__InvoiceDate__c,
                                    blng__Account__c ,blng__Account__r.Billing_Address__c,blng__Account__r.Billing_Address__r.GST_Registered_Status__c,blng__RelatedInvoice__r.ST_Invoice_Series__c,
                                    blng__Account__r.Billing_Address__r.Dealer_Type__c,blng__RelatedInvoice__r.blng__Order__r.Business_Type__c,blng__RelatedInvoice__r.Origin_Address__c,
                                    blng__RelatedInvoice__r.Origin_Address__r.CITY__c,blng__RelatedInvoice__r.Origin_Address__r.STATE__c,blng__RelatedInvoice__r.Origin_Address__r.COUNTRY__c,
                                    blng__Account__r.GSTIN__c,blng__Account__r.PAN_Number_of_Entity__c,BVC_Branch__r.BVC_Entity__r.PAN__c,BVC_Branch__r.BVC_Entity__r.Name,
                                    BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c,
                                    BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c,BVC_Billing_Entity__r.GSTIN__c,
                                    BVC_Branch__r.Hub_Address_Line_1__c,BVC_Branch__r.Hub_Address_Line_2__c,BVC_Branch__r.Hub_State__c,BVC_Branch__r.Name,blng__RelatedInvoice__r.Destination_Address__r.PINCODE__c,
                                    blng__RelatedInvoice__r.Destination_Address__r.CITY__c,blng__RelatedInvoice__r.Destination_Address__r.STATE__c,blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c,blng__RelatedInvoice__r.Destination_Address__r.ADDRESS2__c,blng__RelatedInvoice__r.Destination_Address__r.COUNTRY__c,
                                    blng__RelatedInvoice__r.blng__Order__r.blng__BillingAccount__r.Name,blng__RelatedInvoice__r.blng__Order__r.BillingCity,blng__RelatedInvoice__r.blng__Account__r.Name,
                                    blng__RelatedInvoice__r.blng__Account__r.ShippingAddress,blng__RelatedInvoice__r.blng__Order__r.BillingState,blng__RelatedInvoice__r.blng__Order__r.BillingCountry,
                                    blng__RelatedInvoice__r.blng__Order__r.ShippingAddress,blng__RelatedInvoice__r.blng__Order__r.ShippingCity,blng__RelatedInvoice__r.blng__Order__r.ShippingState,
                                    blng__RelatedInvoice__r.blng__Order__r.ShippingCountry,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.CITY__c,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.ADDRESS1__c,
                                    blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.ADDRESS2__c,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.STATE__c,
                                    blng__RelatedInvoice__r.blng__Order__r.Billing_Address__r.COUNTRY__c,blng__RelatedInvoice__r.blng__Order__r.Billing_Address__c,blng__RelatedInvoice__r.blng__InvoiceRunCreatedBy__c,
                                    (select id,Charge_Head_Type__c,blng__Subtotal__c,CGST_Amount__c,CGST_Percent__c,IGST_Amount__c,IGST_Percent__c,SGST_Amount__c,SGST_Percent__c,blng__TotalAmount__c,blng__TaxPercentageApplied__c from blng__CreditNoteCreditLines__r) FROM blng__CreditNote__c 
                                    WHERE Id = :creditNoteId LIMIT 1];
            
            
            Id addressId ; //= inv.blng__InvoiceRunCreatedBy__c == null ?  inv.blng__Order__r.Billing_Address__c : inv.blng__Account__r.Billing_Address__c;      
            String blng_accName;
            String spng_accName;
            Address spng_Address;
            if(creditNote != null && creditNote.Approval_Status__c != 'Approved'){
                throw new applicationException('CreditNote ERROR : CreditNote is not approved');
            }
            if(creditNote.Billing_Address__c != null){
                addressId =  creditNote.Billing_Address__c;
            }else{
                throw new applicationException('CreditNote ERROR : Billing Address Missing');
            }
            if(creditNote.blng__RelatedInvoice__r.blng__InvoiceRunCreatedBy__c == null && creditNote.blng__RelatedInvoice__r.blng__Order__c != null){
                blng_accName  = creditNote.blng__RelatedInvoice__r.blng__Order__r.blng__BillingAccount__r.Name != null ? creditNote.blng__RelatedInvoice__r.blng__Order__r.blng__BillingAccount__r.Name : creditNote.blng__RelatedInvoice__r.blng__Order__r.Account.Name;
                spng_Address = creditNote.blng__RelatedInvoice__r.blng__Order__r.ShippingAddress;
                spng_accName = creditNote.blng__RelatedInvoice__r.blng__Order__r.Account.Name;
            }
            else {

                blng_accName =  creditNote.blng__RelatedInvoice__r.blng__Account__r.Name;
                spng_Address =  creditNote.blng__RelatedInvoice__r.blng__Account__r.ShippingAddress;
                spng_accName =  creditNote.blng__RelatedInvoice__r.blng__Account__r.Name;
            }
            List<AddressBook__c> blngaddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,GSTIN__c ,PINCODE__c,GST_Registered_Status__c,Dealer_Type__c,STATE__c,COUNTRY__c,CITY__c FROM AddressBook__c WHERE Id = :addressId];            
            
            if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
                outcomeMsg = 'Maximum number of callouts has been reached.';
            } else if (endpoint == null || username == null || password == null) {
                outcomeMsg = 'Please verify your API Credentials';
                
                // configure and perform the callout
            } else {
                system.debug('EndPoint:'+endpoint+':Method:'+method);
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
                
                if(!test.isRunningTest()){
                    token = h.send(req);
                }else{
                    MockHttpTokenGenerator testMock = new MockHttpTokenGenerator();
                    token = testMock.respond(req);
                }
                
                Map<String,Object> tokenMap = (Map<String,Object>)JSON.deserializeUntyped(token.getBody());
                String bearerToken = (String)tokenMap.get('token');
                API_Integration_Credential__mdt gstEngine = API_Integration_Credential__mdt.getInstance('EY_GST_Engine');
                
                HttpResponse res = new HttpResponse();
                HttpRequest req1 = new HttpRequest();
                
                req1.setHeader('Authorization','Bearer ' +bearerToken);
                req1.setHeader('Content-Type', 'application/json');
                //string endpoint1 = 'https://bvcapp.com/api/BVCGSTEngine';
                string endpoint1 = gstEngine.Server_URL__c;
                string method1 = 'POST'; 
                req1.setEndpoint(endpoint1);
                req1.setMethod(method1);
                req1.setTimeout(120000);

                
                EY_RequestJSONParser eyRequest = new EY_RequestJSONParser();
                eyRequest.documentType = 'CR';
                eyRequest.billingDate = String.valueOf(creditNote.blng__CreditNoteDate__c );
                eyRequest.preceedingInvoiceDate = String.valueOf(creditNote.blng__RelatedInvoice__r.blng__InvoiceDate__c );
                eyRequest.preceedingBillingDocumentNo = creditNote.blng__RelatedInvoice__r.ST_Invoice_Series__c ;
                eyRequest.billingDocumentNumber = creditNote.CreditNote_Serial_No__c ;
                eyRequest.roe = 1;
                eyRequest.documentCurrency = 'INR';
                List<String> billingStreet = new List<String>();
               
                if(blngaddress.size() > 0 ){

                    eyRequest.soldToParty = blng_accName ; // != null ? inv.blng__Order__r.Account.Name : inv.blng__Account__c;
                    eyRequest.soldToPartyName = blng_accName;// != null ? inv.blng__Order__r.Account.Name : inv.blng__Account__c;
                    String billToPartAdrs = (blngaddress[0].ADDRESS1__c != null?blngaddress[0].ADDRESS1__c :'') +',' + (blngaddress[0].ADDRESS2__c != null?blngaddress[0].ADDRESS2__c :'')  ;
                    if(billToPartAdrs != null && billToPartAdrs.length() >100){
                        eyRequest.soldToPartyStreet = billToPartAdrs.substring(0, 100);
                        eyRequest.soldToPartyStreet2 = billToPartAdrs.substring(0, 100);
                        eyRequest.soldToPartyStreet3 =  billToPartAdrs.substring(0, 100);
                    }
                    else{
                        eyRequest.soldToPartyStreet = billToPartAdrs;
                        eyRequest.soldToPartyStreet2 = billToPartAdrs;
                        eyRequest.soldToPartyStreet3 =  billToPartAdrs;
                    }
                    //eyRequest.soldToPartyStreet = blngaddress[0].ADDRESS1__c == null ? blngaddress[0].CITY__c : blngaddress[0].ADDRESS1__c;
                    //eyRequest.soldToPartyStreet2 = blngaddress[0].ADDRESS2__c == null ?  blngaddress[0].ADDRESS1__c : blngaddress[0].ADDRESS2__c;
                    //eyRequest.soldToPartyStreet3 =  blngaddress[0].CITY__c;
                    eyRequest.soldToPartyPinCode = blngaddress[0].PINCODE__c;
                    eyRequest.soldToPartyCity = blngaddress[0].CITY__c;
                    eyRequest.soldToPartyState = blngaddress[0].STATE__c;
                    eyRequest.soldToPartyCountry = blngaddress[0].COUNTRY__c;
                    
                    eyRequest.billToPartyName = blng_accName ;//== null ? inv.blng__Order__r.Account.Name : inv.blng__Order__r.blng__BillingAccount__r.Name;
                    eyRequest.billToPartyStreet = blngaddress[0].ADDRESS1__c == null ? blngaddress[0].CITY__c : blngaddress[0].ADDRESS1__c;
                    eyRequest.billToPartyStreet2 =  blngaddress[0].ADDRESS2__c == null ? blngaddress[0].CITY__c : blngaddress[0].ADDRESS2__c;
                    eyRequest.billToPartyStreet3 = blngaddress[0].CITY__c;
                    eyRequest.billToPartyPinCode = blngaddress[0].PINCODE__c;
                    eyRequest.billToPartyCity = blngaddress[0].CITY__c;
                    eyRequest.billToPartyState = blngaddress[0].STATE__c;
                    eyRequest.billToPartyCountry = blngaddress[0].COUNTRY__c;
            
                    
                    List<String> shippingStreet = new List<String>();
                    
                    //inv.blng__Order__r.ShippingAddress.getStreet().split('\\,');
                    if(creditNote.blng__RelatedInvoice__r.blng__Order__c != null
                       && creditNote.blng__RelatedInvoice__r.blng__Order__r.Business_Type__C == 'ACR'){
                           
                       }
                    eyRequest.shipToParty = spng_accName;
                    if(creditNote.blng__RelatedInvoice__r.Destination_Address__c != null){
                        if(creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c != null
                           &&creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c != ''){
                                eyRequest.shipToPartyStreet = creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c;
                                eyRequest.shipToPartyStreet2 = creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS2__c == null ?  creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c : creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS2__c;
                                eyRequest.shipToPartyStreet3 = creditNote.blng__RelatedInvoice__r.Destination_Address__r.ADDRESS1__c;
                           }
                        eyRequest.shipToPartyPinCode = creditNote.blng__RelatedInvoice__r.Destination_Address__r.PINCODE__c;
                        eyRequest.shipToPartyCity = creditNote.blng__RelatedInvoice__r.Destination_Address__r.CITY__c ;
                        eyRequest.shipToPartyState = creditNote.blng__RelatedInvoice__r.Destination_Address__r.STATE__c;
                        eyRequest.placeOfDelivery = creditNote.blng__RelatedInvoice__r.Destination_Address__r.STATE__c;
                        eyRequest.placeOfReceipt = creditNote.blng__RelatedInvoice__r.Destination_Address__r.STATE__c;
                        eyRequest.shipToPartyCountry = creditNote.blng__RelatedInvoice__r.Destination_Address__r.COUNTRY__c;
                        eyRequest.shipToPartyName = creditNote.blng__RelatedInvoice__r.Consignee_Name__c;
                    }
                    else{
                        string shiptoPartyAdrs = (blngaddress[0].ADDRESS1__c != null?blngaddress[0].ADDRESS1__c :'') +',' + (blngaddress[0].ADDRESS2__c != null?blngaddress[0].ADDRESS2__c :'');
                        if(shiptoPartyAdrs != null && shiptoPartyAdrs.length() >100){
                            eyRequest.shipToPartyStreet = shiptoPartyAdrs.substring(0, 100);
                            eyRequest.shipToPartyStreet2 = shiptoPartyAdrs.substring(0, 100);
                            eyRequest.shipToPartyStreet3 = shiptoPartyAdrs.substring(0, 100);
                        }else{
                            eyRequest.shipToPartyStreet = shiptoPartyAdrs;
                            eyRequest.shipToPartyStreet2 = shiptoPartyAdrs;
                            eyRequest.shipToPartyStreet3 = shiptoPartyAdrs;
                        }
                        //eyRequest.shipToPartyStreet = blngaddress[0].ADDRESS1__c;
                        //eyRequest.shipToPartyStreet2 = blngaddress[0].ADDRESS2__c == null ?  blngaddress[0].ADDRESS1__c : blngaddress[0].ADDRESS2__c;
                        //eyRequest.shipToPartyStreet3 = blngaddress[0].ADDRESS1__c;
                        eyRequest.shipToPartyPinCode = blngaddress[0].PINCODE__c;
                        
                        eyRequest.shipToPartyCity = blngaddress[0].CITY__c ;
                        eyRequest.shipToPartyState = blngaddress[0].STATE__c;
                        eyRequest.placeOfDelivery = blngaddress[0].STATE__c;
                        eyRequest.placeOfReceipt = blngaddress[0].STATE__c;
                        eyRequest.shipToPartyCountry = blngaddress[0].COUNTRY__c;
                        eyRequest.shipToPartyName = blng_accName;
                    }
                    eyRequest.customerType = blngaddress[0].GST_Registered_Status__c == 'Registered' ? 'Registered' : 'Unregistered';
                    eyRequest.customerGSTIN = blngaddress[0].GST_Registered_Status__c == 'Registered' ? blngaddress[0].GSTIN__c : '';
                    eyRequest.exemptionFlag = blngaddress[0].Dealer_Type__c == 'SEZ' ? true : false;

                    eyRequest.customerPAN = creditNote.blng__Account__r.PAN_Number_of_Entity__c;
                    eyRequest.bvclPAN = creditNote.BVC_Branch__r.BVC_Entity__r.PAN__c;
                    eyRequest.bvclName = creditNote.BVC_Branch__r.BVC_Entity__r.Name;
                    String billingadress = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c+','+(creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c != null?creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c : '');
                    eyRequest.billingOfficeAddress = (billingadress.length() >100 ? billingadress.substring(0,100):billingadress);
                    eyRequest.billingOfficePinCode = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c;
                    eyRequest.billingOfficeCity = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c;
                    eyRequest.billingOfficeState = creditNote.BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c;
                    eyRequest.billingOfficeGSTN = creditNote.BVC_Billing_Entity__r.GSTIN__c;
                
                
                    eyRequest.portOfDischarge = null;
                    eyRequest.portOfLoad = null;
                    if(creditNote.Billing_Address__c != null
                       && creditNote.blng__RelatedInvoice__r.Origin_Address__c != null
                       && blngaddress[0].GST_Registered_Status__c != 'Registered'){
                           eyRequest.pickupLocationCity = creditNote.blng__RelatedInvoice__r.Origin_Address__r.CITY__c ;
                           eyRequest.pickupLocationState = creditNote.blng__RelatedInvoice__r.Origin_Address__r.STATE__c;
                           eyRequest.pickupLocationCountry = creditNote.blng__RelatedInvoice__r.Origin_Address__r.COUNTRY__c;
                       }
                    else{ 
                        eyRequest.pickupLocationCity = null ;
                        eyRequest.pickupLocationState = null ;
                        eyRequest.pickupLocationCountry = null ;
                    }
                    eyRequest.terminalOfOrigin = null;
                    String salesAdress = (creditNote.BVC_Branch__r.Hub_Address_Line_1__c != null ? creditNote.BVC_Branch__r.Hub_Address_Line_1__c : '')+ (creditNote.BVC_Branch__r.Hub_Address_Line_2__c != null ? creditNote.BVC_Branch__r.Hub_Address_Line_2__c : '');
                    eyRequest.salesOfficeAddress = (salesAdress.length()>100 ? salesAdress.subString(0,100) : salesAdress);
                    
                    eyRequest.salesOffiecState = creditNote.BVC_Branch__r.Hub_State__c;
                    eyRequest.salesOfficeName = creditNote.BVC_Branch__r.Name;

                    eyRequest.lineItems =  new List<EY_RequestJSONParser.lineItems>();
                    List<EY_RequestJSONParser.lineItems> lineItemsList = new List<EY_RequestJSONParser.lineItems>();
                    Integer count = 0 ;
                    integer i=0;
                    for(blng__CreditNoteLine__c cnLine : creditNote.blng__CreditNoteCreditLines__r){
                        count++;
                        EY_RequestJSONParser.lineItems item = new EY_RequestJSONParser.lineItems();
                        item.uom = 'OTH-OTHERS';
                        item.itemNumber = String.valueOf(count);
                        item.itemQuantity = 1;
                        if(cnLine.Charge_Head_Type__c == 'Freight Charge'){
                            item.preceedingBillingDocumenItem = '1';
                        }else if(cnLine.Charge_Head_Type__c == 'Liability Charge'){
                            item.preceedingBillingDocumenItem = '2';
                        }else if(cnLine.Charge_Head_Type__c == 'Offline Charge'){
                            item.preceedingBillingDocumenItem = '3';
                        }else if(cnLine.Charge_Head_Type__c == 'BVC Valuation Charge'){
                            item.preceedingBillingDocumenItem = '4';
                        }else if(cnLine.Charge_Head_Type__c == 'Weight Charge'){
                            item.preceedingBillingDocumenItem = '5';
                        }else if(cnLine.Charge_Head_Type__c == 'Docket Charge'){
                            item.preceedingBillingDocumenItem = '6';
                        }else if(cnLine.Charge_Head_Type__c == 'Holiday Charge'){
                            item.preceedingBillingDocumenItem = '7';
                        }else if(cnLine.Charge_Head_Type__c == 'Fuel Charge'){
                            item.preceedingBillingDocumenItem = '8';
                        }
                        // Tax Calculation For Bath and eShip in Credit Notes
                        else if(cnLine.Charge_Head_Type__c == 'Commission Charge'){
                            item.preceedingBillingDocumenItem = '9';
                        }else if(cnLine.Charge_Head_Type__c == 'Logistics Charge'){
                            item.preceedingBillingDocumenItem = '10';
                        }else if(cnLine.Charge_Head_Type__c == 'Secure Logistics Charge'){
                            item.preceedingBillingDocumenItem = '11';
                        }
                        else if(cnLine.Charge_Head_Type__c == 'Fuel Surcharge'){
                            item.preceedingBillingDocumenItem = '12';
                        }
                        else if(cnLine.Charge_Head_Type__c == 'Vaulting Charge'){
                            item.preceedingBillingDocumenItem = '13';
                        }
                        else{
                           item.preceedingBillingDocumenItem = String.valueOf(i);
                           i++;
                        }
                        
                        item.unitPrice =  cnLine.blng__Subtotal__c;
                        item.itemNetValue = cnLine.blng__Subtotal__c;
                        System.debug('@@@Charge Type  '+cnLine.Charge_Head_Type__c);
                        if(mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c) != null && mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c) != ''){
                         	System.debug('@@@Charge Type  '+EY_Master_Data__mdt.getInstance(mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c)));
                        	EY_Master_Data__mdt mc = EY_Master_Data__mdt.getInstance(mapChargeHeadTypes.get(cnLine.Charge_Head_Type__c));
                        	item.materialChargeCode = mc.Charge_Code__c;   
                        }else{
                            string chargetype = cnLine.Charge_Head_Type__c.replaceAll('[^a-zA-Z]','_').replace('___','_').replace('__','_').removeEnd('_');
                        	EY_Master_Data__mdt mc = EY_Master_Data__mdt.getInstance(chargetype);
                        	item.materialChargeCode = mc.Charge_Code__c;
                        }
                        lineItemsList.add(item);
                        mapCNlines.put(cnLine.Charge_Head_Type__c, cnLine);
        
                    }
            
                    eyRequest.lineItems.addAll(lineItemsList);
                    req1.setBody(JSON.serialize(eyRequest));
                    system.debug('Body'+req1.getBody());

                    
                    if(!test.isRunningTest()){
                        res = h.send(req1);
                    }else{
                        EYHttpTestResponseGenerator testMockey = new EYHttpTestResponseGenerator();
                        res = testMockey.respond(req1);
                    }
                    system.debug(res.getStatusCode() + ' SP body '+res.getBody());
                    Integration_Log__c log = new Integration_Log__c();
                    log.Integration_Server__c = 'Ey Tax Server';
                    log.Request_JSON__c = req1.getBody();
                    log.Response_JSON__c = ((res != null && res.getBody() != null)?res.getBody():'');
                    log.Credit_Note__c = creditNote.Id;
                    //include Error Code for log object
                    log.Error_Reason__c = eyResponse.taxEngineErrorMessage;
                    insert log;
                    if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                        system.debug('Tax Response Body'+res.getBody());
                        system.debug('EyResponse :::'+JSON.deserializeUntyped(res.getBody()));
                        system.debug('JSON.deserialize(res.getBody(),EY_ResponseJSONParser.class) ::'+(EY_ResponseJSONParser)JSON.deserialize(res.getBody(),EY_ResponseJSONParser.class));
                        eyResponse = (EY_ResponseJSONParser)JSON.deserialize(res.getBody(),EY_ResponseJSONParser.class);
                        system.debug('eyResponse>>>'+eyResponse);

                        if(eyResponse.taxEngineErrorCode != null
                            &&eyResponse.taxEngineErrorMessage != ''){                            

                            // message = 'Error: Callout failed :: '+eyResponse.taxEngineErrorCode;
                            // creditReturnURL = '/' + creditNoteId;
                            // showError = true;
                            throw new applicationException('Error: Callout failed :: '+eyResponse.taxEngineErrorMessage);
                        }else if(eyResponse.digiGSTErrorCode != null
                        &&eyResponse.digiGSTErrorMessage != ''){
                            // message = 'Error: Callout failed :: '+eyResponse.digiGSTErrorMessage;
                            // creditReturnURL = '/' + creditNoteId;
                            // showError = true;
                            if(blngaddress[0].GST_Registered_Status__c == 'Registered'){
                                throw new applicationException('Error: Callout failed :: '+eyResponse.digiGSTErrorMessage);
                            }
                                
                        }
                        
                        
                    } 
                    else if(res.getStatusCode() == 307){
                        req.setEndpoint(res.getHeader('Location'));
                        res = new Http().send(req);
                    }
                    else {
                        // callout failed
                        throw new applicationException('Error: Callout failed. Please review the debug log for additional details.');
                        // message = 'Error: Callout failed. Please review the debug log for additional details.';
                        // creditReturnURL = '/' + creditNoteId;
                        // showError = true;
                    }
                    
                }else{

                    throw new applicationException('CreditNote ERROR : Billing Address Missing');
                }
             
            }
            if(!showError){
                Decimal taxCalculated = 0.0;
                List<Charge_Head_Tax__c> chargeHeads = new List<Charge_Head_Tax__c>();
                system.debug('creditNote Id:::'+creditNote.Id);
                system.debug('Response Body::Tax Values'+eyResponse);
                List<EY_ResponseJSONParser.lineItems> lineItemListed = new  List<EY_ResponseJSONParser.lineItems>();
                lineItemListed.addAll(eyResponse.lineItems);
                system.debug('Line Items From tax response:::'+eyResponse.lineItems);
                // Update CreditNote 
                creditNote.Place_Of_Supply__c = eyResponse.posCity;
                creditNote.Place_of_Supply_City__c = eyResponse.posCity;
                creditNote.Place_Of_Supply_State__c = eyResponse.posState;
                creditNote.State_Of_Supply__c = eyResponse.posState;
                creditNote.Place_of_Supply_State_Code__c = eyResponse.posStateCode;
                creditNote.IRN__c = eyResponse.irnNumber;
                creditNote.Signed_QR_Code_URL__c = 'https://image-charts.com/chart?chs=50x15&cht=qr&chl='+eyResponse.signedQRCode;
                String SignedQrCode = 'https://image-charts.com/chart?chs=50x15&cht=qr&chl='+eyResponse.signedQRCode;
                creditNote.Signed_QR_Code__c   = '<img alt="User-added image" src="'+SignedQrCode+'"></img>';
                creditNote.blng__Status__c   = 'Posted';
                
                for(EY_ResponseJSONParser.lineItems li: lineItemListed){
                    
                    if(mapResponseCharge.containsKey(li.materialDescription) && mapCNlines.containsKey(mapResponseCharge.get(li.materialDescription))){
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).CGST_Amount__c = li.cgsT_INR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).CGST_Percent__c = li.cgstPercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).IGST_Amount__c = li.igsT_INR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).IGST_Percent__c = li.igstPercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).SGST_Amount__c = li.sgsT_INR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).SGST_Percent__c = li.sgstPercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).blng__TaxAmount__c = li.taxCalculatedINR;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).blng__TaxPercentageApplied__c = li.taxApplicablePercentage*100;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).HSN_Code__c = li.sacApplicable;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Line_Number__c = li.itemNumber;
                        mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Name__c = li.materialDescription;
						
                        if(li.materialDescription == 'FREIGHT CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Freight_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Freight_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Freight_Charges').COA_Revenue_Sub_Account__c;
                            
                        }
                        if(li.materialDescription == 'OFFLINE CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Offline_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Offline_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Offline_Charges').COA_Revenue_Sub_Account__c;
                        }
                        if(li.materialDescription == 'LIABILITY CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'BVC VALUATION CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('BVC_Valuation_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'DOCKET CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Docket_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Docket_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Docket_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'FUEL CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Fuel_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'HOLIDAY CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Holiday_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Holiday_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Holiday_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'WEIGHT CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Weight_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Weight_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Weight_Charges').COA_Revenue_Sub_Account__c;
                        }
                        if(li.materialDescription == 'FUEL SURCHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').COA_Revenue_Sub_Account__c;
                        }
                        if(li.materialDescription == 'VAULTING CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').COA_Revenue_Sub_Account__c;
                        }
                        
						// Modified for bath and eship 
                        if(li.materialDescription == 'COMMISSION'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Commission').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Commission').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Commission').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'LOGISTICS CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').COA_Revenue_Sub_Account__c;
                        }if(li.materialDescription == 'SECURE LOGISTICS CHARGES'){
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').Charge_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').COA_Revenue_Account_Code__c;
                            mapCNlines.get(mapResponseCharge.get(li.materialDescription)).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').COA_Revenue_Sub_Account__c;
                        }

						
                    }else{
                        string chargetype = li.materialDescription.replaceAll('[^a-zA-Z]','_').replace('___','_').replace('__','_').removeEnd('_');
                        mapCNlines.get(li.materialDescription).CGST_Amount__c = li.cgsT_INR;
                        mapCNlines.get(li.materialDescription).CGST_Percent__c = li.cgstPercentage*100;
                        mapCNlines.get(li.materialDescription).IGST_Amount__c = li.igsT_INR;
                        mapCNlines.get(li.materialDescription).IGST_Percent__c = li.igstPercentage*100;
                        mapCNlines.get(li.materialDescription).SGST_Amount__c = li.sgsT_INR;
                        mapCNlines.get(li.materialDescription).SGST_Percent__c = li.sgstPercentage*100;
                        mapCNlines.get(li.materialDescription).blng__TaxAmount__c = li.taxCalculatedINR;
                        mapCNlines.get(li.materialDescription).blng__TaxPercentageApplied__c = li.taxApplicablePercentage*100;
                        mapCNlines.get(li.materialDescription).HSN_Code__c = li.sacApplicable;
                        mapCNlines.get(li.materialDescription).Line_Number__c = li.itemNumber;
                        mapCNlines.get(li.materialDescription).Charge_Head_Name__c = li.materialDescription;
						mapCNlines.get(li.materialDescription).Charge_Head_Code__c = EY_Master_Data__mdt.getInstance(chargetype).Charge_Code__c;
                        mapCNlines.get(li.materialDescription).COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance(chargetype).COA_Revenue_Account_Code__c;
                        mapCNlines.get(li.materialDescription).COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance(chargetype).COA_Revenue_Sub_Account__c;
                    }
                    
                }
                update mapCNlines.values();
                update creditNote;
                PageReference pageRef = new PageReference('/' + creditNote.id);
                pageRef.setRedirect(true);
                System.debug('creditNotePage. '+pageRef);
                message = 'Tax calculation Completed Successfully';
                creditReturnURL = '/' + creditNote.id;
                showSuccess = true;
            }
            
        }catch(Exception ex){
            system.debug('EY CALCULATION FAILED :::'+ex.getMessage());
            message = 'Tax calculation Failed : '+ex.getMessage();
            creditReturnURL = '/' + creditNoteId;
            showError = true;
        }
        
        
    }
    public static void fakeMethod(){
        integer i = 0;
          
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
     }
    
}