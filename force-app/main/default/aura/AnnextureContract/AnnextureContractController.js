({ invoke : function(component, event, helper) {
 	var record = component.get("v.recordId");
 	var redirect = $A.get("e.force:navigateToSObject");
 	redirect.setParams({"recordId": record});
 	redirect.fire();
}})