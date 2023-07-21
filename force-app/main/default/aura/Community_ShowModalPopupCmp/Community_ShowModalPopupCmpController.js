({
    closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
    
    doInit : function(component,Event) {
        var action = component.get("c.check_If_KYC_Is_Verified");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result;
            var showModal;
            if (state === "SUCCESS") {
                result= response.getReturnValue();
                /*if(result==true){
                    showModal=false;
                }
                else if(result==false){
                    showModal=true;
                }
                alert(showModal);*/
                showModal=!(result);
                component.set('v.isModalOpen',showModal);
                //alert(showModal);
            }
        });
 $A.enqueueAction(action);
    },
    goToRec : function(component, event, helper) {
        window.open('/s/comm-my-account','_self');
        /*var result;
        var action = component.get("c.navigate_to_AccountId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                result= response.getReturnValue();
            }
            alert(result);
        event.preventDefault();
        var navService = component.find("navService");
            //alert(navLink);
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Account',
                recordId : result 
            },
        };
        navService.navigate(pageRef);
            });
        $A.enqueueAction(action);*/
    }
})