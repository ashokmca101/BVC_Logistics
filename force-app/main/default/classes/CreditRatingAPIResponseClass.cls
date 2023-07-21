public class CreditRatingAPIResponseClass {
    
    public static APICallStatus updateResponseMethod(String getResponse,Id accountId,String pan_number)
    {
        APICallStatus apistatus = new APICallStatus();
            apistatus.status = 'SUCCESS';
        CreditRatingResponseWrapper wrap = CreditRatingResponseWrapper.parse(getResponse);
            system.debug('wrap:::'+wrap);
            system.debug('statusCode:::'+wrap.statusCode);
            system.debug('requestId:::'+wrap.requestId);
        	
            Integer count = 0;
            if(wrap.result.Size() >0)
            {
                List<Credit_Rating__c> lstCreditRaing = new List<Credit_Rating__c>();
                for(CreditRatingResponseWrapper.result lstResult : wrap.result)
                {
                    Credit_Rating__c creditRatingObj = new Credit_Rating__c();
                    creditRatingObj.Customer__c = accountId;
                    creditRatingObj.Name = 'Credit Rating Record - '+lstResult.rating;
                    creditRatingObj.Rating_Agency__c = lstResult.ratingAgency;
                    creditRatingObj.Rating_of_the_instrument_as_assessed_by__c =lstResult.rating;
                    creditRatingObj.Outlook_on_the_entity_as_assessed_by_the__c = lstResult.outlook;
                    creditRatingObj.Date_of_Issuance_of_the_rating_on_the_in__c = lstResult.dateOfIssuance; 
                    if(lstResult.isRatedEntityNonCooperative == true || lstResult.isRatedEntityNonCooperative == False)
                    {
                        creditRatingObj.Whether_the_entity_being_rated_is_non_co__c = lstResult.isRatedEntityNonCooperative;
                    }
                    
                    creditRatingObj.Rating_Rationale__c =  lstResult.ratingRationale;
                    creditRatingObj.Rating_Description__c = lstResult.ratingDescription;
                    creditRatingObj.Absolute_amount_under_the_instrument_bei__c = lstResult.timestamp;
                    creditRatingObj.Currency__c = lstResult.currencyType;
                    creditRatingObj.Product__c = lstResult.product;
                    
                    lstCreditRaing.add(creditRatingObj);
                   
                }
                if(lstCreditRaing.Size() >0)
                {
                    system.debug('lstCreditRaing:::'+lstCreditRaing);
                    system.debug('lstCreditRaing Size :::'+lstCreditRaing.Size());
                    insert lstCreditRaing;
                }
                
            }
       return apistatus; 
    }

}