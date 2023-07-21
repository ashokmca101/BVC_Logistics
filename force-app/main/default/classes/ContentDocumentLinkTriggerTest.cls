@isTest
public class ContentDocumentLinkTriggerTest 
{
    @isTest public static void validateAttachment() 
    {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        
        
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label', 'YYY7777', 'Available', true);        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipping_Note_Number__c = 'EB78464734';

        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        insert Ship1;
        
        
        
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        insert bag1;
        
        ship1.Destination_Address_Name__c= ShipperAddress.id;
        Update Ship1;
        
        Delivery__c delivery = new Delivery__c();
        delivery.Shipment__c = Ship1.Id;
        delivery.Status__c = 'Accepted';
        delivery.Address__c = ShipperAddress.id;
        delivery.POD__c = false;
        delivery.POD_Link_Url__c = '';
        
        Insert delivery;
              
        ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
        insert contentVersion;
     

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug('101.<==> documents :'+documents[0].Id);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = delivery.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.visibility = 'AllUsers';
        insert cdl;

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = bag1.id;
        cdl1.ContentDocumentId = documents[0].Id;
        cdl1.shareType = 'V';
        cdl1.visibility = 'AllUsers';
        insert cdl1;        

        ContentDocumentLink cdl12 = New ContentDocumentLink();
        cdl12.LinkedEntityId = Ship1.id;
        cdl12.ContentDocumentId = documents[0].Id;
        cdl12.shareType = 'V';
        cdl12.visibility = 'AllUsers';
        insert cdl12; 
        
        delete documents;
        
        
    }
}