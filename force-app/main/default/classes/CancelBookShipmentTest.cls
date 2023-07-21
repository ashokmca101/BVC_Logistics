@istest
public class CancelBookShipmentTest {

    @istest
    public static void  CancelapiSuces() {
        test.startTest();
        Shipment__c objship = new Shipment__c();
        objship.Shipment_Date__c = System.today();
        objship.Cancelled_Reason__c = 'test';
        //objship.Consignee_PAN__c = 'ASFF3432';    
        objship.Shipping_Note_Number__c = 'BM55345';
        objship.Status__c = 'Billed';
        objship.E_Invoice_Number__c = '2223';
        objship.Shipment_Date__c = System.Today() ;
        objship.Shipper_PAN__c = 'Dcw3r3';
        objship.Consignee_PAN__c = 'SFR323';
        objship.Product_Description__c = 'trest';
        objship.Net_Weight__c = 6 ;
        objship.Net_Weight_UOM__c = '6ks';
        objship.Gross_Weight__c = 8 ;
        objship.Gross_Weight_UOM__c = '8kg' ;
        objship.Number_of_Packages__c = 9 ;
        objship.Insurance_By_BVC__c = 'test';
        Insert objship;
        system.debug('----objship'+objship.Id);

        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/CancelBookshipment/';
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        CancelBookShipment.InsertCancelshipment(objship.Shipping_Note_Number__c,objship.Cancelled_Reason__c);
        test.stopTest();
    }
    
    @istest
    public static void  CancelapiError() {
        test.startTest();
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://bvc2--bvcuat.my.salesforce.com/services/apexrest/CancelBookshipment/';
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
       CancelBookShipment.InsertCancelshipment(null,null);
        test.stopTest();
    }
}