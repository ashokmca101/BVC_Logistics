@isTest
public class InvoiceTriggerHandlerTest {
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
        Active_Pincode__c bengaluruPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert bengaluruPin;
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        accList.add(nonAcrNonContractedAccount);
        
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        Contact ConNew = TestUtility.createContact(accList[0]);
        ConNew.LastName = 'Carlsson New';
        ConNew.Email = 'abccarl@abc.com';
        insert ConNew;
        
        //AccountContactRelation acrRec = TestUtility.createAccountContactRelation(nonAcrNonContractedAccount,ConNew);
        //insert acrRec;
        Opportunity opp = TestUtility.createOpportunity(accList,con,ent)[0];
        //List<Opportunity> oppList = new List<Opportunity>{opp};
        insert opp;
        
        List<OpportunityContactRole> roleList = new List<OpportunityContactRole>();
        OpportunityContactRole opptyRole  = TestUtility.createOpportunityContactRole(opp,con,'Decision Maker');
        OpportunityContactRole opptyRole1  = TestUtility.createOpportunityContactRole(opp,ConNew,'Evaluator');
        roleList.add(opptyRole);
        roleList.add(opptyRole1);
        insert roleList;
 
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
        test.startTest();
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
        insert stdACRPrice;
        
        ST_NonACR_Standard_Price__c noAcrPrice = TestUtility.createNONACRStandardPrice(prodList[1]);
        insert noAcrPrice;
        
       Account shipperAccount = TestUtility.createShipperAccount();
        insert shipperAccount;
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',bengaluruPin.id,'Bengaluru',true);
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        //insert ship1;
        //ship1.Status__c = 'Picked for Billing';
        
        //update ship1;
        test.stopTest();
            
        
                                      
        
    }
    
    
    @isTest
    static void invoiceCancellationTest(){
        
        
        /*test.startTest();
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];

        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
         List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createQuoteLines(quote.Id,pbEntries,stdPriceList));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        orderList[0].Business_Type__c = 'ACR';
        insert orderList;
        
        List<OrderItem> acrItems = Testutility.createACROrderItems(quoteLines, orderList[0]);
        insert acrItems;
        
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account nonAcrNonContractedAccountNew = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        List<Contact> contactList = new List<Contact>();
        Contact Con = TestUtility.createContact(nonAcrNonContractedAccountNew);
        Con.Email = 'newTest@kadal.com';
        Con.LastName = 'NewTest';
        contactList.add(Con);
        Contact testCon = TestUtility.createContact(nonAcrNonContractedAccountNew);
        testCon.Email = 'juriyadi@hssj.com';
        testCon.LastName = 'essions';
        contactList.add(testCon);
        insert contactList;
        
        List<AccountContactRelation> updateList = new List<AccountContactRelation>();
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: nonAcrNonContractedAccountNew.Id ]){
            acr.Roles = 'Finance; Invoice Recepient';
            updateList.add(acr);
        }
        if(updateList.size()>0){
            update updateList;
        }
        
        
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( nonAcrNonContractedAccountNew,branch,orderList[0]);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.ACR_Cancelled__c = true;
        inv.blng__Order__c = orderList[0].Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.ST_Offline_Charge__c = 1500;
        invLine.blng__Subtotal__c = 1500;
        invLine.blng__UnitPrice__c = 1500;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        invLine.blng__OrderProduct__c = acrItems[0].Id;
        
        insert invLine;
            
            
        
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.Short_URL__c = 'www.google.com';
        inv.Razorpay_Id__c = 'hshsyyw5562727';
        update inv;
        
         Attachment attach=new Attachment();       
         attach.Name='Unit Test Attachment';
         Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = inv.id;
        insert attach;
        
        //blng__Invoice__c invRec = [Select id,Billing_Address__c, blng__Account__c, BVC_Branch__c, BVC_Billing_Entity__c,BVC_Billing_Entity__r.GSTIN_State_Code__c, BVC_Entity__c, blng__BillToContact__c from blng__Invoice__c where blng__InvoiceStatus__c ='Posted' Limit 1];
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = inv.blng__Account__c;
        creditNote.BVC_Branch__c = inv.BVC_Branch__c;
        creditNote.BVC_Billing_Entity__c = inv.BVC_Billing_Entity__c;
        creditNote.Billing_Address__c = inv.Billing_Address__c;
        creditNote.blng__BillToContact__c = inv.blng__BillToContact__c;
        creditNote.BVC_Entity__c = inv.BVC_Entity__c;
        creditNote.blng__RelatedInvoice__c = inv.Id;
        creditNote.blng__CreditNoteDate__c = System.Today();
        creditNote.Approval_Status__c = 'Approved';
        creditNote.Reason_for_Credit_Note__c = 'Duplicate Billing';
        insert creditNote;
        
        
        blng__CreditNoteLine__c newCNLine = new blng__CreditNoteLine__c ();
        newCNLine.Charge_Head_Type__c  = 'Offline Charge';
        newCNLine.blng__CreditNote__c   = creditNote.Id;
        newCNLine.blng__Product__c   = prod.Id;
        newCNLine.blng__Subtotal__c   = 0;
        insert newCNLine;
        
        blng__CreditNoteAllocation__c  CNAllocation = new blng__CreditNoteAllocation__c ();
        CNAllocation.blng__Amount__c  = 0;
        CNAllocation.blng__CreditNoteLine__c = newCNLine.Id;
        CNAllocation.blng__InvoiceLine__c =  invLine.Id;
        CNAllocation.blng__Type__c  = 'Allocation';
        insert CNAllocation;
        blng__Invoice__c invRecord = [Select blng__PaymentStatus__c,blng__Order__r.Business_Type__c from blng__Invoice__c where id=:inv.Id];
        System.debug(' Paymnt status   '+ invRecord.blng__Order__r.Business_Type__c);
        System.debug(' Paymnt status   '+ invRecord.blng__PaymentStatus__c);
        system.schedule('Test Invalid Integration Logs Scheduler1', '0 35 0 ? * * *', new ClearInvalidIntegrationLogsScheduler() );
        test.stopTest();*/
    }
    
    @isTest
    static void ManualinvoiceTest(){
        test.startTest();
        
        
        List<Opportunity> oppList = [select id,AccountId from Opportunity];
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        Pricebook2 pbook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<ST_ACR_Standard_Price__c> stdPriceList = [Select Id,ST_Product__c from ST_ACR_Standard_Price__c];
        List<PricebookEntry> pbEntries = [select id,Product2Id from PricebookEntry where Pricebook2Id =:pbook.Id];

        SBQQ__Quote__c quote = TestUtility.createACRQuote(pbook.Id, oppList, branch)[0];
        insert quote;
        List<Order> orderList = TestUtility.createACROrder(new List<SBQQ__Quote__c>{quote}, quote.SBQQ__PricebookId__c);
        orderList[0].Business_Type__c = 'ACR';
        insert orderList;
        
        Account nonAcrNonContractedAccountNew = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        AddressBook__c billingAddress = [SELECT Id,Customer__c FROM AddressBook__c WHERE Customer__c = :nonAcrNonContractedAccountNew.Id Limit 1];
        system.debug('nonAcrNonContractedAccountNew : '+nonAcrNonContractedAccountNew);
        List<Contact> contactList = new List<Contact>();
        Contact Con = TestUtility.createContact(nonAcrNonContractedAccountNew);
        Con.Email = 'newTest@kadal.com';
        Con.LastName = 'NewTest';
        contactList.add(Con);
        Contact testCon = TestUtility.createContact(nonAcrNonContractedAccountNew);
        testCon.Email = 'juriyadi@hssj.com';
        testCon.LastName = 'essions';
        contactList.add(testCon);
        insert contactList;
        List<AccountContactRelation> updateList = new List<AccountContactRelation>();
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: nonAcrNonContractedAccountNew.Id ]){
            acr.Roles = 'Finance; Invoice Recepient';
            updateList.add(acr);
        }
        if(updateList.size()>0){
            update updateList;
        }
       
        
        Product2 prod = [select id,Name from Product2 limit 1];
        blng__Invoice__c inv = Testutility.createInvoice( nonAcrNonContractedAccountNew,branch,orderList[0]);
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.ACR_Cancelled__c = true;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.ST_Offline_Charge__c = 1500;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        //invLine.Fuel_Surcharge__c=100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.blng__Subtotal__c = 2100;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        
        insert invLine;
        inv.Total_Docket_Charge_Tax__c = 18;
        inv.Total_Offline_Tax__c = 270;
        inv.Total_Fuel_Charge_Tax__c = 18;
        inv.Total_Holiday_Charge_Tax__c = 18;
        inv.Total_Weight_Charge_Tax__c = 18;
        //inv.Total_Fuel_surcharge_Tax__c = 18;
        inv.Total_BVC_Valuation_Charge_Tax__c = 18;    
        inv.Short_URL__c = 'www.google.com';
        inv.Razorpay_Id__c = 'hshsyyw5562727';
        inv.EY_Tax_Calculation_Status__c = 'Success';
        update inv;
        
        invLine.blng__TaxAmount__c = 360;
        update invLine;
        
        inv.blng__InvoiceStatus__c = 'Posted';
        
        update inv;
        Database.executeBatch(new ClearInvalidIntegrationLogBatch());
        test.stopTest();
    }
    
     @isTest
    static void consolidateInvoiceTest(){
        test.startTest();
        Hub__c branch = [select id,ST_BVC_Billing_Entity__c from Hub__c Limit 1];
        blng__LegalEntity__c legEntity = [SELECT Id,Default_Branch__c,BVC_Entity__c 
                                            FROM blng__LegalEntity__c 
                                            WHERE Id = :branch.ST_BVC_Billing_Entity__c];
        system.debug('Legal Entities : '+legEntity);
        Product2 prod = [select id,Name from Product2 limit 1];
        Account nonAcrNonContractedAccountNew = [SELECT Id,Billing_Address__c FROM Account Limit 1];
        AddressBook__c billingAddress = [SELECT Id,Customer__c FROM AddressBook__c WHERE Customer__c = :nonAcrNonContractedAccountNew.Id Limit 1];
         
        system.debug('nonAcrNonContractedAccountNew : '+nonAcrNonContractedAccountNew);
        blng__InvoiceRun__c run = new blng__InvoiceRun__c(Name='Test Run',
                                                         blng__TargetDate__c = Date.today(),
                                                         blng__Status__c = 'Completed');
        insert run;
        //Shipment__c ship = [SELECT Id FROM Shipment__c LIMIT 1];
        /*Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
           fieldNames.add(fieldName);
            
        }
        string queries = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c LIMIT 1';
        List<Shipment__c> ships = Database.query(queries);
        system.debug('Shipment Product Code : '+ships[0].Product_Code__c);
        Map<Id,Shipment__c> ship = new Map<Id,Shipment__c>(ships);
        
        OrderCreateShipment.createOrderShipment(ship);
        OrderItem oi = [SELECT Id FROM OrderItem where order.Shipment__c = :ships[0].Id LIMIT 1];*/
        blng__Invoice__c inv = Testutility.createInvoice( nonAcrNonContractedAccountNew,branch,null);
        inv.blng__InvoiceRunCreatedBy__c = run.Id;
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
        invLine.blng__InvoiceRun__c = run.Id;
        //invLine.Shipment__c = ship.Id;
        invLine.Name = prod.Name;
        //invLine.blng__OrderProduct__c = oi.Id;
        insert invLine;
        
        InvoiceLineTriggerHandler.Method1();
        
        test.stopTest();
    }
    @isTest
    Public Static void Method2test(){
        InvoiceTriggerHandler.Method2();
    }
   /* @isTest
    public static void InvoiceMapOnContract(){
         Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
        insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH');
        //Product2 prodESHIP = new Product2(Name = 'BVC eSHIP',Family = 'BATH',ProductCode='BVC eSHIP');
        //Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BATH',ProductCode='BVC iValSHIP');
        //Product2 prodiEVALSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BATH',ProductCode='BVC ieSHIP');
        //Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BATH',ProductCode='BVC ExhibiSHIP``````````````````````````');
        prodList.add(prodBATh);
        //prodList.add(prodESHIP);
        //prodList.add(prodiVALSHIP);
        //prodList.add(prodiEVALSHIP);
        //prodList.add(prodExibiSHIP);
        insert prodList;
        list<PricebookEntry> PBentry = new list<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry BVCPrice2 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry BVCPrice3 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry BVCPrice4 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        //PricebookEntry BVCPrice5 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PBentry.add(standardPrice1);
        //PBentry.add(standardPrice2);
        //PBentry.add(standardPrice3);
        //PBentry.add(standardPrice4);
        //PBentry.add(standardPrice5);
        PBentry.add(BVCPrice1);
        //PBentry.add(BVCPrice2);
        //PBentry.add(BVCPrice3);
        //PBentry.add(BVCPrice4);
        //PBentry.add(BVCPrice5);
        insert PBentry;
        String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        //User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        //List<Hub__c> BVCbranchBatheShip = [select id,Billing_Entity_Name__c,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        String BillingRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
         Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        //acc.RecordTypeId=BillingRecordTypeID;
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test@bvc.com';
        insert acc;
        Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
        insert entity;
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
        insert leObj;
        Hub__c newHub = new Hub__c();
        newHub.Name='MUMBAI-BDB';
        newHub.Branch__c='AGRA';
        newHub.Billing_Entity_Name__c=leObj.id;
        insert newHub;
        
        Zone__c newZone = new Zone__c();
        newZone.Name='data Zone';
        insert newZone;
        Active_Pincode__c newActivePinCode = new Active_Pincode__c();
        newActivePinCode.Pincodes__c='43785';
        newActivePinCode.City__c='Agra';
        newActivePinCode.Country__c='India';
        newActivePinCode.State__c='Delhi';
        newActivePinCode.Hub__c=newHub.ID;
        newActivePinCode.Zone__c=newZone.Id;
        insert newActivePinCode;
        
        String BillingAddRecordTypeID = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        AddressBook__c BillingAdd = new AddressBook__c();
        BillingAdd.RecordTypeId=BillingAddRecordTypeID;
        BillingAdd.Customer__c=acc.Id;
        BillingAdd.Your_Address_Identifier__c='shivaji Ward';
        BillingAdd.ADDRESS1__c='shivaji ward Ghatanji';
        BillingAdd.TRADE_NAME__c='TESTKYC';
        BillingAdd.Dealer_Type__c='Regular';
        BillingAdd.GSTIN__c='Test';
        BillingAdd.Legacy_Record__c=true;
        BillingAdd.Active_Pincode__c=newActivePinCode.Id;
        insert BillingAdd;
        //acc.HasAddress__c=true;
        //acc.Billing_Address__c=BillingAdd.Id;
        //acc.Primary_Address__c=BillingAdd.Id;
        //acc.Is_Finance_Contact_Present__c=true;
        //acc.KYC_Status__c='API Verified';
        //acc.Name_As_Per_PAN_Manual_Input__c='TESTKYCTUTVHNJK';
        //acc.Name_As_Per_PAN__pc='TESTKYCTUTVHNJK';
        //acc.KARZAA_Name_As_Per_PAN__c='TESTKYCTUTVHNJK';
        //acc.Trade_Name__c='TESTKYC';
        //update acc;
        Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        //cc.AccountId=acc.id;
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        //Insert cc;
        Opportunity opp=new Opportunity();
        String OppAddRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC BATH Deal').getRecordTypeId();
        opp.Name = 'test1';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.newInstance(2016, 12, 9);
        opp.StageName = 'Inbound Lead';
        opp.Amount=1;
        //opp.RecordTypeId=OppAddRecordTypeID;
        //opp.Decision_Maker__c=cc.id;
        //opp.Evaluator__c=cc.id;
        //opp.Influencer__c=cc.id;
        opp.BVC_Product__c=prodBATh.id;
        insert opp;
        SBQQ__Quote__c qT= new SBQQ__Quote__c();
        qT.SBQQ__Account__c=acc.Id;
        qT.BVC_Service__c='BATH';
        qT.Tariff_Plan_Bath_Eship__c='Standard';
        //qT.Business_Type__c='ACR';
        qT.BVC_Branch__c=hub.Id;
        qT.SBQQ__Opportunity2__c=opp.id;
        qT.SBQQ__Primary__c=true;
        //insert qT;
        Order o = new Order();
        o.AccountId = acc.id;
        o.EffectiveDate = System.today().addDays(-10);
        o.blng__BillingDayOfMonth__c = '20';
        o.Status='Draft';
        o.blng__BillingAccount__c = acc.id;
        //o.SBQQ__Quote__c=qT.id;
        o.Pricebook2Id = BVCPricebook.id;
        o.OpportunityId=opp.id;
        insert o;
        Contract con = new Contract();
        con.AccountId=acc.Id;
        //con.Business_Type__c='ACR';
        con.BVC_Service__c='BATH';
        con.BVC_Branch__c=newHub.id;
        con.BVC_Billing_Entity__c=leObj.id;
        con.Status='Draft';
        con.StartDate=Date.Today();
        con.EndDate=Date.newInstance(2028, 06, 09);
        con.ContractTerm=12;
        con.Contract_Amount__c=150000;
        //con.SBQQ__Quote__c=qT.ID;
        insert con;
        con.Status='Activated';
        update con;
        blng__InvoiceRun__c run = new blng__InvoiceRun__c(Name='Test Run',
                                                         blng__TargetDate__c = Date.today(),
                                                         blng__Status__c = 'Completed');
        insert run;

        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c = acc.Id;
        inv.BVC_Branch__c = newHub.Id;
        inv.Email_Recepients__c='test@gmail.com';
        //inv.Billing_Address__c = acc.Billing_Address__c;
        inv.blng__InvoiceStatus__c = 'Draft';
        inv.blng__InvoiceDate__c = system.today();
        inv.blng__InvoiceRunCreatedBy__c = run.Id;
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
        invLine.blng__Product__c = prodBATh.Id;
        invLine.blng__InvoiceRun__c = run.Id;
        invLine.Name = prodBATh.Name;
        //invLine.blng__OrderProduct__c = oi.Id;
        //insert invLine;
    }*/
}