public class Indigo_AWBResponse_Wrapper {
 // this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB apex class.
	public String d;

	
	public static Indigo_AWBResponse_Wrapper parse(String json) {
		return (Indigo_AWBResponse_Wrapper) System.JSON.deserialize(json, Indigo_AWBResponse_Wrapper.class);
	}
}