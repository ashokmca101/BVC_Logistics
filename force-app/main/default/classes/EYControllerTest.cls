@isTest
public class EYControllerTest {
    @testSetup
    static void testSetup(){
        test.startTest();
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
        nonAcrNonContractedAccount.Last_Name__c = 'Test';
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
        list<rsdoc__Document_Action__c> doclist=new list<rsdoc__Document_Action__c>();
        rsdoc__Document_Action__c doc1=new rsdoc__Document_Action__c();
        doc1.rsdoc__Template_Name__c ='CB Import Tax Invoice';
        doc1.rsdoc__Base_object_API__c = 'blng__Invoice__c';
        doc1.rsdoc__Template_Document_ID__c='1uZcLxCSH_49alJviesXWA0xMFwLBTytgaA0TdIIvkag';
        rsdoc__Document_Action__c doc2=new rsdoc__Document_Action__c();
        doc2.rsdoc__Template_Name__c ='CB Import Bill of Supply Invoice';
        doc2.rsdoc__Base_object_API__c = 'blng__Invoice__c';
        doc2.rsdoc__Template_Document_ID__c='1uZcLxCSH_49alJviesXWA0xMFwLBTytgaA0TdIIvkag';
        rsdoc__Document_Action__c doc3=new rsdoc__Document_Action__c();
        doc3.rsdoc__Template_Name__c ='CB Import Commercial Invoice';
        doc3.rsdoc__Base_object_API__c = 'blng__Invoice__c';
        doc3.rsdoc__Template_Document_ID__c='1uZcLxCSH_49alJviesXWA0xMFwLBTytgaA0TdIIvkag';
        doclist.add(doc1);doclist.add(doc2);doclist.add(doc3);
        insert doclist;
        test.stopTest();
        system.debug(doclist.size());
        
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
        
        
        test.stopTest();
    }
    
    @isTest 
    static void invoiceCallOutFail(){
        test.startTest();
        
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        DocumentSeries__c newDoc = new DocumentSeries__c();
        newDoc.Name = '28TI011';
        newDoc.Last_Serial_Number__c = '28TI011';
        newDoc.Unique_Key__c  = '28TI01';
        insert newDoc;
        Order ord = [SELECT Id FROM Order Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        AccountContactRelation acr = [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: acc.Id limit 1];
        if(acr != null){
            acr.Roles = 'Finance; Invoice Recepient';
            update acr;
        }
        blng__Invoice__c inv = Testutility.createInvoice( acc,  branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        insert inv;
        
        system.enqueueJob(new RazorpayQueueable(new List<Id>{inv.Id}));
        
        test.stopTest();
    }
    @isTest
    static void manualInvoiceTaxTest(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.ST_Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
        
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    
    @isTest
    static void manualInvoiceTaxSecondTest(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id,GST_Registered_Status__c FROM AddressBook__c Limit 1];
        billingAddress.GST_Registered_Status__c = 'Registered';
        billingAddress.Dealer_Type__c = 'Regular';
        billingAddress.GSTIN__c = '27AABCB7286R1ZV';
        billingAddress.ADDRESS1__c = 'of all time';
        billingAddress.ADDRESS2__c = ' of all time';
        update billingAddress;
        Account acc = [select id,Billing_Address__c from Account Limit 1 ];
        
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Origin_Address__c = billingAddress.Id;
        inv.Destination_Address__c = billingAddress.Id;
        insert inv;
        
        
        
        try{
            EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
        }catch(Exception e){
            System.debug('error message '+e.getMessage());
        }        NumberTOWordConvertion numbword = new NumberTOWordConvertion();
        numbword.getNumberTOWordConvertion(102023472.15);
        
        blng__Invoice__c invRec = [select id,blng__InvoiceStatus__c from blng__Invoice__c where id=:inv.Id];
        System.debug('Test Inv Status. '+invRec.blng__InvoiceStatus__c);
        test.stopTest();
    }
    //Anamika
    @isTest
    static void manualInvoiceTaxThirdTest(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        
        Account acc = [select id,Billing_Address__c,Invoice_Pre_Approval__c from Account Limit 1 ];
        acc.Invoice_Pre_Approval__c = true;
        update acc;
        
        
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.ST_Offline_Charge__c = 1500;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 2000;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        
        //inv.blng__InvoiceStatus__c = 'Draft';
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.Short_URL__c = 'www.google.com';
        inv.Razorpay_Id__c = 'hshsyyw5562727';
        update inv;
        
        
        
        try{
            EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
        }catch(Exception e){
            System.debug('error message '+e.getMessage());
        }        
        test.stopTest();
    }
    
    @isTest
    static void manualInvoiceTaxTestmark1(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Origin_Address__c = billingAddress.Id;
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        
		inv.Total_Commission_Tax__c=100;
        inv.Total_Logistics_Tax_Amount__c=100;
        inv.Total_Secure_Logistics_Tax_Amount__c=100;
		
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        
		invLine.Commission_Charges__c  = 100;
        invLine.Logistics_Charges__c  = 100;
        
        invLine.Secure_Logistics_Charges__c  = 100;
		
        invLine.blng__Invoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.ST_Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 3500;
        invLine.Fuel_Surcharge__c = 1000;
        invLine.Vaulting_Charges__c = 1000 ;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
        
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void manualInvoiceTaxTestmark2(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        Order ord = [SELECT Id FROM Order Limit 1];
        blng__BillingRule__c BlngRule = TestUtility.createBillingRule();
        insert Blngrule;
        blng__RevenueRecognitionRule__c RevenueRule= TestUtility.createRevenueRule();
        insert RevenueRule;
        blng__TaxRule__c TaxRule = TestUtility.createTaxRule();
        insert TaxRule;
        Product2 ChargeHead = TestUtility.createACRProduct(Blngrule,RevenueRule,TaxRule);
        ChargeHead.Name='COURIER CHARGES';
        ChargeHead.ProductCode='CB-22';
        insert ChargeHead;
        list<Product2> prodlist=new list<Product2>();
        prodlist.add(ChargeHead);
        Pricebook2 PB=  TestUtility.createPriceBook();
        insert PB;
        id StandardPricebookid =Test.getStandardPricebookId();
        PricebookEntry PBEstandard= new PricebookEntry(Pricebook2Id =StandardPricebookid, Product2Id = ChargeHead.Id, UnitPrice = 1000, IsActive = true);
        insert PBEstandard;
        List<PricebookEntry> PBEntry= TestUtility.createPricebookEntry(PB.id,prodlist);
        insert PBEntry;
        
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Is_CB_Invoice__c = True ;
        inv.Origin_Address__c = billingAddress.Id;
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.blng__Product__c = ChargeHead.Id;
        invLine.Name = ChargeHead.Name;
        insert invLine;
        
        
        try{
            EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void manualInvoiceTaxTestmark3(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        
        
        Order ord = [SELECT Id FROM Order Limit 1];
        blng__BillingRule__c BlngRule = TestUtility.createBillingRule();
        insert Blngrule;
        blng__RevenueRecognitionRule__c RevenueRule= TestUtility.createRevenueRule();
        insert RevenueRule;
        blng__TaxRule__c TaxRule = TestUtility.createTaxRule();
        insert TaxRule;
        Product2 ChargeHead = TestUtility.createACRProduct(Blngrule,RevenueRule,TaxRule);
        ChargeHead.Name='COURIER CHARGES';
        ChargeHead.ProductCode='CB-22';
        insert ChargeHead;
        list<Product2> prodlist=new list<Product2>();
        prodlist.add(ChargeHead);
        Pricebook2 PB=  TestUtility.createPriceBook();
        insert PB;
        id StandardPricebookid =Test.getStandardPricebookId();
        PricebookEntry PBEstandard= new PricebookEntry(Pricebook2Id =StandardPricebookid, Product2Id = ChargeHead.Id, UnitPrice = 1000, IsActive = true);
        insert PBEstandard;
        List<PricebookEntry> PBEntry= TestUtility.createPricebookEntry(PB.id,prodlist);
        insert PBEntry;
        
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Commercial Invoice';
        inv.BVC_CB_Invoice_Type__c = 'Commercial Invoice';
        inv.BVC_CB_Is_CB_Invoice__c = True ;
        inv.Origin_Address__c = billingAddress.Id;
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_CB_Operation_Type__c='Import';
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.blng__Product__c = ChargeHead.Id;
        invLine.Name = ChargeHead.Name;
        insert invLine;
        
        //EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
        
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void QueryUtilitytest1(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        
        Account parentacc = new Account();
        parentacc.Name = 'saidubabu - ';
        parentacc.Last_Name__c = 'Billing djzpd0151a';
        parentacc.Invoice_Pre_Approval__c = false;
        insert parentacc;
        
        
        Account acc = [SELECT Id,Billing_Address__c,Invoice_Pre_Approval__c,ParentId FROM Account Limit 1];
        acc.ParentId= parentacc.Id;
        update acc;
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Is_CB_Invoice__c = false ;
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.ST_Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void QueryUtilitytest2(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c,Invoice_Pre_Approval__c,ParentId FROM Account Limit 1];
        acc.ParentId= null;
        update acc;
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        //inv.BVC_CB_Is_CB_Invoice__c = true;
        inv.BVC_Branch__c = branch.Id;
        
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.ST_Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        
        
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void QueryUtilitytest3(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        
        Account parentacc = new Account();
        parentacc.Name = 'saidubabu - ';
        parentacc.Last_Name__c = 'Billing djzpd0151a';
        parentacc.Invoice_Pre_Approval__c = false;
        insert parentacc;
        
        
        Account acc = [SELECT Id,Billing_Address__c,Invoice_Pre_Approval__c,ParentId FROM Account Limit 1];
        acc.Invoice_Pre_Approval__c= true;
        // acc.ParentId= parentacc.Id;
        //acc.ParentId= null;
        update acc;
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Operation_Type__c='Import';
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_CB_Is_CB_Invoice__c = True;
        inv.BVC_Branch__c = branch.Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.ST_Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        
        
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest
    static void QueryUtilitytest4(){
        test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c,Invoice_Pre_Approval__c,ParentId FROM Account Limit 1];
        
        Order ord = [SELECT Id FROM Order Limit 1];
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Commercial Invoice';
        inv.BVC_CB_Invoice_Type__c = 'Commercial Invoice';
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_CB_Is_CB_Invoice__c = True;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_CB_Operation_Type__c='Import';
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.ST_Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        
        
        try{
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
  @isTest
    static void connectcontrollertest(){
        test.startTest();
         blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        Product2 acrProd = new Product2();
        acrProd.name = 'AIRLINE FREIGHT - CSR';
        acrProd.ProductCode = 'CB-505';
        acrProd.blng__BillingRule__c = bRule.Id;
        acrProd.IsActive = true;
        acrProd.SBQQ__PricingMethod__c = 'List';
        acrProd.blng__RevenueRecognitionRule__c = revRule.id;
        acrProd.blng__TaxRule__c = taxRule.id;
        insert acrProd;
        
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        Order ord = [SELECT Id FROM Order Limit 1];
  		list<blng__Invoice__c> invlist=new list<blng__Invoice__c>();
        blng__Invoice__c inv = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Invoice_Type__c =  'Tax Invoice';
        inv.Origin_Address__c = billingAddress.Id;
        inv.Destination_Address__c = billingAddress.Id;
        inv.Billing_Address__c = billingAddress.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_CB_Operation_Type__c='Import';
        inv.BVC_CB_Is_CB_Invoice__c =true;
         //inv.BVC_CB_PreTaxBill__c = Pretaxbill.Id;
        invlist.add(inv);
        blng__Invoice__c inv1 = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv1.BVC_CB_Invoice_Type__c =  'Tax Invoice';//'Bill of Supply Invoice';
        inv1.Origin_Address__c = billingAddress.Id;
        inv1.Destination_Address__c = billingAddress.Id;
        inv1.Billing_Address__c = billingAddress.Id;
        inv1.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv1.BVC_Entity__c = branch.BVC_Entity__c;
        inv1.BVC_Branch__c = branch.Id;
        inv1.BVC_CB_Is_CB_Invoice__c =true;
       inv1.BVC_CB_PreTaxBill__c =  inv.BVC_CB_PreTaxBill__c;
        //insert inv1;
        invlist.add(inv1);
          blng__Invoice__c inv2 = Testutility.createInvoice( acc,branch,ord);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv2.BVC_CB_Invoice_Type__c =  'Tax Invoice';
        inv2.Origin_Address__c = billingAddress.Id;
        inv2.Destination_Address__c = billingAddress.Id;
        inv2.Billing_Address__c = billingAddress.Id;
        inv2.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv2.BVC_Entity__c = branch.BVC_Entity__c;
        inv2.BVC_Branch__c = branch.Id;
        inv2.BVC_CB_Is_CB_Invoice__c =true;
       inv2.BVC_CB_PreTaxBill__c =  inv.BVC_CB_PreTaxBill__c;
        invlist.add(inv2);
        insert invlist;
        blng__BillingRule__c BlngRule = TestUtility.createBillingRule();
        insert Blngrule;
        blng__RevenueRecognitionRule__c RevenueRule= TestUtility.createRevenueRule();
        insert RevenueRule;
        blng__TaxRule__c TaxRule1 = TestUtility.createTaxRule();
        insert TaxRule1;
          blng__FinanceBook__c bfb= new blng__FinanceBook__c();
            bfb.name= 'test bfb';
            bfb.blng__PeriodType__c ='Accounting';
            insert bfb;
            blng__BillingTreatment__c Btreatment = new blng__BillingTreatment__c();
        Btreatment.Name ='test treatment';
            Btreatment.blng__BillingRule__c =Blngrule.id;
            btreatment.blng__BillingFinanceBook__c = bfb.id;
        insert Btreatment;
        Product2 ChargeHead = TestUtility.createACRProduct(Blngrule,RevenueRule,TaxRule1);
        ChargeHead.Name='COURIER CHARGES';
        ChargeHead.ProductCode='CB-22';
        insert ChargeHead;
        list<Product2> prodlist=new list<Product2>();
        prodlist.add(ChargeHead);
        Pricebook2 PB=  TestUtility.createPriceBook();
        insert PB;
        id StandardPricebookid =Test.getStandardPricebookId();
        PricebookEntry PBEstandard= new PricebookEntry(Pricebook2Id =StandardPricebookid, Product2Id = ChargeHead.Id, UnitPrice = 1000, IsActive = true);
       insert PBEstandard;
        List<PricebookEntry> PBEntry= TestUtility.createPricebookEntry(PB.id,prodlist);
        insert PBEntry;
       
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv2.Id;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = ChargeHead.Id;
        invLine.Name = ChargeHead.Name;
        insert invLine;
        list<id> invIDS= new list<id>();
        invIDS.add(inv2.Id);
        //invIDS.add(inv2.Id);
        //invIDS.add(inv1.Id);
        CPQ_ConnectController.authurl(invIDS);
        //CPQ_ConnectController.fakemethod();
        try{
            //EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id));
            //CPQ_ConnectController.authurl(invIDS);
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
     @isTest
    static void connectcontrollertest1(){
        test.startTest();
         blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        Product2 acrProd = new Product2();
        acrProd.name = 'AIRLINE FREIGHT - CSR';
        acrProd.ProductCode = 'CB-505';
        acrProd.blng__BillingRule__c = bRule.Id;
        acrProd.IsActive = true;
        acrProd.SBQQ__PricingMethod__c = 'List';
        acrProd.blng__RevenueRecognitionRule__c = revRule.id;
        acrProd.blng__TaxRule__c = taxRule.id;
        insert acrProd;
        
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c,BVC_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];
        
        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        insert orderList;
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account acc = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        Order ord = [SELECT Id FROM Order Limit 1];
        //Product2 prod = [select id,Name from Product2 limit 1];
       list<blng__Invoice__c> invlist=new list<blng__Invoice__c>();
         blng__Invoice__c inv3 = Testutility.createInvoice( acc,branch,ord);
        inv3.Invoice_Type__c = 'Commercial Invoice';
       inv3.BVC_CB_Invoice_Type__c =  'Commercial Invoice';
        inv3.Origin_Address__c = billingAddress.Id;
        inv3.Destination_Address__c = billingAddress.Id;
        inv3.Billing_Address__c = billingAddress.Id;
        inv3.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv3.BVC_Entity__c = branch.BVC_Entity__c;
        inv3.BVC_Branch__c = branch.Id;
        inv3.BVC_CB_Is_CB_Invoice__c =true;
        inv3.BVC_CB_Operation_Type__c='Import';
        //inv3.BVC_CB_PreTaxBill__c = 'a6C6D0000005vr5UAA';
        invlist.add(inv3);
    
         blng__Invoice__c inv4 = Testutility.createInvoice( acc,branch,ord);
        inv4.Invoice_Type__c ='Bill of Supply Invoice';
        inv4.BVC_CB_Invoice_Type__c =  'Bill of Supply Invoice';
        inv4.Origin_Address__c = billingAddress.Id;
        inv4.Destination_Address__c = billingAddress.Id;
        inv4.Billing_Address__c = billingAddress.Id;
        inv4.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv4.BVC_Entity__c = branch.BVC_Entity__c;
        inv4.BVC_Branch__c = branch.Id;
        inv4.BVC_CB_Is_CB_Invoice__c =true;
        inv4.BVC_CB_Operation_Type__c='Import';
       //inv4.BVC_CB_PreTaxBill__c =  'a6C6D0000005vr5UAA';
        //insert inv4;
        invlist.add(inv4);
         blng__Invoice__c inv5 = Testutility.createInvoice( acc,branch,ord);
        inv5.BVC_CB_Invoice_Type__c =  'Commercial Invoice';
        inv5.Origin_Address__c = billingAddress.Id;
        inv5.Destination_Address__c = billingAddress.Id;
        inv5.Billing_Address__c = billingAddress.Id;
        inv5.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv5.BVC_Entity__c = branch.BVC_Entity__c;
        inv5.BVC_Branch__c = branch.Id;
        inv5.BVC_CB_Is_CB_Invoice__c =true;
        inv5.BVC_CB_Operation_Type__c='Import';
       //inv5.BVC_CB_PreTaxBill__c =  'a6C6D0000005vr5UAA';
        //insert inv5;
        invlist.add(inv5);
        insert invlist;
        product2 p1=[select id,name from product2 limit 1];
        list<blng__InvoiceLine__c> invlines=new list<blng__InvoiceLine__c>();
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv5.Id;
        invLine.blng__Subtotal__c = 3500;
        invLine.blng__Product__c = p1.Id;
        invLine.Name = p1.Name;
        invlines.add(invLine);
        
        blng__InvoiceLine__c invLine1 = new blng__InvoiceLine__c ();
        invLine1.blng__Invoice__c  = inv4.Id;
        invLine1.blng__Subtotal__c = 3500;
        invLine1.blng__Product__c = p1.Id;
        invLine1.Name = p1.Name;
        invlines.add(invLine1);
        insert invlines;
        list<id> invIDS= new list<id>();
        invIDS.add(inv3.Id);
       
        try{
            CPQ_ConnectController.authurl(invIDS);
            CPQ_ConnectController.fakemethod();
            //EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv3.Id));
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    
       
        
}