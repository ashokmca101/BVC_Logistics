public class Community_FetchPaymentWrapperShipment {
   
		public String id{get;set;}
		public Integer first_min_partial_amount{get;set;}
		public Integer expired_at{get;set;}
		public List<notes> notes{get;set;}
		public Integer expire_by{get;set;}
		public notify notify{get;set;}
		public String description{get;set;}
		public String order_id{get;set;}
        public customer customer{get;set;}
		//public List<customer> customer{get;set;}
		public list<payments> payments{get;set;}
		public Boolean reminder_enable{get;set;}
		public String reference_id{get;set;}
		public list<reminders> reminders{get;set;}
		//public String currency{get;set;}
		public String short_url{get;set;}
		public Integer created_at{get;set;}
		public String status{get;set;}
		public Integer cancelled_at{get;set;}
		public Integer updated_at{get;set;}
		public Integer amount_paid{get;set;}
		public Boolean upi_link{get;set;}
		public Integer amount{get;set;}
		public String user_id{get;set;}
		public Boolean accept_partial{get;set;}
	public class payments{
		public String method{get;set;}
		public String payment_id{get;set;}
		public Integer created_at{get;set;}
		public String status{get;set;}
		public Integer amount{get;set;}
	}
	public class reminders{
		public String status{get;set;}
	}
	public class notes{
		public String policy_name{get;set;}
	}
	public class notify{
		public Boolean sms{get;set;}
		public Boolean email{get;set;}
	}
	public class customer{
		public String name{get;set;}
		public String email{get;set;}
		public String contact{get;set;}
		public String customer_id{get;set;}
	}

    public static Community_FetchPaymentWrapperShipment parse(String json){
		return (Community_FetchPaymentWrapperShipment) System.JSON.deserialize(json, Community_FetchPaymentWrapperShipment.class);
	}
}