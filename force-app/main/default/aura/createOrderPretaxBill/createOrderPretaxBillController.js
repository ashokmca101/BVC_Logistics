({
	doInit : function(component, event, helper) {
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
		 var action = component.get("c.invokebatch");
       action.setParams({ recordid : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var ordercreated= response.getReturnValue().BVC_CB_Is_Order_Created__c;
            var billdetailcreated = response.getReturnValue().BVC_CB_PretaxDetails_Inserted__c;
           
           if(ordercreated === false && billdetailcreated === true){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                "title": "Success!",
                "type":"success",    
                "message": "Order has been created successfully."
                });
                toastEvent.fire();
                    // var dismissActionPanel = $A.get("e.force:closeQuickAction");
    dismissActionPanel.fire();
              // alert('success block');
               // $A.get('e.force:refreshView').fire();

               // window.location.reload();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                         var toastEvent = $A.get("e.force:showToast");
                              toastEvent.setParams({
                              "title": "Error",
                              "type":"error",
                              "message": errors[0].message
                                });
                             toastEvent.fire();
                            
                                 dismissActionPanel.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
           }else{
               if(billdetailcreated === false){
                   var toastEvent = $A.get("e.force:showToast");
                              toastEvent.setParams({
                              
                              "type":"warning",
                              "message": "PretaxBillDetail records not inserted.Please verify!"
                                });
                             toastEvent.fire();
                dismissActionPanel.fire();
               } else if(ordercreated === true){
                   var toastEvent = $A.get("e.force:showToast");
                              toastEvent.setParams({
                              
                              "type":"warning",
                              "message": "Orders have been created for this Pretaxbill already. Please verify!"
                                });
                             toastEvent.fire();
                dismissActionPanel.fire();
               } 
           }
        });

        $A.enqueueAction(action);
       
       // alert('last line');
        // $A.get('e.force:refreshView').fire();
    }
})