public class KYCPanVerificationResponseWrapper {
    
    public String request_id{get;set;}
	public String status_code{get;set;}
    public String statusCode{get;set;}
    public String requestId{get;set;}     
	public result result{get;set;}
    
	public class result{
		public String name{get;set;}
        public StatutoryRegistration statutoryRegistration{get;set;}
        public Profile profile{get;set;}
        public Management management{get;set;}
	}
    public class StatutoryRegistration {
		public PANS[] pans{get;set;}
		public GST[] gst{get;set;} 
        public MCA[] mca{get;set;} 
        public TAN[] tan{get;set;} 
        public IEC[] iec{get;set;} 
    }
    
    public class GST {
        public Branches[] branches{get;set;} 
        public SignatoriesContact[] signatoriesContact{get;set;} 
        public String gstin{get;set;}
        public String email{get;set;}
        public String legalName{get;set;}
        public String tradeName{get;set;}
        public String status{get;set;}
        public String address{get;set;}
        public String contact{get;set;} 
        public String dealerType{get;set;}
        public string addr{get;set;}
        public string complianceRating{get;set;}
        public string constitutionOfBusiness{get;set;}
        public string contacted{get;set;}
        public string dateOfRegistration{get;set;}
        public string dateOfRegistrationCancellation{get;set;}
        public string dateOfVatRegistration{get;set;}
        public string emailDomain{get;set;}
        public string isFieldVisitConducted{get;set;}
        public string isMoreAdditionalPlaces{get;set;}
        public string kid{get;set;}
        public string lastUpdatedDate{get;set;}
        public string[] natureOfBusiness{get;set;}
        public string natureOfTrade{get;set;}
        public string pan{get;set;}
        public string[] signatories{get;set;}
        public string name{get;set;}
        public string sourceUri{get;set;}
        //public	string state_{get;set;}
        public string timestamp{get;set;}
        public string tin{get;set;}
    }
    public class MCA {
        public string activeCompliance {get;set;}
        //public string activityClass_ {get;set;} //can't use '_' inside varriable
        //public string activityGroup_ {get;set;} //can't use '_' inside varriable
        //public string activitySubClass_ {get;set;} //can't use '_' inside varriable
        public string alternateAddress {get;set;}
        public string authorisedCapital {get;set;}
        public string category {get;set;}
        //public string class {get;set;}               //can't use class as varriable
        public string countryOfIncorporation {get;set;}
        public string dateOfAnnualReturnFiled {get;set;}
        public string dateOfBalanceSheet {get;set;}
        public string dateOfIncorporation {get;set;}
        public string dateOfLastAgm {get;set;}
        public string dateOfStatementOfAccountsAndSolvencyFiled {get;set;}

    }
    public class TAN {
        public string address{get;set;}
        public string areaCode{get;set;}
        public string assessingOfficerNumber{get;set;}
        public string branch{get;set;}
        public string buildingName{get;set;}
        public string category{get;set;}
        public string deductorCategory{get;set;}
        public string divisionName{get;set;}
        public string[] emailDomains{get;set;}
        public string[] emails{get;set;}
        public string kid{get;set;}
        public string name{get;set;}
        public string pan{get;set;}
        public string sourceUri{get;set;}
        public string subCategory{get;set;}
        public string tan{get;set;}
        public string tanStatus{get;set;}
        public string timestamp{get;set;}
        public string dispatchDate{get;set;}

    }
    public class SignatoriesContact{
        public String contact{get;set;} 
    }
    public class Branches {
        public String email{get;set;}
        public String address{get;set;}
        public String contact{get;set;}  
        public String addr{get;set;}  
        public String emailDomain{get;set;}  
        public String natureOfTrade{get;set;}  
        public String lastUpdatedDate{get;set;} 	            

    }
    public class PANS {
        public string address{get;set;}
        public string dateOfBirth{get;set;}
        public string dateOfIssuance{get;set;}
        public string email{get;set;}
        public string emailDomain{get;set;}
        //public string isAddressQualityPoor_{get;set;}   //can't use '_' inside varriable
        public string isPanInactive{get;set;}
        public string mcaEntityId{get;set;}
        public string mcaEntityType{get;set;}
        public string name{get;set;}
        public string pans{get;set;}
        public string panType{get;set;}
        public string pincode{get;set;}
        public string state{get;set;}
        public string timestamp{get;set;}
        public string yearMonthOfIssuance{get;set;}

    }
    
    public class IEC {
        public string accountNumber{get;set;}
        public string accountType{get;set;}
        public string address{get;set;}
        public string bank{get;set;}
        public string bin{get;set;}
        //public Array branches{get;set;}
        public string contact{get;set;}
        //public Array contacts_{get;set;}
        public string dateOfIecAllotment{get;set;}
        public string dateOfIncorporation{get;set;}
        public string email{get;set;}
        public string emailDomain{get;set;}
        public string entityType{get;set;}
        public string exporterType{get;set;}
        public string fileDate{get;set;}
        public string fileNumber{get;set;}
        public string iec{get;set;}
        public string iecGateStatus{get;set;}
        public string iecPrintStatus{get;set;}
        public string name{get;set;}
        public ORDERS[] orders{get;set;}
        public REGISTRATIONS[] registrations{get;set;} 

    }
    public class ORDERS{
        public string orderNumber{get;set;}
        public string issuedBy{get;set;}
        public string dateOfOrder{get;set;}
        public string details{get;set;}
        public string rcmcNumber{get;set;}
        public string type{get;set;}
        //public string issuedBy{get;set;}
        public string issueDate{get;set;}
        public string expiryDate{get;set;}
    }
    public class REGISTRATIONS{
        public string registrationNumber{get;set;}
        public string type{get;set;}
        public string place{get;set;}
        public string dateOfRegistration{get;set;}
    }
    
    public class Profile {
        public string name{get;set;}  
        public string tradeName{get;set;}  
        //public FormerNamesFromProfile[] formerNames{get;set;}   
        //public FormerEntityIdsFromProfile[] formerEntityIds{get;set;}  
        public string[] pans{get;set;} 
        public string contact{get;set;}  
        public string email{get;set;}  
        public string industry{get;set;}
        public string subIndustry{get;set;}
        public string activityGroup{get;set;}
        public string activityClass{get;set;}
        public string activitySubClass{get;set;}
        public string entityClass{get;set;}
        public string[]  natureOfBusiness{get;set;}
        public string fatherName{get;set;}
        public string registeredAddress{get;set;}
        public string city{get;set;}
        public string state{get;set;}
        public string pin{get;set;}
        public string dateOfIncorporation{get;set;}
        public string dateOfBirth{get;set;}
        public string dateOfVatRegistration{get;set;}
        public string entityId{get;set;}
        public string type{get;set;}
        public string descriptionOfMainDivision{get;set;}
        public string mainDivisonOfBusinessActivity{get;set;}


    }
    public class FormerNamesFromProfile {
        public string  name{get;set;}  
        public string fromDate{get;set;}  
        public string toDate{get;set;} 
    }
    public class FormerEntityIdsFromProfile {
        public string entityId{get;set;}  
        public string fromDate{get;set;}  
        public string toDate{get;set;}  
    }
    
    public class Management {
        public string source{get;set;}  
		public Current[] current{get;set;}  
    }
    public class Current {
        public string kid{get;set;} 
        public string din{get;set;} 
        //public string dinPan_{get;set;}  //can't use '_' inside varriable
        public string[] pans{get;set;} 
        public string name{get;set;} 
        public string contact{get;set;} 
        public string gender{get;set;} 
        public string email{get;set;} 
        public string isDscRegistered{get;set;} 
        public string dscExpiryDate{get;set;} 
        public string designation{get;set;} 
        public string dateOfBirth{get;set;} 
        public string[] alerts{get;set;} 
        public string tenureBeginDate{get;set;} 
        public string tenureEndDate{get;set;} 
        public string fatherName{get;set;} 
        public string status{get;set;} 
        public string address{get;set;} 
        public string city{get;set;} 
        public string state{get;set;} 
        public string pin{get;set;} 
        public string dinDateOfApproval{get;set;} 
        public string nationality{get;set;} 

    }
    

    public static KYCPanVerificationResponseWrapper parse(String json){
		return (KYCPanVerificationResponseWrapper) System.JSON.deserialize(json, KYCPanVerificationResponseWrapper.class);
	}

	
}