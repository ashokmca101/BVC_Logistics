@isTest
public class ExternalContractCalcUtilTest_2 {
    
    public static String CRON_EXP = '0 0 0 24 7 ? 2022';
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
        
        Active_Pincode__c suratPin = TestUtility.createBengaluruPinCode(branches[1]);
        //Active_Pincode__c suratPin = TestUtility.createSuratPinCode(branches[1]);
        insert suratPin;
        system.debug('BEngalurur Pin:::'+suratPin);
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonAcrNonContractedAccount.Email__c='ert@cfg.com';
         nonAcrNonContractedAccount.Primary_Customer_Email__c ='uih@dfc.com';
         nonAcrNonContractedAccount.Last_Name__c='namesdf';
        nonAcrNonContractedAccount.Name = 'NonACRnonContracted'+Math.random()*1000;
        accList.add(nonAcrNonContractedAccount);
        Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonACRContractedAccount.Name = 'Non ACR Contracted Account'+ Math.random()*1000;
        //accList.add(nonACRContractedAccount);
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        Con.AccountId = accList[0].Id;
           Con.LastName = 'Carlssons';
           Con.FirstName='sampletest';
           Con.Phone='6754346790';
           con.Email = 'abc1@abc.com';
        insert Con;
        
        AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList LIMIT 1];//TestUtility.createAccountContactRelation(accList[0],con);
        relation.Roles = 'Finance; Invoice Recepient';
        update relation;
        
        List<Opportunity> oppList = TestUtility.createOpportunity(accList,null,ent);
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
        Account shipperAccount = TestUtility.createShipperAccount();
         shipperAccount.Email__c='er3t@cfg.com';
         shipperAccount.Primary_Customer_Email__c ='u4ih@dfc.com';
         shipperAccount.Last_Name__c='namettsdf';
        insert shipperAccount;
           Con.AccountId = shipperAccount.Id;
           Con.LastName = 'Carlssons';
           Con.FirstName='sampletest';
           Con.Phone='6754346790';
           con.Email = 'abc1@abc.com';
        //insert con;
        AddressBook__c shipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',shipperAccount.id,'Line 1',suratPin.id,'Bengaluru',true);
        Shipment__c ship1 = BVCL_TestDataFactory.createShipment(accList[0].id, shipperAccount.id, ShipperAddress.id, shipperAccount.id, ShipperAddress.id, false);
        ship1.Shipment_Date__c = system.today();
        ship1.Gross_Weight__c = 8000;
        insert ship1;
        
       
        
    }
    
    @isTest
    static void acrShipmentTestMethod(){
        test.startTest();
        /*List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,
                                                          Pincode_TMS__r.Hub__r.Billing_Entity_Name__c,
                                                          COUNTRY__c,CITY__c,PINCODE__c,Customer__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                          ORDER BY PINCODE__c desc];
        system.debug('originDestinationAdddress:::'+originDestinationAdddress);
        List<Account> accList = [select id from Account];
        */
        Shipment__c ship = [SELECT Id,Bill_To_Account__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,Bill_To_Account__r.Active_contract__c,
                                Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                                Destination_Address_City__c,Origin_Address_City__c,Shipment_Date__c,
                                Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.ST_BVC_Billing_Entity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                                Origin_Type__c,Destination_Type__c FROM Shipment__c LIMIT 1];
        ship.Status__c = 'Pending Billing';
        ship.Shipment_Stage__c='BVC Weighment Done';
        update ship;
        Product2 nonACRprod = [select Id from product2 where ProductCode = 'GOLD-EX-C2C' limit 1];
        External_Contract__c extCon = new External_Contract__c();
        extCon.Customer__c = ship.Bill_To_Account__c;
        extCon.Product__c = nonACRprod.id;
        extCon.Active__c = true;
        extCon.Monthly_Contract__c = false;
        extCon.Filter_By__c = 'Origin Hub';
        //extCon.Origin_City__c = shipCalc.origin;
        //extCon.Destination_City__c = shipCalc.destination;
        insert extCon;  
        
       /* List<Hub__c> branches = [SELECT Id,Hub_Address_Line_1__c,Hub_Address_Line_2__c,
                                 Hub_Pincode__c,ST_BVC_Billing_Entity__c,BVC_Entity__c
                                 FROM Hub__c ];
        List<AddressBook__c> blngAddressList = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,COUNTRY__c,
                                                PINCODE__c,CITY__c,Customer__c,Dealer_Type__c,GST_Registered_Status__c,
                                                GSTIN__c FROM AddressBook__c LIMIT 3];
        
        */
        system.debug('Origin Hub  : '+ship.Origin_Hub__c);
        List<ShipmentCalcUtil.ShipmentDetail> shipCalcs = new  List<ShipmentCalcUtil.ShipmentDetail>();
        ShipmentCalcUtil.ShipmentDetail shipCalc = new ShipmentCalcUtil.ShipmentDetail();
        shipCalc.grossWeight = 2000;
        shipCalc.productId = nonACRprod.id;
        shipCalc.accountId = ship.Bill_To_Account__c;
        shipCalc.isOriginOfflineLoc = true;
        shipCalc.isDestOfflineLoc = true;
        shipCalc.orderLineItemId = ship.Id;
        shipCalc.originHub = ship.Origin_Hub__c;
        shipCalc.externalContractId = extCon.Id;
        shipCalcs.add(shipCalc);
		system.debug('filterById   :  '+shipCalcs[0]);        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalculation=ShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalculation1=ShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        test.stoptest();
    }    
    
    //For Non ACR Non Contracted
   /* static testMethod void testExternalContractCommunityCase(){
        //testSetup();
        
        Account acc = TestUtility.createnonACRnonContractedAccount();
        acc.Name = 'Test-BVC-Standav';
        insert acc;
        
        blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
        
        Product2 optionProduct = TestUtility.createProduct(bRule, revRule, taxRule);
        insert optionProduct;
        //Shipment__c ship = TestUtility.createnonACRnonContShipment(acc.Id, );
        //insert ship;
        Product2 nonACRprod = [select Id from product2 where ProductCode = 'GOLD-EX-C2C' limit 1];
        External_Contract__c extCon = new External_Contract__c();
        extCon.Customer__c = acc.id;
        extCon.Product__c = nonACRprod.id;
        extCon.Active__c = true;
        //  extCon.Origin_City__c = shipCalc.origin;
        //extCon.Destination_City__c = shipCalc.destination;
        insert extCon;  
        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalcs = new  List<ShipmentCalcUtil.ShipmentDetail>();
        ShipmentCalcUtil.ShipmentDetail shipCalc = new ShipmentCalcUtil.ShipmentDetail();
        shipCalc.grossWeight = 2000;
        shipCalc.productId = nonACRprod.id;
        shipCalc.accountId = acc.id;
        shipCalc.isOriginOfflineLoc = true;
        shipCalc.isDestOfflineLoc = true;
        //  shipCalc.origin = 'Ahmedabad';   
        //   shipCalc.destination = 'Rajkot';
        //shipCalc.orderLineItemId = ship.Id;
        //   shipCalc.customerProdCategory = 'GoldSHIP';
        shipCalcs.add(shipCalc);
        
        test.startTest();
        List<ShipmentCalcUtil.ShipmentDetail> shipCalculation=ShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        test.stopTest();
    }*/
}