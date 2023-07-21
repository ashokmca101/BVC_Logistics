@isTest
public class ContractActivationBatchTest_2 {

    
    public static String CRON_EXP = '0 0 0 24 7 ? 2025';
    @testSetup
    static void testSetup(){
        test.StartTest();
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
         Active_Pincode__c suratPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert suratPin;
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        accList.add(nonAcrNonContractedAccount);
        Account nonACRContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonACRContractedAccount.Name = 'Non ACR Contracted Account';
        accList.add(nonACRContractedAccount);
        insert accList;
        
        //Contact Con = TestUtility.createContact(accList[0]);
        //insert Con;
        
        /*AccountContactRelation relation = [SELECT Id,AccountId,ContactId,Contact.Email,Roles FROM AccountContactRelation WHERE AccountId IN :accList];//TestUtility.createAccountContactRelation(accList[0],con);
        relation.Roles = 'Finance; Invoice Recepient';
        update relation; */
        
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
        update accList[0];
        
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
        insert subs;
        List<AddressBook__c> originDestinationAdddress = [SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,
                                                          Pincode_TMS__r.Hub__r.Billing_Entity_Name__r.Id,
                                                         COUNTRY__c,CITY__c,PINCODE__c,Customer__c FROM AddressBook__c
                                                          WHERE CITY__c IN ('Mumbai','Bengaluru')
                                                         ORDER BY PINCODE__c desc];
        system.debug('originDestinationAdddress:::'+originDestinationAdddress);
        List<Shipment__c> ship = TestUtility.createnonACRnonContShipment(accList[0], branches, blngAddress);
        List<Shipment__c> insertShips = new List<Shipment__c>();
        for(Shipment__c s : ship){
            s.Shipper_Name_TMS__c = originDestinationAdddress[1].Customer__c;
            s.Consignee_Name_TMS__c = originDestinationAdddress[0].Customer__c;
            s.Destination_Address_Name__c =originDestinationAdddress[0].Id;
            s.Origin_Address_Name__c = originDestinationAdddress[1].Id;
            insertShips.add(s);
        }
        
        insert insertShips;
        */
    }   
    
    
    @isTest
    static void activationTest(){
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Entity__c ent = TestUtility.createBVCEntity();
        insert ent;
        
        Active_Pincode__c pin = [SELECT Id FROM Active_Pincode__c WHERE Pincodes__c = '400093'];
                
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
        //Active_Pincode__c suratPin = TestUtility.createBengaluruPinCode(branches[1]);
        //insert suratPin;
        Account acc = TestUtility.createnonACRnonContractedAccount();
        /*acc.name = 'non ACR Non Contracted Account1234321';
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non ACR Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        acc.KYC_Indicator_for_Domestic_Flag__c = true;*/
        
        insert acc;
        test.starttest();
        Contract cont = new Contract(AccountId = acc.Id,
                                    //SBQQ__Order__c = o.Id,
                                    StartDate = System.today().addDays(10),
                                    EndDate = System.today().addDays(100),
                                    Original_Contract_End_Date__c = system.today().addDays(45),
                                    Contract_Signed_Date__c = system.today(),
                                    Business_Type__c = 'Non ACR',
                                    Status = 'Draft',
                                    Contracted_ACR_Package__c = 'Package 2 : 60K',
                                    Contract_Amount__c = 60000,
                                    BVC_Branch__c = branches[0].Id,
                                    BVC_Billing_Entity__c = branches[0].ST_BVC_Billing_Entity__c,
                                    BVC_Entity__c = branches[0].BVC_Entity__c);   
        
        insert cont;
        
        Contract c = [select id,Business_Type__c, AccountId, StartDate from Contract limit 1];
        
        c.StartDate = system.today();
        update c;
        
        UtilClass.isFirstTime = false;
        ContractActivationBatch tb = new ContractActivationBatch();
        Id batchId = Database.executeBatch(tb);
         test.stoptest();
    }
    
    @isTest 
    static void scheduleBatchTest(){
        Test.startTest();
        String cronExpr = '0 0 0 15 9 ? 2022';
        ContractActivationBatch abs= new ContractActivationBatch();
        String jobId = System.schedule('myJobTestJobName', cronExpr, abs);
        abs.execute(null);
        Test.stopTest();
    }    
}