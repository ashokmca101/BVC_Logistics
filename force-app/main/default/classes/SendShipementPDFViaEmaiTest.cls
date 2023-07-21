@isTest
public class SendShipementPDFViaEmaiTest {
    
    // Create test records in setup method
    // We only have one test method in this case so it's not necessary to create test data here.
    // We could create test records in the test method itself but this could be useful if you want to have
    // additional test methods to test other things
    
    @TestSetup static void testSetup(){
        Shipment__c testShipment = new Shipment__c();
        testShipment.Customer_Product_Category__c = 'GoldSHIP';
        testShipment.Shipper_Email__c = 'test@gmail.com';
        testShipment.Product_Description__c = 'GOLD BAR';
        testShipment.Insurance_By__c = 'BVC';
        testShipment.Net_Weight__c = 12;
        testShipment.Shipment_Value__c = 12;
        
        insert testShipment;
       system.debug('testShipment:::'+testShipment);       
    }
	
    // Test email is sent
    @isTest static void testEmailIsSent(){
        // Retrieve shipment record
        // I usually  retrieve records in a list since it protects against a QueryException (Probably not needed in this case
        // since you know that the shipment record was created and inserted by the setup method.) Just check the list for data before using it
        
        List<Shipment__c> testShipmentList = [Select Id,shipper_email__c FROM shipment__c WHERE Shipper_Email__c = 'test@gmail.com'];
        
        // Check that the test account was actually inserted by the setup method. Again, probably not necessary...
        System.assertEquals(false, testShipmentList.isEmpty(), 'Test Account record does not exist.');
        
        // Create and populate args List of Lists
        List<List<String>> args = new List<List<String>>();
        
        // Email value is expected first
        // shipment record Id value is expected second
        args.add(new List<String>{'test@test.com', testShipmentList[0].Id});
        
        // This creates new set of gov limits and executes all async processes upon the stopTest function call.
        Test.startTest();
        
        // Add shipmentID param for SendShipementPDFViaEmail class
        ApexPages.currentPage().getParameters().put('Id', testShipmentList[0].Id);
                  
        // Call generatePDF method
        SendShipementPDFViaEmail.sendPDF(args);
        
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        // Check that an email was sent
        System.assertEquals(1, emailInvocations, 'Email was not sent.');

    }
}