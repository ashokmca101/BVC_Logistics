public class IndigoWrapperGetFlgtDetailsClass {
 // this apex class is used as wrapper class and it is also used to deserialize the http response. 
 // This class is used in FlightScheduleBatch_Helper.getFlightDetails apex class.
	public String d;

	
	public static IndigoWrapperGetFlgtDetailsClass parse(String json) {
		return (IndigoWrapperGetFlgtDetailsClass) System.JSON.deserialize(json, IndigoWrapperGetFlgtDetailsClass.class);
	}
}