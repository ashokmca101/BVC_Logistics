@isTest
public class CreditNoteTriggerTest {
    @testSetup
    static void testSetup(){
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
        system.debug('Branches::Test Setup::'+branches);
        List<Account> accList = new List<Account>();
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        accList.add(nonAcrNonContractedAccount);
        
        insert accList;
        
        Contact Con = TestUtility.createContact(accList[0]);
        insert Con;
        
        Contact ConNew = TestUtility.createContact(accList[0]);
        ConNew.LastName = 'Carlsson New';
        ConNew.Email = 'abccarl@abc.com';
        insert ConNew;
        
        //AccountContactRelation acrRec = TestUtility.createAccountContactRelation(nonAcrNonContractedAccount,ConNew);
        //insert acrRec;
        Opportunity opp = TestUtility.createOpportunity(accList,con,ent)[0];
        //List<Opportunity> oppList = new List<Opportunity>{opp};
        insert opp;
        
        List<OpportunityContactRole> roleList = new List<OpportunityContactRole>();
        OpportunityContactRole opptyRole  = TestUtility.createOpportunityContactRole(opp,con,'Decision Maker');
        OpportunityContactRole opptyRole1  = TestUtility.createOpportunityContactRole(opp,ConNew,'Evaluator');
        roleList.add(opptyRole);
        roleList.add(opptyRole1);
        insert roleList;
 
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
        accList[0].Is_Finance_Contact_Present__c = true;
        accList[0].Primary_Address__c = blngAddress[0].Id;
        update accList[0];
        
        List<ST_ACR_Standard_Price__c> stdACRPrice = TestUtility.createACRStandardPrice(prodList);
        insert stdACRPrice;
        
        ST_NonACR_Standard_Price__c noAcrPrice = TestUtility.createNONACRStandardPrice(prodList[1]);
        insert noAcrPrice;
             
        
                                      
        
    }
    
    @isTest
    static void manualCreditNoteTriggerTest(){
        test.startTest();
        
      
        
        Hub__c branch = [SELECT Id,ST_BVC_Billing_Entity__c,BVC_Entity__c FROM Hub__c Limit 1];
        
        
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account nonAcrNonContractedAccountNew = [select id,Billing_Address__c from Account Limit 1 ];
        List<Contact> contactList = new List<Contact>();

        Contact Con = TestUtility.createContact(nonAcrNonContractedAccountNew);
        Con.Email = 'newTest@kadal.com';
        Con.LastName = 'NewTest';
        contactList.add(Con);
        Contact testCon = TestUtility.createContact(nonAcrNonContractedAccountNew);
        testCon.Email = 'juriyadi@hssj.com';
        testCon.LastName = 'essions';
        contactList.add(testCon);
       
        insert contactList;
        List<AccountContactRelation> updateList = new List<AccountContactRelation>();
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: nonAcrNonContractedAccountNew.Id ]){
            acr.Roles = 'Finance; Invoice Recepient';
            updateList.add(acr);
        }
        if(updateList.size()>0){
            update updateList;
        }
        
        
        
        Product2 prod = [select id,Name from Product2 limit 1];

        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c = nonAcrNonContractedAccountNew.Id;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.Billing_Address__C = billingAddress.Id;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.ACR_Cancelled__c = true;
        insert inv;

        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.ST_Offline_Charge__c = 3000;
        invLine.blng__Subtotal__c = 3000;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.Short_URL__c = 'www.google.com';
        inv.Razorpay_Id__c = '67363868268';
        update inv;
        
        blng__Invoice__c invRec = [Select id,Billing_Address__c, blng__Account__c, BVC_Branch__c, BVC_Billing_Entity__c,BVC_Billing_Entity__r.GSTIN_State_Code__c, BVC_Entity__c, blng__BillToContact__c from blng__Invoice__c where blng__InvoiceStatus__c ='Posted' Limit 1];
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = invRec.blng__Account__c;
        creditNote.BVC_Branch__c = invRec.BVC_Branch__c;
        System.debug(' Billing Entity. '+invRec.BVC_Billing_Entity__c);
        System.debug(' Billing Entity GSTN State Code '+invRec.BVC_Billing_Entity__r.GSTIN_State_Code__c);
        creditNote.BVC_Billing_Entity__c = invRec.BVC_Billing_Entity__c;
        creditNote.Billing_Address__c = invRec.Billing_Address__c;
        creditNote.blng__BillToContact__c = invRec.blng__BillToContact__c;
        creditNote.BVC_Entity__c = invRec.BVC_Entity__c;
        creditNote.Reason_for_Credit_Note__c = 'ACR Shipment';
        creditNote.Remark__c = 'ACR Shipment';
        creditNote.blng__RelatedInvoice__c = invRec.Id;
        creditNote.blng__CreditNoteDate__c = System.Today();
        creditNote.Approval_Status__c = 'Approved';
        
        
        insert creditNote;
        
        
        blng__CreditNoteLine__c newCNLine = new blng__CreditNoteLine__c ();
                  	//newCNLine.Type__c ='Master';                   
        newCNLine.Charge_Head_Type__c  = 'Offline Charge';
        newCNLine.blng__CreditNote__c   = creditNote.Id;
        newCNLine.blng__Product__c   = prod.Id;
        newCNLine.blng__Subtotal__c   = 1500;
        
        insert newCNLine;
        
        blng__CreditNote__c creditNote1 = new blng__CreditNote__c();
        creditNote1.blng__Account__c = invRec.blng__Account__c;
        creditNote1.BVC_Branch__c = invRec.BVC_Branch__c;
        creditNote1.Reason_for_Credit_Note__c = 'Duplicate Billing';
        System.debug(' Billing Entity. '+invRec.BVC_Billing_Entity__c);
        System.debug(' Billing Entity GSTN State Code '+invRec.BVC_Billing_Entity__r.GSTIN_State_Code__c);
        creditNote1.BVC_Billing_Entity__c = invRec.BVC_Billing_Entity__c;
        creditNote1.Billing_Address__c = invRec.Billing_Address__c;
        creditNote1.blng__BillToContact__c = invRec.blng__BillToContact__c;
        creditNote1.BVC_Entity__c = invRec.BVC_Entity__c;
        creditNote1.blng__RelatedInvoice__c = invRec.Id;
        creditNote1.blng__CreditNoteDate__c = System.Today();
        
        insert creditNote1;
        
        
        blng__CreditNoteLine__c newCNLine1 = new blng__CreditNoteLine__c ();
         //newCNLine1.Type__c ='Master';           
        newCNLine1.Charge_Head_Type__c  = 'Offline Charge';
        newCNLine1.blng__CreditNote__c   = creditNote1.Id;
        newCNLine1.blng__Product__c   = prod.Id;
        newCNLine1.blng__Subtotal__c   = 1500;
        
        insert newCNLine1;
        
        
        
        
       
        test.stopTest();
    }
    
    @isTest
    static void manualCreditNoteTaxTest(){
        test.startTest();
        
        

        Hub__c branch = [SELECT Id,ST_BVC_Billing_Entity__c,BVC_Entity__c FROM Hub__c Limit 1];
        
        
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        // Account nonAcrNonContractedAccountNew = TestUtility.createNonACRnonContractedAccount();
        // nonAcrNonContractedAccountNew.Invoice_Pre_Approval__c = true;
        // nonAcrNonContractedAccountNew.Is_Finance_Contact_Present__c = true;
        // nonAcrNonContractedAccountNew.Primary_Address__c = billingAddress.Id;
        // nonAcrNonContractedAccountNew.Billing_Address__c = billingAddress.Id;
        // insert nonAcrNonContractedAccountNew;
        Account nonAcrNonContractedAccountNew = [select id,Billing_Address__c from Account Limit 1 ];
        List<Contact> contactList = new List<Contact>();

        Contact Con = TestUtility.createContact(nonAcrNonContractedAccountNew);
        Con.Email = 'newTest@kadal.com';
        Con.LastName = 'NewTest';
        contactList.add(Con);
        Contact testCon = TestUtility.createContact(nonAcrNonContractedAccountNew);
        testCon.Email = 'juriyadi@hssj.com';
        testCon.LastName = 'essions';
        contactList.add(testCon);
        insert contactList;
        List<AccountContactRelation> updateList = new List<AccountContactRelation>();
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: nonAcrNonContractedAccountNew.Id ]){
            acr.Roles = 'Finance; Invoice Recepient';
            updateList.add(acr);
        }
        if(updateList.size()>0){
            update updateList;
        }
        
        
        
        Product2 prod = [select id,Name from Product2 limit 1];

        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c = nonAcrNonContractedAccountNew.Id;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.Billing_Address__C = billingAddress.Id;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.ACR_Cancelled__c = true;
        insert inv;


        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        invLine.ST_Offline_Charge__c = 1500;
        invLine.Freight_Charges__c = 1000;
        invLine.Weight_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.blng__Subtotal__c = 3000;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        inv.blng__InvoiceStatus__c = 'Posted';
        update inv;
        
        blng__Invoice__c invRec = [Select id,Billing_Address__c, blng__Account__c, BVC_Branch__c, BVC_Billing_Entity__c,BVC_Billing_Entity__r.GSTIN_State_Code__c, BVC_Entity__c, blng__BillToContact__c from blng__Invoice__c where blng__InvoiceStatus__c ='Posted' Limit 1];
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = invRec.blng__Account__c;
        creditNote.BVC_Branch__c = invRec.BVC_Branch__c;
        System.debug(' Billing Entity. '+invRec.BVC_Billing_Entity__c);
        System.debug(' Billing Entity GSTN State Code '+invRec.BVC_Billing_Entity__r.GSTIN_State_Code__c);
        creditNote.BVC_Billing_Entity__c = invRec.BVC_Billing_Entity__c;
        creditNote.Billing_Address__c = invRec.Billing_Address__c;
        creditNote.blng__BillToContact__c = invRec.blng__BillToContact__c;
        creditNote.BVC_Entity__c = invRec.BVC_Entity__c;
        creditNote.blng__RelatedInvoice__c = invRec.Id;
        creditNote.blng__CreditNoteDate__c = System.Today();
        creditNote.Approval_Status__c = 'Approved';
        creditNote.Reason_for_Credit_Note__c = 'Duplicate Billing';
        
        insert creditNote;
        
        
        List<blng__CreditNoteLine__c> cnLineList = new List<blng__CreditNoteLine__c>();
        blng__CreditNoteLine__c newCNLine = new blng__CreditNoteLine__c ();
        //newCNLine.Type__c ='Master'; 
        newCNLine.Charge_Head_Type__c  = 'Weight Charge';
        newCNLine.blng__CreditNote__c   = creditNote.Id;
        newCNLine.blng__Product__c   = prod.Id;
        newCNLine.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLine);
        
        blng__CreditNoteLine__c newCNLinedocket = new blng__CreditNoteLine__c ();
        //newCNLinedocket.Type__c ='Master';
        newCNLinedocket.Charge_Head_Type__c  = 'Docket Charge';
        newCNLinedocket.blng__CreditNote__c   = creditNote.Id;
        newCNLinedocket.blng__Product__c   = prod.Id;
        newCNLinedocket.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLinedocket);
        blng__CreditNoteLine__c newCNLineFuel = new blng__CreditNoteLine__c ();
        //newCNLineFuel.Type__c ='Master';
        newCNLineFuel.Charge_Head_Type__c  = 'Fuel Charge';
        newCNLineFuel.blng__CreditNote__c   = creditNote.Id;
        newCNLineFuel.blng__Product__c   = prod.Id;
        newCNLineFuel.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLineFuel);
        blng__CreditNoteLine__c newCNLineHoliday = new blng__CreditNoteLine__c ();
        //newCNLineHoliday.Type__c ='Master';
        newCNLineHoliday.Charge_Head_Type__c  = 'Holiday Charge';
        newCNLineHoliday.blng__CreditNote__c   = creditNote.Id;
        newCNLineHoliday.blng__Product__c   = prod.Id;
        newCNLineHoliday.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLineHoliday);
        blng__CreditNoteLine__c newCNLineBVCValuation = new blng__CreditNoteLine__c ();
        //newCNLineBVCValuation.Type__c ='Master';
        newCNLineBVCValuation.Charge_Head_Type__c  = 'BVC Valuation Charge';
        newCNLineBVCValuation.blng__CreditNote__c   = creditNote.Id;
        newCNLineBVCValuation.blng__Product__c   = prod.Id;
        newCNLineBVCValuation.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLineBVCValuation);
        blng__CreditNoteLine__c newCNLineFreight = new blng__CreditNoteLine__c ();
        //newCNLineFreight.Type__c ='Master';
        newCNLineFreight.Charge_Head_Type__c  = 'Freight Charge';
        newCNLineFreight.blng__CreditNote__c   = creditNote.Id;
        newCNLineFreight.blng__Product__c   = prod.Id;
        newCNLineFreight.blng__Subtotal__c   = 1000;
        cnLineList.add(newCNLineFreight);
        blng__CreditNoteLine__c newCNLineOffline = new blng__CreditNoteLine__c ();
        //newCNLineOffline.Type__c ='Master';
        newCNLineOffline.Charge_Head_Type__c  = 'Offline Charge';
        newCNLineOffline.blng__CreditNote__c   = creditNote.Id;
        newCNLineOffline.blng__Product__c   = prod.Id;
        newCNLineOffline.blng__Subtotal__c   = 1500;
        cnLineList.add(newCNLineOffline);
        
        insert cnLineList;
        
        PageReference pageRef = Page.crediteNoteTaxPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',creditNote.Id);
        CPQ_CNEYTaxCalculation cont = new CPQ_CNEYTaxCalculation();
        cont.doTaxCalculation();
        test.stopTest();
    }
    @isTest
    static void manualCreditNoteCancelTest(){
        test.startTest();
        
        Hub__c branch = [SELECT Id,ST_BVC_Billing_Entity__c,BVC_Entity__c FROM Hub__c Limit 1];
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        // Account nonAcrNonContractedAccountNew = TestUtility.createNonACRnonContractedAccount();
        // nonAcrNonContractedAccountNew.Invoice_Pre_Approval__c = true;
        // nonAcrNonContractedAccountNew.Is_Finance_Contact_Present__c = true;
        // nonAcrNonContractedAccountNew.Primary_Address__c = billingAddress.Id;
        // nonAcrNonContractedAccountNew.Billing_Address__c = billingAddress.Id;
        // insert nonAcrNonContractedAccountNew;
        Account nonAcrNonContractedAccountNew = [select id,Billing_Address__c from Account Limit 1 ];
        Product2 prod = [select id,Name from Product2 limit 1];

        
        Contact Con = TestUtility.createContact(nonAcrNonContractedAccountNew);
        Con.Email = 'newTest@kadal.com';
        Con.LastName = 'NewTest';
        insert Con;
        AccountContactRelation acr = [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: nonAcrNonContractedAccountNew.Id limit 1];
        if(acr != null){
            acr.Roles = 'Finance; Invoice Recepient';
            //update acr;
        }

        
        
        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c = nonAcrNonContractedAccountNew.Id;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.Billing_Address__C = billingAddress.Id;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.blng__BillToContact__c = Con.Id;
        inv.ACR_Cancelled__c = true;
        insert inv;
        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        
        invLine.blng__Invoice__c  = inv.Id;
        invLine.ST_Offline_Charge__c = 1500;
        invLine.Freight_Charges__c = 1000;
        invLine.Weight_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.blng__Subtotal__c = 3000;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
        inv.blng__InvoiceStatus__c = 'Posted';
        update inv;
        List<blng__CreditNote__c> cn1List = new List<blng__CreditNote__c>();
        //blng__Invoice__c invRec = [Select id,Billing_Address__c, blng__Account__c, BVC_Branch__c, BVC_Billing_Entity__c,BVC_Billing_Entity__r.GSTIN_State_Code__c, BVC_Entity__c, blng__BillToContact__c from blng__Invoice__c where blng__InvoiceStatus__c ='Posted' Limit 1];
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = inv.blng__Account__c;
        creditNote.BVC_Branch__c = inv.BVC_Branch__c;
        creditNote.BVC_Billing_Entity__c = inv.BVC_Billing_Entity__c;
        creditNote.Billing_Address__c = inv.Billing_Address__c;
        creditNote.blng__BillToContact__c = inv.blng__BillToContact__c;
        creditNote.BVC_Entity__c = inv.BVC_Entity__c;
        creditNote.blng__RelatedInvoice__c = inv.Id;
        creditNote.blng__CreditNoteDate__c = System.Today();
        creditNote.Approval_Status__c = 'Approved';
        creditNote.Reason_for_Credit_Note__c = 'Duplicate Billing';
        cn1List.add(creditNote);
        insert cn1List;
        system.debug('insert!!!!!'+cn1List);
        
        List<blng__CreditNoteLine__c> cnLineList = new List<blng__CreditNoteLine__c>();
        blng__CreditNoteLine__c newCNLine = new blng__CreditNoteLine__c ();
        	//newCNLine.Type__c = 'Master';
        newCNLine.Charge_Head_Type__c  = 'Weight Charge';
        newCNLine.blng__CreditNote__c   = creditNote.Id;
        newCNLine.blng__Product__c   = prod.Id;
        newCNLine.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLine);
        
        blng__CreditNoteLine__c newCNLinedocket = new blng__CreditNoteLine__c ();
        //newCNLinedocket.Type__c ='Master';
        newCNLinedocket.Charge_Head_Type__c  = 'Docket Charge';
        newCNLinedocket.blng__CreditNote__c   = creditNote.Id;
        newCNLinedocket.blng__Product__c   = prod.Id;
        newCNLinedocket.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLinedocket);
        blng__CreditNoteLine__c newCNLineFuel = new blng__CreditNoteLine__c ();
        //newCNLineFuel.Type__c ='Master';
        newCNLineFuel.Charge_Head_Type__c  = 'Fuel Charge';
        newCNLineFuel.blng__CreditNote__c   = creditNote.Id;
        newCNLineFuel.blng__Product__c   = prod.Id;
        newCNLineFuel.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLineFuel);
        blng__CreditNoteLine__c newCNLineHoliday = new blng__CreditNoteLine__c ();
        //newCNLineHoliday.Type__c ='Master';
        newCNLineHoliday.Charge_Head_Type__c  = 'Holiday Charge';
        newCNLineHoliday.blng__CreditNote__c   = creditNote.Id;
        newCNLineHoliday.blng__Product__c   = prod.Id;
        newCNLineHoliday.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLineHoliday);
        blng__CreditNoteLine__c newCNLineBVCValuation = new blng__CreditNoteLine__c ();
        //newCNLineBVCValuation.Type__c ='Master';
        newCNLineBVCValuation.Charge_Head_Type__c  = 'BVC Valuation Charge';
        newCNLineBVCValuation.blng__CreditNote__c   = creditNote.Id;
        newCNLineBVCValuation.blng__Product__c   = prod.Id;
        newCNLineBVCValuation.blng__Subtotal__c   = 100;
        cnLineList.add(newCNLineBVCValuation);
        blng__CreditNoteLine__c newCNLineFreight = new blng__CreditNoteLine__c ();
        //newCNLineFreight.Type__c ='Master';
        newCNLineFreight.Charge_Head_Type__c  = 'Freight Charge';
        newCNLineFreight.blng__CreditNote__c   = creditNote.Id;
        newCNLineFreight.blng__Product__c   = prod.Id;
        newCNLineFreight.blng__Subtotal__c   = 1000;
        cnLineList.add(newCNLineFreight);
        blng__CreditNoteLine__c newCNLineOffline = new blng__CreditNoteLine__c ();
        //newCNLineOffline.Type__c ='Master';
        newCNLineOffline.Charge_Head_Type__c  = 'Offline Charge';
        newCNLineOffline.blng__CreditNote__c   = creditNote.Id;
        newCNLineOffline.blng__Product__c   = prod.Id;
        newCNLineOffline.blng__Subtotal__c   = 1500;
        cnLineList.add(newCNLineOffline);
        
        insert cnLineList;
        
        blng__CreditNoteAllocation__c  CNAllocation = new blng__CreditNoteAllocation__c ();
        CNAllocation.blng__Amount__c  = 3000;
        CNAllocation.blng__CreditNoteLine__c = newCNLine.Id;
        CNAllocation.blng__InvoiceLine__c =  invLine.Id;
        CNAllocation.blng__Type__c  = 'Allocation';
        insert CNAllocation;
        
        System.debug(' Paymnt status   '+[Select blng__PaymentStatus__c,blng__Order__r.Business_Type__c from blng__Invoice__c where id=:inv.Id]);
        test.stopTest();
    }
     @isTest
    static void manualCreditNoteTriggerTest1(){
        test.startTest();
       
         String BOSCreditnoteid;
        for(recordtype r:[select Id,DeveloperName from RecordType where SobjectType ='blng__CreditNote__c']){
            if(r.DeveloperName == 'BOS_Credit_Note'){
                BOSCreditnoteid = r.id;
            }
        }
       
        
       	blng__BillingRule__c bRule = TestUtility.createBillingRule();
        insert bRule;        
        
        blng__RevenueRecognitionRule__c revRule = TestUtility.createRevenueRule();
        insert revRule;
        
        blng__TaxRule__c taxRule = TestUtility.createTaxRule();
        insert taxRule;
         Product2 prod = new Product2();
        prod.name = 'AIRLINE FREIGHT - CSR';
        prod.ProductCode = 'CB-505';
        prod.blng__BillingRule__c = bRule.Id;
        prod.blng__RevenueRecognitionRule__c = revRule.id;
        prod.blng__TaxRule__c = taxRule.id;
      insert prod;
        
        Hub__c branch = [SELECT Id,ST_BVC_Billing_Entity__c,BVC_Entity__c FROM Hub__c Limit 1];
        
        
        AddressBook__c billingAddress = [SELECT Id FROM AddressBook__c Limit 1];
        Account nonAcrNonContractedAccountNew = [select id,Billing_Address__c from Account Limit 1 ];
        List<Contact> contactList = new List<Contact>();

        Contact Con = TestUtility.createContact(nonAcrNonContractedAccountNew);
        Con.Email = 'newTest@kadal.com';
        Con.LastName = 'NewTest';
        contactList.add(Con);
       
       
        insert contactList;
        List<AccountContactRelation> updateList = new List<AccountContactRelation>();
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where AccountId =: nonAcrNonContractedAccountNew.Id ]){
            acr.Roles = 'Finance; Invoice Recepient';
            updateList.add(acr);
        }
        if(updateList.size()>0){
            update updateList;
        }
        
        
        
        //Product2 prod = [select id,Name from Product2 limit 1];

        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c = nonAcrNonContractedAccountNew.Id;
        inv.BVC_Branch__c = branch.Id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.Billing_Address__C = billingAddress.Id;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.Invoice_Type__c = 'Tax Invoice';
        //inv.ACR_Cancelled__c = true;
        //inv.BVC_CB_Is_CB_Invoice__c =true;
         inv.blng__InvoiceStatus__c = 'Posted';
        insert inv;

        
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c ();
        invLine.blng__Invoice__c  = inv.Id;
        //invLine.ST_Offline_Charge__c = 3000;
        invLine.blng__Subtotal__c = 3000;
        invLine.blng__Product__c = prod.Id;
        invLine.Name = prod.Name;
        insert invLine;
        
       // inv.blng__InvoiceStatus__c = 'Posted';
        //inv.Short_URL__c = 'www.google.com';
        //inv.Razorpay_Id__c = '67363868268';
       // update inv;
        
        blng__Invoice__c invRec = [Select id,Billing_Address__c, blng__Account__c, BVC_Branch__c, BVC_Billing_Entity__c,BVC_Billing_Entity__r.GSTIN_State_Code__c, BVC_Entity__c, blng__BillToContact__c from blng__Invoice__c where blng__InvoiceStatus__c ='Posted' Limit 1];
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = invRec.blng__Account__c;
        creditNote.BVC_Branch__c = invRec.BVC_Branch__c;
        System.debug(' Billing Entity. '+invRec.BVC_Billing_Entity__c);
        System.debug(' Billing Entity GSTN State Code '+invRec.BVC_Billing_Entity__r.GSTIN_State_Code__c);
        creditNote.BVC_Billing_Entity__c = invRec.BVC_Billing_Entity__c;
        creditNote.Billing_Address__c = invRec.Billing_Address__c;
        creditNote.blng__BillToContact__c = invRec.blng__BillToContact__c;
        creditNote.BVC_Entity__c = invRec.BVC_Entity__c;
        creditNote.Reason_for_Credit_Note__c = 'ACR Shipment';
        creditNote.Remark__c = 'ACR Shipment';
        creditNote.blng__RelatedInvoice__c = invRec.Id;
        creditNote.blng__CreditNoteDate__c = System.Today();
        creditNote.Approval_Status__c = 'Approved';
        //creditNote.RecordTypeId =  BOSCreditnoteid ;                            
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        insert creditNote;
        
        
        blng__CreditNoteLine__c newCNLine = new blng__CreditNoteLine__c ();
                  	//newCNLine.Type__c ='CB';                   
        //newCNLine.Charge_Head_Type__c  = 'CUSTOM DUTY-REM';
        newCNLine.blng__CreditNote__c   = creditNote.Id;
        newCNLine.blng__Product__c   = prod.Id;
        newCNLine.blng__Subtotal__c   = 1500;
        
        insert newCNLine;
        CPQ_CNEYTaxCalculation.fakeMethod();       
        test.stopTest();
    }
      
}