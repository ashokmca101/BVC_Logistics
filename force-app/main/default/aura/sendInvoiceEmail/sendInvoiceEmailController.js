({
    doinIt : function(component, event, helper) {
        component.set("v.hideSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.SendContractDetails");
        action.setParams({
            InvoiceId :recId
        });
        action.setCallback(this, function (response) {
            
            var state = response.getState();
            var retVal = response.getReturnValue();
            if (state === "SUCCESS") {
               var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        Title:'title',
                        type:'success',
                        message:retVal
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
        		
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.hideSpinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            Title:'title',
                            type:'error',
                            message:errors[0].message
                        });
                        $A.get("e.force:closeQuickAction").fire();
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                } else {
                    component.set("v.hideSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        Title:'title',
                        type:'error',
                        message:'Unknown Error'
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    }
})