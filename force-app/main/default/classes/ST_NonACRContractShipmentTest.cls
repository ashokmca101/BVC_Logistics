@isTest
public with sharing class ST_NonACRContractShipmentTest {
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
        Active_Pincode__c bengaluruPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert bengaluruPin;
        system.debug('BEngalurur Pin:::'+bengaluruPin);
        system.debug('Branches::Test Setup::'+branches);
        blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        
        List<Product2> prodList = new List<Product2>();
        //Product2 prod = TestUtility.createACRProduct(bRule, revRule, taxRule);
        //prodList.add(prod);
        
        
        Product2 optionProduct = TestUtility.createProduct(bRule, revRule, taxRule);
        prodList.add(optionProduct);
        
        Product2 valProduct = TestUtility.createValProduct(bRule, revRule, taxRule);
        prodList.add(valProduct);
        
        Product2 exbproduct = TestUtility.createExhibiProduct(bRule, revRule, taxRule);
        insert exbproduct;
        insert prodList;
        
        SBQQ__ProductOption__c prodOption = TestUtility.createProductOption(prodList[0], prodList[1]);
        insert prodOption;
        Id stdPriceBookId = Test.getStandardPricebookId();
        Pricebook2 pb = TestUtility.createPriceBook();
        insert pb;
        
        //PricebookEntry standardACRPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[0].Id, UnitPrice = 1000, IsActive = true);
        //insert standardACRPBE;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[0].Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry standarValdPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[1].Id, UnitPrice = 1000, IsActive = true);
        insert standarValdPBE;
        
        List<Account> accList = new List<Account>();
        
        Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonACRContractedAccount.Name = 'Non ACR Contracted Account';
        nonACRContractedAccount.Last_Name__c = 'test Account';//added last name
        accList.add(nonACRContractedAccount);
        
        
        
        Account acc = new Account();
        acc.name ='CB Account';
        acc.Last_Name__c = 'test Account';
        acc.ST_Pricing_Type__c ='Non ACR';
        acc.Billing_Frequency__c='Shipment';
        accList.add(acc);
        
        insert accList;
        
        Contact con = TestUtility.createContact(accList[0]);
        insert con;
        
        AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList LIMIT 1];//TestUtility.createAccountContactRelation(accList[0],con);
        relation.Roles = 'Finance; Invoice Recepient';
        update relation;
        
        List<Opportunity> oppList1 = TestUtility.createOpportunity(accList,con,ent);
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(oppList1[0]);
        insert oppList;
        
        List<PricebookEntry> customACRPrices = TestUtility.createACRPricebookEntry(pb.Id,prodList);
        insert customACRPrices;
        
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        AddressBook__c destiAddressBook = TestUtility.destinationAddress(accList[0]);
        AddressBook__c originAddressBook = TestUtility.originAddress(accList[0]);
        originAddressBook.Pincode_TMS__c = bengaluruPin.Id;
        originAddressBook.Name = 'Line 1';
        destiAddressBook.Name = 'Desti 1';
        blngAddress.add(destiAddressBook);
        blngAddress.add(originAddressBook);
        insert blngAddress;
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Is_Finance_Contact_Present__c = true;
        accList[0].Primary_Address__c = blngAddress[0].Id;
        update accList[0];
        //update accList[0];
        
        
        List<ST_NonACR_Standard_Price__c> nonACRPriceList = new List<ST_NonACR_Standard_Price__c>();
        ST_NonACR_Standard_Price__c nonAcrPrice1 = TestUtility.createNONACRStandardPrice(prodList[0]);
        //nonACRPriceList.add(nonAcrPrice1);
        
        ST_NonACR_Standard_Price__c nonAcrPrice2 = TestUtility.createNONACRStandardPrice(prodList[1]);
        nonAcrPrice2.ST_Destination__c = 'Bengaluru';
        nonAcrPrice2.ST_Origin__c = 'Mumbai';
        nonAcrPrice2.ST_Freight_on_Invoice_Value__c = 0.01;
        nonACRPrice2.ST_Gross_Weight_Slabs__c = '';
        nonACRPriceList.add(nonAcrPrice2);
        insert nonACRPriceList;
        
        List<SBQQ__Quote__c> quotes1 = TestUtility.createnonACRQuote(pb.Id, oppList, branches[0]);
        quotes1[0].Business_Type__c = 'Non ACR';
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(quotes1[0]);
        //quotes[1].Business_Type__c = 'Non ACR';
        insert quotes;
        test.startTest();
        system.debug('Quotes>>>'+quotes);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonACRPriceList[0]));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> nonACROrderList = TestUtility.createNonACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
        insert nonACROrderList;
        
        List<OrderItem> nonACRItems = Testutility.createNonACROrderItems(quoteLines, nonACROrderList[0]);
        insert nonACRItems;
        
        Contract cont = TestUtility.createNonACRContract(nonACROrderList[0], branches[0]);
        cont.StartDate =  system.today().addDays(2);
        insert cont;
        
        List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(nonACRItems, cont);
        insert subs;
        
        cont.Status = 'Activated';
        //cont.StartDate = system.today().addDays(2);
        update cont;
        
        Account shipperAccount = TestUtility.createShipperAccount();
        shipperAccount.Name = 'Non ACR Contracted Account';
        shipperAccount.Last_Name__c = 'test Account';//added last name
        insert shipperAccount;
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',bengaluruPin.id,'Bengaluru',true);
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        insert ship1;
        
        test.stopTest();
        
    }
    
    @isTest
    static void misfitNonACRContractedShipmentTestMethod(){
        test.startTest();
        //sam
        ExhibitionShipmentCalcUtil.f1Method();
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        ShipmentCalcUtil.fMethod();
        ShipmentCalcUtil.fgMethod();
        OrderCreateShipment.Method2();
        
        acc1.Name = 'NonACR Account';
        acc1.Last_Name__c = 'Test account';
        
        insert acc1;
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exempt.New_Offline_Charge__c=200;
        exemptlist.add(exempt);
        insert exemptlist;
        
        delete [SELECT Id FROM ST_NonACR_Contracted_Price__c];
        Contract cont = [SELECT Id,AccountId FROM Contract LIMIT 1];
        Product2 gold = [SELECT Id FROM Product2 WHERE ProductCode = 'GOLD-EX-C2C' LIMIT 1];
        List<ST_NonACR_Contracted_Price__c> misfitPrices = TestUtility.createMisfitNonACRPriceTable(cont.AccountId, cont.Id,gold.Id);
        insert misfitPrices;
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        update shipList;
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        // PlatformUserBatch pu = new PlatformUserBatch(ids);
        //pu.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest();
    }
    
    @isTest
    static void stdNonACRContractedShipmentTestMethod(){
        test.startTest();
        //sam
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        acc1.Name = 'NonAcr Account';
        acc1.Last_Name__c = ' test account';
        
        insert acc1;
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='Mul'; 
        exempt.New_Offline_Charge__c=200;
        exemptlist.add(exempt);
        insert exemptlist;
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        shipList.Status__c = 'Pending Billing';
        update shipList;
        
        
        shipList.Liability_Cover_By_BVC__c = 'Yes';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        shipList.Next_Billing_Date__c = system.today().adddays(3);
        shipList.Pickup_Time_Date__c = system.now().addDays(2);
        shipList.Status__c = 'Verified for Billing';
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(ships);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        } 
        test.stopTest();
    }
    
    @isTest
    static void nonACRContractedShipmentTestMethod1(){
        test.startTest();
        
        //sam
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        
        acc1.Name = 'NonAcr Account';
        acc1.Last_Name__c = ' test account';
        
        insert acc1;
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exempt.New_Offline_Charge__c=200;
        exemptlist.add(exempt);
        insert exemptlist;
        
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'VAL-SS';
        //shipList.Origin_Type__c = 'Offline';
        //shipList.Window_Pickup__c = false;
        update shipList;
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        } 
        test.stopTest();
    }
    
    @isTest
    static void misfitNonACRContractedShipmentTestMethod1(){
        test.startTest();
        Account acc1 = [select Id,Name from Account where Name ='Non ACR Contracted Account' LIMIT 1];
        
        
        delete [SELECT Id FROM ST_NonACR_Contracted_Price__c];
        Contract cont = [SELECT Id,AccountId FROM Contract LIMIT 1];
        Product2 gold = [SELECT Id FROM Product2 WHERE ProductCode = 'GOLD-EX-C2C' LIMIT 1];
        List<ST_NonACR_Contracted_Price__c> misfitPrices = TestUtility.createMisfitNonACRPriceTable(cont.AccountId, cont.Id,gold.Id);
        insert misfitPrices;
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        shipList.Destination_Type__c  = 'Offline';
        shipList.Window_Delivery__c = false;
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c = false;
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        PlatformUserBatch pu = new PlatformUserBatch(ids);
        pu.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    @isTest
    static void misfitNonACRContractedShipmentTestMethodone(){
        test.startTest();
        Account acc1 = [select Id,Name from Account where Name ='Non ACR Contracted Account' LIMIT 1];
        
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        shipList.Destination_Type__c  = 'Offline';
        shipList.Window_Delivery__c = false;
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c = false;
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    
    
    
    
    @isTest
    static void misfitNonACRContractedShipmentTestMethod2(){
        test.startTest();
        Account acc1 = [select Id,Name from Account where Name ='Non ACR Contracted Account' LIMIT 1];
        OrderCreateShipment.Method2();
        
        delete [SELECT Id FROM ST_NonACR_Contracted_Price__c];
        Contract cont = [SELECT Id,AccountId FROM Contract LIMIT 1];
        Product2 gold = [SELECT Id FROM Product2 WHERE ProductCode = 'GOLD-EX-C2C' LIMIT 1];
        List<ST_NonACR_Contracted_Price__c> misfitPrices = TestUtility.createMisfitNonACRPriceTable(cont.AccountId, cont.Id,gold.Id);
        insert misfitPrices;
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        shipList.Destination_Type__c  = 'Offline';
        shipList.Window_Delivery__c = true;
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c = false;
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        PlatformUserBatch pu = new PlatformUserBatch(ids);
        pu.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    
    @isTest
    static void misfitNonACRContractedShipmentTestMethodtwo(){
        test.startTest();
        Account acc1 = [select Id,Name from Account where Name ='Non ACR Contracted Account' LIMIT 1];
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        shipList.Destination_Type__c  = 'Offline';
        shipList.Window_Delivery__c = true;
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c = false;
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    @isTest
    static void misfitNonACRContractedShipmentTestMethod3(){
        test.startTest();
        Account acc1 = [select Id,Name from Account where Name ='Non ACR Contracted Account' LIMIT 1];
        
        delete [SELECT Id FROM ST_NonACR_Contracted_Price__c];
        Contract cont = [SELECT Id,AccountId FROM Contract LIMIT 1];
        Product2 gold = [SELECT Id FROM Product2 WHERE ProductCode = 'GOLD-EX-C2C' LIMIT 1];
        List<ST_NonACR_Contracted_Price__c> misfitPrices = TestUtility.createMisfitNonACRPriceTable(cont.AccountId, cont.Id,gold.Id);
        insert misfitPrices;
        
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        shipList.Destination_Type__c  = 'Offline';
        shipList.Window_Delivery__c = false;
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c = true;
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    
    @isTest
    static void misfitNonACRContractedShipmentTestMethodthree(){
        test.startTest();
        Account acc1 = [select Id,Name from Account where Name ='Non ACR Contracted Account' LIMIT 1];
        
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        shipList.Destination_Type__c  = 'Offline';
        shipList.Window_Delivery__c = false;
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c = true;
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    
    
    @isTest
    static void misfitNonACRContractedShipmentTestMethod4(){
        test.startTest();
        Product2 exb = [SELECT Id,name FROM Product2 WHERE ProductCode = 'EXHIBI-S-C2C' LIMIT 1];
        ST_NonACR_Standard_Price__c stdprice = TestUtility.nonACRStdPrice(exb);
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        update shipList;
        
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'EXHIBI-S-C2C';
        update shipList;
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }  
        test.stopTest(); 
    }
    
    @isTest
    static void stdNonACRContractedShipmentTestMethod1(){
        test.startTest();
        
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        
        acc1.Name = 'NonAcr Account';
        acc1.Last_Name__c = ' test account';
        insert acc1;        
        blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        
        list<Product2>prd = new list<Product2>();
        Product2 exbproduct1 = TestUtility.createProduct(bRule, revRule, taxRule);
        //insert exbproduct1;
        prd.add(exbproduct1);
        insert prd;
        
        ST_NonACR_Standard_Price__c nonAcrPrice3 = TestUtility.createNONACRStandardPrice(prd[0]);
        nonAcrPrice3.ST_Origin__c =null;
        nonAcrPrice3.ST_Product__c =null;
        nonAcrPrice3.ST_Destination__c =null;
        nonAcrPrice3.ST_Min_Gross_Weight__c =0;
        nonAcrPrice3.ST_Max_Gross_Weight__c =0;
        nonAcrPrice3.ST_Exhibition__c =null;
        nonAcrPrice3.ST_Effective_Start_Date__c =system.today().addDays(-2);
        nonAcrPrice3.ST_Effective_End_Date__c = system.today().addDays(364);
        insert nonAcrPrice3;
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c,BVC_Product_Name__c FROM Shipment__c LIMIT 1];
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        shipList.Status__c = 'Pending Billing';
        update shipList;
        shipList.Product_Code__c = 'VAL-SS';
        shipList.Origin_Type__c = 'Offline';
        shipList.Window_Pickup__c =false;
        shipList.Status__c = 'Verified for Billing';
        
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        insert exempt;
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{shipList.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(ships);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        

        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        } 
        test.stopTest();
    }
    
    
    
    
}