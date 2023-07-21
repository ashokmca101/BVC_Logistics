@isTest
public class ShipmentTrackingWebHookTest {

    @isTest
    public static void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        //Ship1.Is_Signature_Done__c= false;
       
        Ship1.Destination_Address_Name__c = ShipperAddress.Id;
        Ship1.Consignee_Name__c = 'Test Developer';
        Ship1.Consignee_Designation__c = 'Developer';
        Ship1.Delivered_To_Person__c = 'Test Developer';
        
        insert Ship1;

        Shipment_Tracking__c trackingRecord = new Shipment_Tracking__c();
        trackingRecord.Shipment__c = Ship1.Id;
        insert trackingRecord;
        
        List<Shipment_Tracking__c> trackingList = new List<Shipment_Tracking__c>();
        trackingList.add(trackingRecord);
        
        string sign = 'ruirfgerufgduifufurryerioyioyiwjhdfbvdfuirfgurerofhefherhfouerh'; 
        
        Test.startTest();
        Ship1.Tracking_Status__c = 'Delivered';
        Update Ship1;
        Secure_Bag__c secObj = new Secure_Bag__c(
            Shipment__c = Ship1.Id,                   
            Current_Origin_City__c = 'Mumbai',                                            
            Is_Misrouted__c = false,                                                      
            Is_Count_Mismatch__c = false,                                                 
            //POD__c = false,                                                        
            Current_Scan_Loction__c = 'Delivered',                                        
            Last_Scan_Location__c = 'Out for Delivery'
        );
        insert secObj;
        
        Delivery__c delivery = new Delivery__c();
        delivery.Shipment__c = Ship1.Id;
        delivery.Status__c = 'Accepted';
        delivery.Address__c = ShipperAddress.id;
        
        Insert delivery;
        
		String jsoncontent = ShipmentTrackingWebHook.jsonContent(trackingList);
        ShipmentTrackingWebHook.sendRequest(jsoncontent);
        Test.stopTest(); 
    }
}