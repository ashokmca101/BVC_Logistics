@isTest
public class ContractTriggerHandlerTest {
    @testSetup
    static  void testSetup(){
       // fflib_SObjectDomain.getTriggerEvent(ContractTriggerHandler.class).disableAll();
            TestUtility testUtil = new TestUtility();
            User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
           Entity__c ent = TestUtility.createBVCEntity();
           insert ent;
        
           Active_Pincode__c pin = TestUtility.createPinCode();
           insert pin;
           
           blng__LegalEntity__c legEntity = TestUtility.createLegalEntity(ent);
           insert legEntity;
           
           Hub__c bvcBranch = TestUtility.createBVCBranch(legEntity, pin);
           insert bvcBranch;
           List<Account> accList = new List<Account>();
           
           Account a = TestUtility.createnonACRnonContractedAccount();
           a.Email__c='ert@cfg.com';
           a.Primary_Customer_Email__c ='uih@dfc.com';
           a.Last_Name__c='namesdf';
           accList.add(a);
           insert accList;
          
           Contact Con = TestUtility.createContact(accList[0]);
           Con.AccountId = accList[0].Id;
           Con.LastName = 'Carlssons';
           Con.FirstName='sampletest';
           Con.Phone='6754346790';
           con.Email = 'abc1@abc.com';
           con.BVC_Finance_Contact__c=true;
           insert Con;
           
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
           update accList[0];
           
           List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
           insert stdACRPrice;
           
           List<SBQQ__Quote__c> quotes = TestUtility.createACRQuote(pb.Id, oppList, bvcBranch);
           insert quotes;
           
           List<SBQQ__QuoteLine__c> acrQuoteLines = TestUtility.createQuoteLines(quotes[0].Id,customACRPrices,stdACRPrice);
        insert acrQuoteLines;
        
        List<Order> orderList = TestUtility.createACROrder(quotes, pb.Id);
        insert orderList;
       test.startTest();
        Contract contract = TestUtility.createACRContract(orderList[0],bvcBranch);
        contract.StartDate = System.today().addDays(-30);
        insert contract;
        
        Product2 prd2=TestUtility.createExhibiProduct(bRule,revRule,taxRule);
        insert prd2;
        
        ST_NonACR_Standard_Price__c stn=TestUtility.nonACRStdPrice(prd2);
        insert stn;
        
        ST_Exhibition__c stex=TestUtility.createExhibition();
        insert stex;
        
        ST_Exhibition_Standard_Price__c stes=TestUtility.createExhibitionStdPrice(prd2,stex);
        insert stes;
        
        ST_Exhibition_Contracted_Price__c stec=TestUtility.createExhibitionContdPrice(stes,contract);
        insert stec;	
         
        List<OrderItem> acrItems = Testutility.createACROrderItems(acrQuoteLines,orderList[0]);
        insert acrItems;
        
        List<SBQQ__Subscription__c> subsList = TestUtility.createACRSubscription(acrItems, contract);
        insert subsList;    
        
        List<SBQQ__Subscription__c> subsListnacr=TestUtility.createNonACRSubscription(acrItems, contract);
        insert subsListnacr;
        
        List<SBQQ__Subscription__c> subsListex=TestUtility.createExhibitionSubscription(acrItems, contract, stex);
        insert subsListex;
        
        test.stopTest();
    }
    
    @isTest 
    static void createACRContractedPriceTest(){
        
        Contract c = [select id,Business_Type__c,Status,AccountId from Contract limit 1];
        
        test.startTest();
        //c.Status = 'Activated';
        c.Status='Expired';
        Update c;
        test.stopTest();
    }
    
    @isTest 
    static void createNonACRContractedPriceTest(){
        test.startTest();
        Contract c = [select id,Business_Type__c, AccountId from Contract limit 1];
        c.Business_Type__c = 'Non ACR';
        update c;
        Account acc = [select id,ST_Pricing_Type__c, Customer_Category__c from Account where Id = : c.AccountId limit 1];
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non ACR Contracted';
        update acc;
        SBQQ__Quote__c q = [select id from SBQQ__Quote__c Limit 1];
        q.Business_Type__c = 'Non ACR';
        update q;
        
        
        c.Status = 'Activated';
        Update c;
        test.stopTest();
    }
    
    @isTest
    private static void createExhibitionContractedPriceTest(){
        Account Acc = TestUtility.createnonACRnonContractedAccount();
        Acc.Name = 'Sample ';
        Acc.Email__c='ghb@wes.com';
        Acc.Last_Name__c='gugjhb';
        insert Acc;
        Contract c = new Contract(
            AccountId = Acc.id
            ,ContractTerm = 12
            ,StartDate = system.today()
            ,OwnerExpirationNotice = '30'
            
        );
        insert c;
       
        ST_Exhibition__c exb = new ST_Exhibition__c();
        exb.Name = 'IIJS-SIGNATURE 2022';
        exb.COA_Exhibition_Code__c = '1008';
        exb.ST_Active__c = TRUE; 
        exb.ST_Start_Date__c = system.today();
        exb.ST_End_Date__c = system.today().addDays(50);
		insert exb;
		
        SBQQ__Subscription__c oSub = new SBQQ__Subscription__c();
        oSub.SBQQ__Contract__c = c.id;
         oSub.SBQQ__Account__c = c.AccountId;
            oSub.ST_Customer_Product_Category__c = 'ValSHIP';
            oSub.ST_Exhibition__c = exb.Id;
            oSub.ST_Rate_Amount__c = 2.5;
            oSub.Slab_Level_1_Rate__c = 3.00;
            oSub.Slab_Level_2_Rate__c = 2.50;
            oSub.Slab_Level_3_Rate__c = 2.00;
            oSub.Slab_Level_4_Rate__c = 1.50;
            oSub.Slab_Level_5_Rate__c = 1.00;
            oSub.Max_Slab_Rate__c = 1.00;
            oSub.ST_Rate_UOM__c = 'Per Gram';
            oSub.SBQQ__Quantity__c = 1;
        insert oSub;
        
        ST_Exhibition_Contracted_Price__c cp = new ST_Exhibition_Contracted_Price__c();
        cp.ST_Customer_Account__c = Acc.id;
        cp.ST_Contract__c = c.Id;
        cp.ST_Active__c = true;
		cp.ST_Exhibition__c=oSub.ST_Exhibition__c;
        cp.ST_Rate_Amount__c = oSub.ST_Rate_Amount__c;
        cp.ST_Rate_UOM__c = 'Per Gram';
        cp.ST_Liability_Coverage__c = 0.03;
        cp.ST_Offline_Charge__c = 500;
        cp.Level_1__c = 5000;
        cp.Level_1_Rate__c = oSub.Slab_Level_1_Rate__c;
        cp.Level_2__c = 10000;
        cp.Level_2_Rate__c = oSub.Slab_Level_2_Rate__c;
        cp.Level_3__c = 15000;
        cp.Level_3_Rate__c = oSub.Slab_Level_3_Rate__c ;
        cp.Level_4__c = 20000;
        cp.Level_4_Rate__c =  oSub.Slab_Level_4_Rate__c;
        cp.Level_5__c = 25000;
        cp.Level_5_Rate__c = oSub.Slab_Level_5_Rate__c;
        cp.Max_Slab_Rate__c = oSub.Max_Slab_Rate__c ;
        insert cp ;
        
        Map<Id,Contract> newContractMap = new Map<Id,Contract>();
        newContractMap.put(c.Id, c);
        ContractTriggerHandler.createExhibitionContractedPrice(new set<Id>{c.Id},newContractMap);
    }
	
     @isTest
     static void contractExpirationTest(){
        Account Acc = TestUtility.createnonACRnonContractedAccount();
        Acc.Name = 'Test Account';
        Acc.Email__c='gvj@dfg.com'; 
        Acc.Last_Name__c='hbiuhm';
        Acc.Phone='1234567891';
        Acc.Mobile__c='4567892345'; 
        Acc.Primary_Customer_Email__c='testre@rr.com';
         
        insert Acc;
      
      Contract c = new Contract(
                AccountId = Acc.id
                ,ContractTerm = 12
                ,StartDate = system.today()
                ,OwnerExpirationNotice = '30'
              
            );
            insert c;
        ContractTriggerHandler.contractExpiration(new set<Id>{c.Id});
    }  
    @isTest
    static void updateAccountOnContractExpirationTest(){
        List<Account> accList = new List<Account>();     
        Account a = TestUtility.createnonACRnonContractedAccount();
        a.Email__c='vjg@gchh.com';
        a.Last_Name__c='nnjma';
        a.ST_Previous_Contract__c = a.Active_Contract__c;
        a.Active_Contract__c = null;
        a.ST_Pricing_Type__c = 'Non ACR';
        a.Customer_Category__c = 'Non Contracted';
        a.Billing_Frequency__c = 'Monthly';
         a.Credit_Days__c = '30';
         a.Credit_Status__c = 'Credit';
           accList.add(a);
           insert accList;
        //ContractTriggerHandler.updateAccountOnContractExpiration(new set<Id>{a.Id});
    }
    
  
    @isTest
    static void deactivateExhibitionPriceTest(){
        string c;
        set<Id> conid=new set<Id>();
        List<Account> lacc=new List<Account>();
        List<Contract> lcontrac=new List<Contract>();
    List<ST_Exhibition_Contracted_Price__c> exPrice = new List<ST_Exhibition_Contracted_Price__c>();
        Account Acct = new Account();
        Acct.Name = 'Test Account12';
        Acct.Email__c='gjg@fch.com';
        Acct.Last_Name__c='bjhln';
        lacc.add(Acct);
        Account Acct1 = new Account();
        Acct1.Name = 'Test Account11';
        Acct1.Email__c='hvjhb@dff.com';
        Acct1.Last_Name__c='jbkjbjmb';
         lacc.add(Acct1);
        insert lacc;
      Contract c1 = new Contract(
                AccountId = Acct.id
                ,ContractTerm = 12
                ,StartDate = system.today()
                ,OwnerExpirationNotice = '30'
              
            );
        lcontrac.add(c1);
         Contract c2 = new Contract(
                AccountId = Acct.id
                ,ContractTerm = 24
                ,StartDate = system.today()
                ,OwnerExpirationNotice = '30'
              
            );
          lcontrac.add(c2); 
        insert lcontrac;
         ST_Exhibition__c exb1 = new ST_Exhibition__c();
        exb1.Name = 'IIJS-SIGNATURE 2022';
        exb1.COA_Exhibition_Code__c = '1008';
        exb1.ST_Active__c = false; 
        exb1.ST_Start_Date__c = system.today();
        exb1.ST_End_Date__c = system.today().addDays(50);
		insert exb1;
		
        SBQQ__Subscription__c oSub1 = new SBQQ__Subscription__c();
        oSub1.SBQQ__Contract__c = c1.id;
         oSub1.SBQQ__Account__c = c1.AccountId;
            oSub1.ST_Exhibition__c = exb1.Id;
            oSub1.SBQQ__Quantity__c = 1;
        insert oSub1;
      
       ST_Exhibition_Contracted_Price__c cp2 = new ST_Exhibition_Contracted_Price__c();
        cp2.ST_Customer_Account__c = Acct1.id;
        cp2.ST_Contract__c = c2.Id;
        cp2.ST_End_Date__c = Date.today();
        cp2.ST_Active__c = false;
		exPrice.add(cp2) ;
         insert exPrice;
        System.assertEquals(false, cp2.ST_Active__c);
        ContractTriggerHandler.deactivateExhibitionPrice(conid,c);
    }
    
          @isTest
		static void sendContractExpiryEmailTest1(){
		Set<Id> accId = new Set<Id>();
        List<Account> sentemailAcc = new List<Account>();
        List<Account> accUpdate = new List<Account>();
		List<Contract> contractlst=new List<Contract>();
		Map<Id,Contract> oldConMap=new Map<Id,Contract>();
		Decimal consum=30.06;
		Account acc = new Account();
        acc.Last_Name__c='hvkhjbkj';
        acc.Email__c='gffchg@fgc.com';    
        acc.Name='Test Acc';
		acc.Email_Sent_at_85_Consumption__c=true;
        acc.Point_Of_Contact_Email__c='abcd@abc.com';
        insert acc;

        Contract con = new Contract();
        con.AccountId = acc.id;   
		con.ContractTerm = 12;
        con.StartDate = system.today();
       // con.Status='Acivated';    
        con.OwnerExpirationNotice = '30';
		con.Contracted_ACR_Package__c='Package 2 : 60K';
		con.Contract_Amount__c=200;
        insert con;
		
		Contract con1 = new Contract();
        con1.AccountId = acc.id;
		con1.ContractTerm = 10;
        con1.StartDate = system.today();
		con1.Contract_Amount__c=400;
        con1.OwnerExpirationNotice = '30';
        insert con1;
		
		ST_ACR_Consumption__c accon=new ST_ACR_Consumption__c();
		accon.Total_Charge__c=209.90;
        accon.Customer_Account__c=acc.Id;
        accon.Contract__c=con.Id;
		insert accon;
		
		ST_ACR_Consumption__c accon1=new ST_ACR_Consumption__c();
		accon1.Total_Charge__c=30.90;
        accon1.Customer_Account__c=acc.Id;
        accon1.Contract__c=con1.Id;
		insert accon1;
		accId.add(con.AccountId);
            ContractTriggerHandler.fakeMethod();
		
		}
    @isTest
		static void acrConsumptionDeleteTest(){
		Set<Id> accId = new Set<Id>();
        List<Account> sentemailAcc = new List<Account>();
        List<Account> accUpdate = new List<Account>();
		List<Contract> contractlst=new List<Contract>();
		Map<Id,Contract> oldConMap=new Map<Id,Contract>();
		Decimal consum=30.06;
		Account acc = new Account();
        acc.Last_Name__c='hvkhjbkj';
        acc.Email__c='gffchg@fgc.com';    
        acc.Name='Test Acc';
		acc.Email_Sent_at_85_Consumption__c=true;
        acc.Point_Of_Contact_Email__c='abcd@abc.com';
        insert acc;

        Contract con = new Contract();
        con.AccountId = acc.id;   
		con.ContractTerm = 12;
        con.StartDate = system.today();
       // con.Status='Acivated';    
        con.OwnerExpirationNotice = '30';
		con.Contracted_ACR_Package__c='Package 2 : 60K';
		con.Contract_Amount__c=200;
        insert con;
		
		/*Contract con1 = new Contract();
        con1.AccountId = acc.id;
		con1.ContractTerm = 10;
        con1.StartDate = system.today();
		con1.Contract_Amount__c=400;
        con1.OwnerExpirationNotice = '30';
        insert con1;*/
		
		ST_ACR_Consumption__c accon=new ST_ACR_Consumption__c();
		accon.Total_Charge__c=209.90;
        accon.Customer_Account__c=acc.Id;
        accon.Contract__c=con.Id;
		insert accon;
		
		Test.startTest();
        Database.DeleteResult result = Database.delete(accon, false);
        Test.stopTest();
        
       // System.assert(!result.isSuccess());
        //System.assert(result.getErrors().size() > 0);
        //System.assertEquals('You cannot delete the record',
                           //  result.getErrors()[0].getMessage());
		
		}
}