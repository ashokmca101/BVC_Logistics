@isTest
public class ST_ContractTriggerTest {
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
         Active_Pincode__c bengaluruPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert bengaluruPin;
        system.debug('BEngalurur Pin:::'+bengaluruPin);
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
        
        AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList];//TestUtility.createAccountContactRelation(accList[0],con);
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
        
        test.stopTest();
        
    }
    
  @isTest
    static void acrShipmentTestMethod(){
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
       
        
        
        Contract cont = TestUtility.createACRContract(acrOrderList[0], branches[0]);
        try{
             insert cont;
        }catch(Exception ex){
            system.debug('ACR Contract Insert failed>>>'+ex.getMessage());
        }
       
         system.debug('ACR:::Contract:::'+cont.AccountId);
        List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(acrItems, cont);
        insert subs;
        System.debug('ACR:::Subs FROM Test Class::'+subs);
        cont.EndDate = system.today().addDays(45);
        cont.Status = 'Activated';
        update cont;
        
        List<Shipment__c> ship = TestUtility.createnonACRnonContShipment(accList[0], branches, blngAddressList);
        List<Shipment__c> insertShips = new List<Shipment__c>();
        //for(Shipment__c s : ship){
            ship[0].Shipper_Name_TMS__c = originDestinationAdddress[1].Customer__c;
            ship[0].Consignee_Name_TMS__c = originDestinationAdddress[0].Customer__c;
            ship[0].Destination_Address_Name__c =originDestinationAdddress[0].Id;
            ship[0].Origin_Address_Name__c = originDestinationAdddress[1].Id;
        	//ship[0].Gross_Weight__c = 26000;
            ship[0].Origin_Type__c = 'Offline';
            ship[0].Destination_Type__c = 'Offline';
            ship[0].Liability_Cover_By_BVC__c = 'Yes';
            insertShips.add(ship[0]);
            system.debug('Shipment Before Insert: Test Data'+ship[0]);
        //}
        
        insert insertShips[0];
        
       insertShips[0].Origin_Hub__c = branches[0].Id;
        insertShips[0].Shipment_Date__c = system.today();
        insertShips[0].Bill_To_Account__c = cont.AccountId;
        insertShips[0].Destination_Hub__c = branches[1].Id;
        insertShips[0].Gross_Weight__c = 26000;
        insertShips[0].Ready_for_Billing__c = true;
        insertShips[0].Liability_Cover_By_BVC__c = 'Yes';
        insertShips[0].Shipper_Name_TMS__c = insertShips[0].Bill_To_Account__c;
        insertShips[0].Pickup_Time_Date__c = system.now().addDays(2);
        insertShips[0].Consignee_Name_TMS__c = insertShips[0].Bill_To_Account__c;
        insertShips[0].Status__c = 'Verified for Billing';
        
        
        update insertShips;
        //String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new EmailNotificationScheduler());
        Database.executebatch(new EmailNotificationBatch());
        
        test.stopTest();
    }
  
   @isTest 
    static void acrShipmentTestMethod1(){
        
        test.startTest();
        UtilClass.triggerLoop = false;
         List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,
                                                          Pincode_TMS__r.Hub__r.Billing_Entity_Name__c,
                                                         COUNTRY__c,CITY__c,PINCODE__c,Customer__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                         ORDER BY PINCODE__c desc];
        Account acc = [SELECT Id,Billing_Frequency__c,Customer_Category__c,Billing_Address__c FROM Account LIMIT 1];
        system.debug('originDestinationAdddress:::'+originDestinationAdddress);
        List<ST_ACR_Standard_Price__c> acrPrices = [SELECT Id,ST_ACR_Package_Amount__c,ST_ACR_Package_Type__c,ST_Liability_Coverage__c,
                                                         ST_Effective_Start_Date__c,ST_Effective_End_Date__c,ST_Rate_UOM__c,
                                                         ST_Product__c FROM ST_ACR_Standard_Price__c LIMIT 2];
        system.debug('acrPrices:::'+acrPrices);
        Pricebook2 pb = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'BVC INR Price Book'];
        system.debug('PriceBook::'+pb);
        List<PricebookEntry> customACRPrices = [SELECT Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id];
        system.debug('Custom ACR Prices::'+customACRPrices);
        List<AddressBook__c> blngAddressList = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                                PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                                GSTIN__c FROM AddressBook__c LIMIT 3];
        system.debug('BlngAddressList:::'+blngAddressList);
        AddressBook__c blngAddress = blngAddressList[0];
        List<Hub__c> branch = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                               Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                               FROM Hub__c ];
        system.debug('ACR:::BVC Branch:::'+branch);
        List<Opportunity> oppList = [SELECT Id,AccountId FROm Opportunity WHERE AccountId = :acc.Id];
        
        List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, branch[0]);
        insert quotes;
        system.debug('ACR:::Quotes>>>'+quotes);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createQuoteLines(quotes[0].Id,customACRPrices,acrPrices));
        //quoteLines.addAll(TestUtility.createQuoteLines(quotes[1].Id,customACRPrices,acrPrices));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> acrOrderList = TestUtility.createACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
        acrOrderList[0].blng__BillingDayOfMonth__c = '1';
        insert acrOrderList;
         system.debug('ACR:::Orders:::'+acrOrderList);
        List<OrderItem> acrItems = Testutility.createACROrderItems(quoteLines, acrOrderList[0]);
        insert acrItems;
        
        
        
        Contract cont = TestUtility.createACRContract(acrOrderList[0], branch[0]);
        try{
             insert cont;
        }catch(Exception ex){
            system.debug('ACR Contract Insert failed>>>'+ex.getMessage());
        }
       
         system.debug('ACR:::Contract:::'+cont.AccountId);
        List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(acrItems, cont);
        insert subs;
        System.debug('ACR:::Subs FROM Test Class::'+subs);
        cont.EndDate = system.today().addDays(45);
        cont.Status = 'Activated';
        update cont;
       
         List<Shipment__c> ship = TestUtility.createnonACRnonContShipment(acc, branch, blngAddressList);
        List<Shipment__c> insertShips = new List<Shipment__c>();
        ship[0].Shipper_Name_TMS__c = originDestinationAdddress[1].Customer__c;
            ship[0].Consignee_Name_TMS__c = originDestinationAdddress[0].Customer__c;
            ship[0].Destination_Address_Name__c =originDestinationAdddress[0].Id;
            ship[0].Origin_Address_Name__c = originDestinationAdddress[1].Id;
            ship[0].Origin_Type__c = 'Offline';
            ship[0].Destination_Type__c = 'Offline';
            system.debug('Shipment Before Insert: Test Data'+ship[0]);
       
        
        insert ship[0];
       
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                      Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                      Destination_Address_City__c,Origin_Address_City__c,
                                      Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        system.debug('ACR Contract :Shipment::Test::Class::'+shipList[0].Bill_To_Account__r.Billing_Frequency__c);
        system.debug('Destination City [0]: '+ shipList[0].Destination_Address_City__c + 'OriginCity [0] : ' +shipList[0].Origin_Address_City__c+ 'Active_contract__c : '+shipList[0].Bill_To_Account__r.Active_contract__c);
        shipList[0].Origin_Hub__c = branch[0].Id;
        shipList[0].Shipment_Date__c = system.today();
        shipList[0].Bill_To_Account__c = cont.AccountId;
        shipList[0].Destination_Hub__c = branch[1].Id;
        shipList[0].Ready_for_Billing__c = true;
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        shipList[0].Shipper_Name_TMS__c = shipList[0].Bill_To_Account__c;
        //shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        shipList[0].Consignee_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Status__c = 'Verified for Billing';
        
        
        update shipList;
        
        
         ACR_Adjustment__c adj = new ACR_Adjustment__c( Name = 'CarryforwardAdjustment1',
                                                     Account__c = cont.AccountId,
                                                     Contract__c = cont.Id,
                                                     Adjustment_Amount__c = 5000,
                                                     Adjustment_Type__c = 'Carry Forward');
        insert adj;
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new EmailNotificationScheduler());
        Database.executebatch(new EmailNotificationBatch());
        
        test.stopTest();
    }
    @isTest
    static void nonACRContractedShipmentTestMethod(){
        test.startTest();
        List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,Customer__c,
                                                          COUNTRY__c,CITY__c,PINCODE__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                          ORDER BY PINCODE__c desc];
        Account acc = [SELECT Id,Billing_Frequency__c,Customer_Category__c,Billing_Address__c FROM Account LIMIT 1];
        
        List<ST_NonACR_Standard_Price__c> nonAcrPrice = [SELECT Id,ST_Product_Code__c,ST_Gross_Weight_Slabs__c,ST_Origin__c,ST_Destination__c,
                                                         ST_Effective_Start_Date__c,ST_Effective_End_Date__c,ST_Rate_UOM__c,
                                                         ST_Product__c FROM ST_NonACR_Standard_Price__c LIMIT 2];
        system.debug('nonAcrPrice:::'+nonAcrPrice);
        Pricebook2 pb = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'BVC INR Price Book'];
        system.debug('PriceBook::'+pb);
        List<PricebookEntry> customACRPrices = [SELECT Id,Product2Id,ProductCode FROM PricebookEntry WHERE Pricebook2Id = :pb.Id AND ProductCode ='GOLD-EX-C2C'];
        system.debug('Custom ACR Prices::Non ACR::'+customACRPrices);
        List<AddressBook__c> blngAddressList = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                     PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                     GSTIN__c FROM AddressBook__c LIMIT 3];
        system.debug('BlngAddressList:::'+blngAddressList);
        AddressBook__c blngAddress = blngAddressList[0];
        List<Hub__c> branch = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                               Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                               FROM Hub__c ];
        List<Opportunity> oppList = [SELECT Id,AccountId FROm Opportunity];
        
        List<SBQQ__Quote__c> quotes = TestUtility.createnonACRQuote(pb.Id, oppList, branch[0]);
        quotes[0].Business_Type__c = 'Non ACR';
        quotes[1].Business_Type__c = 'Non ACR';
        insert quotes;
        system.debug('Quotes>>>'+quotes);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice[0]));
        //quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[1].Id,customACRPrices,nonAcrPrice[0]));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> nonACROrderList = TestUtility.createNonACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
        insert nonACROrderList;
        
        List<OrderItem> nonACRItems = Testutility.createNonACROrderItems(quoteLines, nonACROrderList[0]);
        insert nonACRItems;
        
        Contract cont = TestUtility.createNonACRContract(nonACROrderList[0], branch[0]);
        insert cont;
        
        List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(nonACRItems, cont);
        insert subs;
        try{
            cont.Status = 'Activated';
        update cont;
        system.debug('Contract:::'+cont);
        }catch(Exception ex){
            system.debug('Non Acr Contracted Failed'+ex.getMessage());
        }
        
        system.debug('Sybscriptionss:::'+subs);
        List<Shipment__c> ship = TestUtility.createnonACRnonContShipment(acc, branch, blngAddressList);
        List<Shipment__c> insertShips = new List<Shipment__c>();
        for(Shipment__c s : ship){
            s.Shipper_Name_TMS__c = originDestinationAdddress[1].Customer__c;
            s.Consignee_Name_TMS__c = originDestinationAdddress[0].Customer__c;
            s.Destination_Address_Name__c =originDestinationAdddress[0].Id;
            s.Origin_Address_Name__c = originDestinationAdddress[1].Id;
            s.Origin_Type__c = 'Offline';
            s.Destination_Type__c = 'Offline';
            insertShips.add(s);
            system.debug('Shipment Before Insert: Test Data'+s);
        }
        
        insert insertShips;
       
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                      Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                      Destination_Address_City__c,Origin_Address_City__c,
                                      Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 3];
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList[0].Destination_Address_City__c + 'OriginCity [0] : ' +shipList[0].Origin_Address_City__c+ 'Active_contract__c : '+shipList[0].Bill_To_Account__r.Active_contract__c);
        system.debug('Destination City [1]: '+ shipList[1].Destination_Address_City__c + 'OriginCity [1] : ' +shipList[1].Origin_Address_City__c+ 'Active_contract__c : '+shipList[1].Bill_To_Account__r.Active_contract__c);   
        system.debug('Destination City [2]: '+ shipList[2].Destination_Address_City__c + 'OriginCity [2] : ' +shipList[2].Origin_Address_City__c+ 'Active_contract__c : '+shipList[2].Bill_To_Account__r.Active_contract__c);   
        shipList[0].Origin_Hub__c = branch[0].Id;
        shipList[0].Bill_To_Account__c = cont.AccountId;
        shipList[0].Destination_Hub__c = branch[1].Id;
        //shipList[0].Ready_for_Billing__c = true;
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        shipList[0].Shipper_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        shipList[0].Consignee_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Status__c = 'Verified for Billing';
        
        
        shipList[1].Product_Code__c = 'VAL-SS';
        shipList[1].Origin_Hub__c = branch[0].Id;
        shipList[1].Bill_To_Account__c = cont.AccountId;
        shipList[1].Destination_Hub__c = branch[1].Id;
        shipList[1].Ready_for_Billing__c = true;
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Status__c = 'Verified for Billing';
        update shipList;
        test.stopTest();
    }
     @isTest
    static void nonACRContractedShipmentTestMethod1(){
        test.startTest();
        List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,Customer__c,
                                                          COUNTRY__c,CITY__c,PINCODE__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                          ORDER BY PINCODE__c desc];
        Account acc = [SELECT Id,Billing_Frequency__c,Customer_Category__c,Billing_Address__c FROM Account LIMIT 1];
        
        List<ST_NonACR_Standard_Price__c> nonAcrPrice = [SELECT Id,ST_Product_Code__c,ST_Gross_Weight_Slabs__c,ST_Origin__c,ST_Destination__c,
                                                         ST_Effective_Start_Date__c,ST_Effective_End_Date__c,ST_Rate_UOM__c,
                                                         ST_Product__c FROM ST_NonACR_Standard_Price__c LIMIT 2];
        system.debug('nonAcrPrice:::'+nonAcrPrice);
        Pricebook2 pb = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'BVC INR Price Book'];
        system.debug('PriceBook::'+pb);
        List<PricebookEntry> customACRPrices = [SELECT Id,Product2Id,ProductCode FROM PricebookEntry WHERE Pricebook2Id = :pb.Id AND ProductCode ='GOLD-EX-C2C'];
        system.debug('Custom ACR Prices::Non ACR::'+customACRPrices);
        List<AddressBook__c> blngAddressList = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                     PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                     GSTIN__c FROM AddressBook__c LIMIT 3];
        system.debug('BlngAddressList:::'+blngAddressList);
        AddressBook__c blngAddress = blngAddressList[0];
        List<Hub__c> branch = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                               Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                               FROM Hub__c ];
        List<Opportunity> oppList = [SELECT Id,AccountId FROm Opportunity];
        
        List<SBQQ__Quote__c> quotes = TestUtility.createnonACRQuote(pb.Id, oppList, branch[0]);
        quotes[0].Business_Type__c = 'Non ACR';
        quotes[1].Business_Type__c = 'Non ACR';
        insert quotes;
        system.debug('Quotes>>>'+quotes);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[0].Id,customACRPrices,nonAcrPrice[0]));
        //quoteLines.addAll(TestUtility.createnonACRQuoteLines(quotes[1].Id,customACRPrices,nonAcrPrice[0]));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> nonACROrderList = TestUtility.createNonACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
        insert nonACROrderList;
        
        List<OrderItem> nonACRItems = Testutility.createNonACROrderItems(quoteLines, nonACROrderList[0]);
        insert nonACRItems;
        
        Contract cont = TestUtility.createNonACRContract(nonACROrderList[0], branch[0]);
        cont.StartDate =  system.today().addDays(2);
        insert cont;
        
        List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(nonACRItems, cont);
        insert subs;
        
        cont.Status = 'Activated';
        //cont.StartDate = system.today().addDays(2);
        update cont;
        system.debug('Contract:::'+cont);
        system.debug('Sybscriptionss:::'+subs);
        List<Shipment__c> ship = TestUtility.createnonACRnonContShipment(acc, branch, blngAddressList);
        List<Shipment__c> insertShips = new List<Shipment__c>();
        for(Shipment__c s : ship){
            s.Shipper_Name_TMS__c = originDestinationAdddress[1].Customer__c;
            s.Consignee_Name_TMS__c = originDestinationAdddress[0].Customer__c;
            s.Destination_Address_Name__c =originDestinationAdddress[0].Id;
            s.Origin_Address_Name__c = originDestinationAdddress[1].Id;
            s.Origin_Type__c = 'Offline';
            s.Destination_Type__c = 'Offline';
            insertShips.add(s);
            system.debug('Shipment Before Insert: Test Data'+s);
        }
        
        insert insertShips;
       
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                      Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                      Destination_Address_City__c,Origin_Address_City__c,
                                      Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 3];
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList[0].Destination_Address_City__c + 'OriginCity [0] : ' +shipList[0].Origin_Address_City__c+ 'Active_contract__c : '+shipList[0].Bill_To_Account__r.Active_contract__c);
        system.debug('Destination City [1]: '+ shipList[1].Destination_Address_City__c + 'OriginCity [1] : ' +shipList[1].Origin_Address_City__c+ 'Active_contract__c : '+shipList[1].Bill_To_Account__r.Active_contract__c);   
        system.debug('Destination City [2]: '+ shipList[2].Destination_Address_City__c + 'OriginCity [2] : ' +shipList[2].Origin_Address_City__c+ 'Active_contract__c : '+shipList[2].Bill_To_Account__r.Active_contract__c);   
        shipList[0].Origin_Hub__c = branch[0].Id;
        shipList[0].Bill_To_Account__c = cont.AccountId;
        shipList[0].Destination_Hub__c = branch[1].Id;
        shipList[0].Ready_for_Billing__c = true;
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        shipList[0].Shipper_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        shipList[0].Consignee_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Status__c = 'Verified for Billing';
        
        
        shipList[1].Product_Code__c = 'VAL-SS';
        shipList[1].Origin_Hub__c = branch[0].Id;
        shipList[1].Bill_To_Account__c = cont.AccountId;
        shipList[1].Destination_Hub__c = branch[1].Id;
        shipList[1].Ready_for_Billing__c = true;
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Status__c = 'Verified for Billing';
        update shipList;
        test.stopTest();
    }
    @isTest
    static void nonACRnonContractedShipmentTestMethod(){
        test.startTest();
         Account acc = [SELECT Id,Billing_Frequency__c,Customer_Category__c,Billing_Address__c FROM Account LIMIT 1];
         List<AddressBook__c> blngAddressList = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                     PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                     GSTIN__c FROM AddressBook__c LIMIT 3];
         List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,Customer__c,
                                                          COUNTRY__c,CITY__c,PINCODE__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                          ORDER BY PINCODE__c asc];
        system.debug('BlngAddressList:::Non Contracted'+blngAddressList);
        List<Hub__c> branch = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                               Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                               FROM Hub__c ];
        system.debug('BVC Branch:::'+branch);
        List<Shipment__c> shipList = TestUtility.createnonACRnonContShipment(acc, branch, blngAddressList);
        List<Shipment__c> insertShips = new List<Shipment__c>();
        for(Shipment__c s : shipList){
            s.Shipper_Name_TMS__c = originDestinationAdddress[1].Customer__c;
            s.Consignee_Name_TMS__c = originDestinationAdddress[0].Customer__c;
            s.Destination_Address_Name__c =originDestinationAdddress[0].Id;
            s.Origin_Address_Name__c = originDestinationAdddress[1].Id;
            insertShips.add(s);
            system.debug('Shipment Before Insert: Test Data'+s);
        }
        
        insert insertShips;
        Shipment__c ship = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                            Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                            Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                            Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        system.debug('Shipment Non ACR Non Contracted::Test::Class::'+ship.Bill_To_Account__r.Name);
         ship.Origin_Hub__c = branch[0].Id;
        ship.Destination_Hub__c = branch[1].Id;
        ship.Ready_for_Billing__c = true;
        ship.Liability_Cover_By_BVC__c = 'Yes';
        ship.Status__c = 'Verified for Billing';
        ship.Origin_Type__c = 'Offline';
        ship.Destination_Type__c = 'Offline';
            
        update ship;
        test.stopTest();
        
    }

}