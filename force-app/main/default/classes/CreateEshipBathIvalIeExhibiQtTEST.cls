@isTest
Private class CreateEshipBathIvalIeExhibiQtTEST {
	 @testSetup static void testDataSetup(){
         
         Bath_Standard_Pricing__c bathstand= new Bath_Standard_Pricing__c(Secure_logistics_rate__c=300,Visit_Outcome__c='Successful',Origin_Destination_Pairing__c='Within City');
        insert bathstand;
         
         eSHIP_Standard_Pricing__c eshipstand= new eSHIP_Standard_Pricing__c(Gross_Weight_Unit_for_Additional_Weight__c=600, RecordTypeId='0125g000002AVJNAA4',Weight_Covered_Gms__c=700,Weight_Charges__c=900, Logistice_Charges__c=2, Liability_Charges__c=1, Package_Amount__c='50000', Business_Type__c='ACR',Lower_Bound__c=31,Upper_Bound__c=100,Shipment_Type__c='Intracity' );
        insert eshipstand;
         
         eSHIP_Standard_Pricing__c eshipstand1= new eSHIP_Standard_Pricing__c(Gross_Weight_Unit_for_Additional_Weight__c=600, RecordTypeId='0125g000002AVJNAA4',Weight_Covered_Gms__c=700,Weight_Charges__c=900, Logistice_Charges__c=2, Liability_Charges__c=1, Business_Type__c='Non ACR',Lower_Bound__c=31,Upper_Bound__c=100,Shipment_Type__c='Intracity' );
        insert eshipstand1;
         
         
         eSHIP_Standard_Pricing__c eshipstand2= new eSHIP_Standard_Pricing__c(Gross_Weight_Unit_for_Additional_Weight__c=600,  Slab_Criteria__c='Gross Weight Gms',RecordTypeId='0125g000002AVJNAA4',Weight_Covered_Gms__c=700,Weight_Charges__c=900, Logistice_Charges__c=2, Liability_Charges__c=1, Business_Type__c='Non ACR',Lower_Bound__c=31,Upper_Bound__c=100,Shipment_Type__c='Intracity' );
        insert eshipstand2;

        eSHIP_Standard_Pricing__c eshipstand3= new eSHIP_Standard_Pricing__c(Gross_Weight_Unit_for_Additional_Weight__c=600,  Slab_Criteria__c='Invoice Value INR',RecordTypeId='0125g000002AVJNAA4',Weight_Covered_Gms__c=700,Weight_Charges__c=900, Logistice_Charges__c=2, Liability_Charges__c=1, Business_Type__c='Non ACR',Lower_Bound__c=31,Upper_Bound__c=100,Shipment_Type__c='Intracity' );
        insert eshipstand3;

         
         String Uid = UserInfo.getUserId();
         
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BVC BATH',ProductCode='BVC BATH');
        Product2 prodESHIP = new Product2(Name = 'BVC eSHIP',Family = 'BVC eSHIP',ProductCode='BVC eSHIP');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BVC iValSHIP',ProductCode='BVC iValSHIP');
        Product2 prodieSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
        Product2 prodMarketSHIP = new Product2(Name = 'MarketSHIP',Family = 'BVCMarketSHIP',ProductCode='BVCMarketSHIP');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodieSHIP);
        prodList.add(prodExibiSHIP);
        prodList.add(prodMarketSHIP);
        insert prodList;
        list<PricebookEntry> PBentry = new list<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodieSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
         PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodMarketSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice2 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice3 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice4 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodieSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice5 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice6 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodMarketSHIP.Id,UnitPrice = 0, IsActive = true);
        PBentry.add(standardPrice1);
        PBentry.add(standardPrice2);
        PBentry.add(standardPrice3);
        PBentry.add(standardPrice4);
        PBentry.add(standardPrice5);
         PBentry.add(standardPrice6);
        PBentry.add(BVCPrice1);
        PBentry.add(BVCPrice2);
        PBentry.add(BVCPrice3);
        PBentry.add(BVCPrice4);
        PBentry.add(BVCPrice5);
        PBentry.add(BVCPrice6);
        insert PBentry;
        Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test11@gmail.com';
        insert acc;
        
          Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        cc.AccountId=acc.id;
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        Insert cc;
         
     }
    
    @istest static void DealQuoteCreationBathTest(){
        Account acc=[SELECT ID FROM Account];
        Product2 prodBATh=[SELECT ID FROM Product2 WHERE Name='BVC BATH'];

        //Insert Oppourtunity ACR Standard
        List<Opportunity> opp1 = new List<Opportunity>();
        Opportunity opp=new Opportunity();
        opp.BVC_Product__c =prodBATh.id;
        opp.Name = 'test1';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Inbound Lead';
        opp.Business_Type__c='ACR';
        opp.Tariff_Plan__c='Standard';
        opp.Package_Amount__c='50000';
        insert opp;
        CreateEshipBathIvalIeExhibiQTContr.CreateBATHQuote(opp.id);
       
     
          // CreateEshipBathIvalIeExhibiQTContr.CreateQuote(opp.id);
       

      
        //Insert Oppourtunity ACR Custom
        Opportunity opp2=new Opportunity();
        opp2.BVC_Product__c =prodBATh.id;
        opp2.Name = 'test1';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = Date.newInstance(2016, 12, 9);
        opp2.StageName = 'Inbound Lead';
        opp2.Business_Type__c='ACR';
        opp2.Tariff_Plan__c='Custom';
        opp2.Package_Amount__c='50000';
        insert opp2;
        CreateEshipBathIvalIeExhibiQTContr.CreateBATHQuote(opp2.id);
       
    }
    
     

    @istest static void DealQuoteCreationivalShipTest1(){
    Account acc=[SELECT ID FROM Account];
    //Contact con=[SELECT ID FROM Contact];
  
    Product2 prodiVALSHIP=[SELECT ID FROM Product2 WHERE Name='BVC iValSHIP']; 
        
        Opportunity opp3=new Opportunity();
        opp3.BVC_Product__c =prodiVALSHIP.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today();
        opp3.StageName = 'Inbound Lead';
        opp3.Location__c='Mumbai';
        opp3.Product_Category__c='Diamond';
        opp3.Tariff_Plan__c='Standard';
        //opp3.Package_Amount__c='';
        insert opp3;
      	CreateEshipBathIvalIeExhibiQTContr.CreateiVALSHIPQuote(opp3.id); 
       
}

  
     @istest static void DealQuoteCreationEShipTest1(){
        Account acc=[SELECT ID FROM Account];
       // Contact con=[SELECT ID FROM Contact];
        Product2 prodESHIP=[SELECT ID FROM Product2 WHERE Name='BVC eSHIP']; 
                    
        Opportunity opp3=new Opportunity();
         Account acc2= new Account();
        opp3.BVC_Product__c =prodESHIP.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today();
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='ACR';
        opp3.Tariff_Plan__c='Standard';
        opp3.Package_Amount__c='50000';
        opp3.Slab_Criteria__c='Gross Weight Gms';
        insert opp3;
        CreateEshipBathIvalIeExhibiQTContr.CreateeSHIPQuote(opp3.id);
         
       
         } 
    
   @istest static void DealQuoteCreationEShipTest2(){
          Account acc=[SELECT ID FROM Account];
        //Contact con=[SELECT ID FROM Contact];
        Product2 prodESHIP=[SELECT ID FROM Product2 WHERE Name='BVC eSHIP']; 
         Opportunity opp1=new Opportunity();
         Account acc3= new Account();
        opp1.BVC_Product__c =prodESHIP.id;
        opp1.Name = 'test1';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = System.today();
        opp1.StageName = 'Inbound Lead';
        opp1.Business_Type__c='ACR';
        opp1.Tariff_Plan__c='Custom';
        opp1.Package_Amount__c='50000';
        opp1.Is_Deal_with_New_Price__c=true;
        opp1.Slab_Criteria__c='Gross Weight Gms';
        insert opp1;
        CreateEshipBathIvalIeExhibiQTContr.CreateeSHIPQuote(opp1.id);
        
       
    }
    
    
      
    
     @istest static void DealQuoteCreationEShipTest4(){
        Account acc=[SELECT ID FROM Account];
       // Contact con=[SELECT ID FROM Contact];
        Product2 prodESHIP=[SELECT ID FROM Product2 WHERE Name='BVC eSHIP']; 
                    
        Opportunity opp3=new Opportunity();
         Account acc2= new Account();
        opp3.BVC_Product__c =prodESHIP.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today();
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Custom';
        opp3.Package_Amount__c='50000';
        opp3.Slab_Criteria__c='Gross Weight Gms';
         opp3.Is_Deal_with_New_Price__c=false;
        insert opp3;
        CreateEshipBathIvalIeExhibiQTContr.CreateeSHIPQuote(opp3.id);
         
         
         
       
         } 
    
    @istest static void DealQuoteCreationEShipTest6(){
        Account acc=[SELECT ID FROM Account];
        //Contact con=[SELECT ID FROM Contact];
        Product2 prodESHIP=[SELECT ID FROM Product2 WHERE Name='BVC eSHIP']; 
                    
        Opportunity opp3=new Opportunity();
         Account acc2= new Account();
        opp3.BVC_Product__c =prodESHIP.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today();
        opp3.StageName = 'Inbound Lead';
        opp3.Business_Type__c='Non ACR';
        opp3.Tariff_Plan__c='Custom';
        opp3.Package_Amount__c='50000';
        opp3.Slab_Criteria__c='Invoice Value INR';
         opp3.Is_Deal_with_New_Price__c=false;
        insert opp3;
        CreateEshipBathIvalIeExhibiQTContr.CreateeSHIPQuote(opp3.id);
         
       
         } 
   
      @istest static void DealQuoteCreationieSHIPTest(){
        Account acc=[SELECT ID FROM Account];
          Product2 prodExibiSHIP=[SELECT ID FROM Product2 WHERE Name='BVC ieSHIP'];
          Opportunity opp11=new Opportunity();
          Account acc1=new Account();
        opp11.Name = 'test1';
        opp11.AccountId = acc.Id;
        opp11.CloseDate = System.today();
        opp11.StageName = 'Inbound Lead';
        opp11.ieSHIP_Location__c='Mumbai';
        opp11.iSHIP_Sub_Category__c='Ecom';  
        opp11.Tariff_Plan__c='Standard'; 
        insert opp11;
         CreateEshipBathIvalIeExhibiQTContr.CreateieSHIPQuote(opp11.id);
      }
    
          @istest static void CreateExhibiSHIPQuoteTest(){
        Account acc=[SELECT ID FROM Account];
          Product2 prodExibiSHIP=[SELECT ID FROM Product2 WHERE Name='BVC ExhibiSHIP'];
          Opportunity opp11=new Opportunity();
          Account acc1 = new Account();
        opp11.Name = 'test1';
        opp11.AccountId = acc.Id;
        opp11.CloseDate = System.today();
        opp11.StageName = 'Inbound Lead';   
        insert opp11;
         CreateEshipBathIvalIeExhibiQTContr.CreateExhibiSHIPQuote(opp11.id);
      }
    @istest static void DealQuoteCreationMarketSHIPTest(){
        Account acc=[SELECT ID FROM Account];
       // Contact con=[SELECT ID FROM Contact];
        Product2 prodESHIP=[SELECT ID FROM Product2 WHERE Name='MarketSHIP']; 
                    
        Opportunity opp3=new Opportunity();
         Account acc2= new Account();
        opp3.BVC_Product__c =prodESHIP.id;
        opp3.Name = 'test1';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today();
        opp3.StageName = 'Inbound Lead';
        //opp3.Business_Type__c='ACR';
        opp3.Tariff_Plan__c='Standard';
        //opp3.Package_Amount__c='50000';
        //opp3.Slab_Criteria__c='Gross Weight Gms';
        insert opp3;
        CreateEshipBathIvalIeExhibiQTContr.CreateMarketSHIPQuote(opp3.id);
        
        }
    @istest static void DealQuoteCreationEShipTest3(){
          Account acc=[SELECT ID FROM Account];
        //Contact con=[SELECT ID FROM Contact];
        Product2 prodESHIP=[SELECT ID FROM Product2 WHERE Name='BVC eSHIP']; 
       
         Opportunity opp2=new Opportunity();
         opp2.BVC_Product__c =prodESHIP.id;
        opp2.Name = 'test189';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = System.today();
        opp2.StageName = 'Inbound Lead';
        opp2.Business_Type__c='Non ACR';
        opp2.Tariff_Plan__c='Custom';
        opp2.Package_Amount__c=null;
        opp2.Is_Deal_with_New_Price__c=true;
        opp2.Slab_Criteria__c='Gross Weight Gms';
        insert opp2;
        CreateEshipBathIvalIeExhibiQTContr.CreateeSHIPQuote(opp2.id);
        //CreateEshipBathIvalIeExhibiQTContr.CreateQuote(opp2.id);
        CreateEshipBathIvalIeExhibiQTContr.fgMethod();
    }
    
}