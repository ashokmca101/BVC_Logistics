@isTest
public class CongaComposerCtrlTest {
	@testSetup
    static void testSetup(){
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Entity__c ent = TestUtility.createBVCEntity();
        insert ent;
        
        Active_Pincode__c pin = TestUtility.createPinCode();
        insert pin;
        
        blng__LegalEntity__c legEntity = TestUtility.createLegalEntity(ent);
        insert legEntity;
        
        List<Hub__c> branches = new  List<Hub__c>();
        Hub__c bvcBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(bvcBranch);
        insert branches;
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        
        
        accList.add(nonAcrNonContractedAccount);
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        con.FirstName = 'Lionel';
        con.Title = 'The Best';
        insert Con;
        
        Opportunity opp = TestUtility.createOpportunity(accList,con,ent)[0];
        List<Opportunity> oppList = new List<Opportunity>{opp};
        insert oppList;
        
        
        OpportunityContactRole opptyRole  = TestUtility.createOpportunityContactRole(opp,con,'Decision Maker');
        insert opptyRole;
            
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
        
        
        List<PricebookEntry> customACRPrices = TestUtility.createACRPricebookEntry(pb.Id,prodList);
        insert customACRPrices;
        
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        insert blngAddress;
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Is_Finance_Contact_Present__c = true;
        accList[0].Primary_Address__c = blngAddress[0].Id;
        update accList[0];
        
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
        insert stdACRPrice;
        
        ST_NonACR_Standard_Price__c noAcrPrice = TestUtility.createNONACRStandardPrice(prodList[1]);
        insert noAcrPrice;
        
        
        
        
    }

    @isTest 
    static void acrQuoteMethod(){
        test.startTest();
        //List<SBQQ__Quote__c> quote = [SELECT Id From SBQQ__Quote__c where Business_Type__c = 'ACR' ];
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];

        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        
        List<SBQQ__QuoteLine__c> acrQuoteLines = TestUtility.createQuoteLines(quote.Id,pbEntries,stdPriceList);
        //insert acrQuoteLines;

        quote.SBQQ__Status__c = 'Approved';
        update quote;

        PageReference pageRef = Page.CongaVF;
        Test.setCurrentPage(pageRef);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CongaComposerCtrl con = new CongaComposerCtrl(sc);
        con.congaReq();
        
        test.stopTest();
    }
    
    @isTest 
    static void nonApprovedQuoteMethod(){
        test.startTest();

        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];

        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        
        List<SBQQ__QuoteLine__c> acrQuoteLines = TestUtility.createQuoteLines(quote.Id,pbEntries,stdPriceList);
        //insert acrQuoteLines;
        
        PageReference pageRef = Page.CongaVF;
        Test.setCurrentPage(pageRef);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CongaComposerCtrl con = new CongaComposerCtrl(sc);
        con.congaReq();
        
        test.stopTest();
    }
    
    @isTest 
    static void nonContactRoleQuoteMethod(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];

        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        
        List<SBQQ__QuoteLine__c> acrQuoteLines = TestUtility.createQuoteLines(quote.Id,pbEntries,stdPriceList);
        //insert acrQuoteLines;

        List<OpportunityContactRole> oppRoles = [SELECT Role From OpportunityContactRole where Role = 'Decision Maker' ];
        oppRoles[0].Role = 'Authorised Signatory';
        update oppRoles;
        
        PageReference pageRef = Page.CongaVF;
        Test.setCurrentPage(pageRef);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CongaComposerCtrl con = new CongaComposerCtrl(sc);
        con.congaReq();
        
        test.stopTest();
    }
}