@isTest
public class BVCL_TestDataFactory {
    
    public static Account createCustomer(String Name,String recordType,boolean create){
        Account customerRecord = new Account();
        customerRecord.Name = Name;
        customerRecord.Email__c = 'test@gmail88.com';
        customerRecord.Phone = '8956232358';
        customerRecord.Mobile__c= '89562323788';
        customerRecord.Last_Name__c='Test Name888';
        customerRecord.Primary_Customer_Email__c = 'test@gmail888.com';// added by Damco for resloving error in Contact creation
        customerRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if(create)
            insert customerRecord;
        return customerRecord;
    }
    
    public static Transport__c CreateAirport(string name,boolean create){
        Transport__c tp = new Transport__c();
        tp.RecordTypeId = Schema.SObjectType.Transport__c.getRecordTypeInfosByName().get('Airport').getRecordTypeId();
        tp.name = name;
        tp.Airport_Code__c = 'BVC';
        if(create)
            insert tp;
        return tp;
    }
    
    public static Transport__c CreateVehicle(string name,boolean create){
        Transport__c tp = new Transport__c();
        tp.RecordTypeId = Schema.SObjectType.Transport__c.getRecordTypeInfosByName().get('BVC Vehicle').getRecordTypeId();
        tp.name = name;
        tp.Model__c = 'test';
        if(create)
            insert tp;
        return tp;
    }
    
    public static Hub__c CreateHub(string name,boolean create,string branch){
        Hub__c hb = new Hub__c();
        hb.Name = name;
        hb.Branch__c= branch;
        if(create){
            insert hb;
        }
        return hb;
    }
    
    public static Active_Pincode__c CreatePincode(string name,string hub,string city,string district,boolean create){
        Active_Pincode__c ap = new Active_Pincode__c();
        ap.name = name;
        ap.Hub__c = hub;
        ap.City__c = city;
        ap.District__c = district;
        ap.Country__c = 'India';
        if(create)
            insert ap;
        return ap;
    }
    
    public static AddressBook__c CreateAddress(String recordType,string AccId,string AddLine1,String ActivePincode,string city,boolean create){
        AddressBook__c ab = new AddressBook__c();
        ab.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        ab.Customer__c = AccId;
        ab.ADDRESS1__c = AddLine1;
        ab.Active_Pincode__c = ActivePincode;
        ab.CITY__c = city;
        if(create)
            insert ab;
        return ab;
    }
    
    public static Secure_Packaging__c createPackaging(string recordType,string name,string availability, boolean create){
        Secure_Packaging__c pack= new Secure_Packaging__c();
        pack.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        pack.Name = name;
        pack.Status__c = availability;
        if(create)
            insert pack;
        return pack;
    }
    
    public Static Shipment__c CreateShipment(string cust,string shipperAcc,String OriginAddr, String ConsigneeAcc, String DestAddr, boolean create){
        Shipment__c sh = new Shipment__c();
        sh.Customer__c = cust;
        sh.Shipper_Name_TMS__c = shipperAcc;
        sh.Origin_Address_Name__c = OriginAddr;
        sh.Consignee_Name_TMS__c = ConsigneeAcc;
        sh.Destination_Address_Name__c =DestAddr;
        sh.Tracking_Status__c = 'Out for Delivery';
        if(create)
            insert sh;
        return sh;
    }
    
    public static Pickup__c CreatePickup(string CustomerId, String ShippingAcc, String ShipperAddr, boolean create){
        Pickup__c pick = new Pickup__c();
        pick.RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId();
        pick.Customer__c = CustomerId;
        pick.Shipper_Name__c = ShippingAcc;
        pick.Shipper_Address__c = ShipperAddr;
        if(create)
            insert pick;
        return pick;
    }
    
    public static Flight_Schedule__c createFlight(string name,string orignAirport, string DestAirport, Boolean Create){
        Flight_Schedule__c fs = new Flight_Schedule__c();
        fs.Name = name;
        fs.Origin_Airport__c = orignAirport;
        fs.Destination_Airport__c = DestAirport;
        if(Create)
            insert fs;
        return fs;
    }
    
    public static FSE_Sales__c createFSE(string hubId,string UserId,string type, Boolean IsPrimary, Boolean Create){
        FSE_Sales__c fse = new FSE_Sales__c();
        fse.Hub__c = hubId;
        fse.Sales_Person__c = UserId;
        fse.Type__c = type;
        fse.Is_Primary__c = IsPrimary;
        if(Create)
            insert fse;
        return fse;
    }
    
        public Static Shipment_Invoice__c CreateShipmentInvoice(String ShipmentId, Boolean create){
        Shipment_Invoice__c sh = new Shipment_Invoice__c();
		sh.Shipment__c = ShipmentId;
        if(create)
            insert sh;
        return sh;
        }
}