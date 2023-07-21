public class CreditRatingResponseWrapper {
    
    public String statusCode{get;set;}
    public String requestId{get;set;}     
	public result[] result{get;set;}
    
	public class result{
        public string ratingAgency{get;set;}
        public string rating{get;set;}
        public string outlook{get;set;}
        //public string instrumentType_{get;set;}
        //public string rating_{get;set;}
        public string dateOfIssuance{get;set;}
        public boolean isRatedEntityNonCooperative{get;set;}
        public string ratingRationale{get;set;}
        public string ratingDescription{get;set;}
        public string timestamp{get;set;}
        public string currencyType{get;set;}
        public string product{get;set;}

	}
    
    public static CreditRatingResponseWrapper parse(String json){
		return (CreditRatingResponseWrapper) System.JSON.deserialize(json, CreditRatingResponseWrapper.class);
	}
    
    

}