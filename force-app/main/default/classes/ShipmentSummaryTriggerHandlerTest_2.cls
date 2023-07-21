@isTest
public class ShipmentSummaryTriggerHandlerTest_2 {
    
    
    public static String CRON_EXP = '0 0 0 24 7 ? 2022';
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
        Active_Pincode__c suratPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert suratPin;
        system.debug('BEngalurur Pin:::'+suratPin);
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonAcrNonContractedAccount.Name = 'NonACRnonContracted'+Math.random()*1000;
        accList.add(nonAcrNonContractedAccount);
        Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonACRContractedAccount.Name = 'Non ACR Contracted Account'+ Math.random()*1000;
        accList.add(nonACRContractedAccount);
        insert accList;
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        //        AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList];//TestUtility.createAccountContactRelation(accList[0],con);
        //        relation.Roles = 'Finance; Invoice Recepient';
        //        update relation;
        
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
        originAddressBook.Pincode_TMS__c = suratPin.Id;
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
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',suratPin.id,'Bengaluru',true);
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        insert ship1;
        
        
        Contract c = new Contract(); 
        c.Name = 'Test Contract'; 
        c.AccountId = accList[0].Id; 
        c.Status = 'Draft'; 
        c.enddate = system.today().adddays(2);
        insert c;
        
        test.stoptest();
        
        /*List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, branches[0]);
quotes[0].Business_Type__c = 'ACR';
quotes[1].Business_Type__c = 'Non ACR';
insert quotes;

List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
quoteLines.addAll(TestUtility.createQuoteLines(quotes[0].Id,customACRPrices,stdACRPrice));
quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[1].Id,customACRPrices,nonAcrPrice));
insert quoteLines;

//List<SBQQ__QuoteLine__c> nonACRQuoteLines = TestUtility.createnonACRQuoteLines(quotes[1].Id,customACRPrices,nonAcrPrice);
//insert nonACRQuoteLines;

List<Order> orderList = TestUtility.createACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
orderList[0].Business_Type__c = 'ACR';
orderList[1].Business_Type__c = 'Non ACR';
insert orderList;
//List<SBQQ__QuoteLine__c> acrQuoteLines = [SELECT ]
List<OrderItem> acrItems = Testutility.createACROrderItems(quoteLines,orderList[0]);
insert acrItems;

Contract cont = TestUtility.createACRContract(orderList[0], branches[0]);
insert cont;
//cont.Status = 'Activated';
//update cont;
Account acrAccount = TestUtility.createACRCustomer(cont, blngAddress[0]);
insert acrAccount;
system.debug('Contract Shipment Trigger Test:::'+acrAccount);
List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(acrItems, cont);
insert subs;*/
    }    
    
    
    @isTest
    static void acrShipmentTestMethod(){
        
        
        List<Account> accList = [select id,Billing_Address__c from Account];
        
        Product2 nonACRprod = [select Id from product2 where ProductCode = 'GOLD-EX-C2C' limit 1];
        
        List<Hub__c> branches = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                                 Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                                 FROM Hub__c ];
               
           
        test.startTest();
        Shipment__c ship = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        ship.Status__c = 'Pending Billing';
        update ship;
        
        External_Contract__c extCon = new External_Contract__c();
        extCon.Customer__c = ship.Bill_To_Account__c;
        extCon.Product__c = nonACRprod.id;
        extCon.Active__c = true;
        extCon.Monthly_Contract__c = false;
        extCon.Filter_By__c = 'Origin Hub';
        insert extCon;
        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalcs = new  List<ShipmentCalcUtil.ShipmentDetail>();
        ShipmentCalcUtil.ShipmentDetail shipCalc = new ShipmentCalcUtil.ShipmentDetail();
        shipCalc.grossWeight = 2000;
        shipCalc.productId = nonACRprod.id;
        shipCalc.accountId = accList[0].id;
        shipCalc.isOriginOfflineLoc = true;
        shipCalc.isDestOfflineLoc = true;
        shipCalc.orderLineItemId = ship.Id;
        shipCalcs.add(shipCalc);        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalculation=ShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        
        
        blng__Invoice__c invoice = TestUtility.createInvoice(accList[0],branches[0],null);
        insert invoice;
        
       /* External_Contract_Shipment_Summary__c ecss = [select Id, Invoice__c from External_Contract_Shipment_Summary__c LIMIT 1];
        ecss.Invoice__c = invoice.Id;
        update ecss;*/
        test.stopTest();          
        
    }     
    
    @isTest
    static void acrShipmentTestMethod1(){
        
        Contract c = [Select id from Contract limit 1];
        
        List<Account> accList = [select id,Billing_Address__c from Account];
        accList[0].ST_Pricing_Type__c = 'Non ACR';
        accList[0].Customer_Category__c = 'Non ACR Contracted';
        accList[0].Active_Contract__c = c.Id;
        update accList;
        
        Product2 nonACRprod = [select Id from product2 where ProductCode = 'GOLD-EX-C2C' limit 1];
        
        List<Hub__c> branches = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                                 Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                                 FROM Hub__c ];
               
           
        test.startTest();
        Shipment__c ship = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        ship.Status__c = 'Pending Billing';
        update ship;
        
        External_Contract__c extCon = new External_Contract__c();
        extCon.Customer__c = ship.Bill_To_Account__c;
        extCon.Product__c = nonACRprod.id;
        extCon.Active__c = true;
        extCon.Monthly_Contract__c = false;
        extCon.Filter_By__c = 'Origin Hub';
        insert extCon;
        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalcs = new  List<ShipmentCalcUtil.ShipmentDetail>();
        ShipmentCalcUtil.ShipmentDetail shipCalc = new ShipmentCalcUtil.ShipmentDetail();
        shipCalc.grossWeight = 2000;
        shipCalc.productId = nonACRprod.id;
        shipCalc.accountId = accList[0].id;
        shipCalc.isOriginOfflineLoc = true;
        shipCalc.isDestOfflineLoc = true;
        shipCalc.orderLineItemId = ship.Id;
        shipCalcs.add(shipCalc);        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalculation=ShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        
        
        blng__Invoice__c invoice = TestUtility.createInvoice(accList[0],branches[0],null);
        insert invoice;
        
      
        test.stopTest();          
        
    }        
       
}