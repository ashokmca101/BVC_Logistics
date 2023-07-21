@isTest
public class TestCommunity_FetchPaymentWrapperShip {

    @isTest
    static void testWrapper(){
        Community_FetchPaymentWrapperShipment.payments notifyObj = new  Community_FetchPaymentWrapperShipment.payments();
        notifyObj.method = 'ABC';
        notifyObj.payment_id = '1234';
        notifyObj.created_at = 123456;
        notifyObj.status = 'Test';
        notifyObj.amount = 1234;
        Community_FetchPaymentWrapperShipment.customer customerObj = new  Community_FetchPaymentWrapperShipment.customer();
        customerObj.contact = '1234';
        customerObj.email = 'test@gmail.com';
        customerObj.name = 'Test';
        customerObj.customer_id = '1234';
        
        Community_FetchPaymentWrapperShipment.notify notify = new  Community_FetchPaymentWrapperShipment.notify();
        notify.sms = true;
        notify.email = true;
        
        //List<Community_FetchPaymentWrapperShipment.notes> notes = new  List<Community_FetchPaymentWrapperShipment.notes>();
        //notes[0].policy_name = 'true';
        
        
        Community_FetchPaymentWrapperShipment obj = new Community_FetchPaymentWrapperShipment();
        obj.description='dfdfd';
        obj.reference_id = '123455';
        obj.expire_by = 123456;
        obj.accept_partial = true;
        obj.reminder_enable = true;
        obj.amount = 1234;
        obj.customer = customerObj;
        obj.notify = notify; 
        obj.id = '123';
		obj.first_min_partial_amount=123;
		obj.expired_at = 123;
		//obj.notes = notes;
        obj.short_url = 'abc';
		obj.created_at=12345;
		obj.status='Pass';
		obj.cancelled_at = 123456;
		obj.updated_at = 12345;
		obj.amount_paid=1234;
		obj.upi_link = true;
		obj.order_id = '123';
		obj.user_id='123';
		obj.accept_partial=true;
    }
    
}