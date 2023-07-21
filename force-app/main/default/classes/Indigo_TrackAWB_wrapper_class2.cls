public class Indigo_TrackAWB_wrapper_class2 {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_TrackAWB_Helper apex class.
	public List<Table> Table;
	public List<Table1> Table1;
	public List<Table2> Table2;
	public List<Table3> Table3;
	public List<Table1> Table4;
	public List<Table5> Table5;
	public List<Table6> Table6;
	public List<Table7> Table7;
	public List<Table1> Table8;
	public List<Table1> Table9;

	public class Table {
		public Integer ErrorCode;
		public String ErrorDesc;
	}

	public class Table6 {
		public Integer StationCount;
	}
// used in Indigo_TrackAWB_Helper apex class to create linehaul tracking record
	public class Table7 {
		public String LastActivity;
		public String Description;
	}

	public class Table2 {
		public String AWBNumber;
		public String Station;
		public String Milestone;
		public Integer Pieces;
		public String PiecesWeight;
		public String UOM;
		public String FlightNo;
		public String FlightDate;
		public String Origin;
		public String Destination;
		public String ULDNO;
		public Integer OrderBy;
		public String UpdatedOn;
	}

	public class Table3 {
		public Integer SrNo;
		public String AWBNumber;
		public String Station;
		public String AirportName;
		public Object Milestone1;
		public Object PiecesWeight1;
		public Object FlightNoDate1;
		public String IconType1;
		public Object Origin1;
		public Object Destination1;
		public Object Milestone2;
		public Object PiecesWeight2;
		public Object FlightNoDate2;
		public String IconType2;
		public Object Origin2;
		public Object Destination2;
		public Object Milestone3;
		public Object PiecesWeight3;
		public Object FlightNoDate3;
		public String IconType3;
		public Object Origin3;
		public Object Destination3;
		public Object PrevMilestone;
		public Object PrevPiecesWeight;
		public Object PrevFlightNoDate;
		public Integer StationId;
		public Object Milestone4;
		public Object PiecesWeight4;
		public Object FlightNoDate4;
		public String IconType4;
		public Object Milestone5;
		public Object PiecesWeight5;
		public Object FlightNoDate5;
		public String IconType5;
	}

	public class Table5 {
		public Integer MaxConCount;
	}

	public class Table1 {
	}

	
	public static Indigo_TrackAWB_wrapper_class2 parse(String json) {
		return (Indigo_TrackAWB_wrapper_class2) System.JSON.deserialize(json, Indigo_TrackAWB_wrapper_class2.class);
	}
}