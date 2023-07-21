@isTest
public class ST_ShipmentTriggerTest {
    public static String CRON_EXP = '0 0 0 24 7 ? 2022';
    @testSetup
    static void testSetup(){
        test.startTest();
        /*Entity__c ent = TestUtility.createBVCEntity();
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
       // update relation;
        
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
        //update accList[0];
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
        */
        
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
        
        Account shipperAccount = TestUtility.createShipperAccount();
        insert shipperAccount;
        
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.Id,'Line 1',bengaluruPin.id,'Bengaluru',true);
        
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(shipperAccount.id, shipperAccount.Id, shipperAddress.id, shipperAccount.Id, shipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        insert ship1;
       
        test.stopTest();
        
    }
    
    
    @isTest
    static void nonACRnonContractedShipmentTestMethod(){
        test.startTest();
        //sam
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        insert acc1;
        
        
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exemptlist.add(exempt);
        insert exemptlist;
    
        Shipment__c ship = [SELECT Id,Bill_To_Account__c,Shipment_Date__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                            Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                            Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                            Origin_Type__c,Destination_Type__c,platform_User__c FROM Shipment__c LIMIT 1];
        system.debug('Shipment Non ACR Non Contracted::Test::Class::'+ship.Bill_To_Account__r.Billing_Frequency__c);
        ship.Status__c = 'Pending Billing';
        
        update ship;
        
        
        ship.Liability_Cover_By_BVC__c = 'Yes';
        ship.Next_Billing_Date__c = system.today().adddays(3);
        ship.Status__c = 'Verified for Billing';
        ship.Product_Code__c = 'GOLD-EX-C2C';
        ship.Origin_Type__c = 'Offline';
        ship.Destination_Type__c = 'Offline';
        
        try{
            update ship;  
        } catch(exception ex){
            system.debug('Non Acr Non Contract Shipment Failed:'+ex.getMessage());
        }  
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
         string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(ship.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{ship.Id};
        List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(ships);
            
         ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
            cb.execute(null,shipments);
        //Database.executeBatch(new );
     
            test.stopTest();
    }
    @isTest
    static void TestMethod1(){
        list<ShipmentCalcUtil.ShipmentDetail> wrapList = new list<ShipmentCalcUtil.ShipmentDetail>();
        ShipmentCalcUtil.ShipmentDetail wrap = new ShipmentCalcUtil.ShipmentDetail();
        wrap.CommunityUniqueId = 'test';
        wrap.freightOnInvoice=0;
        wrap.perShipment = 0;
        wrap.prodName ='test';
        wrap.errors = 'test';
        wrap.exhibitionContractedPriceId = 'test';
        wrapList.add(wrap);
        
        list<Account> listAcc = new list<Account>();
        Account acc1=TestUtility.createNonACRnonContractedAccount();
        listAcc.add(acc1);
        insert listAcc;
        
        map<id,Account> mapAccount = new map<id,Account>();
        mapAccount.put(listAcc[0].Id,listAcc[0]);
        
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=listAcc[0].Id;
        exempt.Exempted_City__c='Mumbai'; 
        exemptlist.add(exempt);
        insert exemptlist;
    
        Shipment__c ship = [SELECT Id,Bill_To_Account__c,Shipment_Date__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                            Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                            Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                            Origin_Type__c,Destination_Type__c,platform_User__c FROM Shipment__c LIMIT 1];
        system.debug('Shipment Non ACR Non Contracted::Test::Class::'+ship.Bill_To_Account__r.Billing_Frequency__c);
        ship.Status__c = 'Pending Billing';
        
        update ship;
        
       // ShipmentCalcUtil.shipmentCalculationNonACRContract(wrapList,mapAccount);
        
    }
    
}