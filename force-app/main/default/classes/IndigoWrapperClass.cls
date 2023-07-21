public class IndigoWrapperClass {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB apex class.
	public String d;

	
	public static IndigoWrapperClass parse(String json) {
		return (IndigoWrapperClass) System.JSON.deserialize(json, IndigoWrapperClass.class);
	}
}