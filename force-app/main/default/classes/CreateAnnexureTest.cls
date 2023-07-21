/******************************************
     * Created By: Anamika Shinde
     * Created Date: 06-09-2022
     * Purpose: Test Method Of CreateAnnexure class createAnnexureInvoice Method
* *****************************************/
@isTest
public class CreateAnnexureTest {

    
    
    
    @testSetup static void testDataSetup(){
         
        RecordType rec=[SELECT id FROM RecordType WHERE name = 'Billing' and sobjecttype ='Account'];
         Account acc= new Account();
        acc.Name='Test1';
        acc.Last_Name__c='Test';
        acc.RecordTypeId=rec.id;
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test1@bvc.com';
        insert acc;
         
        
  	
        
     }
    @istest static void createAnnexureInvoiceTest(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='Non ACR';
        insert newquo1;
        
        
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='Non ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
       
        insert neword1;
      OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
        
        /*blng__InvoiceLine__c invline1=new  blng__InvoiceLine__c();
        invline1.Name='COD Charges';
        invline1.blng__Invoice__c=inv.id;
        invline1.blng__Quantity__c=1;
        invline1.blng__InvoiceLineStatus__c='Posted';
        invline1.blng__OrderProduct__c=neworderline.id;
        insert invline1;
        blng__InvoiceLine__c invline2=new  blng__InvoiceLine__c();
        invline2.Name='Fuel Surcharge';
        invline2.blng__Invoice__c=inv.id;
        invline2.blng__Quantity__c=1;
        invline2.blng__InvoiceLineStatus__c='Posted';
        invline2.blng__OrderProduct__c=neworderline.id;
        insert invline2;
        blng__InvoiceLine__c invline3=new  blng__InvoiceLine__c();
        invline3.Name='Additional Charge';
        invline3.blng__Invoice__c=inv.id;
        invline3.blng__Quantity__c=1;
        invline3.blng__InvoiceLineStatus__c='Posted';
        invline3.blng__OrderProduct__c=neworderline.id;
        insert invline3;
          
        blng__InvoiceLine__c invline4=new  blng__InvoiceLine__c();
        invline4.Name='Weight Charge';
        invline4.blng__Invoice__c=inv.id;
        invline4.blng__Quantity__c=1;
        invline4.blng__InvoiceLineStatus__c='Posted';
       	invline4.blng__OrderProduct__c=neworderline.id;
        insert invline4;*/
        
       
          
            
        CreateAnnexure.createAnnexureInvoice(inv.id);
        
    }
    
    
     @istest static void createAnnexureInvoiceTest1(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='BVC BATH';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='BATH';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='Non ACR';
        insert newquo1;
        
        
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='Non ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
       
        insert neword1;
      OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        insert neworderline;
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
         
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC BAH';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        insert invline;
       
            
        CreateAnnexure.createAnnexureInvoice(inv.id);
         
        
    }
    
    
      @istest static void createAnnexureInvoiceTest2(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='Non ACR';
        insert newquo1;
         Contract con = new Contract();
        con.AccountId=acc[0].id;
        con.StartDate=System.today();
        con.Status='Draft';
        con.ContractTerm=12;
        con.BVC_Service__c='eSHIP';
        insert con;
        
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
       neword1.Status='Draft';
        neword1.ContractId=con.Id;
         //neword1.Status='Activated';
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='Non ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
        
        insert neword1;
          
         con.Status='Activated';
         Update con;
        OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
        
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        //inv.blng__InvoiceRunCreatedBy__c=invrun.id;
         inv.blng__Order__c=neword1.id;
        inv.blng__InvoiceStatus__c='Posted';
        inv.Product__c=prodBATh.id;
        inv.ST_Tax_Percent__c=0.18;
        insert inv;
          
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        invline.Logistics_Charges__c=100;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
        
        /*blng__InvoiceLine__c invline1=new  blng__InvoiceLine__c();
        invline1.Name='COD Charges';
        invline1.blng__Invoice__c=inv.id;
        invline1.blng__Quantity__c=1;
        invline1.blng__InvoiceLineStatus__c='Posted';
        invline1.blng__OrderProduct__c=neworderline.id;
        insert invline1;
        blng__InvoiceLine__c invline2=new  blng__InvoiceLine__c();
        invline2.Name='Fuel Surcharge';
        invline2.blng__Invoice__c=inv.id;
        invline2.blng__Quantity__c=1;
        invline2.blng__InvoiceLineStatus__c='Posted';
        invline2.blng__OrderProduct__c=neworderline.id;
        insert invline2;
        blng__InvoiceLine__c invline3=new  blng__InvoiceLine__c();
        invline3.Name='Additional Charge';
        invline3.blng__Invoice__c=inv.id;
        invline3.blng__Quantity__c=1;
        invline3.blng__InvoiceLineStatus__c='Posted';
        invline3.blng__OrderProduct__c=neworderline.id;
        insert invline3;
          
        blng__InvoiceLine__c invline4=new  blng__InvoiceLine__c();
        invline4.Name='Weight Charge';
        invline4.blng__Invoice__c=inv.id;
        invline4.blng__Quantity__c=1;
        invline4.blng__InvoiceLineStatus__c='Posted';
       	invline4.blng__OrderProduct__c=neworderline.id;
        insert invline4;*/
        
       
          
            
        CreateAnnexure.createAnnexureInvoice(inv.id);
        CreateContract.createCreateContract(con.id);
        InvoiceTriggerHandler.populateinvoiceBathEship(invlist);
          
          
        
    }
    
     @istest static void createAnnexureInvoiceTest3(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
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
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='ACR';
        insert newquo1;
        
        Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        cc.AccountId=acc[0].id;
        cc.Email='contact@bvc.com';
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        Insert cc;
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
        neword1.BVC_Branch__c=newHub.id;
        insert neword1;
         List<OrderItem> orditemlist=new List<OrderItem>();
      OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
         orditemlist.add(neworderline);
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
	    inv.blng__BillToContact__c=cc.id;
        inv.Product__c=prodBATh.id;
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
        
        /*blng__InvoiceLine__c invline1=new  blng__InvoiceLine__c();
        invline1.Name='COD Charges';
        invline1.blng__Invoice__c=inv.id;
        invline1.blng__Quantity__c=1;
        invline1.blng__InvoiceLineStatus__c='Posted';
        invline1.blng__OrderProduct__c=neworderline.id;
        insert invline1;
        blng__InvoiceLine__c invline2=new  blng__InvoiceLine__c();
        invline2.Name='Fuel Surcharge';
        invline2.blng__Invoice__c=inv.id;
        invline2.blng__Quantity__c=1;
        invline2.blng__InvoiceLineStatus__c='Posted';
        invline2.blng__OrderProduct__c=neworderline.id;
        insert invline2;
        blng__InvoiceLine__c invline3=new  blng__InvoiceLine__c();
        invline3.Name='Additional Charge';
        invline3.blng__Invoice__c=inv.id;
        invline3.blng__Quantity__c=1;
        invline3.blng__InvoiceLineStatus__c='Posted';
        invline3.blng__OrderProduct__c=neworderline.id;
        insert invline3;
          
        blng__InvoiceLine__c invline4=new  blng__InvoiceLine__c();
        invline4.Name='Weight Charge';
        invline4.blng__Invoice__c=inv.id;
        invline4.blng__Quantity__c=1;
        invline4.blng__InvoiceLineStatus__c='Posted';
       	invline4.blng__OrderProduct__c=neworderline.id;
        insert invline4;*/
        
       string header2 = 'Heading for ACR Annexure\n';
        
        String recordString2='Test';
        string finalstr2 = header2 + recordString2;
        Attachment att2=new Attachment();
        att2.Body=Blob.valueOf(finalstr2);
        att2.Name='Annexure.csv';
        att2.parentId=inv.id;
        insert att2;
          
         string header1 = 'Heading for ACR Annexure\n';
        
        String recordString1='Test';
        string finalstr1 = header1 + recordString1;
        Attachment att1=new Attachment();
        att1.Body=Blob.valueOf(finalstr1);
        att1.Name='Bath Eship Invoice.pdf';
        att1.parentId=inv.id;
        insert att1;
          
          
            
       // CreateAnnexure.createAnnexureInvoice(invlist);
        //OrderItemTriggerHandler.orderItemFieldUpdate(orditemlist);
        inv.Invoice_Doc_URL__c='send';
        inv.blng__InvoiceStatus__c='Posted';
         //update inv;
        
    }
    
    
    @istest static void createAnnexureInvoiceTest4(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
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
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='ACR';
        insert newquo1;
        
        
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
        //neword1.BVC_Branch__c=newHub.id;
        insert neword1;
         List<OrderItem> orditemlist=new List<OrderItem>();
      OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
         neworderline.BVC_Branch__c=newHub.id;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
         orditemlist.add(neworderline);
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
        
        /*blng__InvoiceLine__c invline1=new  blng__InvoiceLine__c();
        invline1.Name='COD Charges';
        invline1.blng__Invoice__c=inv.id;
        invline1.blng__Quantity__c=1;
        invline1.blng__InvoiceLineStatus__c='Posted';
        invline1.blng__OrderProduct__c=neworderline.id;
        insert invline1;
        blng__InvoiceLine__c invline2=new  blng__InvoiceLine__c();
        invline2.Name='Fuel Surcharge';
        invline2.blng__Invoice__c=inv.id;
        invline2.blng__Quantity__c=1;
        invline2.blng__InvoiceLineStatus__c='Posted';
        invline2.blng__OrderProduct__c=neworderline.id;
        insert invline2;
        blng__InvoiceLine__c invline3=new  blng__InvoiceLine__c();
        invline3.Name='Additional Charge';
        invline3.blng__Invoice__c=inv.id;
        invline3.blng__Quantity__c=1;
        invline3.blng__InvoiceLineStatus__c='Posted';
        invline3.blng__OrderProduct__c=neworderline.id;
        insert invline3;
          
        blng__InvoiceLine__c invline4=new  blng__InvoiceLine__c();
        invline4.Name='Weight Charge';
        invline4.blng__Invoice__c=inv.id;
        invline4.blng__Quantity__c=1;
        invline4.blng__InvoiceLineStatus__c='Posted';
       	invline4.blng__OrderProduct__c=neworderline.id;
        insert invline4;*/
        
       
          
            
       // CreateAnnexure.createAnnexureInvoice(invlist);
        //OrderItemTriggerHandler.orderItemFieldUpdate(orditemlist);
        
    }
    
     
    @istest static void createAnnexureInvoiceTest5(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
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
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='Non ACR';
        insert newquo1;
        
         /*List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc[0].ID;
        Shipment.Is_Uploaded__c=false;
        Shipment.Customer_Product_Category__c='BATH';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=90;
        Shipment.Origin_Destination_Pairing__c='Within City';
        Shipment.Visit_Outcome__c='Successful';
        Shipment.Net_Weight__c=890;
        Shipment.Gross_Weight__c=560;
        Shipment.Shipment_Type__c='Intercity';
        Shipment.Net_Weight_UOM__c='Gram';
        Shipment.Gross_Weight_UOM__c='Gram';
        insert Shipment;
        ListShipment.add(Shipment);
        newquo1.Shipment__c=Shipment.Id;
        update newquo1;*/
        
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='Shipment';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
        //neword1.BVC_Branch__c=newHub.id;
        insert neword1;
         List<OrderItem> orditemlist=new List<OrderItem>();
     /* OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        neworderline.Shipment__c=Shipment.id;
         neworderline.BVC_Branch__c=newHub.id;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
         orditemlist.add(neworderline);*/
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
        //inv.Invoice_Doc_URL__c='send';
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC BATH';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        //invline.blng__OrderProduct__c=neworderline.id;
        //invline.Shipment__c=Shipment.id;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
    
            
       CreateAnnexure.createAnnexureInvoice(inv.id);
        //OrderItemTriggerHandler.orderItemFieldUpdate(orditemlist);
        
    }
    
    
    @istest static void createAnnexureInvoiceTestT(){
        
          
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
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
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='ACR';
        insert newquo1;
        
        Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        cc.AccountId=acc[0].id;
        cc.Email='contact@bvc.com';
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        Insert cc;
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
        //neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
        neword1.BVC_Branch__c=newHub.id;
        insert neword1;
         List<OrderItem> orditemlist=new List<OrderItem>();
      OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
         orditemlist.add(neworderline);
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        //inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__Order__c=neword1.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
	    inv.blng__BillToContact__c=cc.id;
        inv.Product__c=prodBATh.id;
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
        
        /*blng__InvoiceLine__c invline1=new  blng__InvoiceLine__c();
        invline1.Name='COD Charges';
        invline1.blng__Invoice__c=inv.id;
        invline1.blng__Quantity__c=1;
        invline1.blng__InvoiceLineStatus__c='Posted';
        invline1.blng__OrderProduct__c=neworderline.id;
        insert invline1;
        blng__InvoiceLine__c invline2=new  blng__InvoiceLine__c();
        invline2.Name='Fuel Surcharge';
        invline2.blng__Invoice__c=inv.id;
        invline2.blng__Quantity__c=1;
        invline2.blng__InvoiceLineStatus__c='Posted';
        invline2.blng__OrderProduct__c=neworderline.id;
        insert invline2;
        blng__InvoiceLine__c invline3=new  blng__InvoiceLine__c();
        invline3.Name='Additional Charge';
        invline3.blng__Invoice__c=inv.id;
        invline3.blng__Quantity__c=1;
        invline3.blng__InvoiceLineStatus__c='Posted';
        invline3.blng__OrderProduct__c=neworderline.id;
        insert invline3;
          
        blng__InvoiceLine__c invline4=new  blng__InvoiceLine__c();
        invline4.Name='Weight Charge';
        invline4.blng__Invoice__c=inv.id;
        invline4.blng__Quantity__c=1;
        invline4.blng__InvoiceLineStatus__c='Posted';
       	invline4.blng__OrderProduct__c=neworderline.id;
        insert invline4;*/
        
       string header2 = 'Heading for ACR Annexure\n';
        
        String recordString2='Test';
        string finalstr2 = header2 + recordString2;
        Attachment att2=new Attachment();
        att2.Body=Blob.valueOf(finalstr2);
        att2.Name='Annexure.csv';
        att2.parentId=inv.id;
        insert att2;
          
         string header1 = 'Heading for ACR Annexure\n';
        
        String recordString1='Test';
        string finalstr1 = header1 + recordString1;
        Attachment att1=new Attachment();
        att1.Body=Blob.valueOf(finalstr1);
        att1.Name='Bath Invoice.pdf';
        att1.parentId=inv.id;
        insert att1;
          
       
            
       // CreateAnnexure.createAnnexureInvoice(invlist);
        //OrderItemTriggerHandler.orderItemFieldUpdate(orditemlist);
        inv.Invoice_Doc_URL__c='send';
        inv.blng__InvoiceStatus__c='Posted';
         update inv;
        
    }
    
    
      @istest static void createAnnexureInvoiceTesttt(){
        
        
            String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
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
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;
        blng__BillingRule__c billingrule= new blng__BillingRule__c();
        billingrule.Name='Separate Partial Periods';
         billingrule.blng__InitialBillingTrigger__c='Order Product Activation Date';
         billingrule.blng__PartialPeriodTreatment__c='Separate';
         billingrule.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
         billingrule.blng__GenerateInvoices__c='Yes';
         billingrule.blng__Active__c=true;
        insert billingrule;
        
        blng__RevenueRecognitionRule__c revrule=new blng__RevenueRecognitionRule__c();
        revrule.Name='Standard Revenue Recognition Rule';
        revrule.blng__CreateRevenueSchedule__c='Yes';
        revrule.blng__Active__c=true;
        insert revrule;
        
        blng__TaxRule__c taxrule=new blng__TaxRule__c();
        taxrule.Name='Standard Tax Rule';
        taxrule.blng__TaxableYesNo__c='No';
         taxrule.blng__Active__c=true;
        insert taxrule;
        list<Product2> prodList = new list<Product2>();
        Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BATH',ProductCode='BVC BATH', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodBATh);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
          
 		List<Account> acc= [SELECT ID FROM Account];

        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        
        insert invrun;
        
 		eSHIP_Standard_Pricing__c eshipStand=new eSHIP_Standard_Pricing__c(Business_Type__c=' Non ACR',Rate_INR__c=500);
         insert eshipStand;
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        insert opp3;
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Business_Type__c='Non ACR';
        insert newquo1;
        
         /*List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc[0].ID;
        Shipment.Is_Uploaded__c=false;
        Shipment.Customer_Product_Category__c='BATH';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=90;
        Shipment.Origin_Destination_Pairing__c='Within City';
        Shipment.Visit_Outcome__c='Unsuccessful';
        Shipment.Net_Weight__c=890;
        Shipment.Gross_Weight__c=560;
        Shipment.Shipment_Type__c='Intercity';
        Shipment.Net_Weight_UOM__c='Gram';
        Shipment.Gross_Weight_UOM__c='Gram';
        insert Shipment;
        ListShipment.add(Shipment);
        newquo1.Shipment__c=Shipment.Id;
        update newquo1;*/
        
       
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        //neword1.ContractId=con1.Id;
       // neword1.Shipment__c=ListShipment[0].id;
        neword1.Consignee_Name__c='Test';
        neword1.Business_Type__c='Shipment';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
        neword1.Pricebook2Id=BVCPricebook.id;
        //neword1.BVC_Branch__c=newHub.id;
        insert neword1;
        /* List<OrderItem> orditemlist=new List<OrderItem>();
      OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword1.id;
        neworderline.Product2Id=prodBATh.id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1.id;
        neworderline.UnitPrice=300;
        neworderline.Shipment__c=Shipment.id;
         neworderline.BVC_Branch__c=newHub.id;
        neworderline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert neworderline;
         orditemlist.add(neworderline);*/
    	List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
          blng__Invoice__c inv =new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        inv.blng__InvoiceStatus__c='Post In progress';
        inv.ST_Tax_Percent__c=0.18;
        //inv.Invoice_Doc_URL__c='send';
        insert inv;
        invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC BATH';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
       // invline.blng__OrderProduct__c=neworderline.id;
        //invline.Shipment__c=Shipment.id;
        invline.BATHeSHIPChargesMap__c='{"WeightCharge":650.00,"LiabilityCharges":0.00,"FuelSurcharge":25.00,"eSHIPFreight":500.00,"CODCharges":0.00,"AdditionalCharge":2000.00}';
        insert invline;
    
            
       CreateAnnexure.createAnnexureInvoice(inv.id);
       // OrderItemTriggerHandler.orderItemFieldUpdate(orditemlist);
        
    }
    
}