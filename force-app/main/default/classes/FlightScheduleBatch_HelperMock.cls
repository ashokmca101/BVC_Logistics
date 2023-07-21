@isTest
global class FlightScheduleBatch_HelperMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json; charset=utf-8'); 
        String body = '';
         String body1 = '';
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/GenerateToken')){
        body = '{"d":"RESULT_START:{\\"Table\\":[{\\"TokenNumber\\":\\"CEF99B1B-B29A-484A-8583-0A12DBBC1941\\"}]}:RESULT_END"}';
       // body1 =  JSON.(Body);
       
        }
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/GetUserDetails')){
            body = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\"Table\\":[{\\"AgentCode\\":\\"BVCLBOMDOM\\",\\"ControllingLocator\\":null,\\"CreditController\\":\\"BVCLCNTRAL\\",\\"IsActive\\":true,\\"SessionID\\":\\"dd57776e-f47c-4190-b1ef-31d2f8c5dec6\\",\\"RetStatus\\":\\"Success\\",\\"RoleName\\":\\"Agent\\",\\"AgentName\\":\\"BVC LOGISTICS PRIVATE LIMITED\\",\\"UserType\\":\\"\\",\\"RoleType\\":\\"AGTEXEC\\",\\"AgentBalance\\":2836642.67,\\"AgentEmail\\":\\"\\",\\"AgentContact\\":\\"1111111111\\"}]}:RESULT_END"}';
        }
         if(request.getEndpoint().endswith('SKMobilityWS.asmx/GetFlightListV2')){
             body = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\"Table\\":[{\\"ScheduleID\\":2286201,\\"FltNumber\\":\\"6E122\\",\\"FltOrigin\\":\\"PNQ\\",\\"FltDestination\\":\\"GOI\\",\\"FltDate\\":\\"2022-11-03T00:00:00\\",\\"ArrTime\\":\\"01:05\\",\\"DeptTime\\":\\"00:05\\",\\"LegSequence\\":16193898,\\"DepDateTime\\":\\"2022-11-03T00:05:00\\",\\"ArrDateTime\\":\\"2022-11-03T01:05:00\\",\\"STATUS\\":null}]}:RESULT_END"}';
         }
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/SaveBookingRequestWY')){
            body = '{"d": "RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\"Table6\\":[{\\"ErrorCode\\":0,\\"ErrorDesc\\":\\"AWB booked successfully and is waiting for confirmation\\",\\"AWBNumber\\":\\"26469332\\",\\"DepartureTimeMsg\\":\\"Please tender your shipment 1 hour prior to your requested departure time.\\",\\"CurrentDate\\":\\"2022-10-01T18:26:12.463\\",\\"CommodityName\\":\\"SILSILVER\\",\\"DeptTime\\":\\"01:00\\",\\"FlightRoute\\":\\",6E461,BOM,HYD,02/10/2022,02/10/2022 06:05,02/10/2022 07:30,0@\\",\\"FileUrl\\":\\"\\"}]}:RESULT_END"}';
         }
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/GetTrackingInfoV2')){
            body = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\"Table\\":[{\\"ErrorCode\\":0,\\"ErrorDesc\\":\\"Get Tracking Details successful.\\"}],\\"Table1\\":[],\\"Table2\\":[{\\"AWBNumber\\":\\"312-26496433\\",\\"Station\\":\\"BOM\\",\\"Milestone\\":\\"Booked\\",\\"Pieces\\":1,\\"PiecesWeight\\":\\"10.00 Kgs\\",\\"UOM\\":\\"K\\",\\"FlightNo\\":\\"6E5332 01/11/2022\\",\\"FlightDate\\":\\"31/10/2022 18:49\\",\\"Origin\\":\\"BOM\\",\\"Destination\\":\\"DEL\\",\\"ULDNO\\":\\"\\",\\"OrderBy\\":1,\\"UpdatedOn\\":\\"2022-11-01T00:00:00\\"}],\\"Table3\\":[{\\"SrNo\\":1,\\"AWBNumber\\":\\"312-26496433\\",\\"Station\\":\\"BOM\\",\\"AirportName\\":\\"MUMBAI\\",\\"Milestone1\\":null,\\"PiecesWeight1\\":null,\\"FlightNoDate1\\":null,\\"IconType1\\":\\"Normal\\",\\"Origin1\\":null,\\"Destination1\\":null,\\"Milestone2\\":null,\\"PiecesWeight2\\":null,\\"FlightNoDate2\\":null,\\"IconType2\\":\\"Normal\\",\\"Origin2\\":null,\\"Destination2\\":null,\\"Milestone3\\":null,\\"PiecesWeight\\":null,\\"FlightNoDate3\\":null,\\"IconType3\\":\\"Normal\\",\\"Origin3\\":null,\\"Destination3\\":null,\\"PrevMilestone\\":null,\\"PrevPiecesWeight\\":null,\\"PrevFlightNoDate\\":null,\\"StationId\\":1,\\"Milestone4\\":null,\\"PiecesWeight4\\":null,\\"FlightNoDate4\\":null,\\"IconType4\\":\\"Normal\\",\\"Milestone5\\":null,\\"PiecesWeight5\\":null,\\"FlightNoDate5\\":null,\\"IconType5\\":\\"Normal\\"},{\\"SrNo\\":2,\\"AWBNumber\\":\\"312-26496433\\",\\"Station\\":\\"DEL\\",\\"AirportName\\":\\"DELHI\\",\\"Milestone1\\":null,\\"PiecesWeight1\\":null,\\"FlightNoDate1\\":null,\\"IconType1\\":\\"Normal\\",\\"Origin1\\":null,\\"Destination1\\":null,\\"Milestone2\\":null,\\"PiecesWeight2\\":null,\\"FlightNoDate2\\":null,\\"IconType2\\":\\"Normal\\",\\"Origin2\\":null,\\"Destination2\\":null,\\"Milestone3\\":null,\\"PiecesWeight3\\":null,\\"FlightNoDate3\\":null,\\"IconType3\\":\\"Normal\\",\\"Origin3\\":null,\\"Destination3\\":null,\\"PrevMilestone\\":null,\\"PrevPiecesWeight\\":null,\\"PrevFlightNoDate\\":null,\\"StationId\\":null,\\"Milestone4\\":null,\\"PiecesWeight4\\":null,\\"FlightNoDate4\\":null,\\"IconType4\\":\\"Normal\\",\\"Milestone5\\":null,\\"PiecesWeight5\\":null,\\"FlightNoDate5\\":null,\\"IconType5\\":\\"Normal\\"}],\\"Table4\\":[],\\"Table5\\":[{\\"MaxConCount\\":0}],\\"Table6\\":[{\\"StationCount\\":2}],\\"Table7\\":[{\\"LastActivity\\":\\"Booked at BOM\\",\\"Description\\":\\"1 P / 10.00 Kgs\\"}],\\"Table8\\":[],\\"Table9\\":[]}:RESULT_END"}';
        }
         response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
     
}