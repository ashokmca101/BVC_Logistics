@isTest
public class ChargeHeadTriggerHandlerTest {
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
        Hub__c originBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(originBranch);
        Hub__c destinationBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(destinationBranch);
        insert branches;
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        accList.add(nonAcrNonContractedAccount);
        
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        //Contact ConNew = TestUtility.createContact(accList[0]);
        Contact ConNew = New Contact();
        ConNew.LastName = 'Carlsson New';
        ConNew.Email = 'abccarl@abc.com';
        //insert ConNew;
        
        //AccountContactRelation acrRec = TestUtility.createAccountContactRelation(nonAcrNonContractedAccount,ConNew);
        //insert acrRec;
        Opportunity opp = TestUtility.createOpportunity(accList,con,ent)[0];
        insert opp;
        List<Opportunity> oppList = new List<Opportunity>{opp};
            
            
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
    static void invoiceInsertMethod(){
        
        test.startTest();
        
        List<AddressBook__c> blngAddress = [Select id from AddressBook__c];
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];

        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        Account acc = [select id from Account Limit 1 ];
        Test.setMock(HttpCalloutMock.class, new EYHttpTestResponseGenerator());
        Order ord = [SELECT Id FROM Order Limit 1];
        blng__Invoice__c inv = Testutility.createInvoice(acc.Id,ord.Id);
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Type__c = 'Tax Invoice';
        insert inv;
        Map<String,String> mapResponseCharge = new Map<String,String>{ 'VAULTING CHARGES' => 'Vaulting Charges','FUEL SURCHARGE' => 'Fuel Surcharge','FREIGHT CHARGES' => 'Freight Charge', 'LIABILITY CHARGES'=> 'Liability Charge', 'OFFLINE CHARGES'   => 'Offline Charge','BVC VALUATION CHARGES'   => 'BVC Valuation Charge','DOCKET CHARGES' => 'Docket Charge', 'FUEL CHARGES' => 'Fuel Charge','HOLIDAY CHARGES' => 'Holiday Charge', 'WEIGHT CHARGES' => 'Weight Charge', 'COMMISSION' => 'COMMISSION', 'LOGISTICS CHARGES' => 'LOGISTICS CHARGES', 'SECURE LOGISTICS CHARGES' => 'SECURE LOGISTICS CHARGES'};
        Integer count = 0;
        List<Charge_Head_Tax__c> chargeHeadstoInsert = new List<Charge_Head_Tax__c>();
        for(String str : mapResponseCharge.keySet()){
            count++;
            Charge_Head_Tax__c chTax = new Charge_Head_Tax__c();
            chTax.Name = str;
            chTax.Invoice__c = inv.Id;
            chTax.CGST_Amount__c = 90;
            chTax.IGST__c=0;
            chTax.CGST_Rate__c = 9;
            chTax.IGST_Amount__c = 0;
            chTax.SGST__c = 9;
            chTax.SGST_Amount__c = 90;
            chTax.Total_Amount__c = 180;
            chTax.Line_Number__c = count;
            chTax.Tax_Amount__c = 180;
            chTax.Tax_Percent__c = 18;
            chTax.Taxable_Value__c = 20;
            chTax.HSN_Code__c = '90039';
            chargeHeadstoInsert.add(chTax);        
        }
        if(chargeHeadstoInsert.size()>0){
        insert chargeHeadstoInsert;
        }
                
                
                
                                                                                
        
                                                                                
         
        
        
        test.stopTest();
    }
}