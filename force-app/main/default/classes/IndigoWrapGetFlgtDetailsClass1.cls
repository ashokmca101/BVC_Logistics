public class IndigoWrapGetFlgtDetailsClass1 {
   // this apex class is used as wrapper class and it is also used to deserialize the http response. This class is used in FlightScheduleBatch_Helper.getFlightDetails apex class.
	public class Table {
		public String ScheduleID;
		public String FltNumber;
		public String FltOrigin;
		public String FltDestination;
		public String FltDate;
		public Time ArrTime; 
		public Time DeptTime;
		public String LegSequence;
		public DateTime DepDateTime;
		public DateTime ArrDateTime;
		public String STATUS;
	} 

	public List<Table> Table;

	
	public static IndigoWrapGetFlgtDetailsClass1 parse(String json) {
		return (IndigoWrapGetFlgtDetailsClass1) System.JSON.deserialize(json, IndigoWrapGetFlgtDetailsClass1.class);
	}
}