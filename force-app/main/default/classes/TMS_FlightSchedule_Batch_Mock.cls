@isTest
global class TMS_FlightSchedule_Batch_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json; charset=utf-8');
        string body='';
        if(request.getEndpoint().endswith('/api/login')){
         body ='{"status":"success","code":200,"message":"Login Successfully!","result":{"access_token":"BearereyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vcWEudGhlc3BpY2V0YWcuY29tL2FkbWluL2FwaS9sb2dpbiIsImlhdCI6MTY1OTY4Mjk3MSwiZXhwIjoxNjU5NjkwMTcxLCJuYmYiOjE2NTk2ODI5NzEsImp0aSI6IkQyTTUzR3VkMFJveVpNV3UiLCJzdWIiOiIyNDA1IiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.MyOubc2fhajqvg2P7XIbeXwiJfXFTjSJum4D9m3mNKY","token_type":"bearer","expires_in":7200,"user_data":{"name":"B V C LOGISTICS PRIVATE LIMITED","email":null,"contact_number":null,"user_address":"UNIT NO. 1102, SOLITAIR CORPORATE PARK, 167, GURU HARGOVINDJI MARG, ANDHERI (EAST), MUMBAI MAHARASHT","code":"BVCCENDO","country":"IN","city":"BOM","created_at":"2019-05-23T01:15:25.000000Z","role_id":2,"warehouse_code":"BOM","image_path":null,"is_active":"1","organization_name":"B V C LOGISTICS PRIVATE LIMITED","customer_station":null,"participation_type":"A","latitude":null,"longitude":null,"state":"27","postal_code":"000000","airport_code":"BOM","type":"A2A","default_password":"1","parent_id":0,"default_station":null,"validate_credit":false,"users_profile_image":null},"user_role":{"role_name":"customer","system_type":"CUSTOM_ROLE"}}}';
        }
        else if(request.getEndpoint().endswith('/freighter/list')){
             body ='{"status":"success","code":200,"message":"Data Retrieved Successfully","result":[{"id":5564717,"flight_id":"2945073","departure_date":"2022-08-05","flight_no":"SG537","registration_no":"VT-SYZ","aircraft_type":"737-800B","source":"DEL","destination":"BLR","operational_status":"Operational","dep_bay_no":null,"arr_bay_no":"29","atd":null,"ata":null,"etd":"2022-08-05 20:00:00","eta":"2022-08-05 22:30:00","std":"2022-08-05 20:00:00","sta":"2022-08-05 22:30:00","manufacturer":"BOEING 737","delay_code":null,"delay_reason":null,"dep_delay":null,"is_active":1,"cms_value":"PAX","dom":null,"created_at":"2022-08-05T06:30:15.000000Z","updated_at":"2022-08-05T06:30:15.000000Z"},{"id":5564508,"flight_id":"2897013","departure_date":"2022-08-05","flight_no":"SG191","registration_no":"VT-SXC","aircraft_type":"737-800B","source":"DEL","destination":"BLR","operational_status":"Operational","dep_bay_no":"152","arr_bay_no":"23","atd":"2022-08-05 06:00:00","ata":"2022-08-05 08:50:00","etd":"2022-08-05 06:00:00","eta":"2022-08-05 08:50:00","std":"2022-08-05 06:05:00","sta":"2022-08-05 08:55:00","manufacturer":"BOEING 737","delay_code":null,"delay_reason":null,"dep_delay":null,"is_active":1,"cms_value":"PAX","dom":null,"created_at":"2022-08-05T06:30:14.000000Z","updated_at":"2022-08-05T06:30:14.000000Z"}]}';  
        }   
        else if(request.getEndpoint().endswith('/create-booking')){
            body = '{"status":"success","code": 200,"message":"AWB Saved Successfully","result": {"id": 156706,"awb_number": "775-52303381","booking_type": "A2A","current_status": 27,"mappingrequired": false}}';
        }
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
     
}