@isTest
global class ShipmentWebHookCalloutMock  implements HttpCalloutMock
{
	global HttpResponse respond(HttpRequest req)
    {
        HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type','application/json');
        resp.setBody('{"Id":"123456","Name":"Name"}');
		resp.setStatusCode(200);
		return resp;        
    }
}