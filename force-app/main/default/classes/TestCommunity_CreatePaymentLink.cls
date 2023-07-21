@isTest
public class TestCommunity_CreatePaymentLink {

    @isTest
    static void testWrapper(){
        Community_CreatePaymentLink.notify notifyObj = new  Community_CreatePaymentLink.notify();
        notifyObj.email = true;
        notifyObj.sms = true;
        Community_CreatePaymentLink.customer customerObj = new  Community_CreatePaymentLink.customer();
        customerObj.contact = '1234';
        customerObj.email = 'test@gmail.com';
        customerObj.name = 'Test';
        Community_CreatePaymentLink obj = new Community_CreatePaymentLink();
        obj.description='dfdfd';
        obj.reference_id = '123455';
        obj.expire_by = 123456;
        obj.accept_partial = true;
        obj.reminder_enable = true;
        obj.amount = 1234;
        obj.customer = customerObj;
        obj.notify = notifyObj;
        
       
        
    }
    
}