@isTest
global class MockHttpResponseGeneratorForStitch implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://testapi.karza.in/v2/pan', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        StaticResource sr = [SELECT Id, Name , Body FROM StaticResource where name='StitchProfileResponse' LIMIT 1];
		//String body = sr.Body.toString();
        String getResponse = sr.Body.toString(); 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(getResponse);
        res.setStatusCode(200);
        return res;
    }
}