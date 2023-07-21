@isTest
public class TMS_TrackingWebService_Test { 
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Shipment__c Ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, null, null, null, null, false);
        
        Ship.Shipping_Note_Number__c = 'BL00005';
        insert Ship;
         system.debug('Id'+Ship.Id);
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Signature',
            PathOnClient = 'Signature.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
       
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = Ship.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship.id;
        st.Location__c = 'Origin Hub';
        st.Hub__c = DelhiHub.id;
        st.Scan_Time__c = system.now();
        insert st;
        Shipment_Tracking__c st2 = new Shipment_Tracking__c();
        st2.Shipment__c = Ship.id;
        st2.Location__c = 'Origin Hub';
        st2.Hub__c = DelhiHub.id;
        st2.Scan_Time__c = system.now();
        insert st2;
        Shipment_Tracking__c st3 = new Shipment_Tracking__c();
        st3.Shipment__c = Ship.id;
        st3.Location__c = 'Delivered';
        st3.Scan_Time__c = system.now();
        insert st3;
        
        //ARRANGE - setup request like the external system would....
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        system.debug('Debug in test class '+Ship.Shipping_Note_Number__c);
        req.requestURI = '/services/apexrest/ShipmentTracking/'+Ship.Shipping_Note_Number__c;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        //ACT - make the request from inside the test execution context, rather than from the external system
        Test.startTest();
        TMS_TrackingWebService.TrackingInfo cls = new TMS_TrackingWebService.TrackingInfo();
        cls.Scantime = '';
        cls.Location = st.Location__c;
        cls.City = '';
        TMS_TrackingWebService.DeliveryInfo clss = new TMS_TrackingWebService.DeliveryInfo();
        clss.ActualDeliveryTime = '';
        clss.DeliveredTo = '';
        clss.Signature = '';
        TMS_TrackingWebService.getTrackingById();
        Test.stopTest();
    }
}