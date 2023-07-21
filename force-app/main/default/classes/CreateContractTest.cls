/******************************************
     * Created By: Anamika Shinde
     * Created Date: 06-09-2022
     * Purpose: Test Class  Of CreateContract class createAnnexureInvoice Method
* *****************************************/
@isTest
public class CreateContractTest {
     @testSetup static void testDataSetup(){
    RecordType rec=[SELECT id FROM RecordType WHERE name = 'Billing' and sobjecttype ='Account'];
        Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test1';
        acc.RecordTypeId=rec.id;
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test@bvc.com';
        insert acc;
         
         RecordType rec1=[SELECT id FROM RecordType WHERE name = 'Shipping' and sobjecttype ='Account'];
        Account acc1= new Account();
        acc1.Name='Test shipping';
        acc1.Last_Name__c='Test1';
        acc1.RecordTypeId=rec1.id;
        acc1.PAN_Number_of_Entity__c='546gt89hu7';
        acc1.Primary_Customer_Email__c='test1@bvc.com';
        insert acc1;
       
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
        Product2 prodeSHIP = new Product2(Name = 'BVC eSHIP',Family = 'eSHIP',ProductCode='BVC eSHIP', SBQQ__ChargeType__c='One-Time', blng__BillingRule__c=billingrule.id,blng__RevenueRecognitionRule__c=revrule.id,blng__TaxRule__c=taxrule.id);
        prodList.add(prodeSHIP);
        insert prodList;
          
       list<PricebookEntry> PBentry = new list<PricebookEntry>();
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true); 
          PBentry.add(standardPrice1);
           PBentry.add(BVCPrice1);
          insert PBentry;
       
         
     }
     
  
    
     /* @istest static void createCreateContractTest1(){
          
          list<Product2> prodBATh=[SELECT ID FROM Product2 WHERE Name = 'BVC eSHIP' ];
           List<Account> acc= [SELECT ID FROM Account where RecordTypeId='0125g0000002XavAAE'];
             
       
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodBATh[0].id;
        opp3.Name = 'test1';
        opp3.AccountId = acc[0].Id;
        opp3.CloseDate = Date.newInstance(2016, 12, 9);
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Custom';
        opp3.Package_Amount__c='50000';
        insert opp3;
          
          Contract con1 = new Contract();
        con1.AccountId=acc[0].id;
        con1.StartDate=Date.newInstance(2016, 12, 9);
        con1.Status='Draft';
        con1.ContractTerm=12;
        con1.BVC_Service__c='eSHIP';
        insert con1;
         
        SBQQ__Quote__c newquo1=new SBQQ__Quote__c();
        newquo1.SBQQ__Account__c=acc[0].id;
        newquo1.SBQQ__Opportunity2__c=opp3.id;
        newquo1.Tariff_Plan_Bath_Eship__c='Custom';  
        newquo1.BVC_Service__c='eSHIP';
        newquo1.SBQQ__Primary__c=true;
        newquo1.Package_Amount__c='50000';
        insert newquo1;
        
        
            
        Order neword1=new Order();
        neword1.AccountId=acc[0].id;
        neword1.EffectiveDate=System.today();
        neword1.Status='Draft';
        neword1.ContractId=con1.Id;
        //neword1.Shipment__c=Shipment.id;
        neword1.Consignee_Name__c='Test';
        //neword1.Business_Type__c='ACR';
        neword1.SBQQ__Quote__c=newquo1.ID;
        neword1.blng__BillingDayOfMonth__c='1';
       
        insert neword1;
          
          
       System.debug('Business Type'+neword1.Business_Type__c);
           List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
        blng__Invoice__c inv1=new blng__Invoice__c();
        inv1.blng__Account__c=acc[0].id;
        inv1.blng__Order__c=neword1.id;
      
        insert inv1;
            invlist.add(inv1);
          blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv1.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        //invline.blng__OrderProduct__c=neworderline.id;
        insert invline;
        
          
            
        
        CreateContract.createCreateContract(con1.id);
       CreateAnnexure.createAnnexureInvoice(invlist);
          
         
      }*/
    
    
    
    
    
    
     @istest static void createCreateContractTest5(){
       
         list<Product2> prodBATh=[SELECT ID FROM Product2 WHERE Name = 'BVC BATH' ];
         List<Account> acc= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XavAAE'];
         List<Account> acc1= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XazAAE'];
        Opportunity opp2=new Opportunity();
        opp2.BVC_Product__c =prodBATh[0].id;
        opp2.Name = 'test1';
        opp2.AccountId = acc[0].Id;
        opp2.CloseDate = Date.newInstance(2016, 12, 9);
        opp2.StageName = 'Inbound Lead';
        opp2.Business_Type__c='ACR';
        opp2.Tariff_Plan__c='Standard';
        opp2.Package_Amount__c='50000';
        insert opp2;
          
      
        Contract con = new Contract();
        con.AccountId=acc[0].id;
        con.StartDate=System.today();
        con.Status='Draft';
        con.ContractTerm=12;
        con.BVC_Service__c='BATH';
        insert con;
         /*AddressBook__c add=new AddressBook__c(Name='Bangalore',Customer__c=acc1[0].ID,ADDRESS1__c='Bangalore',Active_Pincode__c='a2e6D000002lnseQAA',Source__c='Manual',RecordTypeId='0125g0000002Xb1AAE',Is_Active__c=true);
         /*insert add;
       /* List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc[0].ID;
        shipment.Customer_Product_Category__c='eSHIP';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=9000;
        Shipment.Shipment_Type__c='Intercity';
        Shipment.No_Of_Attempts__c=2;
        Shipment.Gross_Weight__c=250;
        Shipment.Net_Weight__c=250;
        Shipment.Shipper_Name_TMS__c=acc1[0].ID;
        Shipment.Origin_Address_Name__c=add.id;
        Shipment.RecordTypeId='0126D000002c4J2QAI';
        ListShipment.add(Shipment);
        insert ListShipment;*/
         
        SBQQ__Quote__c newquo=new SBQQ__Quote__c();
        newquo.SBQQ__Account__c=acc[0].id;
        newquo.SBQQ__Opportunity2__c=opp2.id;
        newquo.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo.BVC_Service__c='BATH';
        newquo.SBQQ__Primary__c=true;
        newquo.Is_Uploaded__c=true;
        //newquo.Tariff_Plan_Bath_Eship__c='Standard';
        insert newquo;
       
         
        Order neword=new Order();
        neword.AccountId=acc[0].id;
        neword.EffectiveDate=System.today();
        neword.Status='Draft';
        neword.Contract_ID_Map__c=con.Id;
        //neword.Shipment__c=ListShipment[0].id;
        neword.Consignee_Name__c='Test';
        neword.Business_Type__c='Non ACR';
        neword.SBQQ__Quote__c=newquo.Id;
         neword.blng__BillingDayOfMonth__c='1';
        //neword.BVC_Service__c='BATH';
        insert neword;
        System.debug('Name='+neword.Shipment__c);
         List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
        blng__Invoice__c inv=new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__Order__c=neword.id;
         inv.Product__c=prodBATh[0].id;
        inv.blng__InvoiceStatus__c='Posted';
        insert inv;
         invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC BATH';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        //invline.blng__OrderProduct__c=neworderline.id;
        insert invline;
        CreateContract.createCreateContract(con.id);
        CreateAnnexure.createAnnexureInvoice(inv.id);
         
         
        CreateAnnexure.generateDocumentBathEShip(inv.id);
         
      }
        
     @istest static void createCreateContractTest6(){
       
         list<Product2> prodBATh=[SELECT ID FROM Product2 WHERE Name = 'BVC eSHIP' ];
         List<Account> acc= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XavAAE'];
         List<Account> acc1= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XazAAE'];
        Opportunity opp2=new Opportunity();
        opp2.BVC_Product__c =prodBATh[0].id;
        opp2.Name = 'test1';
        opp2.AccountId = acc[0].Id;
        opp2.CloseDate = Date.newInstance(2016, 12, 9);
        opp2.StageName = 'Inbound Lead';
        opp2.Business_Type__c='ACR';
        opp2.Tariff_Plan__c='Standard';
        opp2.Package_Amount__c='50000';
        insert opp2;
          
      
        Contract con = new Contract();
        con.AccountId=acc[0].id;
        con.StartDate=Date.newInstance(2016, 12, 9);
        con.Status='Draft';
        con.ContractTerm=12;
        con.BVC_Service__c='eSHIP';
        insert con;
         /*AddressBook__c add=new AddressBook__c(Name='Bangalore',Customer__c=acc1[0].ID,ADDRESS1__c='Bangalore',Active_Pincode__c='a2e6D000002lnseQAA',Source__c='Manual',RecordTypeId='0125g0000002Xb1AAE',Is_Active__c=true);
         /*insert add;
       /* List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc[0].ID;
        shipment.Customer_Product_Category__c='eSHIP';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=9000;
        Shipment.Shipment_Type__c='Intercity';
        Shipment.No_Of_Attempts__c=2;
        Shipment.Gross_Weight__c=250;
        Shipment.Net_Weight__c=250;
        Shipment.Shipper_Name_TMS__c=acc1[0].ID;
        Shipment.Origin_Address_Name__c=add.id;
        Shipment.RecordTypeId='0126D000002c4J2QAI';
        ListShipment.add(Shipment);
        insert ListShipment;*/
         
        SBQQ__Quote__c newquo=new SBQQ__Quote__c();
        newquo.SBQQ__Account__c=acc[0].id;
        newquo.SBQQ__Opportunity2__c=opp2.id;
        newquo.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo.BVC_Service__c='eSHIP';
        newquo.SBQQ__Primary__c=true;
        newquo.Is_Uploaded__c=true;
        //newquo.Tariff_Plan_Bath_Eship__c='Standard';
        insert newquo;
       
         
        Order neword=new Order();
        neword.AccountId=acc[0].id;
        neword.EffectiveDate=System.today();
        neword.Status='Draft';
        neword.Contract_ID_Map__c=con.Id;
        //neword.Shipment__c=ListShipment[0].id;
        neword.Consignee_Name__c='Test';
        neword.Business_Type__c='Non ACR';
        neword.SBQQ__Quote__c=newquo.Id;
         neword.blng__BillingDayOfMonth__c='1';
        //neword.BVC_Service__c='BATH';
        insert neword;
        System.debug('Name='+neword.Shipment__c);
         List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
        blng__Invoice__c inv=new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__Order__c=neword.id;
         inv.Product__c=prodBATh[0].id;
        inv.blng__InvoiceStatus__c='Posted';
        insert inv;
         invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='BVC eSHIP';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        //invline.blng__OrderProduct__c=neworderline.id;
        insert invline;
        CreateContract.createCreateContract(con.id);
        CreateAnnexure.createAnnexureInvoice(inv.id);
         
         
        CreateAnnexure.generateDocumentBathEShip(inv.id);
         
      }
      
    /*@istest static void createCreateContractTest6(){
       
         list<Product2> prodBATh=[SELECT ID FROM Product2 WHERE Name = 'BVC BATH' ];
           List<Account> acc= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XavAAE'];
           List<Account> acc1= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XazAAE'];
        Opportunity opp2=new Opportunity();
        opp2.BVC_Product__c =prodBATh[0].id;
        opp2.Name = 'test1';
        opp2.AccountId = acc[0].Id;
        opp2.CloseDate =System.today();
        opp2.StageName = 'Inbound Lead';
        opp2.Business_Type__c='ACR';
        opp2.Tariff_Plan__c='Standard';
        opp2.Package_Amount__c='50000';
        insert opp2;
          
      
        Contract con = new Contract();
        con.AccountId=acc[0].id;
        con.StartDate=Date.newInstance(2016, 12, 9);
        con.Status='Draft';
        con.ContractTerm=12;
        con.BVC_Service__c='BATH';
        insert con;
         AddressBook__c add=new AddressBook__c(Name='Bangalore',Customer__c=acc1[0].ID,ADDRESS1__c='Bangalore',Active_Pincode__c='a2e6D000002lnseQAA',Source__c='Manual',RecordTypeId='0125g0000002Xb1AAE',Is_Active__c=true);
         insert add;
         AddressBook__c add1=new AddressBook__c(Name='Bangalore1',TRADE_NAME__c='Trade',Customer__c=acc[0].ID,ADDRESS1__c='Bangalore',Active_Pincode__c='a2e6D000002lnseQAA',Source__c='Manual',RecordTypeId='0125g0000002Xb0AAE',Is_Active__c=true);
         insert add1;
        List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc[0].ID;
        shipment.Customer_Product_Category__c='eSHIP';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=9000;
        Shipment.Shipment_Type__c='Intercity';
        Shipment.No_Of_Attempts__c=2;
        Shipment.Gross_Weight__c=250;
        Shipment.Net_Weight__c=250;
        Shipment.Shipper_Name_TMS__c=acc1[0].ID;
        Shipment.Origin_Address_Name__c=add.id;
        Shipment.RecordTypeId='0126D000002c4J2QAI';
        ListShipment.add(Shipment);
        insert ListShipment;
         
        SBQQ__Quote__c newquo=new SBQQ__Quote__c();
        newquo.SBQQ__Account__c=acc[0].id;
        //newquo.SBQQ__Opportunity2__c=opp2.id;
        newquo.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo.BVC_Service__c='BATH';
        newquo.SBQQ__Primary__c=true;
        newquo.Is_Uploaded__c=true;
        //newquo.Tariff_Plan_Bath_Eship__c='Standard';
        insert newquo;
       
         
        Order neword=new Order();
        neword.AccountId=acc[0].id;
        neword.EffectiveDate=System.today();
        neword.Status='Draft';
        neword.ContractId=con.Id;
        neword.Shipment__c=ListShipment[0].id;
        neword.Consignee_Name__c='Test';
        neword.Business_Type__c='Non ACR';
        neword.SBQQ__Quote__c=newquo.Id;
        neword.blng__BillingDayOfMonth__c='1';
        neword.Billing_Address__c=add1.id;
        //neword.BVC_Service__c='BATH';
        insert neword;
        System.debug('Name='+neword.Shipment__c);
         List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
        blng__Invoice__c inv=new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__Order__c=neword.id;
      
        insert inv;
         invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='Bath Fright Secure Logistics Charges';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        //invline.blng__OrderProduct__c=neworderline.id;
        insert invline;
        
        
       
        CreateAnnexure.createAnnexureInvoice(invlist);
         
         
        CreateAnnexure.generateDocumentBathEShip(invlist);
      }
      
    
    
    @istest static void createCreateContractTest6(){
       
         list<Product2> prodBATh=[SELECT ID FROM Product2 WHERE Name = 'BVC BATH' ];
           List<Account> acc= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XavAAE'];
           List<Account> acc1= [SELECT ID FROM Account where RecordTypeId=:'0125g0000002XazAAE'];
        List<Pricebook2> BVCPricebook= [SELECT ID FROM Pricebook2 where Name='BVC INR Price Book'];
         List<PricebookEntry> BVCPrice1= [SELECT ID FROM PricebookEntry where Product2Id=:prodBATh[0].id];
        Opportunity opp2=new Opportunity();
        opp2.BVC_Product__c =prodBATh[0].id;
        opp2.Name = 'test1';
        opp2.AccountId = acc[0].Id;
        opp2.CloseDate = Date.newInstance(2016, 12, 9);
        opp2.StageName = 'Inbound Lead';
        opp2.Business_Type__c='ACR';
        opp2.Tariff_Plan__c='Standard';
        opp2.Package_Amount__c='50000';
        insert opp2;
          
      
        Contract con = new Contract();
        con.AccountId=acc[0].id;
        con.StartDate=Date.newInstance(2016, 12, 9);
        con.Status='Draft';
        con.ContractTerm=12;
        con.BVC_Service__c='BATH';
        insert con;
         AddressBook__c add=new AddressBook__c(Name='Bangalore',Customer__c=acc1[0].ID,ADDRESS1__c='Bangalore',Active_Pincode__c='a2e6D000002lnseQAA',Source__c='Manual',RecordTypeId='0125g0000002Xb1AAE',Is_Active__c=true);
         insert add;
      
         
        SBQQ__Quote__c newquo=new SBQQ__Quote__c();
        newquo.SBQQ__Account__c=acc[0].id;
        newquo.SBQQ__Opportunity2__c=opp2.id;
        newquo.Tariff_Plan_Bath_Eship__c='Standard';  
        newquo.BVC_Service__c='BATH';
        newquo.SBQQ__Primary__c=true;
        newquo.Is_Uploaded__c=true;
        //newquo.Tariff_Plan_Bath_Eship__c='Standard';
        insert newquo;
       
         
        Order neword=new Order();
        neword.AccountId=acc[0].id;
        neword.EffectiveDate=System.today();
        neword.Status='Draft';
        neword.ContractId=con.Id;
        //neword.Shipment__c=ListShipment[0].id;
        neword.Consignee_Name__c='Test';
        neword.Business_Type__c='Non ACR';
        neword.SBQQ__Quote__c=newquo.Id;
         neword.blng__BillingDayOfMonth__c='1';
        neword.Pricebook2Id=BVCPricebook[0].id;
        //neword.BVC_Service__c='BATH';
        insert neword;
        
        
        blng__InvoiceRun__c invrun= new blng__InvoiceRun__c();
        invrun.Name='Bath Non-ACR Invoice';
        invrun.blng__Status__c='Completed';
        invrun.blng__TargetDate__c= Date.newInstance(2016, 12, 9);
        insert invrun;
        System.debug('Name='+neword.Shipment__c);
        List<blng__Invoice__c> invlist=new  List<blng__Invoice__c>();
        blng__Invoice__c inv=new blng__Invoice__c();
        inv.blng__Account__c=acc[0].id;
        inv.blng__InvoiceRunCreatedBy__c=invrun.id;
        //inv.blng__Order__c=neword.id;
         OrderItem neworderline=new OrderItem();
        neworderline.OrderId=neword.id;
        neworderline.Product2Id=prodBATh[0].id;
        neworderline.Quantity=1;
        neworderline.PricebookEntryId=BVCPrice1[0].id;
        neworderline.UnitPrice=300;
        insert neworderline;
        insert inv;
        
        
        
         invlist.add(inv);
        blng__InvoiceLine__c invline=new  blng__InvoiceLine__c();
        invline.Name='Bath Fright Secure Logistics Charges';
        invline.blng__Invoice__c=inv.id;
        invline.blng__Quantity__c=1;
        invline.blng__InvoiceLineStatus__c='Posted';
        invline.blng__OrderProduct__c=neworderline.id;
        insert invline;

        

        CreateAnnexure.createAnnexureInvoice(invlist);
         
         
        
      }*/
    
    

}