@isTest
public class QuoteTriggerTest {
    @testSetup
    static void testSetup(){
        Test.startTest();
        Entity__c ent = TestUtility.createBVCEntity();
        insert ent;
        
        Active_Pincode__c pin = TestUtility.createPinCode();
        insert pin;
        
        blng__LegalEntity__c legEntity = TestUtility.createLegalEntity(ent);
        insert legEntity;
        
        List<Hub__c> branches = new  List<Hub__c>();
        Hub__c bvcBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(bvcBranch);
        Hub__c originBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(originBranch);
        Hub__c destinationBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(destinationBranch);
        insert branches;
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        accList.add(nonAcrNonContractedAccount);
        Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonACRContractedAccount.Name = 'Non ACR Contracted Account';
        accList.add(nonACRContractedAccount);
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        AccountContactRelation relation = [SELECT Id,AccountId,Roles FROM AccountContactRelation WHERE AccountId IN :accList LIMIT 1];
        relation.Roles = 'Finance; Invoice Recepient';
        update relation;
        
        List<Opportunity> oppList = TestUtility.createOpportunity(accList,con,ent);
        insert oppList;
        
        blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TestUtility.createACRProduct(bRule, revRule, taxRule);
        prodList.add(prod);
        
        
        Product2 optionProduct = TestUtility.createProduct(bRule, revRule, taxRule);
        optionProduct.Name = 'Gold Surface C2C';
        Product2 valProduct = TestUtility.createValProduct(bRule, revRule, taxRule);
        valProduct.Name = 'SilverSHIP Express C2C';
        prodList.add(valProduct);
        prodList.add(optionProduct);
        insert prodList;
        
        Product2 exhibiProduct = TestUtility.createProduct(bRule, revRule, taxRule);
        exhibiProduct.Name = 'ExhibiSHIP Surface C2C';
        exhibiProduct.ProductCode = 'EXHIBI-S-C2C';
        insert exhibiProduct;
        
        SBQQ__ProductOption__c prodOption = TestUtility.createProductOption(prodList[0], prodList[1]);
        insert prodOption;
        
        Id stdPriceBookId = test.getStandardPricebookId();
        
        Pricebook2 pb = TestUtility.createPriceBook();
        insert pb;
        
        PricebookEntry standardACRPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[0].Id, UnitPrice = 1000, IsActive = true);
        insert standardACRPBE;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[1].Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry standardvalPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[2].Id, UnitPrice = 1000, IsActive = true);
        insert standardvalPBE;
        
        
        List<PricebookEntry> customACRPrices = TestUtility.createACRPricebookEntry(pb.Id,prodList);
        insert customACRPrices;
        
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        insert blngAddress;
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        update accList[0];
        
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
        insert stdACRPrice;
        
        ST_NonACR_Standard_Price__c nonAcrPrice = TestUtility.createNONACRStandardPrice(prodList[1]);
        insert nonAcrPrice;
        ST_NonACR_Standard_Price__c nonAcrPrice2 = TestUtility.createNONACRStandardPrice(prodList[2]);
        insert nonAcrPrice2;
        ST_NonACR_Standard_Price__c nonAcrPrice3 = TestUtility.createNONACRStandardPrice(prodList[2]);
        nonAcrPrice3.ST_Gross_Weight_Slabs__c = '0 - 20 Kg';
        insert nonAcrPrice3;
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void quoteTestMethod(){
        test.startTest();
        List<ST_NonACR_Standard_Price__c> nonAcrPrice = [SELECT Id FROM ST_NonACR_Standard_Price__c LIMIT 3];
        Pricebook2 pb = TestUtility.createPriceBook();
        insert pb;
        List<PricebookEntry> customACRPrices = [SELECT Id,Product2Id FROM PricebookEntry];
        AddressBook__c blngAddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                      PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                      GSTIN__c FROM AddressBook__c LIMIT 1];
        List<Hub__c> branch = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                               Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                               FROM Hub__c ];
        List<Opportunity> oppList = [SELECT Id,AccountId FROm Opportunity];
        
        List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        quotes[0].Business_Type__c = 'Non ACR';
        quotes[0].SBQQ__Status__c = 'Draft';
        quotes[0].SBQQ__Primary__c = false;
        
        insert quotes;
        UtilClass.qliRecursionCheck = false;
        system.debug('Quotes>>>'+quotes);
        List<SBQQ__QuoteLine__c> insertQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLines1 = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLines2 = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLines3 = new List<SBQQ__QuoteLine__c>();
        quoteLines1.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice[0]));
        insertQuoteLines.addAll(quoteLines1);
        quoteLines2.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice[1]));
        insertQuoteLines.addAll(quoteLines2);
        quoteLines3.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice[2]));
        insertQuoteLines.add(quoteLines3[0]);
        insertQuoteLines[0].ST_Rate_Amount__c = 4;
        // quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insertQuoteLines[1].ST_Rate_Amount__c = 4;
        insertQuoteLines[2].ST_Rate_Amount__c = 1;
        insertQuoteLines[2].ST_Gross_Weight_Slabs__c = '0 - 20 Kg';
        //  quoteLines[1].ST_Gross_Weight_Slabs__c = '0 - 20 Kg';
        
        insert insertQuoteLines;
        SBQQ__QuoteLine__c qli = [SELECT Id,ST_Rate_Amount__c FROM SBQQ__QuoteLine__c LIMIT 1];
        qli.Max_Discount__c =50;
        update qli;
        UtilClass.qliRecursionCheck = false;
        qli.ST_Rate_Amount__c = 0.3*qli.ST_Rate_Amount__c;
        update qli;
        Non_ACR_Template__c nonacrtemp = new Non_ACR_Template__c();
        system.debug('QuoteLines++'+insertQuoteLines.size());
        Map<Id,SBQQ__Quote__c> quotes2Update = new Map<Id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c q : quotes){
            q.SBQQ__Status__c = 'Draft';
            quotes2Update.put(q.Id,q);
        }
        quotes2Update.values()[0].Base_Quote__c = true;
        system.debug('quotes2Update::'+quotes2Update);
        update quotes2Update.values();
        for(SBQQ__Quote__c q : quotes){
            q.SBQQ__Status__c = 'Approved';
            //q.Base_Quote__c = true;
            quotes2Update.put(q.Id,q);
        }
        system.debug('quotes2Update::'+quotes2Update);
        try{
            update  quotes2Update.values();
        }catch(Exception ex){
            system.debug('Quote Validation Success');
        }
        try{
            delete quotes2Update.values();
        }catch(Exception ex){
            system.debug('Quote Validation Success');
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void exhibitionQuoteTest(){
         Id stdPriceBookId = test.getStandardPricebookId();
        Pricebook2 pb = TestUtility.createPriceBook();
        insert pb;
        Product2 prod = [SELECT Id,Name,ProductCode FROM Product2 WHERE ProductCode LIKE '%EXHIBI%'];
        PricebookEntry standardACRPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardACRPBE;
        PricebookEntry exiPbe = new PricebookEntry(IsActive = true,
                                                   Pricebook2Id = pb.Id,
                                                   Product2Id = prod.Id,
                                                   UnitPrice = 0.0);
        insert exiPbe;
        
        Opportunity opp = [SELECT Id,AccountId FROm Opportunity LIMIT 1];
        Hub__c branch = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                         Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                         FROM Hub__c LIMIT 1];
       
        ST_Exhibition__c exi = TestUtility.createExhibition();
        insert exi;
         ST_Exhibition_Standard_Price__c esp = TestUtility.createExhibitionStdPrice(prod,exi);
        insert esp;
        test.startTest();
        SBQQ__Quote__c quote = TestUtility.createExhibitionQuote(pb.Id, opp, branch,exi);
        insert quote;
        SBQQ__QuoteLine__c line = TestUtility.createExhibitionQuoteLines(quote.Id,exiPbe,esp,exi);
        insert line;
        line.Slab_Level_5_Rate__c = line.Slab_Level_5_Rate__c - 0.2;
        update line;
        UtilClass.qliRecursionCheck = false;
        line.Slab_Level_5_Rate__c = line.Slab_Level_5_Rate__c - 0.2;
        update line;
        test.stopTest();
    }
}