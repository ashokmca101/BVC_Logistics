@isTest
public class CreateOrderForPlatformschedulertest {

    @testSetup
    static void testSetup(){
        test.startTest();
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
        Active_Pincode__c bengaluruPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert bengaluruPin;
        system.debug('BEngalurur Pin:::'+bengaluruPin);
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        
               
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        accList.add(nonAcrNonContractedAccount);
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList LIMIT 1];//TestUtility.createAccountContactRelation(accList[0],con);
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
        optionProduct.Name = 'GoldSHIP Express C2C';
        optionProduct.ProductCode = 'GOLD-EX-C2C';
            optionProduct.Invoice_Group_ID__c = 'GOLD-EX-C2C';
        prodList.add(optionProduct);
        
        Product2 valProduct = TestUtility.createValProduct(bRule, revRule, taxRule);
        prodList.add(valProduct);
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
        
        PricebookEntry standarValdPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[2].Id, UnitPrice = 1000, IsActive = true);
        insert standarValdPBE;
        
        
        List<PricebookEntry> customACRPrices = TestUtility.createACRPricebookEntry(pb.Id,prodList);
        insert customACRPrices;
        
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        AddressBook__c destiAddressBook = TestUtility.destinationAddress(accList[0]);
        AddressBook__c originAddressBook = TestUtility.originAddress(accList[0]);
        originAddressBook.Pincode_TMS__c = bengaluruPin.Id;
        blngAddress.add(destiAddressBook);
        blngAddress.add(originAddressBook);
        insert blngAddress;
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Is_Finance_Contact_Present__c = true;
        accList[0].Primary_Address__c = blngAddress[0].Id;
        update accList[0];
        //update accList[0];
        
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
        insert stdACRPrice;
        
        List<ST_NonACR_Standard_Price__c> nonACRPriceList = new List<ST_NonACR_Standard_Price__c>();
        ST_NonACR_Standard_Price__c nonAcrPrice1 = TestUtility.createNONACRStandardPrice(prodList[1]);
        nonACRPriceList.add(nonAcrPrice1);
        
        ST_NonACR_Standard_Price__c nonAcrPrice2 = TestUtility.createNONACRStandardPrice(prodList[2]);
        nonAcrPrice2.ST_Destination__c = 'Bengaluru';
        nonAcrPrice2.ST_Origin__c = 'Mumbai';
        nonAcrPrice2.ST_Freight_on_Invoice_Value__c = 0.01;
        nonACRPrice2.ST_Gross_Weight_Slabs__c = '';
        nonACRPriceList.add(nonAcrPrice2);
        insert nonACRPriceList;
        Account shipperAccount = TestUtility.createShipperAccount();
        insert shipperAccount;
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',bengaluruPin.id,'Bengaluru',true);
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        //ship1.Gross_Weight__c = 8000;
        Ship1.platform_User__c=true;
        insert ship1;
       
        test.stopTest();
        
    }
    
    @isTest
    private static void method1(){
        Test.StartTest();        


 		 Shipment__c testlist = [Select id,Verified_for_Billing__c from Shipment__c];
         testlist.Verified_for_Billing__c=true;
         testlist.Product_Code__c='EXHIBI-WC';
         testlist.Gross_Weight__c = 8000;
         update testlist;
        
        CreateOrderForPlatform testobj = new CreateOrderForPlatform();
        String cronexpression = '0 0 0 ? * * *';
        System.schedule('Testing', cronexpression, testobj);
    Test.stopTest(); 
    }
      @isTest
    private static void method2(){
        Test.StartTest();        
          	 Product2 prods = [SELECT Id,Name,ProductCode FROM Product2 LIMIT 1];

             Shipment__c testlist = [Select id,Verified_for_Billing__c,Product_Code__c,Product_Name__c from Shipment__c];
             testlist.Verified_for_Billing__c=true;
            //testlist.Product_Name__c= prods.Name;
            testlist.Product_Code__c='GOLD-EX-C2C';
      
      
         update testlist;
        
        CreateOrderForPlatform testobj = new CreateOrderForPlatform();
               
        String cronexpression = '0 0 0 ? * * *';
        System.schedule('Testing', cronexpression, testobj);
                CreateOrderForPlatform.fakeMethod();
            Test.stopTest(); 
    }

 
  
}