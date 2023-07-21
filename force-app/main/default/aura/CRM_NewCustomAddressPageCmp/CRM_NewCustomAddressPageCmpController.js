({
    save : function(component, event, helper) {
        event.preventDefault();
        helper.validate(component, event, helper);
     },
    doInit : function(component, event, helper) {
        helper.getCustomerId(component, event, helper);
        
        var url_string = window.location.href;
        var recordtypeids=url_string.substring(url_string.indexOf("recordTypeId") + 13,url_string.indexOf("recordTypeId") + 28);
		//alert(url_string.substring(url_string.indexOf("recordTypeId") + 13,url_string.indexOf("recordTypeId") + 28));
		
        component.find("RecordTypeId").set("v.value",recordtypeids);
        helper.getRecordTypeId(component, event, helper);
    },
    handleOnSuccess :function(component, event, helper) {
        component.set("v.isLoading",false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Address Created Successfully',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
        var payload = event.getParams().response;
        console.log(payload.id);
        if(component.get("v.isCommunity")){
            window.open('/s/settings-addresses','_self');
        }else{
             var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId":payload.id ,
                    "slideDevName": "related"
                });
                navEvt.fire(); 
        }
         
    },
    
    cancelDialog : function(component, event, helper) {
        helper.cancel(component, event, helper);
    },
    CustChanged : function(component, event, helper){
        var accValue = component.find("Customer").get("v.value");
        if(accValue ) {
            var action = component.get('c.gstStatus');
            action.setParams({
                AccId : accValue
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                //console.log('res-'+res);
                if (state === "SUCCESS") {
                    if(res===true)
                        component.find("GST_Registered_Status__c").set("v.value","Registered");
                    else
                        component.find("GST_Registered_Status__c").set("v.value","Unregistered");
                }
                else {
                    component.find("GST_Registered_Status__c").set("v.value",null);
                }
            });
            $A.enqueueAction(action);
        }else{
            component.find("GST_Registered_Status__c").set("v.value",null);
        }
    },
    GstStatusChanged : function(component, event, helper){
        var gstValue = component.find("GST_Registered_Status__c").get("v.value");
        if(gstValue=="Unregistered")
            component.find("Dealer_Type__c").set("v.value","Unregistered");
        else
            component.find("Dealer_Type__c").set("v.value",null);
    },
    PincodeChanged : function(component, event, helper) {
        var PincodeValue = component.find("ActivePincode").get("v.value");
        console.log("pin",PincodeValue);
        if(PincodeValue ) {
            
            var action = component.get('c.findCountryStateAndCityBasedOnPin');
            
            action.setParams({
                Pincode : PincodeValue
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                console.log('res-'+res);
                if (state === "SUCCESS" && res.Status==="PINCODERECEIVED") {
                    
                    component.find("City").set("v.value",res.City);
                    var district = component.find("District");
                    if(district !=null && district !=''){
                        district.set("v.value",res.District);
                    }
                    //component.find("District").set("v.value",res.City);
                    component.find("State").set("v.value",res.State);
                    component.find("Country").set("v.value",res.Country);
                    console.log('res'+res.City);
                }
                else {
                    component.find("City").set("v.value","");
                    component.find("District").set("v.value","");
                    component.find("State").set("v.value","");
                    component.find("Country").set("v.value","");     
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.find("District").set("v.value","");
            component.find("State").set("v.value","");
            component.find("Country").set("v.value","");
            component.find("City").set("v.value","");
        }
        
    },
    
    onError : function(component, event, helper){
        component.set("v.isLoading",false);
        component.set("v.isLoading",false);
       // alert(event.getParam('detail'));
        var errMsg = event.getParam('detail');
        if(errMsg){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        console.log(JSON.stringify(event.getParams()));
         
        
    }
})