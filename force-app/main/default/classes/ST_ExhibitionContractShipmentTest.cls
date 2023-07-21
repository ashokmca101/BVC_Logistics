@isTest
public class ST_ExhibitionContractShipmentTest {
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
        
        ST_Exhibition__c exb = TestUtility.createExhibition();
        insert exb;
        
        
        List<Account> accList = new List<Account>();
        
        Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonACRContractedAccount.Name = 'Non ACR Contracted Account';
        accList.add(nonACRContractedAccount);
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
        product2 prod = TestUtility.createExhibiProduct(bRule, revRule, taxRule);
        prodList.add(prod);
        
        product2 optionProduct = TestUtility.createExhibiProduct(bRule, revRule, taxRule);
        optionProduct.Name = 'ExhibiSHIP Within City';
        optionProduct.ProductCode = 'EXHIBI-WC';
        prodList.add(optionProduct);
        insert prodList;
        
        /*SBQQ__ProductOption__c prodOption = TestUtility.createProductOption(prodList[0], prodList[1]);
insert prodOption;*/
        
        Id stdPriceBookId = Test.getStandardPricebookId();
        Pricebook2 pb = TestUtility.createPriceBook();
        insert pb;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[0].Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry standardPBE1 = new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[1].Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE1;
        
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
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Billing_Address__c = blngAddress[0].Id;
        accList[0].Is_Finance_Contact_Present__c = true;
        accList[0].Primary_Address__c = blngAddress[0].Id;
        update accList[0];
        
        List<ST_Exhibition_Standard_Price__c> exhibPriceList = new List<ST_Exhibition_Standard_Price__c>();
        ST_Exhibition_Standard_Price__c exhibPrice1 = TestUtility.createExhibitionStdPrice(prodList[0], exb);
        exhibPriceList.add(exhibPrice1);
        
        ST_Exhibition_Standard_Price__c exhibPrice2 = TestUtility.createExhibitionStdPrice(prodList[1], exb);
        exhibPriceList.add(exhibPrice2);
        insert exhibPriceList;
        
        
        
        SBQQ__Quote__c quotes = TestUtility.createExhibitionQuote(pb.Id, oppList[0], branches[0], exb);
        quotes.Business_Type__c = 'Exhibition';
        insert quotes;
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.add(TestUtility.createExhibitionQuoteLines(quotes.Id, customACRPrices[0], exhibPrice1, exb));
        //quoteLines[0].ST_Gross_Weight_Slabs__c = '';
        insert quoteLines;
        
        List<Order> exhibitionOrderList = TestUtility.createExhibitionOrder(quotes, quotes.SBQQ__PricebookId__c, exb);
        insert exhibitionOrderList;
        
        List<OrderItem> exhibitionItems = Testutility.createExhibitionOrderItems(quoteLines, exhibitionOrderList[0], exb);
        insert exhibitionItems;
        
        test.startTest();
        Contract cont = TestUtility.createExhibitionContract(exhibitionOrderList[0], branches[0], exb);
        
        insert cont;
        
        
       
        List<SBQQ__Subscription__c> subs = TestUtility.createExhibitionSubscription(exhibitionItems, cont, exb);
        insert subs;
         ST_Exhibition_Contracted_Price__c ecp = TestUtility.createExhibitionContdPrice(exhibPriceList[0],cont);
        insert ecp;
        // ecp.Level_2__c = 10000;
        //ecp.Level_1__c=1000;
       // update ecp;
        cont.status = 'Activated';
        update cont;
        
        
        
        Account shipperAccount = TestUtility.createShipperAccount();
        insert shipperAccount;
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',bengaluruPin.id,'Bengaluru',true);
        List<Shipment__c> shipList = new List<Shipment__c>();
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        
        ship1.Exhibition__c = exb.Id;
        ship1.Exhibition_Movement_Type__c = 'Inward';
        ship1.Customer_Product_Category__c = 'ValSHIP';
        ship1.IsExhibition__c = true;
        shipList.add(ship1);
        
        Shipment__c ship2 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship2.Shipment_Date__c = system.today();
        ship2.IsExhibition__c = true;
        ship2.Customer_Product_Category__c = 'ValSHIP';
        ship2.Gross_Weight__c = 4000;
        ship2.Exhibition__c = exb.Id;
        ship2.Exhibition_Movement_Type__c = 'Inward';
        shipList.add(ship2);
        
        insert shipList;
        
        test.stopTest();
    }
    
    @isTest
    static void stdExhibitionShipmentTestMethod(){
        test.startTest();
    
        Contract cont = [SELECT Id,AccountId,Status,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Status Cont : '+cont.Status);
        List<Product2> prods = [SELECT Id,ProductCode FROM Product2];
        //system.debug('Contract : > '+ cont); 
        system.debug('EcP : '+[SELECT Id,ST_Active__c,ST_Product__r.ProductCode,ST_Contract__r.Status,ST_Customer_Product_Category__c,ST_Exhibition__c,ST_Customer_Account__c FROM ST_Exhibition_Contracted_Price__c where ST_Contract__c= :cont.Id AND ST_Product__c IN :prods LIMIT 1]) ;
        ST_Exhibition_Contracted_Price__c ecp  = [SELECT Id,ST_Active__c,ST_Product__r.ProductCode,ST_Contract__r.Status,ST_Customer_Product_Category__c,ST_Exhibition__c,ST_Customer_Account__c, Level_1__c, Level_1_Rate__c, Level_2__c,
                                                     Level_2_Rate__c, Level_3__c, Level_3_Rate__c,
                                                     Level_4__c, Level_4_Rate__c, Level_5__c,
                                                     Level_5_rate__c, Max_Slab_Rate__c FROM ST_Exhibition_Contracted_Price__c where ST_Contract__c= :cont.Id AND ST_Product__c IN :prods LIMIT 1];
        //delete ecp;
        system.debug('Standard Prices : '+[SELECT Id,ST_Product__r.ProductCode FROM ST_Exhibition_Standard_Price__c]);
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,
                                      Bill_To_Account__r.Active_contract__c,Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Balance_Amount__c,
                                      Shipment_Value__c,Destination_Address_City__c,Origin_Address_City__c,Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,
                                      Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c,Customer_Product_Category__c,Exhibition__c,Next_Billing_Date__c FROM Shipment__c LIMIT 2];

        
        shipList[0].Status__c = 'Pending Billing';
        shipList[1].Status__c = 'Pending Billing';
        update shipList;
        system.debug('Insert Ships::Exhibition Shipment Method::'+shipList);
                 //sam
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        insert acc1;
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exempt.New_Offline_Charge__c=400;
        exemptlist.add(exempt);
        Exempted_City__c exempt1=new Exempted_City__c();
        exempt1.Customer__c=acc1.Id;
        exempt1.Exempted_City__c='Annur'; 
        exempt1.New_Offline_Charge__c=600;
        exemptlist.add(exempt1);
        insert exemptlist;
        try{
            exempt.Exempted_City__c= shipList[0].Origin_Address_City__c;
            update exempt;
        
           exempt1.Exempted_City__c= shipList[0].Destination_Address_City__c;
            update exempt1;
        }
         catch(Exception Ex){
            system.debug(':'+Ex.getMessage());
        }
        
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        shipList[0].Product_Code__c = 'EXHIBI-S-C2C';
        shipList[0].Origin_Type__c = 'Offline';
        shipList[0].Destination_Type__c = 'Offline';
        shipList[0].Customer_Product_Category__c = 'ValSHIP';
        shipList[0].Shipment_Value__c  = 10000;
        // shipList[0].Offline_Charges__c = 500;
        shipList[0].Status__c = 'Verified for Billing';
        
        shipList[1].Product_Code__c = 'EXHIBI-WC';
        shipList[1].Shipment_Value__c  = 20000;
        //shipList[1].Offline_Charges__c = 500;
        shipList[1].Ready_for_Billing__c = true;
        shipList[1].Destination_Type__c = 'Offline';
        shipList[1].Destination_Type__c = 'Offline';
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Customer_Product_Category__c = 'ValSHIP';
        
        shipList[1].Status__c = 'Verified for Billing';
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Exhibition Contracted Shipment Failed:'+ex.getMessage());
        } 
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }    
        Set<Id> ids = new Set<Id>{shipList[0].Id,shipList[1].Id};
            system.debug('Prod category :'+shipList[0].Customer_Product_Category__c);
        system.debug('Prod category :'+shipList[1].Customer_Product_Category__c);
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id IN (\''+shipList[0].Id+'\',\''+shipList[1].Id+'\')';
        List<Shipment__c> ships = Database.query(query);
        
        List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        test.stopTest();
    }
    
    @isTest
    static void contExhibitionShipmentTestMethod(){
        test.startTest();
    
        Contract cont = [SELECT Id,AccountId,Status,SBQQ__Quote__r.Business_Type__c FROM Contract LIMIT 1];
        system.debug('Status Cont : '+cont.Status);
        List<Product2> prods = [SELECT Id,ProductCode FROM Product2];
        //system.debug('Contract : > '+ cont); 
        system.debug('EcP : '+[SELECT Id,ST_Active__c,ST_Product__r.ProductCode,ST_Contract__r.Status,ST_Customer_Product_Category__c,ST_Exhibition__c,ST_Customer_Account__c FROM ST_Exhibition_Contracted_Price__c where ST_Contract__c= :cont.Id AND ST_Product__c IN :prods LIMIT 1]) ;
        ST_Exhibition_Contracted_Price__c ecp  = [SELECT Id,ST_Active__c,ST_Product__r.ProductCode,ST_Contract__r.Status,ST_Customer_Product_Category__c,ST_Exhibition__c,ST_Customer_Account__c, Level_1__c, Level_1_Rate__c, Level_2__c,
                                                     Level_2_Rate__c, Level_3__c, Level_3_Rate__c,
                                                     Level_4__c, Level_4_Rate__c, Level_5__c,
                                                     Level_5_rate__c, Max_Slab_Rate__c FROM ST_Exhibition_Contracted_Price__c where ST_Contract__c= :cont.Id AND ST_Product__c IN :prods LIMIT 1];
        delete ecp;
        system.debug('Standard Prices : '+[SELECT Id,ST_Product__r.ProductCode FROM ST_Exhibition_Standard_Price__c]);
        List<Shipment__c> shipList = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,
                                      Bill_To_Account__r.Active_contract__c,Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Balance_Amount__c,
                                      Shipment_Value__c,Destination_Address_City__c,Origin_Address_City__c,Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,
                                      Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                      Origin_Type__c,Destination_Type__c,Customer_Product_Category__c,Exhibition__c,Next_Billing_Date__c FROM Shipment__c LIMIT 2];

        
        shipList[0].Status__c = 'Pending Billing';
        shipList[1].Status__c = 'Pending Billing';
        update shipList;
        system.debug('Insert Ships::Exhibition Shipment Method::'+shipList);
                 //sam
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        insert acc1;
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exempt.New_Offline_Charge__c=400;
        exemptlist.add(exempt);
        Exempted_City__c exempt1=new Exempted_City__c();
        exempt1.Customer__c=acc1.Id;
        exempt1.Exempted_City__c='Annur'; 
        exempt1.New_Offline_Charge__c=600;
        exemptlist.add(exempt1);
        insert exemptlist;
        try{
            exempt.Exempted_City__c= shipList[0].Origin_Address_City__c;
            update exempt;
        
           exempt1.Exempted_City__c= shipList[0].Destination_Address_City__c;
            update exempt1;
        }
         catch(Exception Ex){
            system.debug(':'+Ex.getMessage());
        }
        
        shipList[0].Liability_Cover_By_BVC__c = 'Yes';
        shipList[0].Next_Billing_Date__c = system.today().adddays(3);
        shipList[0].Pickup_Time_Date__c = system.now().addDays(2);
        shipList[0].Product_Code__c = 'EXHIBI-S-C2C';
        shipList[0].Origin_Type__c = 'Offline';
        shipList[0].Destination_Type__c = 'Offline';
        shipList[0].Customer_Product_Category__c = 'ValSHIP';
        shipList[0].Shipment_Value__c  = 10000;
        // shipList[0].Offline_Charges__c = 500;
        shipList[0].Status__c = 'Verified for Billing';
        
        shipList[1].Product_Code__c = 'EXHIBI-WC';
        shipList[1].Shipment_Value__c  = 20000;
        //shipList[1].Offline_Charges__c = 500;
        shipList[1].Ready_for_Billing__c = true;
        shipList[1].Destination_Type__c = 'Offline';
        shipList[1].Destination_Type__c = 'Offline';
        shipList[1].Liability_Cover_By_BVC__c = 'Yes';
        shipList[1].Customer_Product_Category__c = 'ValSHIP';
        
        shipList[1].Status__c = 'Verified for Billing';
        try{
            update shipList;
        } catch(exception ex){
            system.debug('Exhibition Contracted Shipment Failed:'+ex.getMessage());
        } 
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }    
        Set<Id> ids = new Set<Id>{shipList[0].Id,shipList[1].Id};
            system.debug('Prod category :'+shipList[0].Customer_Product_Category__c);
        system.debug('Prod category :'+shipList[1].Customer_Product_Category__c);
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id IN (\''+shipList[0].Id+'\',\''+shipList[1].Id+'\')';
        List<Shipment__c> ships = Database.query(query);
        
        List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(shipList);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,ships);
        test.stopTest();
    }
}