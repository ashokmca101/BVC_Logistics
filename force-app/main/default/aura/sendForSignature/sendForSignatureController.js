({
    doinIt : function(component, event, helper) {
        component.set("v.hideSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.validateAndSendEsign");
        action.setParams({
            recordId :recId
        });
        action.setCallback(this, function (response) {
            console.log('A');
            var retVal = response.getReturnValue();
            if(retVal == 'A'){
                console.log('A');
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'error',
                    message:'KYC is not verified for Account'
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else if(retVal == 'B'){
                console.log('B');
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'error',
                    message:'Kindly Update second level product for Deal'
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if(retVal == 'C'){
                console.log('C');
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'error',
                    message:'Authorized Signatory missing, Please verify'
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else if(retVal == 'D'){
                console.log('D');
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'error',
                    message:'Cannot find Envelope Configuration, Please Contact System Admin'
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else if(retVal == 'E'){
                console.log('E');
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'error',
                    message:'Some Error Occured, Please contact System Admin'
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else {
                console.log('F');
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                "url": retVal
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})