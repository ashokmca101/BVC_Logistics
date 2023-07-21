@isTest
public class UpdateOrderBillNowTest {
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
        
        AccountContactRelation relation = [SELECT Id,AccountId,Roles FROM AccountContactRelation WHERE AccountId IN :accList];//TestUtility.createAccountContactRelation(accList[0],con);
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
    static void updateorderBillNowTest(){
        test.startTest();
        List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,
                                                          Pincode_TMS__r.Hub__r.Billing_Entity_Name__c,
                                                         COUNTRY__c,CITY__c,PINCODE__c,Customer__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                         ORDER BY PINCODE__c desc];
        system.debug('originDestinationAdddress:::'+originDestinationAdddress);
        List<Account> accList = [select id from Account];
        List<Hub__c> branches = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                               Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                               FROM Hub__c ];
        List<AddressBook__c> blngAddressList = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                                PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                                GSTIN__c FROM AddressBook__c LIMIT 3];
        
        
        
        UtilClass.triggerLoop = false;
        
        AddressBook__c blngAddress = blngAddressList[0];
        List<ST_ACR_Standard_Price__c> acrPrices = [SELECT Id,ST_ACR_Package_Amount__c,ST_ACR_Package_Type__c,ST_Liability_Coverage__c,
                                                         ST_Effective_Start_Date__c,ST_Effective_End_Date__c,ST_Rate_UOM__c,
                                                         ST_Product__c FROM ST_ACR_Standard_Price__c LIMIT 2];
        Pricebook2 pb = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'BVC INR Price Book'];
        List<PricebookEntry> customACRPrices = [SELECT Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id];
        
        
        
        List<Opportunity> oppList = [SELECT Id,AccountId FROm Opportunity];
        
        List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, branches[0]);
        insert quotes;
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createQuoteLines(quotes[0].Id,customACRPrices,acrPrices));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> acrOrderList = TestUtility.createACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
        acrOrderList[0].blng__BillingDayOfMonth__c = '1';
        insert acrOrderList;
        List<OrderItem> acrItems = Testutility.createACROrderItems(quoteLines, acrOrderList[0]);
        insert acrItems;
       List<Id> oIds = new List<Id>();
        
        List<Order> orderList = [SELECT Id FROM ORDER WHERE Business_Type__c = 'ACR' AND Status = 'Activated'];
        system.debug('OrderList::UpdateOrder bill Now'+orderList);
        for(Order O : orderList){
            oIds.add(o.Id);
        }
        System.debug('List Of Oids::: '+oIds);
        UpdateOrderBillnow.orderBillnow(oIds);
        Test.stopTest();
    }

}