@istest
public class SendInvoice_Ctrl_test {
@istest
    public static void sendEmailwithAttachment(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer 23','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer 24','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label', 'YYY7777', 'Available', true);
         test.startTest();
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipping_Note_Number__c = 'EB78464734';
        ship1.Product_Code__c = 'VAL-EX-C2C';
        ship1.Shipment_Date__c = system.today(); 
        ship1.Gross_Weight__c = 8000; 
        insert Ship1;
        system.debug('Shipment Inserted === '+Ship1);
        
        //ship1.Verified_for_Billing__c = true;
        //Update ship1;
        
        Order orderRecord = new Order();
        orderRecord.AccountId = BillingAcc.id;
        OrderRecord.Status = 'Draft'; 
        OrderRecord.Shipment__c = ship1.Id;
        OrderRecord.EffectiveDate = System.today();
        Insert OrderRecord; 
        
        
        system.debug('Shipment Updated === '+Ship1);
        blng__Invoice__c invoiceRecord = new blng__Invoice__c();
        invoiceRecord.blng__Account__c =  BillingAcc.Id;
        invoiceRecord.blng__Order__c =     OrderRecord.Id;  
        InvoiceRecord.Razorpay_Id__c = 'plink_JGScM65gXV98AO';
        InvoiceRecord.blng__InvoiceStatus__c = 'Posted';
        InvoiceRecord.ST_Invoice_Series__c = '2578981';
        InvoiceRecord.Short_URL__c = 'https://rzp.io/i/7AJtJMg';
        
        Insert InvoiceRecord;
        system.debug('Invoice Inserted === '+InvoiceRecord);
        system.debug('Short_URL__c Inserted === '+InvoiceRecord.Short_URL__c);
        system.debug('Name Inserted === '+InvoiceRecord.Name);
         system.debug('ST_Invoice_Series__c Inserted === '+InvoiceRecord.ST_Invoice_Series__c);
        blng__Payment__c paymentRecord= new blng__Payment__c();
        paymentRecord.blng__Account__c = BillingAcc.Id;
        paymentRecord.blng__Amount__c = 100;
        paymentRecord.blng__Invoice__c= invoiceRecord.Id;
        paymentRecord.blng__Status__c= 'Draft';
        insert paymentRecord;
        system.debug('paymentRecord Inserted === '+paymentRecord);
        
        blng__PaymentAllocationInvoice__c paymentAllocationRecord = new blng__PaymentAllocationInvoice__c();
        paymentAllocationRecord.blng__Payment__c= paymentRecord.Id;
        paymentAllocationRecord.blng__Invoice__c= InvoiceRecord.Id;
        paymentAllocationRecord.blng__Amount__c= 100;
        insert paymentAllocationRecord; 
        system.debug('paymentAllocationRecord Inserted === '+paymentAllocationRecord);
        
        Ship1.Order__c = OrderRecord.Id;
        Update Ship1;
        
        String name = '';
        for(blng__Invoice__c inv : [SELECT Id,name from blng__Invoice__c where id=: InvoiceRecord.Id]){
            name = inv.name;
            system.debug('Name '+name);
        }
        Shipment_Invoice__c shpInviceRecord = BVCL_TestDataFactory.CreateShipmentInvoice(Ship1.Id, false); 
        shpInviceRecord.Payment_Link__c= 'https://rzp.io/i/5NoApZpPOV';
        //shpInviceRecord.Invoice_Number__c = InvoiceRecord.Name;
        shpInviceRecord.Invoice_Number__c = name;
        shpInviceRecord.Invoice_Amount__c = 110;
        shpInviceRecord.Invoice_Date__c = system.today();
        insert shpInviceRecord;
        system.debug('shpInviceRecord Inserted === '+shpInviceRecord);
        system.debug('InvoiceRecord.Name=== '+InvoiceRecord.Name);
        system.debug('Invoice Name on SI === '+shpInviceRecord.Invoice_Number__c);
        
        
        Payment__c shppaymentRecord = new Payment__c();
        shppaymentRecord.Shipment_Invoice__c = shpInviceRecord.Id;
        shppaymentRecord.Amount__c = 110;
        insert shppaymentRecord;
        system.debug('Payment__c Inserted === '+shppaymentRecord);
        
        
        
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=shpInviceRecord.id;
        insert attach;
        system.debug('attach Inserted === '+attach);
        
       
        SendInvoice_ctlr.flowParameters wrapperMethod= new SendInvoice_ctlr.flowParameters();
        wrapperMethod.email= 'email@2345.com';
        wrapperMethod.recIds= Ship1.Id;
        wrapperMethod.firstName= 'faraz';
        //SendInvoice_ctlr.sendEmailwithAttachment();
        List<sendInvoice_ctlr.flowparameters> para = new List<sendInvoice_ctlr.flowparameters>();
        //para.add(new sendInvoice_ctlr.flowparameters('test@email.com', Ship1.Id, 'Mrinal'));
        para.add(wrapperMethod);
        SendInvoice_ctlr.sendEmailwithAttachment(para);
        test.stopTest();
    }
}