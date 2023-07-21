@isTest
public class ST_ACRContractShipmentTest {
    public static String CRON_EXP = '0 0 0 24 7 ? 2023';
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
        
        Account acrNonContractedAccount = TestUtility.createACRnonContractedAccount();
        acrNonContractedAccount.Name='ACR Account';
        acrNoncontractedAccount.Last_Name__c = 'test account';
        accList.add(acrNonContractedAccount);
        /*Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
accList.add(nonAcrNonContractedAccount);
Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
nonACRContractedAccount.Name = 'Non ACR Contracted Account';
accList.add(nonACRContractedAccount);*/
        insert accList;
        
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList limit 1];//TestUtility.createAccountContactRelation(accList[0],con);
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
        
        // Product2 exb = TestUtility.createExhibiProduct(bRule, revRule, taxRule);
        // insert exb;
        
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
        originAddressBook.Pincode_TMS__c = pin.Id;
        originAddressBook.Pincode_TMS__c = bengaluruPin.Id;
        blngAddress.add(destiAddressBook);
        blngAddress.add(originAddressBook);
        insert blngAddress;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u;
        accList[0].Sales_Secondary_Owner__c = u.id;
        accList[0].Customer_Category_Static__c = 'ACR';
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
        
        List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, branches[0]);
        insert quotes;
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.addAll(TestUtility.createQuoteLines(quotes[0].Id,customACRPrices,stdACRPrice));
        quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> acrOrderList = TestUtility.createACROrder(quotes, quotes[0].SBQQ__PricebookId__c);
        acrOrderList[0].blng__BillingDayOfMonth__c = '1';
        insert acrOrderList;
        test.stopTest();
        List<OrderItem> acrItems = Testutility.createACROrderItems(quoteLines, acrOrderList[0]);
        insert acrItems;
        // List<OrderItem> acrItemsDraft = Testutility.createACROrderItems(quoteLines, acrOrderList[1]);
        //insert acrItemsDraft;
        
        
        Contract cont = TestUtility.createACRContract(acrOrderList[0], branches[0]);
        try{
            insert cont;
        }catch(Exception ex){
            system.debug('ACR Contract Insert failed>>>'+ex.getMessage());
        }
        
        
        List<SBQQ__Subscription__c> subs = TestUtility.createACRSubscription(acrItems, cont);
        insert subs;
        cont.EndDate = system.today().addDays(45);
        cont.Status = 'Activated';
        try{
            update cont;
        }catch(Exception ex){
            System.debug('Activation Failed : '+ex.getMessage());
        }
        
        
        //accList[0].Active_Contract__c = cont.Id;
        //update accList[0];
        
        
        
        Account shipperAccount = TestUtility.createShipperAccount();
        shipperAccount.Name='acr contract';
        shipperAccount.Last_Name__c = 'test account';
        insert shipperAccount;
        Product2 valProduct1 = TestUtility.createValProduct(bRule, revRule, taxRule);
        insert valProduct1;
        //List<ST_NonACR_Contracted_Price__c > misFitPrices = TestUtility.createMisfitNonACRPriceTable (cont.AccountId, cont.Id, valProduct1.Id);
        //insert misFitPrices;
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',bengaluruPin.id,'Bengaluru',false);
        shipperAddress.STATE__c = 'Karnataka';
        shipperAddress.COUNTRY__c = 'India';
        insert shipperAddress;
        List<Shipment__c> shipList = new List<Shipment__c>();
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        shipList.add(ship1);
        Shipment__c ship2 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship2.Shipment_Date__c = system.today();
        ship2.Gross_Weight__c = 5000;
        shipList.add(ship2);
        
        insert shipList;
        
        
    }
    @isTest 
    static void acrShipmentTestMethod1(){
        test.startTest();
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont); 
        delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        system.debug('Standard Prices : '+[SELECT Id,ST_Product__r.ProductCode FROM ST_ACR_Standard_Price__c]);        
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                      Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                      Destination_Address_City__c,Origin_Address_City__c,
                                      Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 3];
        system.debug('ACR Contract :Shipment::Test::Class::'+shipList[0].Bill_To_Account__r.Billing_Frequency__c);
        system.debug('Destination City [0]: '+ shipList[0].Destination_Address_City__c + 'OriginCity [0] : ' +shipList[0].Origin_Address_City__c+ 'Active_contract__c : '+shipList[0].Bill_To_Account__r.Active_contract__c);
        
        
        //shipList[0].Origin_Hub__c = branch[0].Id;
        shipList[0].Shipment_Date__c = system.today();
        //shipList[0].Bill_To_Account__c = cont.AccountId;
        //shipList[0].Destination_Hub__c = branch[1].Id;
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        shipList[0].Product_Code__c = 'GOLD-EX-C2C';
        //shipList[0].Shipper_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        //shipList[0].Consignee_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Status__c = 'Verified for Billing';
        
        //shipList[1].Origin_Hub__c = branch[0].Id;
        //shipList[1].Bill_To_Account__c = cont.AccountId;
        shipList[1].Shipment_Date__c = system.today();
        //shipList[1].Destination_Hub__c = branch[1].Id;
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Product_Code__c = 'VAL-EX-C2C';
        // shipList[1].Shipper_Name_TMS__c = shipList[1].Bill_To_Account__c;
        shipList[1].Pickup_Time_Date__c = system.now().addDays(2);
        //shipList[1].Consignee_Name_TMS__c = shipList[1].Bill_To_Account__c;
        shipList[1].Status__c = 'Verified for Billing';
        
        try{
            update shipList[0];
        }catch(Exception Ex){
            system.debug('Insert Ships::ACR SHipment Method1::Failed::'+Ex.getMessage());
        }
        
        //update shipList;
        //String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new EmailNotificationScheduler());
        Database.executebatch(new EmailNotificationBatch());
        
        test.stopTest();
    }
    
    @isTest
    static void stdACRShipmentTestMethod(){
        test.startTest();
        
        
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont); 
        //delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        system.debug('Standard Prices : '+[SELECT Id,ST_Product__r.ProductCode FROM ST_ACR_Standard_Price__c]);
        
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                      Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                      Destination_Address_City__c,Origin_Address_City__c,
                                      Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 2];
        shipList[0].Status__c = 'Pending Billing';
        shipList[1].Status__c = 'Pending Billing';
        update shipList;
        system.debug('Insert Ships::ACR SHipment Method::'+shipList);
        
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        //shipList[0].Shipper_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        //shipList[0].Consignee_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Product_Code__c = 'GOLD-EX-C2C';
        shipList[0].Origin_Type__c = 'Offline';
        shipList[0].Shipment_Value__c  = 10000;
        shipList[0].Status__c = 'Verified for Billing';
        
        
        shipList[1].Product_Code__c = 'VAL-SS';
        shipList[1].Shipment_Value__c  = 20000;
        
        shipList[1].Ready_for_Billing__c = true;
        shipList[1].Destination_Type__c = 'Offline';
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Status__c = 'Verified for Billing';
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Acr Contracted Shipment Failed:'+ex.getMessage());
        } 
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }    
        Set<Id> ids = new Set<Id>{shipList[0].Id,shipList[1].Id};
            //system.debug('Prod category :'+shipList[0].Customer_Product_Category__c);
            //system.debug('Prod category :'+shipList[1].Customer_Product_Category__c);
            string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id IN (\''+shipList[0].Id+'\',\''+shipList[1].Id+'\')';
        List<Shipment__c> ships = Database.query(query);
        
        List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        
        test.stopTest();
        OrderTriggerHandler.fakeMethod1();
    }
    
    @isTest
    static void acrMisfitShipmentTestMethod(){
        test.startTest();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont);
        List<Product2> prodListGold = [Select id,ProductCode from Product2 where ProductCode = 'GOLD-EX-C2C'];
        system.debug('Products : > '+prodListGold);
        delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        List<ST_ACR_Contracted_Price__c > misFitPrices = TestUtility.createMisfitACRPriceTable (cont.AccountId, cont.Id, prodListGold[0].Id);
        insert misFitPrices;
        system.debug('misFitPrices : >'+misFitPrices);
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                      Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                      Destination_Address_City__c,Origin_Address_City__c,
                                      Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 2];
        shipList[0].Status__c = 'Pending Billing';
        shipList[1].Status__c = 'Pending Billing';
        update shipList;
        system.debug('Insert Ships::ACR SHipment Method::'+shipList);
        
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        //shipList[0].Shipper_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        //shipList[0].Consignee_Name_TMS__c = shipList[0].Bill_To_Account__c;
        shipList[0].Product_Code__c = 'GOLD-EX-C2C';
        shipList[0].Origin_Type__c = 'Offline';
        shipList[0].Shipment_Value__c  = 10000;
        shipList[0].Status__c = 'Verified for Billing';
        
        
        shipList[1].Product_Code__c = 'VAL-SS';
        shipList[1].Shipment_Value__c  = 20000;
        
        shipList[1].Ready_for_Billing__c = true;
        shipList[1].Destination_Type__c = 'Offline';
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Status__c = 'Verified for Billing';
        shipList[1].Window_Delivery__c = false;
        shipList[1].Window_Pickup__c = false;
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Acr Contracted Shipment Failed:'+ex.getMessage());
        } 
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='mumbai'; 
        exempt.New_Offline_Charge__c=200;
        //exemptlist.add(exempt);
        insert exempt;
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }    
        Set<Id> ids = new Set<Id>{shipList[0].Id,shipList[1].Id};
            // system.debug('Prod category :'+shipList[0].Customer_Product_Category__c);
            // system.debug('Prod category :'+shipList[1].Customer_Product_Category__c);
            string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id IN (\''+shipList[0].Id+'\',\''+shipList[1].Id+'\')';
        List<Shipment__c> ships = Database.query(query);
        
        List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        
        
        
        
        //ShipmentCalcUtil.fakeMethod();
        test.stopTest();
    }
    
    /* @istest
public static void reverseOrderTest(){

List<Order> orders = [Select Id,Status,TotalAmount,AccountId,EffectiveDate,blng__BillingDayOfMonth__c from Order where status = 'Draft' ];
System.debug('Kumar--->'+orders);

List<OrderItem> orderItems = [Select Id,OrderId from OrderItem ];

//Order orderCloned = orders[0].clone(false,true,false,false);
//orderCloned.Status = 'Draft';
//insert orderCloned;
// System.debug('Kumar--->'+orderCloned);

//List<QuoteLine__c> quotelines = TestUtility.createQu
//List<OrderItem> insertItem = TestUtility.createACROrderItems(qlinesList, o)
List<Order> ordertoUpdate = new List<Order>();
for(Order rec:orders){
if(rec.Id==orderItems[0].Id)
ordertoUpdate.add(rec);
}
ordertoUpdate[0].Status = 'Draft';
update ordertoUpdate;
ordertoUpdate[0].Status = 'Cancelled';
update ordertoUpdate;
}  */
    
    @isTest
    static void acrMisfitShipmentTestMethod1(){
        Test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont);
        List<Product2> prodListGold = [Select id,ProductCode from Product2 where ProductCode = 'GOLD-EX-C2C'];
        system.debug('Products : > '+prodListGold);
        delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        List<ST_ACR_Contracted_Price__c > misFitPrices = TestUtility.createMisfitACRPriceTable (cont.AccountId, cont.Id, prodListGold[0].Id);
        insert misFitPrices;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c limit 1';
        List<Shipment__c> ships = Database.query(query);
        /*Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c,Pickup_Time_Date__c,Billing_Account__c,
                                Shipment_Type__c,Product_Description__c,Origin_Hub__r.BVC_Entity__c FROM Shipment__c LIMIT 1];*/
        ships[0].Status__c = 'Pending Billing';
        update ships[0];
        system.debug('Non ACR Contract :Shipment::Test::Class::'+ships[0]);
        //system.debug('Destination City [0]: '+ ships[0].Destination_Address_City__c + 'OriginCity [0] : ' +ships[0].Origin_Address_City__c+ 'Active_contract__c : '+ships[0].Bill_To_Account__r.Active_contract__c);
        
        ships[0].Liability_Cover_By_BVC__c = 'Yes';      
        ships[0].Status__c = 'Verified for Billing';
        ships[0].Product_Code__c = 'GOLD-EX-C2C';
        ships[0].Destination_Type__c = 'offline';
        //shipList.Origin_Type__c = 'offline';
        ships[0].Window_Delivery__c = false;
        //shipList.Window_Pickup__c = false;
        update ships[0];
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c=  'mumbai'; 
        exempt.New_Offline_Charge__c=200;
        
        insert exempt;
        
              
       /* string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(shipList.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);*/
        Set<Id> ids = new Set<Id>{ships[0].Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.add(ships[0]);
        System.debug('total queries::'+Limits.getQueries());//32 queries
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,shipments);
        
        try{
            update ships[0];
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        }
        
        	
        test.stopTest();
    }
    @isTest
    static void acrMisfitShipmentTestMethod2(){
        test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont);
        List<Product2> prodListGold = [Select id,ProductCode from Product2 where ProductCode = 'GOLD-EX-C2C'];
        system.debug('Products : > '+prodListGold);
        delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        List<ST_ACR_Contracted_Price__c > misFitPrices = TestUtility.createMisfitACRPriceTable (cont.AccountId, cont.Id, prodListGold[0].Id);
        insert misFitPrices;
        
        
        
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c,Pickup_Time_Date__c,Billing_Account__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Liability_Cover_By_BVC__c = 'Yes'; 
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = false;
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void ACRContractedShipmentTestMethod(){
        test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
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
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = false;
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c=  'mumbai'; 
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
    static void ACRContractedShipmentTestMethod2(){
        test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
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
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = true;
        shipList.Window_Pickup__c = false;
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void acrMisfitShipmentTestMethod3(){
        test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
        
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont);
        List<Product2> prodListGold = [Select id,ProductCode from Product2 where ProductCode = 'GOLD-EX-C2C'];
        system.debug('Products : > '+prodListGold);
        delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        List<ST_ACR_Contracted_Price__c > misFitPrices = TestUtility.createMisfitACRPriceTable (cont.AccountId, cont.Id, prodListGold[0].Id);
        insert misFitPrices;
        
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Liability_Cover_By_BVC__c = 'Yes'; 
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = true;
        shipList.Window_Pickup__c = false;
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void ACRContractedShipmentTestMethod3(){
        test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
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
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = true;
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void acrMisfitShipmentTestMethod4(){
        test.startTest();
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
        Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Contract : > '+ cont);
        List<Product2> prodListGold = [Select id,ProductCode from Product2 where ProductCode = 'GOLD-EX-C2C'];
        system.debug('Products : > '+prodListGold);
        delete [SELECT Id FROM ST_ACR_Contracted_Price__c WHERE ST_Contract__c = :cont.Id];
        List<ST_ACR_Contracted_Price__c > misFitPrices = TestUtility.createMisfitACRPriceTable (cont.AccountId, cont.Id, prodListGold[0].Id);
        insert misFitPrices;
        
        Shipment__c shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        shipList.Status__c = 'Pending Billing';
        update shipList;
        system.debug('Non ACR Contract :Shipment::Test::Class::'+shipList);
        system.debug('Destination City [0]: '+ shipList.Destination_Address_City__c + 'OriginCity [0] : ' +shipList.Origin_Address_City__c+ 'Active_contract__c : '+shipList.Bill_To_Account__r.Active_contract__c);
        
        shipList.Liability_Cover_By_BVC__c = 'Yes'; 
        shipList.Status__c = 'Verified for Billing';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = true;
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
        SendEmailUtility.fMethod();
        
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Non Acr Contracted Shipment Failed:'+ex.getMessage());
        } 
        test.stopTest();
    }
    
    @isTest
    static void ACRContractedShipmentTestMethod4(){
        test.startTest();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        //Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        list<Product2>prd = new list<Product2>();
        Product2 exb = TestUtility.createExhibiProduct(bRule, revRule, taxRule);
        prd.add(exb);
        insert prd;
        
        Delete[select id from ST_ACR_Contracted_Price__c];
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prd);
        stdACRPrice[0].ST_Product__c = null;
        stdACRPrice[0].ST_Effective_End_Date__c = System.today().adddays(20);
        stdACRPrice[0].ST_Effective_Start_Date__c = System.today().adddays(-20);
        stdACRPrice[0].ST_ACR_Package_Type__c =null;
        insert stdACRPrice;
        
        
        
        
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
        // shipList.Product_Code__c = 'EXHIBI-S-C2C';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        //shipList.Bill_To_Account__c = acc1.Id;
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = false;
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void ACRContractedShipmentTestMethod5(){
        test.startTest();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        //Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        list<Product2>prd = new list<Product2>();
        Product2 exb = TestUtility.createExhibiProduct(bRule, revRule, taxRule);
        prd.add(exb);
        insert prd;
        
        Delete[select id from ST_ACR_Contracted_Price__c];
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prd);
        stdACRPrice[0].ST_Product__c = null;
        stdACRPrice[0].ST_Effective_End_Date__c = System.today().adddays(20);
        stdACRPrice[0].ST_Effective_Start_Date__c = System.today().adddays(-20);
        stdACRPrice[0].ST_ACR_Package_Type__c =null;
        insert stdACRPrice;
        
        
        
        
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
        // shipList.Product_Code__c = 'EXHIBI-S-C2C';
        shipList.Product_Code__c = 'GOLD-EX-C2C';
        //shipList.Bill_To_Account__c = acc1.Id;
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = true;
        shipList.Window_Pickup__c = false;
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void ACRContractedShipmentTestMethod6(){
        test.startTest();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        
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
        shipList.Product_Code__c = 'EXHIBI-S-C2C';
        
        //shipList.Bill_To_Account__c = acc1.Id;
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = true;
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    static void ACRContractedShipmentTestMethod7(){
        test.startTest();
        Account acc1 = [select id,name from Account where name ='ACR Account'LIMIT 1];
        //Contract cont = [SELECT Id,AccountId,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        
        
        
        
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
        shipList.Product_Code__c = 'EXHIBI-S-C2C';
        // shipList.Product_Code__c = 'GOLD-EX-C2C';
        //shipList.Bill_To_Account__c = acc1.Id;
        shipList.Destination_Type__c = 'offline';
        shipList.Origin_Type__c = 'offline';
        shipList.Window_Delivery__c = false;
        shipList.Window_Pickup__c = true;
        
        update shipList;
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c= 'mumbai'; 
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
    //SendEmailUtility.EmailConfigurator();
}