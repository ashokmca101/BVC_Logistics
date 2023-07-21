public class EY_ResponseJSONParser{
		public String digiGSTErrorCode{get;set;}
		public String lospCity{get;set;}
		public String lospState{get;set;}
		public String lospColumn{get;set;}
		public String lospStateCode{get;set;}
		public String lospTable{get;set;}
		public String supplyType{get;set;}
		public String posStateCode{get;set;}
		public String irnNumber{get;set;}
		public String posState{get;set;}
		public String signedQRCode{get;set;}
		public String posCity{get;set;}
		public String ackNumber{get;set;}
		public String posColumn{get;set;}
		public String ackDateTime{get;set;}
		public String posTable{get;set;}
		public String taxEngineErrorCode{get;set;}
		public String registrationStatus{get;set;}
		public String taxEngineErrorMessage{get;set;}
		public String processingDate{get;set;}
		public String digiGSTErrorMessage{get;set;}
		public String billingDocumentNumber{get;set;}
		public list<lineItems> lineItems{get;set;}
		public String billingDate{get;set;}
	public class lineItems{
		public Decimal taxCalculatedINR{get;set;}
		public Decimal igstPercentage{get;set;}
		public Decimal taxCalculated{get;set;}
		public Decimal cgstPercentage{get;set;}
		public String taxCategory{get;set;}
		public Decimal sgstPercentage{get;set;}
		public Decimal taxApplicablePercentage{get;set;}
		public Decimal igst{get;set;}
		public String sacApplicable{get;set;}
		public Decimal cgst{get;set;}
		public String natureOfService{get;set;}
		public Decimal sgst{get;set;}
		public String materialDescription{get;set;}
		public Decimal igsT_INR{get;set;}
		public Decimal totalItemValue{get;set;}
		public Decimal cgsT_INR{get;set;}
		public Decimal tax{get;set;}
		public Decimal sgsT_INR{get;set;}
		public String itemNumber{get;set;}
	}
    public EY_ResponseJSONParser(){
        
    }
}