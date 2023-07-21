@isTest
global class RazorpayHTTPMockResponseGenerator implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"accept_partial": true,"amount": 800000,"amount_paid": 800000,"cancelled_at": 0,"created_at": 1625637533,'
    				+'"currency": "INR","customer": {"email": "vaibhav.pancholi@bvcventures.com","name": "Vaibhav UAT_1"},"description": "Payment for the Invoice : INV-0164",'
    				+'"expire_by": 1626501531,"expired_at": 0,"first_min_partial_amount": 100,"id": "plink_HVvxcm0H8RY6HS","notes": null,'
                    +'"notify": {"email": true,"sms": false},"order_id": "order_HVxnTJDtsqpgOi","payments": [{"amount": 800000,"created_at": 1625644032,'
                    +'"method": "card","payment_id": "pay_HVxnxw6M8P7Tz6","status": "captured"}],"reference_id": "a251m0000028a2DAAQ","reminder_enable": false,'
                    +'"reminders": [],"short_url": "https://rzp.io/i/OjHTshd","status": "partially_paid","updated_at": 1625645297,"upi_link": false,"user_id": ""}');
//}');
        res.setStatusCode(200);
        return res;
          
    }

}