public class Community_CreatePaymentLink{
        public String description{get;set;}
		public String reference_id{get;set;}
		public Integer expire_by{get;set;}
		public customer customer{get;set;}
		public Boolean accept_partial{get;set;}
		public notify notify{get;set;}
		//public String currency{get;set;}
		public Boolean reminder_enable{get;set;}
		public Integer amount{get;set;}
	public class notify{
		public Boolean email{get;set;}
		public Boolean sms{get;set;}
	}
   public class customer{
        public String contact{get;set;}
        public String email{get;set;}
        public String name{get;set;}
    }
}