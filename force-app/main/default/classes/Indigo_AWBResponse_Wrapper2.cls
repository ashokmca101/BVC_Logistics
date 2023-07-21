public class Indigo_AWBResponse_Wrapper2 {
// class is used to deserialization and used in Indigo_CreateAWB  apex class
	public List<Table6> Table6;

	public class Table6 {
		public Integer ErrorCode;
		public String ErrorDesc;
		public String AWBNumber;
		public String DepartureTimeMsg;
		public String CurrentDate;
		public String CommodityName;
		public String DeptTime;
        public String FlightRoute;
	}

	
	public static Indigo_AWBResponse_Wrapper2 parse(String json) {
		return (Indigo_AWBResponse_Wrapper2) System.JSON.deserialize(json, Indigo_AWBResponse_Wrapper2.class);
	}
}