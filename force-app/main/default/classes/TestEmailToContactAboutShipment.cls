@isTest(SeeAllData = false)
public class TestEmailToContactAboutShipment {

    static testMethod void testMethod1() {
        Shipment_Lot__c shipLot = new Shipment_Lot__c();
        shipLot.Amount_Calculated_For_All_Shipment__c = true;
        shipLot.Name = 'XYZ'; 
        insert shipLot;
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.Customer_Status__c = 'Active';
        //testAccts.Category__c = 'Merchant';
            testAccts.Type_Of_Customer__c = 'Consignee';
            testAccts.BVC_Legal_Entity__c = 'B.V. Chinai & Co. (India) Private Limited';
        insert testAccts;
        Contact conObj = new Contact();
        conObj.lastname = 'test2';
        conObj.AccountId = testAccts.Id;
        conObj.MobilePhone = '1234567890';
        conObj.Email = 'test@gmail.com';
        conObj.BVC_Finance_Contact__c = true;
        insert conObj;
        Id BillingId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id ShippingId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        AddressBook__c ab=new AddressBook__c();
        ab.name='demo';
        ab.ADDRESS1__c='Address1';
        ab.ADDRESS2__c='Address2';
        ab.CITY__c='city';
        ab.COUNTRY__c='India';
        ab.Customer__c=testAccts.id;
        ab.PINCODE__c='854105';
        ab.District__c='district';
        ab.TRADE_NAME__c=testAccts.name;
        //ab.GSTIN__c='UNREGISTERRED12';
        ab.Is_Billing_Address__c=true;
        ab.RecordTypeId = BillingId;
        ab.GSTIN__c = '';
        insert ab;
        AddressBook__c ab1=new AddressBook__c();
        ab1.name='demo';
        ab1.ADDRESS1__c='Address1';
        ab1.ADDRESS2__c='Address2';
        ab1.CITY__c='city';
        ab1.COUNTRY__c='India';
        ab1.Customer__c=testAccts.id;
        ab1.PINCODE__c='854105';
        ab1.District__c='district';
        //ab1.TRADE_NAME__c=testAccts.name;
        //ab1.GSTIN__c='';
        ab1.RecordTypeId = ShippingId;
        //ab1.Is_Billing_Address__c=false;
        //insert ab1;
        
        
        
        Pickup__c pickObj = new Pickup__c();
        pickObj.Pickup_Address__c  = ab1.Id; 
        pickObj.Name = 'Pickup 1';
        pickObj.Customer__c = testAccts.Id;
        insert pickObj;
        
        List<Shipment__c> shipmentListToInsert = new List<Shipment__c>();
        
        Shipment__c shipObj = new Shipment__c();
        shipObj.Name = 'Shipment 1';
        shipObj.Pickup__c =pickObj.Id;
        shipObj.Customer__c = testAccts.Id;
        shipObj.AddressBook__c = ab1.Id;
        shipObj.Bill_To_Party_PAN__c = 'ABC';
        shipObj.Bill_To_Party_Address__c ='ABC';
        shipObj.Billing_Entity_Name__c ='ABC';
        shipObj.Bill_to_1__c = 'Shipper';
        shipObj.Bill_To_GSTIN__c = 'ABC';
        shipObj.Shipment_Lot__c = shipLot.Id;
        shipObj.Invoice_Calculated_Amount__c = 2222;
        shipObj.Razorpay_Id__c = '123';
        shipObj.Short_URL__c = 'ABCD';
        //insert shipObj;
        shipmentListToInsert.add(shipObj);
        
        Shipment__c shipObjNew = new Shipment__c();
        shipObjNew.Name = 'Shipment 1';
        shipObjNew.Pickup__c =pickObj.Id;
        shipObjNew.Customer__c = testAccts.Id;
        shipObjNew.AddressBook__c = ab1.Id;
        shipObjNew.Bill_To_Party_PAN__c = 'ABC';
        shipObjNew.Bill_To_Party_Address__c ='ABC';
        shipObjNew.Billing_Entity_Name__c ='ABC';
        shipObjNew.Bill_to_1__c = 'Shipper';
        shipObjNew.Bill_To_GSTIN__c = 'ABC';
        shipObjNew.Shipment_Lot__c = shipLot.Id;
        shipObjNew.Invoice_Calculated_Amount__c = 2222;
        shipObjNew.Razorpay_Id__c = '123';
        shipObjNew.Short_URL__c = 'ABCD';
        //shipObjNew.Shipment_Lot__c = shipLot.Id;
        shipObjNew.Shipment_Payment_Status__c = 'Unpaid';
        //insert shipObjNew;
        shipmentListToInsert.add(shipObjNew);
        
        //List<Shipment__c> shipmentList = new List<Shipment__c>();
        //shipmentList.add(shipObj);
        //shipmentList.add(shipObjNew);
        List<Shipment_Lot__c> ShipLotList = New List<Shipment_Lot__c>();
        For(integer i = 0; i<200; i++){
            Shipment_Lot__c ShipLotNew = New Shipment_Lot__c();
            ShipLotNew.Name = 'Test'+i;
            ShipLotNew.Amount_Calculated_For_All_Shipment__c = TRUE;
            ShipLotList.add(ShipLotNew);
        }
        Insert ShipLotList;
        Shipment__c Ship = New Shipment__c();
        Ship.Name = 'TestShipment';
        Ship.Pickup__c = pickObj.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = testAccts.Name;
        Ship.Customer__c = testAccts.Id;
        Ship.Shipment_Lot__c = ShipLotList[1].Id;
        //Insert Ship;
        shipmentListToInsert.add(Ship);
        insert shipmentListToInsert;
        
        List<Shipment_Lot__c> shipmentLotList = new List<Shipment_Lot__c>();
        shipmentLotList.add(shipLot);
       system.debug('shipmentLotList '+shipmentLotList);
        system.debug('shipmentLotList Shipments__r '+shipmentLotList[0].Shipments__r);
        system.debug('shipmentLotList Size:'+shipmentLotList.size());
        List<Shipment__c> shipObjLst= [SELECT Id,Name,Short_URL__c,Invoiced_Amount__c,Invoice_Calculated_Amount__c,Total_Charge__c,Total_Invoice_Value__c,Customer__c,Shipment_Lot__c FROM Shipment__c WHERE Shipment_Lot__c =:shipLot.Id];
        system.debug('shipObjLst:'+shipObjLst);
        MAP<String,List<String>> customerToEmailsMap = new MAP<String,List<String>>();
        customerToEmailsMap.put(conObj.AccountId,new List<String>{conObj.Email}); 
        
         MAP<String,List<String>> customerToEmailsMapNew = new MAP<String,List<String>>();
        Set<Id> customerIds = new  Set<Id>();
         for(Shipment_Lot__c shipLotObj : ShipLotList){
             system.debug('shipLotObj::'+shipLotObj);
             system.debug('shipLotObj Shipments__r::'+shipLotObj.Shipments__r);
            for(Shipment__c shipObjNewVar : shipLotObj.Shipments__r){
                system.debug('shipObjNewVar:'+shipObjNewVar.Customer__c);
                customerIds.add(shipObjNewVar.Customer__c);
            }
        }
        
        List<Contact> contactList =[SELECT Id,Name,Email,BVC_Finance_Contact__c,Phone,MobilePhone,AccountId FROM Contact WHERE AccountId in : customerIds AND Email != null AND BVC_Finance_Contact__c = true];
       
        for(Contact con : contactList){
            customerToEmailsMapNew.put(con.AccountId,new List<String>{con.Email}); 
        }   
        system.debug('mapEmailShip:::'+customerToEmailsMap);
        
        Test.startTest();

        EmailToContactAboutShipment.sendEmailTest1(shipmentLotList, customerToEmailsMapNew);
        EmailToContactAboutShipment.sendEmailTest1(ShipLotList, customerToEmailsMapNew);
        EmailToContactAboutShipment.sendEmailForShipment(shipmentListToInsert,customerToEmailsMap);
        EmailToContactAboutShipment.testcoverage();
        
        Test.stopTest();  
    }
    
    
}