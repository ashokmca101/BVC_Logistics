public class Indigo_TrackAWB_wrapper_class1 {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_TrackAWB_Helper apex class.
	public String d;

	
	public static Indigo_TrackAWB_wrapper_class1 parse(String json) {
		return (Indigo_TrackAWB_wrapper_class1) System.JSON.deserialize(json, Indigo_TrackAWB_wrapper_class1.class);
	}
}