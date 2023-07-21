@isTest(SeeAllData=true)
public class Indigo_TrackAWB_Batch_Test {
@isTest 
    public static void generateToken_TestUnit() { 
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());
        String response = FlightScheduleBatch_Button_Helper.generateToken();
        if(response != null && response != ''){
         String response2 = FlightScheduleBatch_Button_Helper.generateSessionId();
        }
        Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
        commodity.Commodity_Code__c = 'SIL';
        commodity.Commodity_Description__c= 'SIL';
        commodity.Name = 'SIL';
        commodity.SHC_Code__c = 'SIL';
        insert commodity;
        List<Linehaul__c> awbList  = new List<Linehaul__c>();
        Linehaul__c linehaulRecord = new Linehaul__c();
        linehaulRecord.AWB_Number__c = '23456799';
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
         awbList.add(linehaulRecord);
        
        
        String originFlightCode = 'HYD';
        String indigoLoginName = 'BVCLBOM';
        String indigoAirlineCode = '6E';
        String indigoEndpoint = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GetTrackingInfoV2';
        AirLine1__c airline= new AirLine1__c();
        airline.Airline_Name__c= 'Indigo';
         Map<String,String> awbStatusMap = new Map<String,String>();
         AWB_Tracking_Status__mdt[] awbStatusList = [SELECT MasterLabel,Indigo_AWB_Status__c 
                                                 FROM AWB_Tracking_Status__mdt 
                                                 WHERE 
                                                 DeveloperName = 'AWB_Booked' OR DeveloperName = 'AWB_Finalized' OR DeveloperName = 'Airline_Deposited' OR 
                                                 DeveloperName = 'On_Route_Airport' OR DeveloperName = 'Pre_Flight_at_Airport' OR DeveloperName = 'Flight_Departed'OR
                                                 DeveloperName = 'Flight_Arrived' OR DeveloperName = 'Pre_Retrieval_at_Airport' OR DeveloperName = 'Retrieved'];
        for(AWB_Tracking_Status__mdt awbStatus : awbStatusList){
            if(awbStatus.Indigo_AWB_Status__c != null && awbStatus.Indigo_AWB_Status__c !=''){
                if(awbStatus.MasterLabel != null && awbStatus.MasterLabel != ''){
                    awbStatusMap.put(awbStatus.Indigo_AWB_Status__c,awbStatus.MasterLabel);
                }
                
            }
            
        }

        
        Test.startTest();
        
        List<Linehaul_Tracking__c> response3 = Indigo_TrackAWB_Helper.trackAWB(awbList,response,awbStatusMap);
        
        Database.executeBatch(new Indigo_TrackAWB_Batch(),200);
        Test.stopTest();
    }
}