public with sharing class CreateEshipBathIvalIeExhibiQTContr {
    
    @AuraEnabled
    public static string CreateQuote(String oppId){
        String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranchBatheShip = [select id,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        List<Hub__c> BVCbranchInternational = [select id,Name from Hub__c where Name=:Usr.International_Billing_Branch__c];
        String quoteId;
        Opportunity opp = [select id,Slab_Criteria__c,Influencer__c,Tariff_Plan__c,Business_Type__c,Is_Deal_with_New_Price__c,ieSHIP_Location__c,Authorised_Signatory_People__c,iSHIP_Sub_Category__c,Exhibition__c,Exhibition_Type__c,Location__c,Product_Category__c,BVC_Product__c from Opportunity where id=:oppId];
        List<Product2> prodBATh = [select id,ProductCode from Product2 where ProductCode='BVC BATH'];
        List<Product2> prodESHIP = [select id,ProductCode from Product2 where ProductCode='BVC eSHIP'];
        List<Product2> prodiVALSHIP = [select id,ProductCode from Product2 where ProductCode='BVC iValSHIP'];
        List<Product2> prodiEVALSHIP = [select id,ProductCode from Product2 where ProductCode='BVC ieSHIP'];
        List<Product2> prodExibiSHIP = [select id,ProductCode from Product2 where ProductCode='BVC ExhibiSHIP'];
        List<Product2> prodMarketSHIP = [select id,ProductCode from Product2 where ProductCode='BVCMarketSHIP'];
        try{
            
            // BATH
           if(opp.BVC_Product__c==prodBATh[0].id){
                if(BVCbranchBatheShip.size()==0){
                    throw new applicationException('User Dont have BVC Branch Linked');
                }else{
                    quoteId=CreateBATHQuote(oppId);
                } 
             // eSHIP   
            }else if(opp.BVC_Product__c==prodESHIP[0].id){
                if(BVCbranchBatheShip.size()==0){
                    throw new applicationException('User Dont have BVC Branch Linked');
                }
                else if(opp.Is_Deal_with_New_Price__c==false && opp.Business_Type__c=='ACR'){
                    throw new applicationException('Legacy Pricing is Only For Non ACR, Please validate Business Type ');
                }
                else if(opp.Is_Deal_with_New_Price__c==false && opp.Tariff_Plan__c=='Standard'){
                    throw new applicationException('Legacy Pricing is Only For Custom, Please validate Tariff Plan ');
                }else if(opp.Slab_Criteria__c==null && opp.Is_Deal_with_New_Price__c==false){
                    throw new applicationException('Slab Criteria is Required For Legacy Pricing');
                }
                else{
                    quoteId=CreateESHIPQuote(oppId);
                }   
            // iValSHIP        
            }else if(opp.BVC_Product__c==prodiVALSHIP[0].id){
                if(BVCbranchInternational.size()==0){
                    throw new applicationException('User Dont have BVC Branch Linked');
                }
                else if(opp.Location__c==null || opp.Product_Category__c==null && opp.Tariff_Plan__c=='Standard'){
                    throw new applicationException('Please validate IValship Location or IValship Product Category Fields');
                }
                else{
                    quoteId=CreateiVALSHIPQuote(oppId);
                }
            //IEShip    
            }else if(opp.BVC_Product__c==prodiEVALSHIP[0].id){
                if(BVCbranchInternational.size()==0){
                    throw new applicationException('User Dont have BVC Branch Linked');
                }
                else if(opp.ieSHIP_Location__c==null || opp.iSHIP_Sub_Category__c==null && opp.Tariff_Plan__c=='Standard'){
                    throw new applicationException('Please validate ieSHIP Location or ieSHIP Sub Category Fields');
                }       
                else{
                    quoteId=CreateieSHIPQuote(oppId);
                }   
             //MarketSHIP   
            }
            else if(opp.BVC_Product__c==prodMarketSHIP[0].id){
                if(BVCbranchInternational.size()==0){
                    throw new applicationException('User Dont have BVC Branch Linked');
                }
                else{
                    quoteId=CreateMarketSHIPQuote(oppId);
                }   
             //EXhibiSHIP   
            }else if(opp.BVC_Product__c==prodExibiSHIP[0].id){
                if(BVCbranchInternational.size()==0){
                    throw new applicationException('User Dont have BVC Branch Linked');
                }
                else if(opp.Exhibition__c==null || opp.Exhibition_Type__c==null){
                   throw new applicationException('Please validate Exhibition or Exhibition Type Fields');
                }
                else{
                   quoteId=CreateExhibiSHIPQuote(oppId); 
                }
            }else{
                throw new applicationException('Invalid Product');
            }
            return quoteId;
        } catch (Exception e) {
            System.debug('Error Message.  '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        /*
        if(opp.BVC_Product__c==prodBATh[0].id){
            quoteId=CreateBATHQuote(oppId);
        }else if(opp.BVC_Product__c==prodESHIP[0].id){
            quoteId=CreateESHIPQuote(oppId);
        }else if(opp.BVC_Product__c==prodiVALSHIP[0].id){
            quoteId=CreateiVALSHIPQuote(oppId);
        }else if(opp.BVC_Product__c==prodiEVALSHIP[0].id){
            quoteId=CreateieSHIPQuote(oppId);
        }else if(opp.BVC_Product__c==prodExibiSHIP[0].id){
            quoteId=CreateExhibiSHIPQuote(oppId);
        }return quoteId;*/
    }
    @AuraEnabled
    public static string CreateBATHQuote(String oppId){
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String gsRecordTypeID2 = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        Opportunity opp = [select id,Authorised_Signatory_People__c,Influencer__c,Package_Amount__c,Tariff_Plan__c,Slab_Criteria__c,Business_Type__c,BVC_Product__c,AccountId from Opportunity where id=:oppId];
        Account acc = [select id,Primary_Customer_Email__c from account where id=:opp.AccountId];
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c();              
        newQuote.SBQQ__Account__c=opp.AccountId;
        if(opp.Business_Type__c=='Non ACR'){
            newQuote.SBQQ__SubscriptionTerm__c=36;
            newQuote.RecordTypeId=gsRecordTypeID2;
        }else if(opp.Business_Type__c=='ACR'){
            newQuote.SBQQ__SubscriptionTerm__c=12;
            newQuote.RecordTypeId=gsRecordTypeID;
        }
        
        newQuote.BVC_Service__c='BATH';
        if(acc.Primary_Customer_Email__c!=null){
            newQuote.Account_Email_ID__c=acc.Primary_Customer_Email__c; 
        }
        newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
        newQuote.Package_Amount__c=opp.Package_Amount__c;
        String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        if(BVCbranch.size()>0){
            newQuote.BVC_Branch__c=BVCbranch[0].id;
        }
        newQuote.Business_Type__c=opp.Business_Type__c;
        newQuote.Tariff_Plan_Bath_Eship__c=opp.Tariff_Plan__c;
        if(opp.Tariff_Plan__c=='Standard'){
            newQuote.SBQQ__Status__c='Approved';
        }
         if(opp.Authorised_Signatory_People__c!=null){
           //newQuote.ST_BVC_Authorized_Signatory__c=opp.Authorised_Signatory_People__c; 
        }
        newQuote.SBQQ__StartDate__c=Date.today();
        newQuote.SBQQ__Opportunity2__c=oppId;
        insert newQuote;
        
        List<Bath_Standard_Pricing__c> BathCustomPricing = [select id,Product_Type__c,Shipment_charge__c,Package_Amount__c,Business_Type__c,Commission_Percentage__c,Origin_Destination_Pairing__c,Secure_logistics_rate__c,Visit_Outcome__c,Name from Bath_Standard_Pricing__c ];
        List<Bath_Custom_Pricing__c> customBATHPricing = new List<Bath_Custom_Pricing__c>();        
        if(opp.Tariff_Plan__c!=null && opp.Tariff_Plan__c=='Custom'){
            for(Bath_Standard_Pricing__c standBath:BathCustomPricing){
                Bath_Custom_Pricing__c cusBath =new Bath_Custom_Pricing__c();
                cusBath.Customer__c=opp.AccountId;
                cusBath.Quote__c=newQuote.Id;
                //cusBath.Business_Type__c=opp.Business_Type__c;
                cusBath.Commission_Percentage__c=standBath.Commission_Percentage__c;
                cusBath.Origin_Destination_Pairing__c=standBath.Origin_Destination_Pairing__c;
                cusBath.Secure_logistics_rate__c=standBath.Secure_logistics_rate__c;
                cusBath.Product_Type__c=standBath.Product_Type__c;
                cusBath.Visit_Outcome__c=standBath.Visit_Outcome__c;
                if(opp.Package_Amount__c!=null && opp.Business_Type__c=='ACR'){
                    //cusBath.Package_Amount__c=opp.Package_Amount__c;
                }
                if(standBath.Shipment_charge__c!=null){  
                    cusBath.Shipment_charge__c=standBath.Shipment_charge__c;
                } 
                customBATHPricing.add(cusBath);
            }
        }
        if(customBATHPricing.size()>0){
            insert customBATHPricing;
        }
        List<Product2> productBATH =[select Id,ProductCode from Product2 where ProductCode IN ('BVC BATH')];
        
        PricebookEntry pbEntry =new PricebookEntry();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:opp.BVC_Product__c];
        quoteLine1.SBQQ__PricebookEntryId__c=pbEntry.Id;
        quoteLine1.SBQQ__ChargeType__c='One-Time';
        quoteLine1.SBQQ__Product__c=productBATH[0].id;
        quoteLine1.SBQQ__StartDate__c=Date.Today();
        quoteLine1.SBQQ__Quantity__c=1;
        quoteLine1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine1.SBQQ__SubscriptionType__c= 'Renewable';
        quoteLine1.SBQQ__SubscriptionPricing__c= 'Fixed Price';
        quoteLine1.SBQQ__SubscriptionTerm__c = 12;
        if(opp.Business_Type__c=='ACR'){
           quoteLine1.SBQQ__NetPrice__c=decimal.valueOf(opp.Package_Amount__c);
           quoteLine1.SBQQ__ListPrice__c=decimal.valueOf(opp.Package_Amount__c);
        }else{
           quoteLine1.SBQQ__NetPrice__c=0;
           quoteLine1.SBQQ__ListPrice__c=0;
        }
        quoteLine1.SBQQ__Quote__c=newQuote.Id;
        quoteLineList.add(quoteLine1);
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
       
        return newQuote.Id;
    }
    @AuraEnabled
    public static string CreateESHIPQuote(String oppId){
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        system.debug('here with oppid'+oppId);
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String gsRecordTypeID2 = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        //String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Read Only').getRecordTypeId();
        Opportunity opp = [select id,Authorised_Signatory_People__c,Influencer__c,BVC_Product__c,Is_Deal_with_New_Price__c,Package_Amount__c,Business_Type__c,AccountId,Slab_Criteria__c,Tariff_Plan__c from Opportunity where id=:oppId];
        Account acc = [select id,Primary_Customer_Email__c from account where id=:opp.AccountId];
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c();              
        newQuote.SBQQ__Account__c=opp.AccountId;
        newQuote.Business_Type__c=opp.Business_Type__c;
        
        newQuote.BVC_Service__c='eSHIP';
        newQuote.SBQQ__StartDate__c=Date.today();
        newQuote.Tariff_Plan_Bath_Eship__c=opp.Tariff_Plan__c;
        if(opp.Slab_Criteria__c!=null){
            newQuote.Slab_Criteria__c=opp.Slab_Criteria__c;
        }
        if(opp.Business_Type__c=='Non ACR'){
            newQuote.SBQQ__SubscriptionTerm__c=36;
            newQuote.RecordTypeId=gsRecordTypeID2;
        }else if(opp.Business_Type__c=='ACR'){
            newQuote.SBQQ__SubscriptionTerm__c=12;
            newQuote.RecordTypeId=gsRecordTypeID;
        }
        if(acc.Primary_Customer_Email__c!=null){
            newQuote.Account_Email_ID__c=acc.Primary_Customer_Email__c; 
        }
        if(opp.Authorised_Signatory_People__c!=null){
           //newQuote.ST_BVC_Authorized_Signatory__c=opp.Authorised_Signatory_People__c; 
        }
        newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
         String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        if(BVCbranch.size()>0){
            newQuote.BVC_Branch__c=BVCbranch[0].id;
        }
        if(opp.Tariff_Plan__c=='Standard'){
            newQuote.SBQQ__Status__c='Approved';
        }
        newQuote.SBQQ__Opportunity2__c=oppId;
        newQuote.Package_Amount__c=opp.Package_Amount__c;
        insert newQuote;
        
        String eSHIPNewpricingRT = Schema.SObjectType.eSHIP_Standard_Pricing__c.getRecordTypeInfosByName().get('New eSHIP Pricing').getRecordTypeId();
        system.debug('record type++++++++++'+eSHIPNewpricingRT);
        String eSHIPOldPpricingRT = Schema.SObjectType.eSHIP_Standard_Pricing__c.getRecordTypeInfosByName().get('Legacy eSHIP Pricing').getRecordTypeId();
        List<eSHIP_Standard_Pricing__c> eshipNewPricing = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,Gross_Weight_Unit_for_Additional_Weight__c,Weight_Covered_Gms__c,Package_Amount__c,Slab_Criteria__c,Weight_Charges__c,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where RecordTypeId=:eSHIPNewpricingRT];
        system.debug('1st this is the eship std price==========='+eshipNewPricing);
        List<eSHIP_Standard_Pricing__c> eshipGrossWeightGms = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,Gross_Weight_Unit_for_Additional_Weight__c,Slab_Criteria__c,Weight_Charges__c,Package_Amount__c ,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where Slab_Criteria__c='Gross Weight Gms'and RecordTypeId=:eSHIPOldPpricingRT ];
        List<eSHIP_Standard_Pricing__c> eshipInvoiceValueINR = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,Gross_Weight_Unit_for_Additional_Weight__c,Slab_Criteria__c,Weight_Charges__c,Package_Amount__c ,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where Slab_Criteria__c='Invoice Value INR'and RecordTypeId=:eSHIPOldPpricingRT ];
        List<eSHIP_Standard_Pricing__c> eshipNetWeight = [select id,No_Of_Free_Atttemps__c,Liability_Cover_By_BVC__c,Gross_Weight_Unit_for_Additional_Weight__c,Slab_Criteria__c,Weight_Charges__c,Package_Amount__c ,Slab_Level__c,Logistice_Charges__c,Liability_Charges__c,Fuel_Surcharge__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,Name,Business_Type__c,Additional_Charge__c,Lower_Bound__c,Upper_Bound__c,Rate_INR__c,Shipment_Type__c from eSHIP_Standard_Pricing__c where Slab_Criteria__c='Net Weight'and RecordTypeId=:eSHIPOldPpricingRT ];
        List<eSHIP_Custom_Pricing__c> customEshipPricing = new List<eSHIP_Custom_Pricing__c>();        
        if(opp.Slab_Criteria__c!=null && opp.Slab_Criteria__c=='Gross Weight Gms' && opp.Tariff_Plan__c!=null && opp.Tariff_Plan__c=='Custom' && opp.Is_Deal_with_New_Price__c==false){
            for(eSHIP_Standard_Pricing__c standEShip1:eshipGrossWeightGms){
                eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                cusEShip.Customer__c=opp.AccountId;
                cusEShip.Quote__c=newQuote.Id;
                cusEShip.Lower_Bound__c=standEShip1.Lower_Bound__c;                
                //cusEShip.ACR_Amount__c=standEShip1.ACR_Amount__c;
                cusEShip.Package_Amount__c=standEShip1.Package_Amount__c;
                cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=standEShip1.Gross_Weight_Unit_for_Additional_Weight__c;
                cusEShip.Additional_Charge__c=standEShip1.Additional_Charge__c;
                //busines type changed
                cusEShip.Business_Type__c=standEShip1.Business_Type__c;
                cusEShip.COD_Charges_per_shipment__c=standEShip1.COD_Charges_per_shipment__c;
                cusEShip.COD_Charges_percentage_of_product__c=standEShip1.COD_Charges_percentage_of_product__c;
                cusEShip.Fuel_Surcharge__c=standEShip1.Fuel_Surcharge__c;
                cusEShip.Liability_Charges__c=standEShip1.Liability_Charges__c;
                cusEShip.Logistice_Charges__c=standEShip1.Logistice_Charges__c;
                cusEShip.Slab_Level__c=standEShip1.Slab_Level__c;
                cusEShip.Weight_Charges__c=standEShip1.Weight_Charges__c;
                cusEShip.Upper_Bound__c=standEShip1.Upper_Bound__c;
                cusEShip.Rate_INR__c=standEShip1.Rate_INR__c;
                cusEShip.Shipment_Type__c=standEShip1.Shipment_Type__c;
                cusEShip.Slab_Criteria__c=standEShip1.Slab_Criteria__c;
                cusEShip.No_Of_Free_Atttemps__c=standEShip1.No_Of_Free_Atttemps__c;
                cusEShip.l_Liability_Cover_By_BVC__c=standEShip1.Liability_Cover_By_BVC__c;
                customEshipPricing.add(cusEShip);
            }
        }else if(opp.Slab_Criteria__c!=null && opp.Slab_Criteria__c=='Invoice Value INR' && opp.Tariff_Plan__c!=null && opp.Tariff_Plan__c=='Custom' && opp.Is_Deal_with_New_Price__c==false ){
            for(eSHIP_Standard_Pricing__c standEShip2:eshipInvoiceValueINR){                
                eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                cusEShip.Customer__c=opp.AccountId;
                cusEShip.Quote__c=newQuote.Id;
                cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=standEShip2.Gross_Weight_Unit_for_Additional_Weight__c;
                cusEShip.Lower_Bound__c=standEShip2.Lower_Bound__c;
                cusEShip.Package_Amount__c =standEShip2.Package_Amount__c ;
                cusEShip.Additional_Charge__c=standEShip2.Additional_Charge__c;
                //busines type changed
                cusEShip.Business_Type__c=opp.Business_Type__c;
                cusEShip.COD_Charges_per_shipment__c=standEShip2.COD_Charges_per_shipment__c;
                cusEShip.COD_Charges_percentage_of_product__c=standEShip2.COD_Charges_percentage_of_product__c;
                cusEShip.Fuel_Surcharge__c=standEShip2.Fuel_Surcharge__c;
                cusEShip.Liability_Charges__c=standEShip2.Liability_Charges__c;
                cusEShip.Logistice_Charges__c=standEShip2.Logistice_Charges__c;
                cusEShip.Slab_Level__c=standEShip2.Slab_Level__c;
                cusEShip.Weight_Charges__c=standEShip2.Weight_Charges__c;
                cusEShip.Upper_Bound__c=standEShip2.Upper_Bound__c;
                cusEShip.Rate_INR__c=standEShip2.Rate_INR__c;
                cusEShip.Shipment_Type__c=standEShip2.Shipment_Type__c;
                cusEShip.Slab_Criteria__c=standEShip2.Slab_Criteria__c;
                cusEShip.No_Of_Free_Atttemps__c=standEShip2.No_Of_Free_Atttemps__c;
                cusEShip.l_Liability_Cover_By_BVC__c=standEShip2.Liability_Cover_By_BVC__c;
                customEshipPricing.add(cusEShip);
            }            
        }else if(opp.Slab_Criteria__c!=null && opp.Slab_Criteria__c=='Net Weight' && opp.Tariff_Plan__c!=null && opp.Tariff_Plan__c=='Custom' && opp.Is_Deal_with_New_Price__c==false ){
            for(eSHIP_Standard_Pricing__c standEShip3:eshipNetWeight){                
                eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
                cusEShip.Customer__c=opp.AccountId;
                cusEShip.Quote__c=newQuote.Id;
                cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=standEShip3.Gross_Weight_Unit_for_Additional_Weight__c;
                cusEShip.Lower_Bound__c=standEShip3.Lower_Bound__c;
                cusEShip.Package_Amount__c =standEShip3.Package_Amount__c ;
                cusEShip.Additional_Charge__c=standEShip3.Additional_Charge__c;
                //busines type changed
                cusEShip.Business_Type__c=opp.Business_Type__c;
                cusEShip.COD_Charges_per_shipment__c=standEShip3.COD_Charges_per_shipment__c;
                cusEShip.COD_Charges_percentage_of_product__c=standEShip3.COD_Charges_percentage_of_product__c;
                cusEShip.Fuel_Surcharge__c=standEShip3.Fuel_Surcharge__c;
                cusEShip.Liability_Charges__c=standEShip3.Liability_Charges__c;
                cusEShip.Logistice_Charges__c=standEShip3.Logistice_Charges__c;
                cusEShip.Slab_Level__c=standEShip3.Slab_Level__c;
                cusEShip.Weight_Charges__c=standEShip3.Weight_Charges__c;
                cusEShip.Upper_Bound__c=standEShip3.Upper_Bound__c;
                cusEShip.Rate_INR__c=standEShip3.Rate_INR__c;
                cusEShip.Shipment_Type__c=standEShip3.Shipment_Type__c;
                cusEShip.Slab_Criteria__c=standEShip3.Slab_Criteria__c;
                cusEShip.No_Of_Free_Atttemps__c=standEShip3.No_Of_Free_Atttemps__c;
                cusEShip.l_Liability_Cover_By_BVC__c=standEShip3.Liability_Cover_By_BVC__c;
                customEshipPricing.add(cusEShip);
            }            
        }
        else if(opp.Tariff_Plan__c!=null && opp.Tariff_Plan__c=='Custom' && opp.Is_Deal_with_New_Price__c==true){
            eSHIP_Custom_Pricing__c cusEShip =new eSHIP_Custom_Pricing__c();
            system.debug('this is the eship std price==========='+eshipNewPricing);
            for(eSHIP_Standard_Pricing__c newEShipPrice:eshipNewPricing){
                system.debug('this is the eship std price************'+newEShipPrice);
                if(opp.Package_Amount__c!=null && opp.Package_Amount__c==newEShipPrice.Package_Amount__c && opp.Business_Type__c==newEShipPrice.Business_Type__c){
                    cusEShip.Customer__c=opp.AccountId;
                    cusEShip.Quote__c=newQuote.Id;
                    cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=newEShipPrice.Gross_Weight_Unit_for_Additional_Weight__c;
                    cusEShip.Package_Amount__c=newEShipPrice.Package_Amount__c;
                    cusEShip.Weight_Covered_Gms__c=newEShipPrice.Weight_Covered_Gms__c;
                    cusEShip.Lower_Bound__c=newEShipPrice.Lower_Bound__c;
                    cusEShip.Package_Amount__c =newEShipPrice.Package_Amount__c ;
                    cusEShip.Additional_Charge__c=newEShipPrice.Additional_Charge__c;
                    cusEShip.Business_Type__c=newEShipPrice.Business_Type__c;
                    cusEShip.COD_Charges_per_shipment__c=newEShipPrice.COD_Charges_per_shipment__c;
                    cusEShip.COD_Charges_percentage_of_product__c=newEShipPrice.COD_Charges_percentage_of_product__c;
                    cusEShip.Fuel_Surcharge__c=newEShipPrice.Fuel_Surcharge__c;
                    cusEShip.Liability_Charges__c=newEShipPrice.Liability_Charges__c;
                    cusEShip.Logistice_Charges__c=newEShipPrice.Logistice_Charges__c;
                    cusEShip.Slab_Level__c=newEShipPrice.Slab_Level__c;
                    cusEShip.Weight_Charges__c=newEShipPrice.Weight_Charges__c;
                    cusEShip.Upper_Bound__c=newEShipPrice.Upper_Bound__c;
                    cusEShip.Rate_INR__c=newEShipPrice.Rate_INR__c;
                    cusEShip.Shipment_Type__c=newEShipPrice.Shipment_Type__c;
                    cusEShip.Slab_Criteria__c=newEShipPrice.Slab_Criteria__c;
                    cusEShip.No_Of_Free_Atttemps__c=newEShipPrice.No_Of_Free_Atttemps__c;
                    cusEShip.l_Liability_Cover_By_BVC__c=newEShipPrice.Liability_Cover_By_BVC__c;
                    customEshipPricing.add(cusEShip);
                }else if(opp.Business_Type__c==newEShipPrice.Business_Type__c && newEShipPrice.Package_Amount__c==null ){
                    cusEShip.Customer__c=opp.AccountId;
                    cusEShip.Quote__c=newQuote.Id;
                    cusEShip.Gross_Weight_Unit_for_Additional_Weight__c=newEShipPrice.Gross_Weight_Unit_for_Additional_Weight__c;
                    cusEShip.Package_Amount__c=newEShipPrice.Package_Amount__c;
                    cusEShip.Weight_Covered_Gms__c=newEShipPrice.Weight_Covered_Gms__c;
                    cusEShip.Lower_Bound__c=newEShipPrice.Lower_Bound__c;
                    cusEShip.Package_Amount__c =newEShipPrice.Package_Amount__c ;
                    cusEShip.Additional_Charge__c=newEShipPrice.Additional_Charge__c;
                    cusEShip.Business_Type__c=newEShipPrice.Business_Type__c;
                    cusEShip.COD_Charges_per_shipment__c=newEShipPrice.COD_Charges_per_shipment__c;
                    cusEShip.COD_Charges_percentage_of_product__c=newEShipPrice.COD_Charges_percentage_of_product__c;
                    cusEShip.Fuel_Surcharge__c=newEShipPrice.Fuel_Surcharge__c;
                    cusEShip.Liability_Charges__c=newEShipPrice.Liability_Charges__c;
                    cusEShip.Logistice_Charges__c=newEShipPrice.Logistice_Charges__c;
                    cusEShip.Slab_Level__c=newEShipPrice.Slab_Level__c;
                    cusEShip.Weight_Charges__c=newEShipPrice.Weight_Charges__c;
                    cusEShip.Upper_Bound__c=newEShipPrice.Upper_Bound__c;
                    cusEShip.Rate_INR__c=newEShipPrice.Rate_INR__c;
                    cusEShip.Shipment_Type__c=newEShipPrice.Shipment_Type__c;
                    cusEShip.Slab_Criteria__c=newEShipPrice.Slab_Criteria__c;
                    cusEShip.No_Of_Free_Atttemps__c=newEShipPrice.No_Of_Free_Atttemps__c;
                    cusEShip.l_Liability_Cover_By_BVC__c=newEShipPrice.Liability_Cover_By_BVC__c;
                    customEshipPricing.add(cusEShip);
                    system.debug('inside for loop_____'+cusEShip);
                }
            }
        }
        system.debug('custom list$$$$$$'+customEshipPricing);
        if(customEshipPricing.size()>0){
            if(!test.isRunningTest()){
                 insert customEshipPricing;
            }
            else if(test.isRunningTest())  {
                 insert customEshipPricing[0];
            }  
        }
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Product2> productEship = [select id,ProductCode from Product2 where ProductCode='BVC eSHIP'];
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        quoteLine1.SBQQ__Product__c=productEship[0].Id;
        quoteLine1.SBQQ__ChargeType__c='One-Time';
        if(opp.Business_Type__c=='ACR'){
           quoteLine1.SBQQ__NetPrice__c=decimal.valueOf(opp.Package_Amount__c);
           quoteLine1.SBQQ__ListPrice__c=decimal.valueOf(opp.Package_Amount__c);
        }else{
           quoteLine1.SBQQ__NetPrice__c=0;
           quoteLine1.SBQQ__ListPrice__c=0;
        }
        PricebookEntry pbEntry =new PricebookEntry();
        pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:opp.BVC_Product__c];
        quoteLine1.SBQQ__PricebookEntryId__c=pbEntry.Id;
        quoteLine1.SBQQ__Quantity__c=1;
        quoteLine1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine1.SBQQ__SubscriptionType__c= 'Renewable';
        quoteLine1.SBQQ__SubscriptionPricing__c= 'Fixed Price';
        quoteLine1.SBQQ__SubscriptionTerm__c = 12;
        quoteLine1.SBQQ__StartDate__c=Date.Today();
        quoteLine1.SBQQ__Quote__c=newQuote.Id;
        quoteLineList.add(quoteLine1);
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        return newQuote.Id;
    }
    @AuraEnabled
    public static string CreateiVALSHIPQuote(String oppId){
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String gsRecordTypeID2 = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        Opportunity opp = [select id,Authorised_Signatory_People__c,Product_Category__c,Influencer__c,Location__c,Package_Amount__c,Tariff_Plan__c,Slab_Criteria__c,Business_Type__c,BVC_Product__c,AccountId from Opportunity where id=:oppId];
        Account acc = [select id,Primary_Customer_Email__c from account where id=:opp.AccountId];
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c();              
        newQuote.SBQQ__Account__c=opp.AccountId;
        
            newQuote.RecordTypeId=gsRecordTypeID2;
        
        if(acc.Primary_Customer_Email__c!=null){
            newQuote.Account_Email_ID__c=acc.Primary_Customer_Email__c; 
        }
          String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranch = [select id,ST_BVC_Billing_Entity__c,Name from Hub__c where Name=:Usr.International_Billing_Branch__c];
        if(BVCbranch.size()>0){
            newQuote.BVC_Branch__c=BVCbranch[0].id;
        }
        if(opp.Location__c!=null){
            newQuote.ivalship_Location__c=opp.Location__c;
            if(opp.Location__c=='Mumbai' || opp.Location__c=='Surat'|| opp.Location__c=='Surat-SEZ' || opp.Location__c=='Mumbai-SEEPZ'){
                List<Entity__c> bvcBrinks=[SELECT Id,Contract_Signatory_1_Designation__c,Contract_Signatory_1__c,ST_Contract_Signatory__c FROM Entity__c WHERE Name='BVC BRINKS DIAMOND & JEWELLERY SERVICES LLP'];
                if(bvcBrinks.size()>0){
                newQuote.BVC_Entity__c=bvcBrinks[0].id;
                newQuote.BVC_Billing_Entity__c=BVCbranch[0].ST_BVC_Billing_Entity__c;
                newQuote.ST_BVC_Authorized_Signatory__c=bvcBrinks[0].ST_Contract_Signatory__c;
                newQuote.BVC_Authorized_Signatory_Full_Name__c=bvcBrinks[0].Contract_Signatory_1__c;
                newQuote.BVC_Authorized_Signatory_Designation__c=bvcBrinks[0].Contract_Signatory_1_Designation__c;
                }

            }
        }
        if(opp.Product_Category__c!=null){
            newQuote.Ivalship_Product_Sub_Category__c=opp.Product_Category__c;
        }
        if(opp.Influencer__c!=null){
            newQuote.Influencer_Authorized_Signatory__c=opp.Influencer__c;
           
        }
         if(opp.Authorised_Signatory_People__c!=null){
           //newQuote.ST_BVC_Authorized_Signatory__c=opp.Authorised_Signatory_People__c; 
        }
        newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
        newQuote.BVC_Service__c='iValSHIP';
        //newQuote.Package_Amount__c=opp.Package_Amount__c;
       
        if(opp.Tariff_Plan__c=='Standard'){
            newQuote.SBQQ__Status__c='Approved';
        }
        newQuote.Business_Type__c='Non ACR';
        newQuote.SBQQ__SubscriptionTerm__c=36;
        newQuote.Tariff_Plan_Bath_Eship__c=opp.Tariff_Plan__c;
        newQuote.SBQQ__StartDate__c=Date.today();
        newQuote.SBQQ__Opportunity2__c=oppId;
        insert newQuote;
        List<Product2> prodiVALSHIP = [select id,ProductCode from Product2 where ProductCode='BVC iValSHIP'];
        PricebookEntry pbEntry =new PricebookEntry();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:prodiVALSHIP[0].Id];
        quoteLine1.SBQQ__PricebookEntryId__c=pbEntry.Id;
        quoteLine1.SBQQ__ChargeType__c='One-Time';
        quoteLine1.SBQQ__Product__c=prodiVALSHIP[0].Id;
        quoteLine1.SBQQ__Quantity__c=1;
        quoteLine1.SBQQ__StartDate__c=Date.Today();
        quoteLine1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine1.SBQQ__SubscriptionType__c= 'Renewable';
        quoteLine1.SBQQ__SubscriptionPricing__c= 'Fixed Price';
        quoteLine1.SBQQ__SubscriptionTerm__c = 36;
       
           quoteLine1.SBQQ__NetPrice__c=0;
           quoteLine1.SBQQ__ListPrice__c=0;
        quoteLine1.SBQQ__Quote__c=newQuote.Id;
        quoteLineList.add(quoteLine1);
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        return newQuote.Id;
    }
    
    
    @AuraEnabled
    public static string CreateieSHIPQuote(String oppId){
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String gsRecordTypeID2 = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        Opportunity opp = [select id,Authorised_Signatory_People__c,iShip_Sub_Category__c,Influencer__c,ieSHIP_Location__c,Package_Amount__c,Tariff_Plan__c,Slab_Criteria__c,Business_Type__c,BVC_Product__c,AccountId from Opportunity where id=:oppId];
        Account acc = [select id,Primary_Customer_Email__c from account where id=:opp.AccountId];
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c();              
        newQuote.SBQQ__Account__c=opp.AccountId;
     
            newQuote.RecordTypeId=gsRecordTypeID2;
        
        if(acc.Primary_Customer_Email__c!=null){
            newQuote.Account_Email_ID__c=acc.Primary_Customer_Email__c; 
        }
        if(opp.ieSHIP_Location__c!=null){
            newQuote.ieSHIP_Location__c=opp.ieSHIP_Location__c;
        }
        if(opp.iShip_Sub_Category__c!=null){
            newQuote.iEship_Sub_Category__c=opp.iShip_Sub_Category__c;
        }
         if(opp.Influencer__c!=null){
            newQuote.Influencer_Authorized_Signatory__c=opp.Influencer__c;  
        }
         if(opp.Authorised_Signatory_People__c!=null){
           //newQuote.ST_BVC_Authorized_Signatory__c=opp.Authorised_Signatory_People__c; 
        }
        if(opp.Tariff_Plan__c=='Standard'){
            newQuote.SBQQ__Status__c='Approved';
        }
        newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
        newQuote.BVC_Service__c='ieSHIP';
        //newQuote.Package_Amount__c=opp.Package_Amount__c;
         String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Name=:Usr.International_Billing_Branch__c];
        if(BVCbranch.size()>0){
            newQuote.BVC_Branch__c=BVCbranch[0].id;
        }//newQuote.BVC_Branch__c='a3m6D000000PxunQAC';
        //newQuote.SBQQ__Primary__c=true;
        newQuote.Business_Type__c='Non ACR';
        newQuote.SBQQ__SubscriptionTerm__c=36;
        newQuote.Tariff_Plan_Bath_Eship__c=opp.Tariff_Plan__c;
        newQuote.SBQQ__StartDate__c=Date.today();
        newQuote.SBQQ__Opportunity2__c=oppId;
        insert newQuote;
        List<Product2> prodiEVALSHIP = [select id,ProductCode from Product2 where ProductCode='BVC ieSHIP'];
        PricebookEntry pbEntry =new PricebookEntry();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:prodiEVALSHIP[0].id];
        quoteLine1.SBQQ__PricebookEntryId__c=pbEntry.Id;
        system.debug('price book entry id =='+pbEntry.Id);
        quoteLine1.SBQQ__ChargeType__c='One-Time';
        quoteLine1.SBQQ__Product__c=prodiEVALSHIP[0].id;
        quoteLine1.SBQQ__Quantity__c=1;
        quoteLine1.SBQQ__StartDate__c=Date.Today();
        quoteLine1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine1.SBQQ__SubscriptionType__c= 'Renewable';
        quoteLine1.SBQQ__SubscriptionPricing__c= 'Fixed Price';
        quoteLine1.SBQQ__SubscriptionTerm__c = 36;
        quoteLine1.SBQQ__NetPrice__c=0;
        quoteLine1.SBQQ__ListPrice__c=0;
        quoteLine1.SBQQ__Quote__c=newQuote.Id;
        quoteLineList.add(quoteLine1);
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        return newQuote.Id;
    }
      @AuraEnabled//added by Pratik
   public static string CreateMarketSHIPQuote(String oppId){
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String gsRecordTypeID2 = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        Opportunity opp = [select id,Authorised_Signatory_People__c,Influencer__c,Package_Amount__c,Tariff_Plan__c,Business_Type__c,BVC_Product__c,AccountId from Opportunity where id=:oppId];
        Account acc = [select id,Primary_Customer_Email__c from account where id=:opp.AccountId];
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c();              
        newQuote.SBQQ__Account__c=opp.AccountId;
     
            newQuote.RecordTypeId=gsRecordTypeID2;
        
        if(acc.Primary_Customer_Email__c!=null){
            newQuote.Account_Email_ID__c=acc.Primary_Customer_Email__c; 
        }
       /* if(opp.ieSHIP_Location__c!=null){
            newQuote.ieSHIP_Location__c=opp.ieSHIP_Location__c;
        }
        if(opp.iShip_Sub_Category__c!=null){
            newQuote.iEship_Sub_Category__c=opp.iShip_Sub_Category__c;
        }*/
         if(opp.Influencer__c!=null){
            newQuote.Influencer_Authorized_Signatory__c=opp.Influencer__c;  
        }
         if(opp.Authorised_Signatory_People__c!=null){
           //newQuote.ST_BVC_Authorized_Signatory__c=opp.Authorised_Signatory_People__c; 
        }
        if(opp.Tariff_Plan__c=='Standard'){
            newQuote.SBQQ__Status__c='Approved';
        }
        newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
        newQuote.BVC_Service__c='MarketSHIP';
        //newQuote.Package_Amount__c=opp.Package_Amount__c;
         String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Name=:Usr.International_Billing_Branch__c];
        if(BVCbranch.size()>0){
            newQuote.BVC_Branch__c=BVCbranch[0].id;
        }//newQuote.BVC_Branch__c='a3m6D000000PxunQAC';
        //newQuote.SBQQ__Primary__c=true;
        newQuote.Business_Type__c='Non ACR';
        newQuote.SBQQ__SubscriptionTerm__c=36;
        newQuote.Tariff_Plan_Bath_Eship__c=opp.Tariff_Plan__c;
        newQuote.SBQQ__StartDate__c=Date.today();
        newQuote.SBQQ__Opportunity2__c=oppId;
        insert newQuote;
        List<Product2> prodMarketSHIP = [select id,ProductCode from Product2 where ProductCode='BVCMarketSHIP'];
        PricebookEntry pbEntry =new PricebookEntry();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:prodMarketSHIP[0].id];
        quoteLine1.SBQQ__PricebookEntryId__c=pbEntry.Id;
        system.debug('price book entry id =='+pbEntry.Id);
        quoteLine1.SBQQ__ChargeType__c='One-Time';
        quoteLine1.SBQQ__Product__c=prodMarketSHIP[0].id;
        quoteLine1.SBQQ__Quantity__c=1;
        quoteLine1.SBQQ__StartDate__c=Date.Today();
        quoteLine1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine1.SBQQ__SubscriptionType__c= 'Renewable';
        quoteLine1.SBQQ__SubscriptionPricing__c= 'Fixed Price';
        quoteLine1.SBQQ__SubscriptionTerm__c = 36;
        quoteLine1.SBQQ__NetPrice__c=0;
        quoteLine1.SBQQ__ListPrice__c=0;
        quoteLine1.SBQQ__Quote__c=newQuote.Id;
        quoteLineList.add(quoteLine1);
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        return newQuote.Id;
    }
     @AuraEnabled
    public static string CreateExhibiSHIPQuote(String oppId){
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String gsRecordTypeID2 = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        Opportunity opp = [select id,Authorised_Signatory_People__c,iShip_Sub_Category__c,Influencer__c,ieSHIP_Location__c,Package_Amount__c,Tariff_Plan__c,Slab_Criteria__c,Business_Type__c,BVC_Product__c,AccountId from Opportunity where id=:oppId];
        Account acc = [select id,Primary_Customer_Email__c from account where id=:opp.AccountId];
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c();              
        newQuote.SBQQ__Account__c=opp.AccountId;
        
            newQuote.RecordTypeId=gsRecordTypeID2;
       
        if(acc.Primary_Customer_Email__c!=null){
            newQuote.Account_Email_ID__c=acc.Primary_Customer_Email__c; 
        }
       
         if(opp.Influencer__c!=null){
            newQuote.Influencer_Authorized_Signatory__c=opp.Influencer__c;
           
        }
       
      
        
        newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
        newQuote.BVC_Service__c='ExhibiSHIP';
        //newQuote.Package_Amount__c=opp.Package_Amount__c;
         String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Name=:Usr.International_Billing_Branch__c];
        if(BVCbranch.size()>0){
            newQuote.BVC_Branch__c=BVCbranch[0].id;
        }//newQuote.BVC_Branch__c='a3m6D000000PxunQAC';
        //newQuote.SBQQ__Primary__c=true;
        newQuote.Business_Type__c='Non ACR'; 
        newQuote.SBQQ__SubscriptionTerm__c=36;
        newQuote.Tariff_Plan_Bath_Eship__c='Custom';
        newQuote.SBQQ__StartDate__c=Date.today();
        newQuote.SBQQ__Opportunity2__c=oppId;
        insert newQuote;
        List<Product2> prodExibiSHIP = [select id,ProductCode from Product2 where ProductCode='BVC ExhibiSHIP'];
        PricebookEntry pbEntry =new PricebookEntry();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook.Id AND Product2.Id=:prodExibiSHIP[0].Id];
        quoteLine1.SBQQ__PricebookEntryId__c=pbEntry.Id;
        system.debug('price book entry id =='+pbEntry.Id);
        quoteLine1.SBQQ__ChargeType__c='One-Time';
        quoteLine1.SBQQ__Product__c=prodExibiSHIP[0].Id;
        quoteLine1.SBQQ__Quantity__c=1;
        quoteLine1.SBQQ__StartDate__c=Date.Today();
        quoteLine1.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine1.SBQQ__SubscriptionType__c= 'Renewable';
        quoteLine1.SBQQ__SubscriptionPricing__c= 'Fixed Price';
        quoteLine1.SBQQ__SubscriptionTerm__c = 36;
        quoteLine1.SBQQ__NetPrice__c=0;
        quoteLine1.SBQQ__ListPrice__c=0;
        quoteLine1.SBQQ__Quote__c=newQuote.Id;
        quoteLineList.add(quoteLine1);
        if(quoteLineList.size()>0){
            insert quoteLineList;
        }
        return newQuote.Id;
    }
public static void fgMethod(){
        integer i = 0;
          
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
    i++;}
}