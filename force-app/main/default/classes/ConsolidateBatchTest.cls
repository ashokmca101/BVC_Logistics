@isTest
public class ConsolidateBatchTest {
    public static String CRON_EXP = '0 0 0 24 8 ? 2022';
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
        insert bvcBranch;
        
        List<Account> accList = new List<Account>();
        Account nonAcrNonContractedAccount = TestUtility.createNonACRnonContractedAccount();
        nonAcrNonContractedAccount.Billing_Frequency__c = 'Weekly';
        nonAcrNonContractedAccount.Last_Name__c = 'test';
        accList.add(nonAcrNonContractedAccount);
        insert accList;
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        insert blngAddress;
        
        accList[0].Billing_Address__c = blngAddress[0].Id;
        update accList[0];
        
        blng__InvoiceScheduler__c scheduler = TestUtility.createInvoiceScheduler();
        insert scheduler;
        blng__InvoiceRun__c invRun  = testUtility.createInvoiceRun(scheduler);
        insert invRun;
        blng__Invoice__c inv = TestUtility.createConsolidatedInvoice(accList[0],invRun.Id,bvcBranch);
        inv.BVC_Branch__c  = bvcBranch.Id;
        inv.BVC_Billing_Entity__c = bvcBranch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = bvcBranch.BVC_Entity__c;
        inv.Billing_Address__c = blngAddress[0].Id;
        insert inv;
        
        blng__InvoiceLine__c invLine = TestUtility.createConsolidatedInvoiceLine(inv);
        invLine.ST_Offline_Charge__c = 2000;
        invLine.Freight_Charges__c = 15000;
        invLine.Liability_Charges__c = 3000;
        insert invLine;
    }
	@isTest
    static void consolidatedInvicetestMethod(){
        test.startTest();
         String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new ConsolidatedTaxRazorpayScheduler());
        Database.executebatch(new ConsolidateTaxCalBatch());
        test.stopTest();
    }
    @isTest
    static void razorpayAllocationTest(){
        test.startTest();
        FetchPaymentsWrapper wrapper = new FetchPaymentsWrapper();
        Test.setMock(HttpCalloutMock.class, new RazorpayHTTPMockResponseGenerator());
        blng__Invoice__c inv = [SELECT Id,blng__InvoiceStatus__c,blng__Account__c,blng__PaymentStatus__c,Razorpay_Id__c,Short_URL__c FROM blng__Invoice__c LIMIT 1];
        blng__InvoiceLine__c invLine = [SELECT Id,blng__Invoice__c,blng__Subtotal__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c = :inv.Id ];
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.Razorpay_Id__c = 'plink_HYqDPHJNGaguCh';
        inv.Short_URL__c = 'https://rzp.io/i/4UtB30o4';
        inv.Total_Freight_Tax__c  = 1000;
        inv.Total_Liability_Charge_Tax__c = 500;
        inv.Total_Offline_Tax__c = 200;
        update inv;
        system.debug('Invoicee:::Consolidated'+inv);
        system.debug('Invoicee Line:::Consolidated'+invLine);
        String jobId = System.schedule('ScheduledApexTest1',CRON_EXP,new RazorpayPaymentAllocationScheduler());
        Database.executebatch(new RazorpayAllocationBatch());
        test.stopTest();
    }
}