public class IndigoWrapperSessionIdClass1 {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB apex class.
	public class Table {
		public String AgentCode;
		public Object ControllingLocator;
		public String CreditController;
		public Boolean IsActive;
		public String SessionID;
		public String RetStatus;
		public String RoleName;
		public String AgentName;
		public String UserType;
		public String RoleType;
		public Double AgentBalance;
		public String AgentEmail;
		public String AgentContact;
	}

	public List<Table> Table;

	
	public static IndigoWrapperSessionIdClass1 parse(String json) {
		return (IndigoWrapperSessionIdClass1) System.JSON.deserialize(json, IndigoWrapperSessionIdClass1.class);
	}
}