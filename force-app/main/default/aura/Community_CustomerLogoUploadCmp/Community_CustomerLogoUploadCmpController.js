({
    doInit:function(component,event,helper){  
     var action = component.get("c.getCurrentUserAccountId");  
     action.setCallback(this,function(response){  
       var state = response.getState();  
       if(state === 'SUCCESS'){  
         var result = response.getReturnValue();  
         console.log('result: ' +result);  
         component.set("v.AccountId",result);  
       }  
     });  
     $A.enqueueAction(action);  
   } ,
    handleUploadFinished: function (component,event,helper) {
        var action = component.get("c.logoAccessToallUser");
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        console.log(documentId);
        action.setParams({
            logoId : documentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") { 
                	var result=response.getReturnValue();
        			toastEvent.setParams({
                    type: 'success',
                    variant: 'success',
                    title: 'Success!',
                    message: "File "+fileName+" Uploaded successfully.",
                    mode: 'pester'
                 });
        	toastEvent.fire();
           }
            else if (state === "ERROR") {
                var result=response.getReturnValue();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message in (else if error) " + errors+ ' '+result);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
    
})