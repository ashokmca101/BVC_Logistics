({
    doinIt : function(component, event, helper) {
        component.set("v.hideSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.invoiceEyIntegration");
        action.setParams({
            recordId :recId
        });
        action.setCallback(this, function (response) {
            console.log('A');
            var state = response.getState();
            var retVal = response.getReturnValue();
            if (state === "SUCCESS") {
                if(retVal == "Tax Calculation Failed, check Integration Log/Tax Integration message for more details"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        Title:'title',
                        type:'error',
                        message:retVal
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
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