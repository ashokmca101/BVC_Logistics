@isTest
public class ActivateACRContractQueueableTest {
    @isTest
    static void testExecute(){
        
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Entity__c ent = TestUtility.createBVCEntity();
        insert ent;
        
        Active_Pincode__c pin = TestUtility.createPinCode();
        insert pin;
        
        blng__LegalEntity__c legEntity = TestUtility.createLegalEntity(ent);
        insert legEntity;
        
        Hub__c bvcBranch = TestUtility.createBVCBranch(legEntity, pin);
        insert bvcBranch;
        
        List<Account> accList = new List<Account>();
        
        Account a = TestUtility.createnonACRnonContractedAccount();
        accList.add(a);
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
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
        update accList[0];
        
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
        insert stdACRPrice;
        
        List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, bvcBranch);
        insert quotes;
        
        
        List<Order> orderList = TestUtility.createACROrder(quotes, pb.Id);
        insert orderList;
        
        Contract contract = TestUtility.createACRContract(orderList[0],bvcBranch);
        insert contract;
        
        Map<Id,Id> conMap = new Map<Id,Id>();
        conMap.put(contract.Id, orderList[0].id);
        Test.startTest();
        System.enqueueJob(new ActivateACRContractQueueable(conMap));
        Test.stopTest();
    }
}