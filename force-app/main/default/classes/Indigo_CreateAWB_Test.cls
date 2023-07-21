@isTest
public class Indigo_CreateAWB_Test {

    @isTest
    public static void createIndigoAWB(){
         Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());
        Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
        commodity.Commodity_Code__c = 'SIL';
        commodity.Commodity_Description__c= 'SIL';
        commodity.Name = 'SIL';
        commodity.SHC_Code__c = 'SIL';
        insert commodity;
        
        Linehaul__c linehaulRecord = new Linehaul__c();
        linehaulRecord.Select_Airline__c = 'Indigo';
        linehaulRecord.Commodity_Name__c = commodity.Id;
        linehaulRecord.Flight_Date__c = system.today();
        linehaulRecord.Gross_Weight__c = 100;
        linehaulRecord.Origin__c = 'BOM';
        linehaulRecord.Destination__c = 'HYD';
        linehaulRecord.Shipping_City_Picklist__c = 'Mumbai';
        linehaulRecord.Shipping_Agent_Code_Picklist__c = 'BVCLBOMDOM';
        linehaulRecord.Shipping_Account_Code_Picklist__c = 'BOMBVC';
        linehaulRecord.Shipper_Name__c = 'Test Shipper';
        linehaulRecord.Shipper_Contact_Number__c = '8588007113';
        linehaulRecord.Shipper_EmailID__c = 'test@gmail.com';
        linehaulRecord.Consignee_City_Picklist__c = 'HYDERABAD';
        linehaulRecord.Consignee_Account_Code_Picklist__c = 'HYDBVC';
        linehaulRecord.Consignee_Contact_Number__c = '8588007113';
        linehaulRecord.Consignee_Name__c = 'Test Consignee';
        linehaulRecord.Shipping_Address__c = 'Test address';
        linehaulRecord.Shipping_Country_Code__c = 'IN';
        linehaulRecord.Shipping_Pincode__c = '400001';
        linehaulRecord.Shipping_State__c = 'Mahatrastra';
        linehaulRecord.Consignee_Address__c = 'Test address 2';
        linehaulRecord.Consignee_Pincode__c = '500108';
        linehaulRecord.Consignee_State__c = 'Telangana';
        Insert linehaulRecord;
        Test.startTest();
        Indigo_CreateAWB.getlinehaul(linehaulRecord.Id);
        Indigo_CreateAWB.indigoAWB(linehaulRecord.Id);
        //Indigo_CreateAWB.spiceJetAWB(linehaulRecord.Id);
        Test.stopTest();
    }
    @isTest
    public static void createSpiceJetAWB(){
        Test.setMock(HttpCalloutMock.class, new TMS_FlightSchedule_Batch_Mock()); 
        Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
        commodity.Commodity_Code__c = 'VAL S';
        commodity.Commodity_Description__c= 'VAL SILVER';
        commodity.Name = 'VAL SILVER';
        insert commodity;
        AirLine1__c airline= new AirLine1__c();
        airline.Airline_Name__c= 'SPICEJET';
        Insert airline;
        
        Flight_Schedule__c flight = new Flight_Schedule__c();
        flight.AirLine1__c = airline.Id;
        flight.Name = 'SPICE SG251-BOM-MAA-2022-10-04 19:35:00';
        flight.Origin__c = 'BOM';
        flight.Destination__c = 'MAA';
        flight.Schedule_Time_To_Departure__c = datetime.newInstanceGmt(2022, 10, 04, 19, 35, 00);
        Insert flight;
        
        Linehaul__c linehaulRecord = new Linehaul__c();
        linehaulRecord.Select_Airline__c = 'SPICEJET';
        linehaulRecord.Commodity_Name__c = commodity.Id;
        linehaulRecord.Flight_No_for_SpiceJet_Indigo__c = flight.Id;
        linehaulRecord.Flight_Origin__c = 'BOM';
        linehaulRecord.Flight_Destination__c = 'MAA';
        linehaulRecord.Width_Dimension__c = 10;
        linehaulRecord.Length_Dimension__c = 10;
        linehaulRecord.Height_Dimension__c = 10;
        linehaulRecord.Gross_Weight__c = 100;    
        Insert linehaulRecord;
        Test.startTest();
        Indigo_CreateAWB.getlinehaul(linehaulRecord.Id);
        //Indigo_CreateAWB.indigoAWB(linehaulRecord.Id);
        Indigo_CreateAWB.spiceJetAWB(linehaulRecord.Id);
        Test.stopTest();
    }
}