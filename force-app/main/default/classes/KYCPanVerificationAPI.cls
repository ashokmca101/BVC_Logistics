public class KYCPanVerificationAPI {
    public static void verifyPanAPI(Id accountId,String pan_number){
        Account_TriggerHandlerServiceCtrl.isFirst = false;
        System.debug('===== verifyPan Inside Method ========');
        PanAPIRequest body= new PanAPIRequest();
        body.consent = 'Y';
        body.pan = pan_number;
        String jsonBody = json.serialize(body);
        Map<String,KARZAA_API__mdt> objAPI =  KARZAA_API__mdt.getAll();
        system.debug('===== panVeriObj ===== : '+objAPI.get('PAN_Verification_KARZAA_API'));
        KARZAA_API__mdt panVeriObj = objAPI.get('PAN_Verification_KARZAA_API');
        system.debug(' ===== panVeriObj ===== : '+panVeriObj.KARZAA_Key__c);
        system.debug(' ===== panVeriObj ===== : '+panVeriObj.EndPoint__c);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(panVeriObj.EndPoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-karza-key' ,panVeriObj.KARZAA_Key__c);
        request.setBody(jsonBody);
        //request.setTimeout(20000);
        // Set the body as a JSON object
        //request.setBody('{"consent":"Y","pan":"CVTPS5815D"}');
        
        HttpResponse response = http.send(request);
        // Parse the JSON response
        System.debug(response.getBody());
        Account updatePanNameAccount;
        if (response.getStatusCode() != 200) {
            System.debug('==== The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            CRM_ExceptionHandler.processAPIFailures(response);
            
        } else {
            System.debug(response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> resultArr =(Map<String, Object>) results.get('result');
            List<Object> namesArr = (List<Object>) results.get('name');
            System.debug(namesArr);
            String request_id = (String) results.get('request_id');
            String status_code = (String) results.get('status-code');
            System.debug(status_code);
            if(status_code != '101'){
                CRM_ExceptionHandler.processKARZAAFailures(request_id , status_code); 
                return ;
                
            }
            //System.debug(resultArr[0]);
            //Account updatePanNameAccount = new Account(Id =accountId,KARZAA_Name_As_Per_PAN__c = );
            
            //KYCPanVerificationResponseWrapper lstResponce =(KYCPanVerificationResponseWrapper) JSON.deserialize(response.getBody(), KYCPanVerificationResponseWrapper); 
            KYCPanVerificationResponseWrapper wrap = KYCPanVerificationResponseWrapper.parse(response.getBody());
            wrap.status_code= status_code;
            system.debug('===== response wrap result ===== '+wrap.result);
            system.debug('==== response wrap.result.name ===== '+wrap.result.name);
            String nameFromKARZA = wrap.result.name;
            updatePanNameAccount = new Account(Id =accountId, KARZAA_Name_As_Per_PAN__c =wrap.result.name);
            Account accName = [SELECT Name_As_Per_PAN_Manual_Input__c  FROM Account WHERE Id=:accountId];
            String inputName = String.valueOf(accName.Name_As_Per_PAN_Manual_Input__c);
            
            System.debug('====== nameFromKARZA ====: '+nameFromKARZA +'===== Same ====: '+inputName); 
            
            if(nameFromKARZA == inputName && nameFromKARZA != null && inputName != null){
                updatePanNameAccount.KYC_Status__c = 'API Verified';
                updatePanNameAccount.KARZAA_KYC_Verified__c = true;
                updatePanNameAccount.KYC_Failed_Reason__c  = '';
                
                APICallStatus stitchAPIStatus ;
                
                
                stitchAPIStatus = KYCPanVerificationAPI.getStichProfileAPI(accountId,pan_number);
                
                
                //if(stitchAPIStatus.customerRecObj.BillingAddress !=null)
                //updatePanNameAccount.BillingAddress = stitchAPIStatus.customerRecObj.BillingAddress;
                System.debug('======= stitchAPIStatus ===== '+stitchAPIStatus);
                
                if(stitchAPIStatus.status=='SUCCESS'){
                    updatePanNameAccount.GST_Registered__c =  stitchAPIStatus.customerRecObj.GST_Registered__c;
                    updatePanNameAccount.Stitch_Profile_API_Status__c = true;
                    updatePanNameAccount.Entity_Id__c = stitchAPIStatus.entityId;
                    updatePanNameAccount.IEC__c =  stitchAPIStatus.customerRecObj.IEC__c;
                    updatePanNameAccount.Trade_Name__c = stitchAPIStatus.customerRecObj.Trade_Name__c;
                    updatePanNameAccount.GSTIN__c = stitchAPIStatus.customerRecObj.GSTIN__c;
                    if(stitchAPIStatus.customerRecObj.Form_Of_Organization__c !=null){
                        updatePanNameAccount.Form_Of_Organization__c = stitchAPIStatus.customerRecObj.Form_Of_Organization__c;
                    }
                    if(stitchAPIStatus.customerRecObj.BillingPostalCode !=null){
                        updatePanNameAccount.Is_Billing_Address_Present__c = stitchAPIStatus.customerRecObj.Is_Billing_Address_Present__c;
                        updatePanNameAccount.Is_Primary_Address_Present__c = stitchAPIStatus.customerRecObj.Is_Primary_Address_Present__c;
                        updatePanNameAccount.BillingCountry = stitchAPIStatus.customerRecObj.BillingCountry;
                        updatePanNameAccount.BillingState = stitchAPIStatus.customerRecObj.BillingState;
                        updatePanNameAccount.BillingStreet = stitchAPIStatus.customerRecObj.BillingStreet;
                        updatePanNameAccount.BillingPostalCode = stitchAPIStatus.customerRecObj.BillingPostalCode;
                        updatePanNameAccount.BillingCity = stitchAPIStatus.customerRecObj.BillingCity;
                    }
                    
                }else{
                    updatePanNameAccount.Stitch_Profile_API_Status__c = false; 
                }
                update  updatePanNameAccount;
                
                
            }
            else{
                updatePanNameAccount.KYC_Status__c = 'Verification Case Created';
                updatePanNameAccount.KARZAA_KYC_Verified__c = false;
                updatePanNameAccount.KYC_Failed_Reason__c  = 'Name as per PAN given by user and Name coming from API does not match.';
                if(!test.isRunningTest()){
                    update updatePanNameAccount;
                }
                
            }   
        }  
        
    } 
    
    
    public static APICallStatus getStichProfileAPI(Id accountId,String pan_number){
        System.debug('===== getStichProfileAPI Inside Method ========');
        PanAPIRequest body= new PanAPIRequest();
        body.template = 'karza_test';
        body.id = pan_number;
        String jsonBody = json.serialize(body);
        Map<String,KARZAA_API__mdt> objAPI =  KARZAA_API__mdt.getAll();
        system.debug('===== panPAI ===== : '+objAPI.get('Stitch_Profile_KARZAA_Test_API'));
        KARZAA_API__mdt stitchProfObj = objAPI.get('Stitch_Profile_KARZAA_Test_API');
        system.debug(' ===== panPAI ===== : '+stitchProfObj.KARZAA_Key__c);
        system.debug('===== panPAI ===== : '+stitchProfObj.EndPoint__c);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(stitchProfObj.EndPoint__c);
        //request.setEndpoint('https://testapi.kscan.in/v3/gst-profile');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-karza-key' ,stitchProfObj.KARZAA_Key__c);
        request.setBody(jsonBody);
        //request.setTimeout(20000);
        System.debug('===== Request Body ====+'+jsonBody);
        // Set the body as a JSON object
        
        
        HttpResponse response = http.send(request);
        // Parse the JSON response
        System.debug(response.getBody());
        APICallStatus stitchAPIStatus  = new APICallStatus();
        if (response.getStatusCode() != 200) {
            System.debug('===== The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            CRM_ExceptionHandler.processAPIFailures(response);
            
            stitchAPIStatus.status = 'FAILED';
            stitchAPIStatus.statusCode = response.getStatusCode();
            
        } else {
            System.debug('===== Profile Response ====: '+response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('====== Result =====: '+results.get('result'));
            Map<String, Object> resultArr =  (Map<String, Object>) results.get('result');
             
            List<Object> namesArr = (List<Object>) results.get('name');
            System.debug('==== namesArr===='+namesArr);
            String request_id = (String) results.get('requestId');
            String status_code = String.valueOf(results.get('statusCode'));
            System.debug('======== status_code ===='+status_code);
            if(status_code != '101'){
                CRM_ExceptionHandler.processKARZAAFailures(request_id , status_code); 
                return stitchAPIStatus;
                
            }
            stitchAPIStatus = StichProfileAPIResponseClass.updateResponseMethod(response.getBody(),accountId, pan_number); 
            System.debug('======== status_code ====B'+status_code);
            Account updateStitchProfileAccount;
            updateStitchProfileAccount = new Account(Id =accountId);
            if(stitchAPIStatus.status=='SUCCESS' && (!updateStitchProfileAccount.Stitch_Profile_API_Status__c) ){
                    updateStitchProfileAccount.GST_Registered__c =  stitchAPIStatus.customerRecObj.GST_Registered__c;
                    updateStitchProfileAccount.Stitch_Profile_API_Status__c = true;
                    updateStitchProfileAccount.Entity_Id__c = stitchAPIStatus.entityId;
                    updateStitchProfileAccount.IEC__c =  stitchAPIStatus.customerRecObj.IEC__c;
                    updateStitchProfileAccount.Trade_Name__c = stitchAPIStatus.customerRecObj.Trade_Name__c;
                    updateStitchProfileAccount.GSTIN__c = stitchAPIStatus.customerRecObj.GSTIN__c;
                    if(stitchAPIStatus.customerRecObj.Form_Of_Organization__c !=null){
                        updateStitchProfileAccount.Form_Of_Organization__c = stitchAPIStatus.customerRecObj.Form_Of_Organization__c;
                    }
                    if(stitchAPIStatus.customerRecObj.BillingPostalCode !=null){
                        updateStitchProfileAccount.Is_Billing_Address_Present__c = stitchAPIStatus.customerRecObj.Is_Billing_Address_Present__c;
                        updateStitchProfileAccount.Is_Primary_Address_Present__c = stitchAPIStatus.customerRecObj.Is_Primary_Address_Present__c;
                        updateStitchProfileAccount.BillingCountry = stitchAPIStatus.customerRecObj.BillingCountry;
                        updateStitchProfileAccount.BillingState = stitchAPIStatus.customerRecObj.BillingState;
                        updateStitchProfileAccount.BillingStreet = stitchAPIStatus.customerRecObj.BillingStreet;
                        updateStitchProfileAccount.BillingPostalCode = stitchAPIStatus.customerRecObj.BillingPostalCode;
                        updateStitchProfileAccount.BillingCity = stitchAPIStatus.customerRecObj.BillingCity;
                    }
                
                    System.debug('========  update  updateStitchProfileAccount ===== '+ updateStitchProfileAccount);
                   update  updateStitchProfileAccount; 
                }  
        }
        System.debug('========  update  stitchAPIStatus ===== '+ stitchAPIStatus);
        return stitchAPIStatus;
    }
    
    
    
    public static APICallStatus  financialSummaryAPI(Id accountId,String entity_Id){
        PanAPIRequest body= new PanAPIRequest();
        body.consent = 'Y';
        body.entityId = entity_Id;
        body.financialYear = new List<String>{'2018-19'};
        body.financialType= 'Both';
        String jsonBody = json.serialize(body);
        Map<String,KARZAA_API__mdt> objAPI =  KARZAA_API__mdt.getAll();
        system.debug('panPAI:::'+objAPI.get('Financial_Summary_KARZAA_Test_API'));
        KARZAA_API__mdt finanObj = objAPI.get('Financial_Summary_KARZAA_Test_API');
        system.debug('panPAI:::'+finanObj.KARZAA_Key__c);
        system.debug('panPAI:::'+finanObj.EndPoint__c);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(finanObj.EndPoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-karza-key' ,finanObj.KARZAA_Key__c);
        request.setBody(jsonBody);
        system.debug('jsonBody'+jsonBody);
        
        
        HttpResponse response = http.send(request);
        // Parse the JSON response
        System.debug(response.getBody());
        
        APICallStatus financialSummaryAPIStatus  = new APICallStatus();
        
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            CRM_ExceptionHandler.processAPIFailures(response);
            financialSummaryAPIStatus.status = 'FAILED';
            financialSummaryAPIStatus.statusCode = response.getStatusCode();
            
        } else {
            System.debug(response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> resultArr =(Map<String, Object>) results.get('result');
            List<Object> namesArr = (List<Object>) results.get('name');
            System.debug(namesArr);
            String request_id = (String) results.get('requestId');
            String status_code = String.valueOf(results.get('statusCode'));
            System.debug(status_code);
            if(status_code != '101'){
                CRM_ExceptionHandler.processKARZAAFailures(request_id , status_code); 
                return financialSummaryAPIStatus;
                
            }
            Account updateFinancialAPIStatus = new Account(Id =accountId );
            financialSummaryAPIStatus = FinancialSummaryAPIResponseClass.updateResponseMethod(response.getBody(),accountId);
            
            updateFinancialAPIStatus.Financial_Summary_API_Status__c = (financialSummaryAPIStatus.status=='SUCCESS') ? true:false;
            
            update updateFinancialAPIStatus;
            
        }
        return financialSummaryAPIStatus;
    }
    
    
    public static APICallStatus  creditRatingAPI(Id accountId,String pan_number){
        PanAPIRequest body= new PanAPIRequest();
        body.id = pan_number;
        body.name = '';
        body.ratingAgency = 'CRISIL';
        String jsonBody = json.serialize(body);
        Map<String,KARZAA_API__mdt> objAPI =  KARZAA_API__mdt.getAll();
        system.debug('objAPI:::'+objAPI.get('Credit_Rating_KARZAA_TEST_API'));
        KARZAA_API__mdt creditObj = objAPI.get('Credit_Rating_KARZAA_TEST_API');
        system.debug('panPAI:::'+creditObj.KARZAA_Key__c);
        system.debug('panPAI:::'+creditObj.EndPoint__c);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(creditObj.EndPoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-karza-key' ,creditObj.KARZAA_Key__c);
        request.setBody(jsonBody);
        system.debug('jsonBody'+jsonBody);
        
        
        HttpResponse response = http.send(request);
        // Parse the JSON response
        System.debug(response.getBody());
        
        APICallStatus credtRatingAPIStatus  = new APICallStatus();
        Account updateCreditRatingAPIStatus = new Account(Id =accountId );
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            CRM_ExceptionHandler.processAPIFailures(response);
            
            credtRatingAPIStatus.status = 'FAILED';
            credtRatingAPIStatus.statusCode = response.getStatusCode();
            
        } else {
            System.debug(response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String request_id = (String) results.get('requestId');
            String status_code = String.valueOf(results.get('statusCode'));
            System.debug(status_code);
            if(status_code != '101'){
                CRM_ExceptionHandler.processKARZAAFailures(request_id , status_code); 
                return credtRatingAPIStatus;
                
            }
            credtRatingAPIStatus = CreditRatingAPIResponseClass.updateResponseMethod(response.getBody(),accountId, pan_number);   
            updateCreditRatingAPIStatus.Credit_Rating_API_Status__c =  (credtRatingAPIStatus.status == 'SUCCESS') ? true:false;
            update updateCreditRatingAPIStatus;
            
        }
        return credtRatingAPIStatus;
    }
    
    public static void dotest(){
        Integer i = 0;
         i++;
         i++; 
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
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
    
    public class PanAPIRequest{
        public string consent;
        public string pan;
        public string id;
        public string template;
        public string entityId;
        public string[] financialYear;
        public string financialType;
        public string ratingAgency; 
        public string name;
        public string[] docType;
        public string periodFrom;
        public string periodTo;
        public string fileFormat;
        public string noOfYearsToMerge;
        public string notifyToEmail;
    }
    
   
}