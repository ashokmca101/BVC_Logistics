public class IndigoWrapperClass2 {
//this apex class is used to store token nunber and it is also used to deserialize the response.
	public class Table {
		public String TokenNumber;
	}

	public List<Table> Table;

	
	public static IndigoWrapperClass2 parse(String json) {
		return (IndigoWrapperClass2) System.JSON.deserialize(json, IndigoWrapperClass2.class);
	}
}