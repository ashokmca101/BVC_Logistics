({
	
    doInit : function(component, event, helper) {
        var action = component.get("c.reInitiateKYC");
        console.log("accountId:::"+component.get("v.recordId"));
        action.setParams({
            accountId : component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            console.log("state:::"+result.getState());
            if (component.isValid() && state === "SUCCESS"){
                console.log("state:::"+result.getState());
            }
            //$A.get("e.force:closeQuickAction").fire();
        	//$A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);
        var start = System.Now().millisecond();
            
            while(System.Now().millisecond()< start+10) {
                $A.enqueueAction(component.get('c.Refresh')); 
            }
       //
    },
    
    Refresh : function(component, event, helper) {
		console.log("Inside Refresh");
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        //window.location.reload();
	},
    
})