@isTest
private class callFlightScheduleBatch2_Test {
    @isTest
    static void testCallBatch() {
         Test.setMock(HttpCalloutMock.class, new TMS_FlightSchedule_Batch_Mock()); 
        String response = TMS_FlightScheduleBatch_Button_Helper.generateToken();
        
        //String response ='{"status":"success","code":200,"message":"Login Successfully!","result":{"access_token":"BearereyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vcWEudGhlc3BpY2V0YWcuY29tL2FkbWluL2FwaS9sb2dpbiIsImlhdCI6MTY1OTY4Mjk3MSwiZXhwIjoxNjU5NjkwMTcxLCJuYmYiOjE2NTk2ODI5NzEsImp0aSI6IkQyTTUzR3VkMFJveVpNV3UiLCJzdWIiOiIyNDA1IiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.MyOubc2fhajqvg2P7XIbeXwiJfXFTjSJum4D9m3mNKY","token_type":"bearer","expires_in":7200,"user_data":{"name":"B V C LOGISTICS PRIVATE LIMITED","email":null,"contact_number":null,"user_address":"UNIT NO. 1102, SOLITAIR CORPORATE PARK, 167, GURU HARGOVINDJI MARG, ANDHERI (EAST), MUMBAI MAHARASHT","code":"BVCCENDO","country":"IN","city":"BOM","created_at":"2019-05-23T01:15:25.000000Z","role_id":2,"warehouse_code":"BOM","image_path":null,"is_active":"1","organization_name":"B V C LOGISTICS PRIVATE LIMITED","customer_station":null,"participation_type":"A","latitude":null,"longitude":null,"state":"27","postal_code":"000000","airport_code":"BOM","type":"A2A","default_password":"1","parent_id":0,"default_station":null,"validate_credit":false,"users_profile_image":null},"user_role":{"role_name":"customer","system_type":"CUSTOM_ROLE"}}}';
        string originFlightCode='BOM';
        string endpoint='https://qa.thespicetag.com/admin/api/freighter/list';
        AirLine1__c airline= new AirLine1__c();
        airline.Airline_Name__c= 'SpiceJet';
        insert airline;
       // List<Flight_Schedule__c> response2= TMS_FlightScheduleBatch_Button_Helper.getFlightDetails(response, originFlightCode, endpoint,airline.Id);
        Test.startTest();
        callFlightScheduleBatch2.callBatch();
        Test.stopTest();
        
    }
}