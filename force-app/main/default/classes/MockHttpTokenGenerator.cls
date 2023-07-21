@isTest
global class MockHttpTokenGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI0IiwidW5pcXVlX25hbWUiOiJ2YWliaGF2LnBhbmNob2xpQGJ2Y2xvZ2lzdGljcy5jb20iLCJuYmYiOjE2MjY5NTE0NTgsImV4cCI6MTYyNjk4MDI1OCwiaWF0IjoxNjI2OTUxNDU4fQ.G1pf5cMvAgdgucXUiJEdmqg1WogxdbBP51P5EPCc2EqzGLIDmoG21SrhtIfmAhHN8cKM8sP2CQ_z0Rhb77WlxQ","expiration": "2021-07-22T18:57:38Z"}');
        res.setStatusCode(200);
        return res;
    }
}