@isTest
global class RazorpayMockCalloutResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"accept_partial":true,"amount":5000000,"amount_paid":0,"cancelled_at":0,"created_at":1627052422,"currency":"INR","customer":{"email":"vaibhav.pancholi@bvclogistics.com","name":"WADHWA GROUP HOLDINGS PVT.LTD."},"description":"Payment for the Invoice : INV-0485","expire_by":1627916420,"expired_at":0,"first_min_partial_amount":100,"id":"plink_HcPjXdviql8cLH","notes":null,"notify":{"email":true,"sms":false},"payments":null,"reference_id":"a251m0000028b8EAAQ","reminder_enable":false,"reminders":[],"short_url":"www.google.com","status":"created","updated_at":1627052422,"upi_link":false,"user_id":""}');
        res.setStatusCode(200);
        return res;
    }
}