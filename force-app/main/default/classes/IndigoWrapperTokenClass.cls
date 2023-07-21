public class IndigoWrapperTokenClass {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB , Indigo_TrackAWB_Helper apex class.
	public class Table {
		public String TokenNumber;
	}

	public List<Table> Table;

	
	public static IndigoWrapperTokenClass parse(String json) {
		return (IndigoWrapperTokenClass) System.JSON.deserialize(json, IndigoWrapperTokenClass.class);
	}
}