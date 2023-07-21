@isTest
public class TMS_LinehaulClass_Test {
    Public static testmethod void testShipments(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u;
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,u.id,'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        ship1.Product_Description__c = 'Gold Jewellery';
        insert Ship1;
        
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Linehaul_Type__c = 'Road';
        bag1.Finalised_Linehaul_Number__c = 'sss';
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Next_Destination__c = 'Delhi';
        //bag1.Current_Scan_Hub__c = DelhiHub.id;
        insert bag1;
        
        //update bag1;
        System.runAs(u){
            TMS_LinehaulClass.Shipments('Finalised',DelhiHub.name);
            test.startTest();
            TMS_LinehaulClass.Shipments('Inbound',DelhiHub.name);
            bag1.Current_Scan_Hub__c = DelhiHub.id;
            bag1.Finalised_Linehaul_Number__c = null;
            
            update bag1;
            TMS_LinehaulClass.Shipments('Outbound',DelhiHub.name);
            Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
            Flight_Schedule__c flight = BVCL_TestDataFactory.createFlight('Delhi-Delhi', DelhiAir.id, DelhiAir.id, true);
            Transport__c Vehicle = BVCL_TestDataFactory.CreateVehicle('Honda12',true);
            TMS_DLHN__c dhln = new TMS_DLHN__c();
            
            bag1.Finalised_Linehaul_Number__c = 'FL2222';
            bag1.Flight_Schedule__c = flight.id;
            bag1.Vehicle__c = Vehicle.id;
            update bag1;
            List<Secure_Bag__c> baglist = new List<Secure_Bag__c>();
            baglist.add(bag1);
            TMS_LinehaulClass.SecureBagWrapper sbWrap = new TMS_LinehaulClass.SecureBagWrapper();
            sbWrap.sb = bag1;
            sbWrap.process = true;
            List<TMS_LinehaulClass.SecureBagWrapper> WrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
            WrapList.add(sbWrap);
            string bagjson = JSON.serialize(WrapList);
            
            
            TMS_LinehaulClass.SecureBagsList(baglist);
            TMS_LinehaulClass.FilteredBagList(baglist, 'Delhi', 'Completed', 'Valuable');
            TMS_LinehaulClass.FilteredBagByDest(baglist, 'Del');
            /*Secure_Packaging__c Seal2 = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ0023232','Available',true);
            TMS_LinehaulClass.AddBox(bagjson, 'EZ333', Seal2.id, 'Delhi');
            
            TMS_LinehaulClass.currentUserHub();
            
            dhln.Name = 'Final Num';
            dhln.Last_Number__c = 1;
            dhln.Finalized_Number__c = 1;
            insert dhln;
            TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111', Flight.id, System.now(), '');
            TMS_LinehaulClass.SaveProcess(bagjson, 'Road', 'FL1111', '', System.now(), Vehicle.id);
            TMS_LinehaulClass.AddBagToLineHaul(bagjson);
            Ship1.Tracking_Status__c = 'Destination Port';
            update Ship1;*/
        }
        test.stopTest();
    }
    Public static testmethod void testShipments2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u;
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,u.id,'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        ship1.Product_Description__c = 'Gold Jewellery';
        insert Ship1;
        
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Linehaul_Type__c = 'Road';
        bag1.Finalised_Linehaul_Number__c = 'sss';
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Next_Destination__c = 'Delhi';
        //bag1.Current_Scan_Hub__c = DelhiHub.id;
        insert bag1;
        
        //update bag1;
        System.runAs(u){
            //TMS_LinehaulClass.Shipments('Finalised',DelhiHub.name);
            //TMS_LinehaulClass.Shipments('Inbound',DelhiHub.name);
            bag1.Current_Scan_Hub__c = DelhiHub.id;
            bag1.Finalised_Linehaul_Number__c = null;
            //update bag1;
            //TMS_LinehaulClass.Shipments('Outbound',DelhiHub.name);
            
            test.startTest();
            Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
            Flight_Schedule__c flight = BVCL_TestDataFactory.createFlight('Delhi-Delhi', DelhiAir.id, DelhiAir.id, true);
            Transport__c Vehicle = BVCL_TestDataFactory.CreateVehicle('Honda12',true);
            TMS_DLHN__c dhln = new TMS_DLHN__c();
            
            bag1.Finalised_Linehaul_Number__c = 'FL2222';
            bag1.Flight_Schedule__c = flight.id;
            bag1.Vehicle__c = Vehicle.id;
            update bag1;
            List<Secure_Bag__c> baglist = new List<Secure_Bag__c>();
            baglist.add(bag1);
            TMS_LinehaulClass.SecureBagWrapper sbWrap = new TMS_LinehaulClass.SecureBagWrapper();
            sbWrap.sb = bag1;
            sbWrap.process = true;
            List<TMS_LinehaulClass.SecureBagWrapper> WrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
            WrapList.add(sbWrap);
            string bagjson = JSON.serialize(WrapList);
            
            
            //TMS_LinehaulClass.SecureBagsList(baglist);
            //TMS_LinehaulClass.FilteredBagList(baglist, 'Delhi', 'Completed', 'Valuable');
            //TMS_LinehaulClass.FilteredBagByDest(baglist, 'Del');
            Secure_Packaging__c Seal2 = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ0023232','Available',true);
            TMS_LinehaulClass.AddBox(bagjson, 'EZ333', Seal2.id, 'Delhi');
            
            TMS_LinehaulClass.currentUserHub();
            
            dhln.Name = 'Final Num';
            dhln.Last_Number__c = 1;
            dhln.Finalized_Number__c = 1;
            insert dhln;
            TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111', Flight.id, System.now(), '');
            TMS_LinehaulClass.SaveProcess(bagjson, 'Road', 'FL1111', '', System.now(), Vehicle.id);
            TMS_LinehaulClass.AddBagToLineHaul(bagjson);
            Ship1.Tracking_Status__c = 'Destination Port';
            update Ship1;
            TMS_LinehaulClass.LoggedInUserHub();
            TMS_LinehaulClass.FilteredByBagNo(bagjson,baglist,'33');
        }
        test.stopTest();
    }
}