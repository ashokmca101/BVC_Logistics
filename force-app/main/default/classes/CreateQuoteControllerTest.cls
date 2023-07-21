@isTest
public class CreateQuoteControllerTest {
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
        
        AccountContactRelation relation = [SELECT Id,AccountId,Roles FROM AccountContactRelation WHERE AccountId IN :accList LIMIT 1];//TestUtility.createAccountContactRelation(accList[0],con);
        relation.Roles = 'Finance; Invoice Recepient';
        update relation;
        
        List<Opportunity> oppList = TestUtility.createOpportunity(accList,Con,ent);
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
        
        
        
        
    }
    
  @isTest
    public static void quoteTestMethod(){
        test.startTest();
        List<ST_NonACR_Standard_Price__c> nonAcrPrice = [SELECT Id FROM ST_NonACR_Standard_Price__c LIMIT 2];
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
        quotes[0].Business_Type__c = 'ACR';
         quotes[0].SBQQ__Status__c = 'Draft';
        quotes[0].SBQQ__StartDate__c = System.today();
        
		CreateQuoteController.CreateBVCQuote(quotes[0]);
        
        try{
            List<SBQQ__Quote__c> quotesNew = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        quotesNew[0].Business_Type__c = null;
         
            CreateQuoteController.CreateBVCQuote(quotes[0]);
            
        }catch(Exception e){
            System.debug('Message  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void cloneQuoteRelatedTestMethod(){
        test.startTest();
        ST_NonACR_Standard_Price__c nonAcrPrice = [SELECT Id FROM ST_NonACR_Standard_Price__c LIMIT 1];
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
        
        insert quotes;
        system.debug('Quotes>>>'+quotes);
        /*List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;*/
        Base_Quote_Settings__c baseQuote= new Base_Quote_Settings__c();
		baseQuote.Name = 'Non ACR';
        baseQuote.Base_QuoteId__c = quotes[0].Id;
        baseQuote.Quote_Business_Type__c = 'Non ACR';
        insert baseQuote;
        
        try{
            List<SBQQ__Quote__c> quotesNew = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        	quotesNew[0].Business_Type__c = 'Non ACR';
             quotesNew[0].SBQQ__Status__c = 'Draft';
            quotesNew[0].SBQQ__StartDate__c = System.today();
         
            CreateQuoteController.CreateBVCQuote(quotesNew[0]);
            
        }catch(Exception e){
            System.debug('Message  '+e.getMessage());
        }
       
        
        
        test.stopTest();
    }
    
    @isTest
    static void cloneWithoutQuoteTestMethod(){
        test.startTest();
        ST_NonACR_Standard_Price__c nonAcrPrice = [SELECT Id FROM ST_NonACR_Standard_Price__c LIMIT 1];
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
        
        insert quotes;
        system.debug('Quotes>>>'+quotes);
        
        try{
            List<SBQQ__Quote__c> quotesNew = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        	quotesNew[0].Business_Type__c = 'Non ACR';
             quotesNew[0].SBQQ__Status__c = 'Draft';
            quotesNew[0].SBQQ__StartDate__c = System.today();
         
            CreateQuoteController.CreateBVCQuote(quotesNew[0]);
            
        }catch(Exception e){
            System.debug('Message  '+e.getMessage());
        }
       
        
        
        test.stopTest();
    }
    //exhibition
      @isTest
    static void cloneQuoteexhibition(){
        test.startTest();
        ST_NonACR_Standard_Price__c nonAcrPrice = [SELECT Id FROM ST_NonACR_Standard_Price__c LIMIT 1];
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
        
        	ST_Exhibition__c newexb = TestUtility.createExhibition();
        newexb.Name = 'ABC exhibition';
        newexb.ST_Active__c = true;
        insert newexb;
       
        List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        quotes[0].Business_Type__c = 'Exhibition';
         quotes[0].SBQQ__Status__c = 'Draft';
        quotes[0].Exhibition__c =newexb.Id;
        
        insert quotes;
        system.debug('Quotes>>>'+quotes);
        /*List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;*/
        Base_Quote_Settings__c baseQuote= new Base_Quote_Settings__c();
		baseQuote.Name = newexb.Id;
        baseQuote.Base_QuoteId__c = quotes[0].Id;
        baseQuote.Quote_Business_Type__c = 'Exhibition';
        insert baseQuote;
        
        try{
            List<SBQQ__Quote__c> quotesNew = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        	quotesNew[0].Business_Type__c = 'Exhibition';
             quotesNew[0].SBQQ__Status__c = 'Draft';
            quotesNew[0].SBQQ__StartDate__c = System.today();
            quotesNew[0].Exhibition__c =newexb.Id;
            CreateQuoteController.CreateBVCQuote(quotesNew[0]);
            
        }catch(Exception e){
            System.debug('Message  '+e.getMessage());
        }
       
        
        
        test.stopTest();
    }
  
}