public class IndigoWrapperSessionIdClass {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB apex class.
	public String d;

	
	public static IndigoWrapperSessionIdClass parse(String json) {
		return (IndigoWrapperSessionIdClass) System.JSON.deserialize(json, IndigoWrapperSessionIdClass.class);
	}
}