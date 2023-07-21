@isTest(SeeAllData=false)
public class TestUtility {
    
    public static Account createnonACRnonContractedAccount(){
        Account acc = new Account();
        acc.name = 'non ACR Non Contracted Account';
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        /*acc.First_Name__c = 'test';
        acc.Last_Name__c = 'last';
        acc.Mobile__c = '9819829721';
        acc.Email__c = 'abcd@test.com';*/
        acc.KYC_Indicator_for_Domestic_Flag__c = true;
        return acc;
    }
    public static Account createBllingAccount(){
        Account acc = new Account();
        acc.name = 'Billing Account';
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        acc.KYC_Indicator_for_Domestic_Flag__c = true;
        /*acc.First_Name__c = 'test';
        acc.Last_Name__c = 'last';
        acc.Mobile__c = '9819429721';
        acc.Email__c = 'ave@test.com';*/
        return acc;
    }
    public static Account createShipperAccount(){
        Account acc = new Account();
        acc.name = 'Shipper Account';
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        acc.KYC_Indicator_for_Domestic_Flag__c = true;
       /*acc.First_Name__c = 'test';
        acc.Last_Name__c = 'last';
        acc.Mobile__c = '9816529721';
        acc.Email__c = 'yrt@test.com';*/
        return acc;
    }
    public static Account createACRnonContractedAccount(){
        Account acc = new Account();
        acc.name = 'ACR Non Contracted Account';
        acc.ST_Pricing_Type__c = 'ACR';
        acc.Customer_Category__c = 'ACR Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Cristiano Ronaldo';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        acc.KYC_Indicator_for_Domestic_Flag__c = true;
       /* acc.First_Name__c = 'test';
        acc.Last_Name__c = 'last';
        acc.Mobile__c = '9882729721';
        acc.Email__c = 'pae@test.com';*/
        return acc;
    }
    
    public static Active_Pincode__c createPinCode(){
        Active_Pincode__c pinCode = new Active_Pincode__C(
            Name = '400093',
            Pincodes__c = '400093',
            State__c = 'Maharashtra',
            Country__c = 'India',
            City__c = 'Mumbai');
        return pinCode;
    }
    
    public static Active_Pincode__c createBengaluruPinCode(Hub__c hub){
        Active_Pincode__c pinCode = new Active_Pincode__C(
            Name = '560017',
            Pincodes__c = '560017',
            State__c = 'Karnataka',
            Country__c = 'India',
            City__c = 'Bengaluru',
            Hub__c = hub.Id);
        return pinCode;
    }
    
    public static Entity__c createBVCEntity(){
        Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
        return entity;
           
    }
    
    public static blng__LegalEntity__c createLegalEntity(Entity__c entity) {
        blng__LegalEntity__c leObj = new blng__LegalEntity__c(
                                            Name = 'Bvc Legal Entity',
                                            Billing_Authorised_Signatory__c = 'test Signatory',
                                            GSTIN__c = 'DHA528BA5Q',
                                            Billling_Entity_PAN_No__c = 'FHA5HWQ8A',
                                            GSTIN_Principle_Business_Address_Line_1__c = '123,house',
                                            CurrencyIsoCode = 'INR',
                                            GSTIN_State_Code__c = '28',
                                            Billing_Serial_Number__c = 01,
                                            blng__Active__c = true,
                                            blng__Country__c = 'India',
                                            BVC_Entity__c = entity.Id);
        
        return leObj;
    }
    
    public static Hub__c createBVCBranch(blng__LegalEntity__c blngEntity,Active_Pincode__c pin){
        Hub__c branch = new Hub__c(Name = 'Bangalore Hub',
                                   Hub_Address_Line_1__c = '123,Boulevard',
                                   Hub_Address_Line_2__c = 'Olive Main',
                                   Hub_Pincode__c = pin.Id,
                                   Branch__c = 'BANGALORE',
                                   ST_BVC_Billing_Entity__c = blngEntity.Id,
                                   BVC_Entity__c = blngEntity.BVC_Entity__c);
        return branch;
    }
    
    public static List<AddressBook__c> createAddressBook(List<Account> accList){
        List<AddressBook__c> addresses  = new List<AddressBook__c>();
        for(Account acc : accList){
            AddressBook__c ad = new AddressBook__c();
            ad.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            ad.ADDRESS1__c = 'add1Test';
            ad.ADDRESS2__c = 'add2Test';
            ad.STATE__c = 'test State';
            ad.COUNTRY__c = 'test country';
            ad.PINCODE__c = '400093';
            ad.CITY__c = 'test city';
            ad.TRADE_NAME__c = 'FC BARCELONA';
            ad.Customer__c = acc.Id;
            ad.Is_Primary__c = true;
            ad.Is_Billing_Address__c = true;
            ad.Dealer_Type__c = 'Regular';
            ad.GST_Registered_Status__c = 'Registered';
            ad.GSTIN__c = '27AABCB7286R1ZV';
            addresses.add(ad);
        }
        
        return addresses;
    }
    
    public static AddressBook__c originAddress(Account acc){
        AddressBook__c ad = new AddressBook__c();
            ad.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            ad.ADDRESS1__c = 'add1Test';
            ad.ADDRESS2__c = 'add2Test';
            ad.STATE__c = 'Maharashtra';
            ad.COUNTRY__c = 'India'; 
            ad.TRADE_NAME__c = 'FC BARCELONA';
            ad.CITY__c = 'Mumbai';
            ad.PINCODE__c = '400093';
            ad.Customer__c = acc.Id;
            ad.Is_Primary__c = true;
            ad.Is_Billing_Address__c = true;
            ad.Dealer_Type__c = 'Regular';
            ad.GST_Registered_Status__c = 'Registered';
            ad.GSTIN__c = '27AABCB7286R1ZV';
        return ad;
    }
    
    public static AddressBook__c destinationAddress(Account acc){
        AddressBook__c ad = new AddressBook__c();
            ad.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            ad.ADDRESS1__c = 'add1Test';
            ad.ADDRESS2__c = 'add2Test';
            ad.STATE__c = 'Gujarat';
            ad.COUNTRY__c = 'India';
            ad.TRADE_NAME__c = 'FC BARCELONA';
            ad.CITY__c = 'Bengaluru';
            ad.PINCODE__c = '560017';
            ad.Customer__c = acc.Id;
            ad.Is_Primary__c = true;
            ad.Is_Billing_Address__c = true;
            ad.Dealer_Type__c = 'Regular';
            ad.GST_Registered_Status__c = 'Registered';
            ad.GSTIN__c = '27AABCB7286R1ZV';
        return ad;
    }
    
    public static List<Opportunity> createOpportunity(List<Account> accList,Contact people,Entity__c ent){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Account acc : accList){
            Opportunity opp = New Opportunity();
            opp.Name = 'Test - Opp';
            
            opp.Type = 'New Buisness';
            opp.AccountId = acc.Id;
            opp.Second_Level_Product__c = 'Test';
            opp.StageName = 'BVC Opportunity';
            opp.CloseDate = Date.today();
            opp.Authorised_Signatory_People__c = people != null ? people.Id : null;
            opp.BVC_Entity__c = ent.Id;
            opportunities.add(opp);
        }
        
        return opportunities;
    }
    
    public static Contact createContact(Account acc){
        Contact Con = New Contact();
        Con.AccountId = acc.Id;
        Con.LastName = 'Carlsson';
        con.Email = 'abc@abc.com';
        return Con;
    }
    
    public static AccountContactRelation createAccountContactRelation(Account acc, Contact con){
        AccountContactRelation relation = new AccountContactRelation(AccountId = acc.Id,
                                                                    ContactId = con.Id,
                                                                    Roles = 'Finance; Invoice Recepient');
        return relation;
    }
    
    public static blng__BillingRule__c createBillingRule(){
        blng__BillingRule__c bRule = new blng__BillingRule__c();
        bRule.Name = 'test';
        bRule.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        bRule.blng__GenerateInvoices__c ='Yes';
        return bRule;
    }
    
    public static blng__RevenueRecognitionRule__c createRevenueRule(){
        blng__RevenueRecognitionRule__c revRule = new blng__RevenueRecognitionRule__c();
        revRule.Name = 'test rev';
        revRule.blng__CreateRevenueSchedule__c = 'No';
        return revRule;
    }
    
    public static blng__TaxRule__c createTaxRule(){
        blng__TaxRule__c taxRule = new blng__TaxRule__c();
        taxRule.blng__TaxableYesNo__c = 'No';
        return taxRule;
    }
    
    public static Product2 createACRProduct(blng__BillingRule__c bRule, blng__RevenueRecognitionRule__c revRule, blng__TaxRule__c taxRule){
        Product2 acrProd = new Product2();
        acrProd.name = 'ACR Package';
        acrProd.ProductCode = 'ACR';
        acrProd.blng__BillingRule__c = bRule.Id;
        acrProd.IsActive = true;
        acrProd.SBQQ__PricingMethod__c = 'List';
        acrProd.blng__RevenueRecognitionRule__c = revRule.id;
        acrProd.blng__TaxRule__c = taxRule.id;
        return acrProd;
    }
    
    public static Product2 createProduct(blng__BillingRule__c bRule, blng__RevenueRecognitionRule__c revRule, blng__TaxRule__c taxRule){
        Product2 prod = new Product2();
        prod.name = 'GoldSHIP Express C2C';
        prod.ProductCode = 'GOLD-EX-C2C';
        prod.blng__BillingRule__c = bRule.Id;
        prod.blng__RevenueRecognitionRule__c = revRule.id;
        prod.blng__TaxRule__c = taxRule.id;
        return prod;
    }
    
    public static Product2 createValProduct(blng__BillingRule__c bRule, blng__RevenueRecognitionRule__c revRule, blng__TaxRule__c taxRule){
        Product2 prod = new Product2();
        prod.name = 'ValShip Special Service';
        prod.ProductCode = 'VAL-SS';
        prod.blng__BillingRule__c = bRule.Id;
        prod.blng__RevenueRecognitionRule__c = revRule.id;
        prod.blng__TaxRule__c = taxRule.id;
        return prod;
    }
    
    public static Product2 createExhibiProduct(blng__BillingRule__c bRule, blng__RevenueRecognitionRule__c revRule, blng__TaxRule__c taxRule){
        Product2 prod = new Product2();
        prod.name = 'ExhibiSHIP Surface C2C';
        prod.ProductCode = 'EXHIBI-S-C2C';
        prod.blng__BillingRule__c = bRule.Id;
        prod.blng__RevenueRecognitionRule__c = revRule.id;
        prod.blng__TaxRule__c = taxRule.id;
        return prod;
    }
    
    /*public static Product2 createExhibiProduct1(blng__BillingRule__c bRule, blng__RevenueRecognitionRule__c revRule, blng__TaxRule__c taxRule){
        Product2 prod = new Product2();
        prod.name = 'ExhibiSHIP Within City';
        prod.ProductCode = 'EXHIBI-WC';
        prod.blng__BillingRule__c = bRule.Id;
        prod.blng__RevenueRecognitionRule__c = revRule.id;
        prod.blng__TaxRule__c = taxRule.id;
        return prod;
    }*/
    
    public static SBQQ__ProductOption__c createProductOption(Product2 bundleHead,Product2 optionProduct){
        SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 1,
                                                                       SBQQ__ConfiguredSKU__c = bundleHead.Id,
                                                                       SBQQ__Type__c = 'Component',
                                                                       SBQQ__OptionalSKU__c = optionProduct.Id,
                                                                       SBQQ__Selected__c = true);
        
        return prodOption;
    }
    
    
    
    public static Pricebook2 createPriceBook(){
        Pricebook2 customPB = new Pricebook2(Name='BVC INR Price Book', isActive=true);
        return customPB;
    }
    
    public static List<PricebookEntry> createPricebookEntry(Id pbId,List<Product2> productList) {
        
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
       
        for(Integer i = 0; i < productList.size(); i++) {
            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pbId,
                Product2Id = productList.get(i).Id,
                UnitPrice = 0,
                IsActive = true
            );
            priceBookEntryList.add(pbEntry);
        }
        //insert priceBookEntryList;
        return priceBookEntryList;
    }
     
    public static List<PricebookEntry> createACRPricebookEntry(Id pbId,List<Product2> productList) {
        
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
       
        for(Integer i = 0; i < productList.size(); i++) {
            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pbId,
                Product2Id = productList.get(i).Id,
                UnitPrice = 0,
                IsActive = true
            );
            priceBookEntryList.add(pbEntry);
        }
        //insert priceBookEntryList;
        return priceBookEntryList;
    }
    
    public static List<SBQQ__Quote__c> createACRQuote(Id pbId, List<Opportunity> oppList, Hub__c branch){
        List<SBQQ__Quote__c> quoteList = new  List<SBQQ__Quote__c>();
        for(Opportunity opp : oppList){
            SBQQ__Quote__c q = New SBQQ__Quote__c();
            q.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
            q.SBQQ__Opportunity2__c = opp.Id;
            q.SBQQ__Account__c = opp.AccountId;
            q.SBQQ__StartDate__c = system.today();
            q.SBQQ__Status__c = 'Draft';
            q.Business_Type__c = 'ACR';
            q.SBQQ__Type__c = 'Quote';
            q.SBQQ__PriceBook__c = pbId;
            q.SBQQ__PricebookId__c = pbId;
            q.SBQQ__Primary__c = true;
            q.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
            q.BVC_Branch__c = branch.Id;
            q.Business_Type__c = 'ACR';
            quoteList.add(q);
        }
        
        return quoteList;
    }
    
    public static List<SBQQ__Quote__c> createnonACRQuote(Id pbId, List<Opportunity> oppList, Hub__c branch){
        List<SBQQ__Quote__c> quoteList = new  List<SBQQ__Quote__c>();
        for(Opportunity opp : oppList){
            SBQQ__Quote__c q = New SBQQ__Quote__c();
            q.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
            q.SBQQ__Opportunity2__c = opp.Id;
            q.SBQQ__Account__c = opp.AccountId;
            q.SBQQ__StartDate__c = system.today();
            q.SBQQ__Status__c = 'Draft';
            q.Business_Type__c = 'Non ACR';
            q.SBQQ__Type__c = 'Quote';
            q.SBQQ__PriceBook__c = pbId;
            q.SBQQ__PricebookId__c = pbId;
            q.SBQQ__Primary__c = true;
            q.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
            q.BVC_Branch__c = branch.Id;
            q.Business_Type__c = 'Non ACR';
            quoteList.add(q);
        }
        
        return quoteList;
    }
    
    public static SBQQ__Quote__c createExhibitionQuote(Id pbId, Opportunity opp, Hub__c branch, ST_Exhibition__c exhib){
        
       
            SBQQ__Quote__c q = New SBQQ__Quote__c();
            q.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Exhibition').getRecordTypeId();
            q.SBQQ__Opportunity2__c = opp.Id;
            q.SBQQ__Account__c = opp.AccountId;
            q.SBQQ__StartDate__c = system.today();
            q.SBQQ__Status__c = 'Draft';
            q.Business_Type__c = 'Exhibition';
            q.Exhibition__c = exhib.Id;
            q.SBQQ__Type__c = 'Quote';
            q.SBQQ__PriceBook__c = pbId;
            q.SBQQ__PricebookId__c = pbId;
            q.SBQQ__Primary__c = true;
            q.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
            q.BVC_Branch__c = branch.Id;
           
        
        
        return q;
    }
    
    public static ST_Exhibition__c createExhibition(){
        ST_Exhibition__c exb = new ST_Exhibition__c();
        exb.Name = 'IIJS-SIGNATURE 2022';
        exb.COA_Exhibition_Code__c = '1008';
        exb.ST_Active__c = TRUE; 
        exb.ST_Start_Date__c = system.today();
        exb.ST_End_Date__c = system.today().addDays(50);
        return exb;
    }
     
    public static List<SBQQ__QuoteLine__c> createQuoteLines(Id quoteId,List<PricebookEntry> pbEntries,List<ST_ACR_Standard_Price__c> acrPrice){
         List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String,ST_ACR_Standard_Price__c> priceMap = new Map<String,ST_ACR_Standard_Price__c>();
        for(ST_ACR_Standard_Price__c p : acrPrice){
            priceMap.put(p.ST_Product__c,p);
        }
        system.debug('Product Codee:::'+pbEntries);
         for(PricebookEntry pbE : pbEntries){
             SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c ();
             quoteLineObj.SBQQ__Quote__c = quoteId;
             quoteLineObj.SBQQ__Product__c = pbE.Product2Id;
             quoteLineObj.SBQQ__PricingMethod__c = 'List';
             
             if(priceMap.containsKey(pbE.Product2Id)){
                 quoteLineObj.ST_ACR_Standard_Price__c = priceMap.get(pbE.Product2Id).Id;
                 quoteLineObj.ST_Rate_Amount__c = 3;
                 quoteLineObj.ST_Minimum_Freight__c = 500;
                 quoteLineObj.ST_Rate_UOM__c = 'Per Gram';
                 quoteLineObj.ST_Offline_Charge__c = 500;
                 quoteLineObj.ST_Liability_Coverage__c = 0.22;
                 quoteLineObj.SBQQ__ListPrice__c = 0.0;
                 quoteLineObj.SBQQ__NetPrice__c = 0.0;
             }
             else{
                 quoteLineObj.SBQQ__ListPrice__c = 60000;
                 quoteLineObj.SBQQ__NetPrice__c = 60000;
             }
             
             quoteLineObj.SBQQ__PricebookEntryId__c = pbE.Id;
             Date myDate = Date.newInstance(2021, 1, 1);
             //quoteLineObj.SBQQ__StartDate__c = myDate;
             quoteLineObj.ST_Package_Type__c = 'Package 2 : 60K';
             if(priceMap.containsKey(pbE.Product2Id)){
                 
             }
             quoteLineObj.SBQQ__ChargeType__c = 'One-Time';
             quoteLineObj.SBQQ__DefaultSubscriptionTerm__c = 12;
             //quoteLineObj.SBQQ__StartDate__c = system.today();
             quoteLineObj.SBQQ__SubscriptionTerm__c = 12;
             quoteLineObj.SBQQ__Quantity__c = 1;
             quoteLineObj.Max_Discount__c  = 0;
             quoteLines.add(quoteLineObj);

         }          
         
        
        return quoteLines;
        
    }
  
    public static List<SBQQ__QuoteLine__c> createnonACRQuoteLines(Id quoteId,List<PricebookEntry> pbEntries,ST_NonACR_Standard_Price__c nonACRPrice){
         List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        /*Map<String,ST_NonACR_Standard_Price__c> priceMap = new Map<String,ST_NonACR_Standard_Price__c>();
        for(ST_NonACR_Standard_Price__c p : nonACRPrice){
            priceMap.put(p.ST_Product__c,p);
        }*/
         for(PricebookEntry pbE : pbEntries){
             SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c ();
             quoteLineObj.SBQQ__Quote__c = quoteId;
             quoteLineObj.SBQQ__Product__c = pbE.Product2Id;
             quoteLineObj.SBQQ__PricingMethod__c = 'List';
             quoteLineObj.ST_Gross_Weight_Slabs__c = '1.01 - 3 Kg';
             system.debug('Product Codee:::'+pbE);
             //if(priceMap.containsKey(pbE.Product2Id)){
                 quoteLineObj.ST_NonACR_Standard_Price__c = nonACRPrice.Id;
                 quoteLineObj.ST_Rate_Amount__c = 3;
                 quoteLineObj.ST_Minimum_Freight__c = 500;
                 quoteLineObj.ST_Rate_UOM__c = 'Per Gram';
                 quoteLineObj.ST_Offline_Charge__c = 500;
                 quoteLineObj.ST_Liability_Coverage__c = 0.22;
                 quoteLineObj.SBQQ__ListPrice__c = 0.0;
                 quoteLineObj.SBQQ__NetPrice__c = 0.0;
             //}
                         
             quoteLineObj.SBQQ__PricebookEntryId__c = pbE.Id;
             Date myDate = Date.newInstance(2021, 1, 1);
             //quoteLineObj.SBQQ__StartDate__c = myDate;
             //quoteLineObj.ST_Package_Type__c = 'Package 2 : 60K';
             
             quoteLineObj.SBQQ__ChargeType__c = 'One-Time';
             quoteLineObj.SBQQ__DefaultSubscriptionTerm__c = 12;
             //quoteLineObj.SBQQ__StartDate__c = system.today();
             quoteLineObj.SBQQ__SubscriptionTerm__c = 12;
             quoteLineObj.SBQQ__Quantity__c = 1;
             quoteLines.add(quoteLineObj);

         }          
         
        
        return quoteLines;
        
    }
    
    public static SBQQ__QuoteLine__c createExhibitionQuoteLines(Id quoteId,PricebookEntry pbE,ST_Exhibition_Standard_Price__c ExhibitionPrice,ST_Exhibition__c exhib){
         //List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
         
             SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c ();
             quoteLineObj.SBQQ__Quote__c = quoteId;
             quoteLineObj.SBQQ__Product__c = pbE.Product2Id;
             quoteLineObj.ST_Customer_Product_Category__c = 'ValSHIP';
             quoteLineObj.SBQQ__PricingMethod__c = 'List';
             //quoteLineObj.ST_Gross_Weight_Slabs__c = '1.01 - 3 Kg';
             system.debug('Product Codee:::'+pbE);
             //if(priceMap.containsKey(pbE.Product2Id)){
                 quoteLineObj.Exhibition_Standard_Price__c = ExhibitionPrice.Id;
                 quoteLineObj.ST_Rate_Amount__c = 3;
                 quoteLineObj.ST_Exhibition__c = exhib.Id;
                 quoteLineObj.ST_Rate_UOM__c = 'Per Gram';
                 quoteLineObj.ST_Offline_Charge__c = 500;
                 quoteLineObj.ST_Liability_Coverage__c = 0.22;
                 quoteLineObj.Slab_Level_1_Rate__c = 3.00;
                 quoteLineObj.Slab_Level_2_Rate__c = 2.50;
                 quoteLineObj.Slab_Level_3_Rate__c = 2.00;
                 quoteLineObj.Slab_Level_4_Rate__c = 1.50;
                 quoteLineObj.Slab_Level_5_Rate__c = 1.00;
                 quoteLineObj.Max_Slab_Rate__c = 1.00;
                 quoteLineObj.SBQQ__ListPrice__c = 0.0;
                 quoteLineObj.SBQQ__NetPrice__c = 0.0;
             //}
                         
             quoteLineObj.SBQQ__PricebookEntryId__c = pbE.Id;
             Date myDate = Date.newInstance(2021, 1, 1);
             //quoteLineObj.SBQQ__StartDate__c = myDate;
             //quoteLineObj.ST_Package_Type__c = 'Package 2 : 60K';
             quoteLineObj.SBQQ__ChargeType__c = 'One-Time';
             quoteLineObj.SBQQ__DefaultSubscriptionTerm__c = 12;
             //quoteLineObj.SBQQ__StartDate__c = system.today();
             quoteLineObj.SBQQ__SubscriptionTerm__c = 12;
             quoteLineObj.SBQQ__Quantity__c = 1;
             

             
         
        
        return quoteLineObj;
        
    }
    public static List<ST_ACR_Standard_Price__c> createACRStandardPrice(List<Product2> prodList){
        List<ST_ACR_Standard_Price__c> prices = new List<ST_ACR_Standard_Price__c>();
        for(Product2 prod : prodList){
            if(prod.ProductCode != 'ACR'){
                ST_ACR_Standard_Price__c acrStd = new ST_ACR_Standard_Price__c();
                acrStd.ST_Effective_End_Date__c = System.today().adddays(20);
                acrStd.ST_Effective_Start_Date__c = System.today().adddays(-20);
                acrStd.ST_Rate_Amount__c = 2.5;
                acrStd.ST_Minimum_Freight__c = 1000;
                acrStd.ST_ACR_Package_Type__c = 'Package 2 : 60K';
                acrStd.ST_Offline_Charge__c = 500;
                acrStd.ST_Rate_UOM__c = 'Per Gram';
                acrStd.ST_Liability_Coverage__c = 0.22;
                acrStd.ST_Product__c = prod.Id;
                prices.add(acrStd);
            }  
        }
        
        
        return prices;
    }
    
    public static ST_NonACR_Standard_Price__c nonACRStdPrice(Product2 prod){
        ST_NonACR_Standard_Price__c nonPrice = new ST_NonACR_Standard_Price__c();
        nonPrice.Name = prod.Name;
        nonPrice.ST_Product__c = prod.Id;
        nonPrice.ST_Rate_Amount__c = 0.8;
        nonPrice.ST_Minimum_Freight__c = 1000;
        nonPrice.ST_Min_Gross_Weight__c = 1.01;
        nonPrice.ST_Liability_Coverage__c = 0.1;
        nonPrice.ST_Rate_UOM__c = 'Per Gram';
        nonPrice.ST_Gross_Weight_Slabs__c = '1.01 - 3 Kg';
        nonPrice.ST_Max_Gross_Weight__c = 3;
        nonPrice.ST_Offline_Charge__c = 500;
        nonPrice.ST_Effective_Start_Date__c = system.today();
        nonPrice.ST_Effective_End_Date__c = system.today().addDays(364);
        return nonPrice;
    }
    
    public static ST_Exhibition_Standard_Price__c createExhibitionStdPrice(Product2 prod, ST_Exhibition__c exhib){
        ST_Exhibition_Standard_Price__c exhibPrice = new ST_Exhibition_Standard_Price__c();
        exhibPrice.Name = prod.Name;
        exhibPrice.ST_Product__c = prod.Id;
        exhibPrice.ST_Rate_Amount__c = 0.8;
        exhibPrice.ST_Rate_UOM__c = 'Per Gram';
        exhibPrice.ST_Customer_Product_Category__c = 'ValSHIP';
        exhibPrice.ST_Exhibition__c = exhib.Id;
        exhibPrice.ST_Liability_Coverage__c = 0.03;
        exhibPrice.ST_Offline_Charge__c = 500;
        exhibPrice.ST_Active__c = TRUE;
        exhibPrice.Level_1__c = 5000;
        exhibPrice.Level_1_Rate__c = 3.00;
        exhibPrice.Level_2__c = 10000;
        exhibPrice.Level_2_Rate__c = 2.50;
        exhibPrice.Level_3__c = 15000;
        exhibPrice.Level_3_Rate__c = 2.00;
        exhibPrice.Level_4__c = 20000;
        exhibPrice.Level_4_Rate__c = 1.50;
        exhibPrice.Level_5__c = 25000;
        exhibPrice.Level_5_Rate__c = 1.00;
        exhibPrice.Max_Slab_Rate__c = 1.00;
        exhibPrice.ST_Activation_Date__c = System.today().addDays(-2);
        exhibPrice.ST_Inactivation_Date__c = System.today().addMonths(1);
        return exhibPrice;
    }
    
    public static ST_Exhibition_Contracted_Price__c createExhibitionContdPrice(ST_Exhibition_Standard_Price__c esp,Contract cont){
        ST_Exhibition_Contracted_Price__c exhibPrice1 = new ST_Exhibition_Contracted_Price__c();
        //exhibPrice1.Name = prod.Name;
        exhibPrice1.ST_Product__c = esp.ST_Product__c;
        exhibPrice1.ST_Exhibition__c = esp.ST_Exhibition__c;
        exhibPrice1.ST_Rate_Amount__c = 0.8;
        exhibPrice1.ST_Rate_UOM__c = 'Per Gram';
        exhibPrice1.ST_Liability_Coverage__c = 0.03;
        exhibPrice1.ST_Offline_Charge__c = 500;
        exhibPrice1.Level_1__c = 5000;
        exhibPrice1.Level_1_Rate__c = 3.00;
        exhibPrice1.Level_2__c = 10000;
        exhibPrice1.Level_2_Rate__c = 2.50;
        exhibPrice1.Level_3__c = 15000;
        exhibPrice1.Level_3_Rate__c = 2.00;
        exhibPrice1.Level_4__c = 20000;
        exhibPrice1.Level_4_Rate__c = 1.50;
        exhibPrice1.Level_5__c = 25000;
        exhibPrice1.Level_5_Rate__c = 1.00;
        exhibPrice1.Max_Slab_Rate__c = 1.00;
        exhibPrice1.ST_Contract__c = cont.Id;
        exhibPrice1.ST_Customer_Account__c = cont.AccountId;
        exhibPrice1.ST_Active__c = true;
        //exhibPrice.ST_Activation_Date__c = System.today().addDays(-2);
        //exhibPrice.ST_Inactivation_Date__c = System.today().addMonths(1);
        return exhibPrice1;
    }
    
    public static SBQQ__ConfigurationAttribute__c acrPackageAttribute(Product2 prod){
        SBQQ__ConfigurationAttribute__c packageAttribute = new SBQQ__ConfigurationAttribute__c(Name = 'ACR Package Type',
                                                                                               SBQQ__Product__c = prod.Id,
                                                                                               SBQQ__TargetField__c = 'ST_Package_Type__c',
                                                                                               SBQQ__Required__c = true,
                                                                                               SBQQ__ApplyToProductOptions__c = true);
        return packageAttribute;
    }
    
    public static List<Order> createStdOrder(List<SBQQ__Quote__c> stdQuotes, Id pbId){
        List<Order> orderList = new List<Order>();
        for(SBQQ__Quote__c q : stdQuotes){
            Order o = new Order();
            o.AccountId = q.SBQQ__Account__c;
            o.EffectiveDate = System.today().addDays(-10);
            o.blng__BillingDayOfMonth__c = '20';
            o.Status='Draft';
            o.blng__BillingAccount__c = q.SBQQ__Account__c;
            o.Pricebook2Id = pbId;
            orderList.add(o);
        }
        
        return orderList;
    }
    
    public static List<Order> createACROrder(List<SBQQ__Quote__c> stdQuotes, Id pbId){
        List<Order> orderList = new List<Order>();
        for(SBQQ__Quote__c q : stdQuotes){
            Order o = new Order();
            o.AccountId = q.SBQQ__Account__c;
            o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
            o.EffectiveDate = System.today();
            o.Status='Draft';
            o.Business_Type__c = 'ACR';
            o.blng__BillingAccount__c = q.SBQQ__Account__c;
            o.Pricebook2Id = pbId;
            o.SBQQ__Contracted__c = false;
            o.SBQQ__ContractingMethod__c = 'By Subscription End Date';
            o.SBQQ__PaymentTerm__c = 'Net 30';
            o.SBQQ__PriceCalcStatus__c = 'Not Needed';
            o.SBQQ__Quote__c = q.Id;
            o.blng__BillNow__c = false;
            o.blng__BillingDayOfMonth__c = '1';
                orderList.add(o);
        }
        
        return orderList;
    }
    public static List<Order> createNonACROrder(List<SBQQ__Quote__c> nonACRQuotes, Id pbId){
        List<Order> orderList = new List<Order>();
        for(SBQQ__Quote__c q : nonACRQuotes){
            Order o = new Order();
            o.AccountId = q.SBQQ__Account__c;
            o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
            o.EffectiveDate = System.today();
            o.Status='Draft';
            o.blng__BillingAccount__c = q.SBQQ__Account__c;
            o.Business_Type__c = 'Non ACR';
            o.Pricebook2Id = pbId;
            o.SBQQ__Contracted__c = false;
            o.SBQQ__ContractingMethod__c = 'By Subscription End Date';
            o.SBQQ__PaymentTerm__c = 'Net 30';
            o.SBQQ__PriceCalcStatus__c = 'Not Needed';
            o.SBQQ__Quote__c = q.Id;
            o.blng__BillNow__c = false;
            o.blng__BillingDayOfMonth__c = '1';
                orderList.add(o);
        }
        
        return orderList;
    }
    public static List<Order> createExhibitionOrder(SBQQ__Quote__c exhibiQuotes, Id pbId, ST_Exhibition__c exhib){
        List<Order> orderList = new List<Order>();
        //for(SBQQ__Quote__c q : exhibiQuotes){
            Order o = new Order();
            o.AccountId = exhibiQuotes.SBQQ__Account__c;
            o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
            o.EffectiveDate = System.today();
            o.EndDate = System.today().addDays(25);
            o.Status='Draft';
            o.Business_Type__c = 'Exhibition';
            o.blng__BillingAccount__c = exhibiQuotes.SBQQ__Account__c;
            o.Pricebook2Id = pbId;
            o.Exhibition__c = exhib.Id;
            o.SBQQ__Contracted__c = false;
            o.SBQQ__ContractingMethod__c = 'By Subscription End Date';
            o.SBQQ__PaymentTerm__c = 'Net 30';
            o.SBQQ__PriceCalcStatus__c = 'Not Needed';
            o.SBQQ__Quote__c = exhibiQuotes.Id;
            o.blng__BillNow__c = false;
            o.blng__BillingDayOfMonth__c = '1';
                orderList.add(o);
        //}
        
        return orderList;
    }
    public static List<OrderItem> createACROrderItems(List<SBQQ__QuoteLine__c> qlinesList, Order o){
        List<OrderItem> items = new List<orderItem>();
        for(SBQQ__QuoteLine__c qli : qlinesList){
          OrderItem oi = new OrderItem();
            
            oi.PricebookEntryId = qli.SBQQ__PricebookEntryId__c;
            oi.OrderId = o.Id;
            oi.Product2Id = qli.SBQQ__Product__c;
            oi.SBQQ__QuoteLine__c = qli.Id;
            oi.SBQQ__ChargeType__c = 'Recurring';
            oi.blng__LegalEntity__c = o.BVC_Billing_Entity__c;
            oi.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            oi.SBQQ__SubscriptionType__c = 'Renewable';
            oi.SBQQ__ProductSubscriptionType__c = 'Renewable';
            oi.blng__BillableUnitPrice__c = qli.SBQQ__NetPrice__c;
            oi.SBQQ__Status__c = 'Draft';
            oi.Quantity = 1;
            oi.UnitPrice = qli.SBQQ__ListPrice__c;
            oi.SBQQ__DefaultSubscriptionTerm__c = 12;
            oi.SBQQ__BillingFrequency__c = 'Annual';
            oi.SBQQ__BillingType__c = 'Advance';
            items.add(oi);
         }
        return items;
    }
    
    public static List<OrderItem> createNonACROrderItems(List<SBQQ__QuoteLine__c> qlinesList, Order o){
        List<OrderItem> items = new List<orderItem>();
        for(SBQQ__QuoteLine__c qli : qlinesList){
          OrderItem oi = new OrderItem();
            oi.PricebookEntryId = qli.SBQQ__PricebookEntryId__c;
            oi.OrderId = o.Id;
            oi.Product2Id = qli.SBQQ__Product__c;
            oi.SBQQ__QuoteLine__c = qli.Id;
            oi.SBQQ__ChargeType__c = 'Recurring';
            oi.blng__LegalEntity__c = o.BVC_Billing_Entity__c;
            oi.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            oi.SBQQ__SubscriptionType__c = 'Renewable';
            oi.SBQQ__ProductSubscriptionType__c = 'Renewable';
            oi.blng__BillableUnitPrice__c = qli.SBQQ__NetPrice__c;
            oi.SBQQ__Status__c = 'Draft';
            oi.Quantity = 1;
            oi.UnitPrice = qli.SBQQ__ListPrice__c;
            oi.SBQQ__DefaultSubscriptionTerm__c = 12;
            oi.SBQQ__BillingFrequency__c = 'Annual';
            oi.SBQQ__BillingType__c = 'Advance';
            items.add(oi);
         }
        return items;
    }
    
    public static List<OrderItem> createExhibitionOrderItems(List<SBQQ__QuoteLine__c> qlinesList, Order o, ST_Exhibition__c exhib){
        List<OrderItem> items = new List<orderItem>();
        for(SBQQ__QuoteLine__c qli : qlinesList){
          OrderItem oi = new OrderItem();
            oi.PricebookEntryId = qli.SBQQ__PricebookEntryId__c;
            oi.OrderId = o.Id;
            oi.Product2Id = qli.SBQQ__Product__c;
            oi.SBQQ__QuoteLine__c = qli.Id;
            oi.SBQQ__ChargeType__c = 'Recurring';
            oi.ST_Customer_Product_Category__c = 'ValSHIP';
            oi.Exhibition__c = exhib.Id;
            oi.blng__LegalEntity__c = o.BVC_Billing_Entity__c;
            oi.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            oi.SBQQ__SubscriptionType__c = 'Renewable';
            oi.SBQQ__ProductSubscriptionType__c = 'Renewable';
            oi.blng__BillableUnitPrice__c = qli.SBQQ__NetPrice__c;
            oi.SBQQ__Status__c = 'Draft';
            oi.Quantity = 1;
            oi.UnitPrice = qli.SBQQ__ListPrice__c;
            oi.SBQQ__DefaultSubscriptionTerm__c = 12;
            oi.SBQQ__BillingFrequency__c = 'Annual';
            oi.SBQQ__BillingType__c = 'Advance';
            items.add(oi);
         }
        return items;
    }
    
    public static Contract createACRContract(Order o,Hub__c branch){
        Contract con = new Contract(AccountId = o.AccountId,
                                    SBQQ__Order__c = o.Id,
                                    StartDate = system.today(),
                                    EndDate = system.today().addDays(45),
                                    Original_Contract_End_Date__c = system.today().addDays(45),
                                    Contract_Signed_Date__c = system.today(),
                                    Business_Type__c = 'ACR',
                                    Contracted_ACR_Package__c = 'Package 2 : 60K',
                                    Contract_Amount__c = 6000000,
                                    BVC_Branch__c = branch.Id,
                                    BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c,
                                    BVC_Entity__c = branch.BVC_Entity__c);
        return con;
    }
    
    public static Contract createNonACRContract(Order o,Hub__c branch){
        Contract con = new Contract(AccountId = o.AccountId,
                                    SBQQ__Order__c = o.Id,
                                    StartDate = system.today(),
                                    EndDate = system.today().addMonths(36),
                                    Original_Contract_End_Date__c = system.today().addMonths(36),
                                    Contract_Signed_Date__c = system.today(),
                                    Business_Type__c = 'Non ACR',
                                    BVC_Branch__c = branch.Id,
                                    BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c,
                                    BVC_Entity__c = branch.BVC_Entity__c);
        return con;
    }
    
    public static Contract createExhibitionContract(Order o, Hub__c branch, ST_Exhibition__c exhib){
        Contract con = new Contract(AccountId = o.AccountId,
                                    SBQQ__Order__c = o.Id,
                                    StartDate = system.today().addDays(1),
                                    EndDate = system.today().addMonths(12),
                                    Original_Contract_End_Date__c = system.today().addMonths(12),
                                    Contract_Signed_Date__c = system.today(),
                                    //Status = 'Activated',
                                    Business_Type__c = 'Exhibition',
                                    Exhibition__c = exhib.Id,
                                    BVC_Branch__c = branch.Id,
                                    BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c,
                                    BVC_Entity__c = branch.BVC_Entity__c);
        return con;
    }
    
    public static Account createACRCustomer(Contract con,AddressBook__c blngAddress){
        Account acrCustomer = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'ACR',
                                         Customer_Category__c = 'ACR Contracted',
                                         Active_Contract__c = con.Id,
                                         Billing_Address__c = blngAddress.Id);
        return acrCustomer;
    }
    
    public static Account createNonACRCustomer(Contract con,AddressBook__c blngAddress){
        Account acrCustomer = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         Active_Contract__c = con.Id,
                                         Billing_Address__c = blngAddress.Id);
        return acrCustomer;
    }
    
    public static List<SBQQ__Subscription__c> createACRSubscription(List<OrderItem> oLines, Contract con){
        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        for(OrderItem line : oLines){
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
            sub.SBQQ__Account__c = con.AccountId;
            sub.SBQQ__Product__c = line.Product2Id;
            sub.SBQQ__Contract__c = con.Id;
            sub.SBQQ__ListPrice__c = line.TotalPrice;
            sub.ST_Rate_Amount__c = 2.5;
            sub.ST_Package_Type__c = con.Contracted_ACR_Package__c;
            sub.SBQQ__OrderProduct__c = line.Id;
            sub.SBQQ__QuoteLine__c = line.SBQQ__QuoteLine__c;
            sub.ST_Rate_UOM__c = 'Per Gram';
            sub.SBQQ__Quantity__c = 1;
            subs.add(sub);
        }
        system.debug('Subscriptions From Utility Class:::'+subs);
        return subs;
    }
    
    public static List<SBQQ__Subscription__c> createNonACRSubscription(List<OrderItem> oLines, Contract con){
        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        for(OrderItem line : oLines){
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
            sub.SBQQ__Account__c = con.AccountId;
            sub.SBQQ__Product__c = line.Product2Id;
            sub.SBQQ__Contract__c = con.Id;
            sub.SBQQ__ListPrice__c = line.TotalPrice;
            sub.ST_Rate_Amount__c = 2.5;
            sub.SBQQ__OrderProduct__c = line.Id;
            sub.SBQQ__QuoteLine__c = line.SBQQ__QuoteLine__c;
            sub.ST_Gross_Weight_Slabs__c = line.Gross_Weight_Slabs__c;
            sub.ST_Rate_UOM__c = 'Per Gram';
            sub.SBQQ__Quantity__c = 1;
            subs.add(sub);
        }
        system.debug('Subscriptions From Utility Class:::'+subs);
        return subs;
    }
    
    public static List<SBQQ__Subscription__c> createExhibitionSubscription(List<OrderItem> oLines, Contract con, ST_Exhibition__c exhib){
        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        for(OrderItem line : oLines){
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
            sub.SBQQ__Account__c = con.AccountId;
            sub.SBQQ__Product__c = line.Product2Id;
            sub.SBQQ__Contract__c = con.Id;
            sub.SBQQ__ListPrice__c = line.TotalPrice;
            sub.ST_Customer_Product_Category__c = 'ValSHIP';
            sub.ST_Exhibition__c = exhib.Id;
            sub.ST_Rate_Amount__c = 2.5;
            sub.Slab_Level_1_Rate__c = 3.00;
            sub.Slab_Level_2_Rate__c = 2.50;
            sub.Slab_Level_3_Rate__c = 2.00;
            sub.Slab_Level_4_Rate__c = 1.50;
            sub.Slab_Level_5_Rate__c = 1.00;
            sub.Max_Slab_Rate__c = 1.00;
            sub.SBQQ__OrderProduct__c = line.Id;
            sub.SBQQ__QuoteLine__c = line.SBQQ__QuoteLine__c;
            sub.ST_Rate_UOM__c = 'Per Gram';
            sub.SBQQ__Quantity__c = 1;
            subs.add(sub);
        }
        system.debug('Subscriptions From Utility Class:::'+subs);
        return subs;
    }
    
    public static blng__Invoice__c createInvoice(Account acc, Hub__c branch,Order o) {
         blng__Invoice__c inv = new blng__Invoice__c();
         inv.blng__Account__c = acc.Id;
         inv.BVC_Branch__c = branch.Id;
         inv.Billing_Address__c = acc.Billing_Address__c;
         inv.blng__InvoiceStatus__c = 'Draft';
         inv.blng__InvoiceDate__c = system.today();
         return inv;
        }
    
    public static List<Shipment__c> createnonACRnonContShipment(Account acc,List<hub__c> branches,List<AddressBook__c> address){
        List<Shipment__c> shipList = new List<Shipment__c>();
        for(Integer i=0;i<3;i++){
            Shipment__c ship = new Shipment__c();
            ship.Account__c = acc.Id;
            ship.Bill_To_Account__c= acc.Id;
            ship.Customer__c = acc.Id;
            ship.Consignee_Email_ID__c = 'abc@abc.com';
            ship.Gross_Weight__c = 12;
            ship.Origin_Type__c = 'Offline';
            ship.Destination_Type__c = 'Offline';
            ship.Status__c = 'Draft';
            ship.Ready_for_Billing__c = true;
            ship.Shipment_Value__c = 250000;
            ship.Shipment_Date__c = system.today();
            ship.Billing_Account__c = acc.Id;
            ship.Origin_Hub__c = branches[0].Id;
            ship.Shipper_Name_TMS__c = acc.Id;
            ship.Destination_Address_Name__c = branches[0].Id;
            ship.BillTo_Party_Address__c = address[0].Id;
            ship.Origin_Address_Name__c  = address.size() >= 2 ? address[1].Id : address[0].Id;
            ship.Destination_Address_Name__c = address.size() >= 3 ? address[2].Id : address[0].Id;
            ship.Destination_Hub__c = branches[0].Id;
            ship.RecordTypeId =Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();
            ship.Shipping_Note_Number__c = '85187JVAS';
            ship.Origin_Type__c = 'Offline';
            ship.Destination_Type__c = 'Offline';
            ship.Product_Code__c = 'GOLD-EX-C2C';
            ship.Gross_Weight__c = 8000;
            ship.Initiator_PAN__c = 'AGSJ2F2H';
            shipList.add(ship);
        }
        
        return shipList; 
    }
    public static Shipment__c createShipment(Account acc,hub__c branch,AddressBook__c address){
        List<Shipment__c> shipList = new List<Shipment__c>();
        
            Shipment__c ship = new Shipment__c();
            ship.Account__c = acc.Id;
            ship.Bill_To_Account__c= acc.Id;
            ship.Customer__c = acc.Id;
            ship.Consignee_Email_ID__c = 'abc@abc.com';
            ship.Gross_Weight__c = 12;
            ship.Origin_Type__c = 'Offline';
            ship.Destination_Type__c = 'Offline';
            ship.Status__c = 'Draft';
            ship.Ready_for_Billing__c = true;
            ship.Shipment_Value__c = 250000;
            ship.Shipment_Date__c = system.today();
            ship.Billing_Account__c = acc.Id;
            ship.Origin_Hub__c = branch.Id;
            ship.Shipper_Name_TMS__c = acc.Id;
            ship.Destination_Address_Name__c = branch.Id;
            ship.BillTo_Party_Address__c = address.Id;
            ship.Origin_Address_Name__c  = address.Id;
            ship.Destination_Address_Name__c = address.Id;
            ship.Destination_Hub__c = branch.Id;
            ship.RecordTypeId =Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();
            ship.Shipping_Note_Number__c = '85187JVAS';
            ship.Origin_Type__c = 'Offline';
            ship.Destination_Type__c = 'Offline';
            ship.Product_Code__c = 'GOLD-EX-C2C';
            ship.Gross_Weight__c = 8000;
            ship.Initiator_PAN__c = 'AGSJ2F2H';
            
        
        return ship; 
    }
    public static blng__InvoiceScheduler__c createInvoiceScheduler(){
        blng__InvoiceScheduler__c sched = new blng__InvoiceScheduler__c(blng__InvoiceBatches__c = 'Batch 1',
                                                                        blng__InvoiceDate__c = system.today(),
                                                                        blng__StartDateTime__c = system.now().addMinutes(2),
                                                                        blng__TargetDate__c = system.today(),
                                                                        blng__Type__c='Daily',
                                                                        Name = 'BVC Billing Schedule Daily Test Class');
        return sched;
    }
    
    public static blng__InvoiceRun__c createInvoiceRun(blng__InvoiceScheduler__c schd){
        blng__InvoiceRun__c run = new blng__InvoiceRun__c(Name = 'BVC Test Schedule Run',
                                                          blng__InvoiceScheduler__c = schd.Id,
                                                          blng__TargetDate__c = system.today());
        return run;
    }
    public static blng__Invoice__c createInvoice(Id accId, Id orderId){
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = accId;
        invoice.blng__Order__c = orderId;
        invoice.ACR_Cancelled__c = false;        
        return invoice;
        
    }
    
    public static blng__Invoice__c createConsolidatedInvoice(Account acc, Id schedId,Hub__c branch){
         blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__InvoiceStatus__c = 'Draft';
        invoice.blng__InvoiceRunCreatedBy__c = schedId;
        invoice.BVC_Branch__c = branch.id;
        invoice.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        invoice.BVC_Entity__c = branch.BVC_Entity__c;
        invoice.blng__InvoiceDate__c = system.today();
        return invoice;
        
    }
    public static blng__InvoiceLine__c createConsolidatedInvoiceLine(blng__Invoice__c inv){
        blng__InvoiceLine__c invLine  = new blng__InvoiceLine__c();
        invLine.Name = 'GoldSHIP Express C2C';
        invLine.blng__Invoice__c = inv.Id;
        invLine.Freight_Charges__c = 5000;
        invLine.Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 2000;
        invLine.blng__Subtotal__c = 8000;
        invLine.blng__UnitPrice__c = 8000;
        return invLine;
     }
    public static blng__Payment__c createPayment(blng__Invoice__c inv){
        blng__Payment__c payment = new blng__Payment__c(blng__Account__c = inv.blng__Account__c,
                                                       blng__Amount__c = inv.blng__TotalAmount__c,
                                                       blng__Invoice__c = inv.Id,
                                                       blng__Notes__c = 'Test Payment',
                                                       blng__PaymentType__c = 'Cash');
        return payment;
    }
    
    public static blng__PaymentAllocationInvoice__c createPaymentAllocation(blng__Payment__c payment){
        blng__PaymentAllocationInvoice__c allocation = new blng__PaymentAllocationInvoice__c(blng__Amount__c = payment.blng__Amount__c,
                                                                                           blng__Invoice__c = payment.blng__Invoice__c,
                                                                                           blng__Payment__c = payment.Id,
                                                                                           blng__Type__c = 'Allocation');
        return allocation;
    }
    
    public static ST_NonACR_Standard_Price__c createNONACRStandardPrice(Product2 prod){
        ST_NonACR_Standard_Price__c price = new ST_NonACR_Standard_Price__c();
        price.ST_Rate_Amount__c = 1;
        price.ST_Gross_Weight_Slabs__c = '1.01 - 3 Kg';
        price.ST_Effective_Start_Date__c = system.today();
        price.ST_Product__c = prod.Id;
        price.ST_Effective_End_Date__c = system.today().addDays(364);
        price.ST_Rate_UOM__c = 'Per Gram';
        return price;
    }
    
    public static OpportunityContactRole createOpportunityContactRole(Opportunity opp, Contact con, String role){
        OpportunityContactRole oppContact = new OpportunityContactRole();
        oppContact.OpportunityId = opp.Id;
        oppContact.ContactId = con.Id;
        oppContact.Role = role;

        return oppContact;
        
    }
    
    public static rsdoc__Document_Action__c createInvoiceDocActions(String templateName,String ObjectName,Id emailTemplateId){
        rsdoc__Document_Action__c docAction =  new rsdoc__Document_Action__c(
            rsdoc__Email_Template__c = emailTemplateId,
            rsdoc__Template_Document_ID__c = '1RbRn6Yhnwnqg1PmNDHGCTJ_qAW60sp-4Mf5plAJQbUE',
            rsdoc__Template_Name__c = templateName,
            rsdoc__Base_object_API__c = ObjectName,
            rsdoc__Visibility__c = 'Link',
            rsdoc__Email_File_As__c = 'Attachment',
            rsdoc__Email_Action__c = 'Autosend',
            rsdoc__Access__c = 'Can comment',
            rsdoc__Output_format__c = 'pdf',
            rsdoc__Send_for_Signature_Action__c = '',
            rsdoc__Counter_Sign_Method__c = '',
            rsdoc__Email_To__c = '{!blng__Invoice__c.blng__BillToContact__c}',
            rsdoc__Folder_ID__c = '1_FkV6H1xSGBkpE2ux7R8hNS39FbrYX_X',
            rsdoc__Field_To_Update__c = 'Send_Status__c',
            rsdoc__Field_To_Update_Value__c = 'Sent',
            rsdoc__Parent_Lookup_Field_Name__c = '',
            rsdoc__Save_in_Field__c = 'Invoice_Doc_URL__c',
            rsdoc__Email_From_Org_Wide_Address__c = '0D25w000000LBKe',
            rsdoc__Attach_File__c = true
        );
        return docAction;
    }
    
    public static List<ST_NonACR_Contracted_Price__c  > createMisfitNonACRPriceTable (Id accId,Id contractId,Id ProductId){
        List<String> chargeHeadTypeList = new List<String>{'Freight Charge','Weight Charge','Liability Charge','Offline Charge','BVC Valuation Charge','Docket Charge','Holiday Charge','Fuel Charge'};
        List<ST_NonACR_Contracted_Price__c > misfirPrices = new List<ST_NonACR_Contracted_Price__c >();
        for(String str : chargeHeadTypeList){
            ST_NonACR_Contracted_Price__c newNonACRconPriceRec = new ST_NonACR_Contracted_Price__c();
            newNonACRconPriceRec.ST_Active__c = TRUE;
            newNonACRconPriceRec.ST_Contract__c = contractId;
            newNonACRconPriceRec.ST_Customer_Account__c = accId;
            newNonACRconPriceRec.ST_Product__c = ProductId;
            newNonACRconPriceRec.Charge_Type__c = str;
            newNonACRconPriceRec.is_Misfit__c  = true;
            if(str == 'Liability Charge' ){
                newNonACRconPriceRec.Weight_Category__c  = 'Invoice Value';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = 'Per Shipment';
                newNonACRconPriceRec.Multi_Level_Charges__c = true;
                newNonACRconPriceRec.Level_1__c = 10000;
                newNonACRconPriceRec.Level_2__c = 20000;
                newNonACRconPriceRec.Level_3__c = 30000;
                newNonACRconPriceRec.Level_4__c = 40000;
                newNonACRconPriceRec.Level_5__c = 50000;
                newNonACRconPriceRec.Level_1_Rate__c = 100;
                newNonACRconPriceRec.Level_2_Rate__c = 200;
                newNonACRconPriceRec.Level_3_Rate__c = 300;
                newNonACRconPriceRec.Level_4_Rate__c = 400;
                newNonACRconPriceRec.Level_5_Rate__c = 500;
            }else if(str == 'Docket Charge'){
                newNonACRconPriceRec.Free_Quantity__c = 10;
                newNonACRconPriceRec.Weight_Category__c  = 'Net Weight';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = 'Per Lakhs';
                newNonACRconPriceRec.Multi_Level_Charges__c = true;
                newNonACRconPriceRec.Level_1__c = 1000;
                newNonACRconPriceRec.Level_2__c = 2000;
                newNonACRconPriceRec.Level_3__c = 3000;
                newNonACRconPriceRec.Level_4__c = 4000;
                newNonACRconPriceRec.Level_5__c = 5000;
                newNonACRconPriceRec.Level_1_Rate__c = 1000;
                newNonACRconPriceRec.Level_2_Rate__c = 2000;
                newNonACRconPriceRec.Level_3_Rate__c = 3000;
                newNonACRconPriceRec.Level_4_Rate__c = 4000;
                newNonACRconPriceRec.Level_5_Rate__c = 5000;
            }else if(str == 'Holiday Charge'){
                newNonACRconPriceRec.Weight_Category__c  = 'Kilometer';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = 'Per Shipment';
                newNonACRconPriceRec.Multi_Level_Charges__c = true;
                newNonACRconPriceRec.Level_1__c = 100;
                newNonACRconPriceRec.Level_2__c = 200;
                newNonACRconPriceRec.Level_3__c = 300;
                newNonACRconPriceRec.Level_4__c = 400;
                newNonACRconPriceRec.Level_5__c = 500;
                newNonACRconPriceRec.Level_1_Rate__c = 1000;
                newNonACRconPriceRec.Level_2_Rate__c = 2000;
                newNonACRconPriceRec.Level_3_Rate__c = 3000;
                newNonACRconPriceRec.Level_4_Rate__c = 4000;
                newNonACRconPriceRec.Level_5_Rate__c = 5000;
            }
            else if(str == 'Offline Charge' ){
                newNonACRconPriceRec.Free_Quantity__c = 20;
                newNonACRconPriceRec.Weight_Category__c  = 'Gross Weight';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = 'Per Lakhs';
                newNonACRconPriceRec.ST_Rate_Amount__c = 1000;
            }
            else if(str == 'BVC Valuation Charge'){
                newNonACRconPriceRec.Weight_Category__c  = 'Invoice Value';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = '% of Invoice Value';
                newNonACRconPriceRec.ST_Rate_Amount__c = 0.01;
            }else if(str == 'Fuel Charge'){
                newNonACRconPriceRec.Weight_Category__c  = 'Freight Charges';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = '% of Freight Charges';
                newNonACRconPriceRec.ST_Rate_Amount__c = 5;
            }else if(str == 'Freight Charge'){
                newNonACRconPriceRec.ST_Minimum_Freight__c  = 50000;
                newNonACRconPriceRec.Weight_Category__c  = 'Gross Weight';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = 'Gross Weight';
                newNonACRconPriceRec.Multi_Level_Charges__c = true;
                newNonACRconPriceRec.Level_1__c = 1000;
                newNonACRconPriceRec.Level_2__c = 2000;
                newNonACRconPriceRec.Level_3__c = 3000;
                newNonACRconPriceRec.Level_4__c = 4000;
                newNonACRconPriceRec.Level_5__c = 5000;
                newNonACRconPriceRec.Level_1_Rate__c = 1;
                newNonACRconPriceRec.Level_2_Rate__c = 2;
                newNonACRconPriceRec.Level_3_Rate__c = 3;
                newNonACRconPriceRec.Level_4_Rate__c = 4;
                newNonACRconPriceRec.Level_5_Rate__c = 5;
                
                
            }else if(str == 'Weight Charge'){
                newNonACRconPriceRec.Weight_Category__c  = 'Package Weight';
                newNonACRconPriceRec.Misfit_Rate_UOM__c = 'Package Weight';
                newNonACRconPriceRec.Multi_Level_Charges__c = true;
                newNonACRconPriceRec.Level_1__c = 100;
                newNonACRconPriceRec.Level_2__c = 200;
                newNonACRconPriceRec.Level_3__c = 300;
                newNonACRconPriceRec.Level_4__c = 400;
                newNonACRconPriceRec.Level_5__c = 500;
                newNonACRconPriceRec.Level_1_Rate__c = 1;
                newNonACRconPriceRec.Level_2_Rate__c = 2;
                newNonACRconPriceRec.Level_3_Rate__c = 3;
                newNonACRconPriceRec.Level_4_Rate__c = 4;
                newNonACRconPriceRec.Level_5_Rate__c = 5;
            }
            
            misfirPrices.add(newNonACRconPriceRec);
        }
        return misfirPrices;
    }
    
    public static List<ST_ACR_Contracted_Price__c > createMisfitACRPriceTable (Id accId,Id contractId,Id ProductId){
        List<String> chargeHeadTypeList = new List<String>{'Freight Charge','Weight Charge','Liability Charge','Offline Charge','BVC Valuation Charge','Docket Charge','Holiday Charge','Fuel Charge'};
        List<ST_ACR_Contracted_Price__c > misfirPrices = new List<ST_ACR_Contracted_Price__c >();
        for(String str : chargeHeadTypeList){
            ST_ACR_Contracted_Price__c newACRconPriceRec = new ST_ACR_Contracted_Price__c();
            newACRconPriceRec.ST_Active__c = TRUE;
            newACRconPriceRec.ST_Contract__c = contractId;
            newACRconPriceRec.ST_Customer_Account__c = accId;
            newACRconPriceRec.ST_Product__c = ProductId;
            newACRconPriceRec.ST_ACR_Package_Type__c = 'Package 2 : 60K';
            newACRconPriceRec.Charge_Type__c = str;
            newACRconPriceRec.is_Misfit__c  = true;
            newACRconPriceRec.ST_Origin__c  = 'Bengaluru';
            newACRconPriceRec.ST_Destination__c   = 'Bengaluru';
            if(str == 'Liability Charge' ){
                newACRconPriceRec.Slab_Dependency__c  = 'Invoice Value';
                newACRconPriceRec.Misfit_Rate_UOM__c = 'Per Shipment';
                newACRconPriceRec.Multi_Level_Charges__c = true;
                newACRconPriceRec.Level_1__c = 10000;
                newACRconPriceRec.Level_2__c = 20000;
                newACRconPriceRec.Level_3__c = 30000;
                newACRconPriceRec.Level_4__c = 40000;
                newACRconPriceRec.Level_5__c = 50000;
                newACRconPriceRec.Level_1_Rate__c = 100;
                newACRconPriceRec.Level_2_Rate__c = 200;
                newACRconPriceRec.Level_3_Rate__c = 300;
                newACRconPriceRec.Level_4_Rate__c = 400;
                newACRconPriceRec.Level_5_Rate__c = 500;
            }else if(str == 'Docket Charge'){
                newACRconPriceRec.Free_Quantity__c = 10;
                newACRconPriceRec.Slab_Dependency__c  = 'Net Weight';
                newACRconPriceRec.Misfit_Rate_UOM__c = 'Per Lakhs';
                newACRconPriceRec.Multi_Level_Charges__c = true;
                newACRconPriceRec.Level_1__c = 1000;
                newACRconPriceRec.Level_2__c = 2000;
                newACRconPriceRec.Level_3__c = 3000;
                newACRconPriceRec.Level_4__c = 4000;
                newACRconPriceRec.Level_5__c = 5000;
                newACRconPriceRec.Level_1_Rate__c = 1000;
                newACRconPriceRec.Level_2_Rate__c = 2000;
                newACRconPriceRec.Level_3_Rate__c = 3000;
                newACRconPriceRec.Level_4_Rate__c = 4000;
                newACRconPriceRec.Level_5_Rate__c = 5000;
            }else if(str == 'Holiday Charge'){
                newACRconPriceRec.Slab_Dependency__c  = 'Kilometer';
                newACRconPriceRec.Misfit_Rate_UOM__c = 'Per Shipment';
                newACRconPriceRec.Multi_Level_Charges__c = true;
                newACRconPriceRec.Level_1__c = 100;
                newACRconPriceRec.Level_2__c = 200;
                newACRconPriceRec.Level_3__c = 300;
                newACRconPriceRec.Level_4__c = 400;
                newACRconPriceRec.Level_5__c = 500;
                newACRconPriceRec.Level_1_Rate__c = 1000;
                newACRconPriceRec.Level_2_Rate__c = 2000;
                newACRconPriceRec.Level_3_Rate__c = 3000;
                newACRconPriceRec.Level_4_Rate__c = 4000;
                newACRconPriceRec.Level_5_Rate__c = 5000;
            }
            else if(str == 'Offline Charge' ){
                newACRconPriceRec.Free_Quantity__c = 20;
                newACRconPriceRec.Slab_Dependency__c  = 'Gross Weight';
                newACRconPriceRec.Misfit_Rate_UOM__c = 'Per Lakhs';
                newACRconPriceRec.ST_Rate_Amount__c = 1000;
            }
            else if(str == 'BVC Valuation Charge'){
                newACRconPriceRec.Slab_Dependency__c = 'Invoice Value';
                newACRconPriceRec.Misfit_Rate_UOM__c = '% of Invoice Value';
                newACRconPriceRec.ST_Rate_Amount__c = 0.01;
            }else if(str == 'Fuel Charge'){
                newACRconPriceRec.Slab_Dependency__c = 'Freight Charges';
                newACRconPriceRec.Misfit_Rate_UOM__c = '% of Freight Charges';
                newACRconPriceRec.ST_Rate_Amount__c = 5;
            }else if(str == 'Freight Charge'){
                newACRconPriceRec.ST_Minimum_Freight__c  = 50000;
                newACRconPriceRec.Slab_Dependency__c = 'Gross Weight';
                newACRconPriceRec.Misfit_Rate_UOM__c = 'Gross Weight';
                newACRconPriceRec.Multi_Level_Charges__c = true;
                newACRconPriceRec.Level_1__c = 1000;
                newACRconPriceRec.Level_2__c = 2000;
                newACRconPriceRec.Level_3__c = 3000;
                newACRconPriceRec.Level_4__c = 4000;
                newACRconPriceRec.Level_5__c = 5000;
                newACRconPriceRec.Level_1_Rate__c = 1;
                newACRconPriceRec.Level_2_Rate__c = 2;
                newACRconPriceRec.Level_3_Rate__c = 3;
                newACRconPriceRec.Level_4_Rate__c = 4;
                newACRconPriceRec.Level_5_Rate__c = 5;
                
                
            }else if(str == 'Weight Charge'){
                newACRconPriceRec.Slab_Dependency__c = 'Package Weight';
                newACRconPriceRec.Misfit_Rate_UOM__c = 'Package Weight';
                newACRconPriceRec.Multi_Level_Charges__c = true;
                newACRconPriceRec.Level_1__c = 100;
                newACRconPriceRec.Level_2__c = 200;
                newACRconPriceRec.Level_3__c = 300;
                newACRconPriceRec.Level_4__c = 400;
                newACRconPriceRec.Level_5__c = 500;
                newACRconPriceRec.Level_1_Rate__c = 1;
                newACRconPriceRec.Level_2_Rate__c = 2;
                newACRconPriceRec.Level_3_Rate__c = 3;
                newACRconPriceRec.Level_4_Rate__c = 4;
                newACRconPriceRec.Level_5_Rate__c = 5;
            }
            
            misfirPrices.add(newACRconPriceRec);
        }
        return misfirPrices;
    }
    
    public static List<ST_ACR_Contracted_Price__c > createStdACRPriceTable (Id accId,Id contractId,Id ProductId){
        List<ST_ACR_Contracted_Price__c > acrPrices = new List<ST_ACR_Contracted_Price__c >();
            ST_ACR_Contracted_Price__c newACRconPriceRec = new ST_ACR_Contracted_Price__c();
            newACRconPriceRec.ST_Active__c = TRUE;
            newACRconPriceRec.ST_Contract__c = contractId;
            newACRconPriceRec.ST_Customer_Account__c = accId;
            newACRconPriceRec.ST_Product__c = ProductId;
            newACRconPriceRec.is_Misfit__c  = false;
            newACRconPriceRec.ST_Minimum_Freight__c = 1000;
            newACRconPriceRec.ST_Offline_Charge__c = 100;
            newACRconPriceRec.ST_Rate_Amount__c = 10;
            newACRconPriceRec.ST_Rate_UOM__c = 'Per gram';
            
            acrPrices.add(newACRconPriceRec);
            
            
        
        return acrPrices;
    }
    
    public static List<ST_NonACR_Contracted_Price__c > createStdNonACRPriceTable (Id accId,Id contractId,Id ProductId){
        List<ST_NonACR_Contracted_Price__c > NonacrPrices = new List<ST_NonACR_Contracted_Price__c >();
            ST_NonACR_Contracted_Price__c newACRconPriceRec = new ST_NonACR_Contracted_Price__c();
            newACRconPriceRec.ST_Active__c = TRUE;
            newACRconPriceRec.ST_Contract__c = contractId;
            newACRconPriceRec.ST_Customer_Account__c = accId;
            newACRconPriceRec.ST_Product__c = ProductId;
            newACRconPriceRec.is_Misfit__c  = false;
            newACRconPriceRec.ST_Minimum_Freight__c = 1000;
            newACRconPriceRec.ST_Offline_Charge__c = 100;
            newACRconPriceRec.ST_Rate_Amount__c = 10;
            newACRconPriceRec.ST_Rate_UOM__c = 'Per gram';
            
            NonacrPrices.add(newACRconPriceRec);
            
            
        
        return NonacrPrices;
    }
    

     
}