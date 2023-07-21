@IsTest
public class TmsUpdateSecureBagTriggerTest {
    @IsTest
    public static void test1() {
        Hub__c hub1 = new Hub__c();
        hub1 = BVCL_TestDataFactory.CreateHub('name', true, 'MUMBAI');
        
        Hub__c hub2 = new Hub__c();
        hub2 = BVCL_TestDataFactory.CreateHub('name1', true, 'DELHI');
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Flight_Schedule__c testFlightSchedule = new Flight_Schedule__c();
        insert testFlightSchedule;
        
        Secure_Bag__c testSecureBag = new Secure_Bag__c();
        testSecureBag.Shipment__c = Ship1.Id;
        testSecureBag.Current_Scan_Hub__c = hub1.Id;
        testSecureBag.Current_Origin_City__c = 'Delhi';
        testSecureBag.Finalised_Linehaul_Number__c = null;
        testSecureBag.Flight_Schedule__c = null;
        testSecureBag.Linehaul_Type__c = null;
        testSecureBag.Next_Destination__c = null;
        testSecureBag.Flight_Date_Time__c = null;
        testSecureBag.Finalized_Time__c = null;
        
        insert testSecureBag;
        
        Secure_Bag__c testSecureBagToUpdate = [SELECT Id, Current_Scan_Hub__c FROM Secure_Bag__c LIMIT 1];
        testSecureBagToUpdate.Current_Scan_Hub__c = hub2.Id;
        
        Test.startTest();
        update testSecureBagToUpdate;
        Test.stopTest();
        
        
    }
    
    
    
    /*
    @IsTest
    public static void test2() {
        
        Shipment__c testShipment = new Shipment__c();
        insert testShipment;
        
        Secure_Bag__c testSecureBag = new Secure_Bag__c();
        testSecureBag.Shipment__c = testShipment.Id;
        testSecureBag.Lock_Status__c = 'Lock';
        
        insert testSecureBag;
        
        Secure_Bag__c testSecureBagToUpdate = [SELECT Id, Lock_Status__c, Seal_Id__c FROM Secure_Bag__c LIMIT 1];
        testSecureBagToUpdate.Lock_Status__c = 'Unlock';
        
        Test.startTest();
        update testSecureBagToUpdate;
        Test.stopTest();
        
        Secure_Bag__c updatedSecureBag = [SELECT Id, Lock_Status__c, Seal_Id__c FROM Secure_Bag__c WHERE Id = :testSecureBagToUpdate.Id];
        System.assertEquals('Unlock', updatedSecureBag.Lock_Status__c);
        System.assertEquals(null, updatedSecureBag.Seal_Id__c);
    }
    
    @IsTest
    public static void test3() {
        
        Shipment__c testShipment = new Shipment__c();
        insert testShipment;
        
        Secure_Bag__c testSecureBag = new Secure_Bag__c();
        testSecureBag.Shipment__c = testShipment.Id;
        testSecureBag.Lock_Status__c = 'Unlock';
        insert testSecureBag;
        
        Secure_Bag__c testSecureBagToUpdate = [SELECT Id, Lock_Status__c, Seal_Id__c FROM Secure_Bag__c LIMIT 1];
        //testSecureBagToUpdate.Seal_Id__c = 'X0737103';
        testSecureBagToUpdate.Lock_Status__c = 'Lock';
        
        Test.startTest();
        update testSecureBagToUpdate;
        Test.stopTest();
        
        Secure_Bag__c updatedSecureBag = [SELECT Id, Lock_Status__c, Seal_Id__c FROM Secure_Bag__c WHERE Id = :testSecureBagToUpdate.Id];
        System.assertEquals('Lock', updatedSecureBag.Lock_Status__c);
        System.assertEquals(null, updatedSecureBag.Seal_Id__c);
    }
    
    @IsTest
    public static void test4() {
        
        Shipment__c testShipment = new Shipment__c();
        insert testShipment;
        
        Secure_Bag__c testSecureBag = new Secure_Bag__c();
        testSecureBag.Next_Destination__c = 'MUMBAI';
        testSecureBag.Shipment__c = testShipment.Id;
        insert testSecureBag;
        
        Secure_Bag__c testSecureBagToUpdate = [SELECT Id, Next_Destination__c FROM Secure_Bag__c LIMIT 1];
        testSecureBagToUpdate.Next_Destination__c = 'MUMBAI';
        
        Test.startTest();
        update testSecureBagToUpdate;
        Test.stopTest();
        
        Secure_Bag__c updatedSecureBag = [SELECT Id, Next_Destination__c FROM Secure_Bag__c WHERE Id = :testSecureBagToUpdate.Id];
        System.assertEquals('MUMBAI', updatedSecureBag.Next_Destination__c);
    }*/
}