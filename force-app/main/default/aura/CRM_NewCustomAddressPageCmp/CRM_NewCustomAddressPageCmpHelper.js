({
	cancel : function(component, event, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "AddressBook__c"
        });
	homeEvt.fire();
    },
    validate : function(component,event,helper) {
      
        var ADDRESS1__c = component.find("ADDRESS1__c").get("v.value");
        var PINCODE__c = component.find("ActivePincode").get("v.value");
        var CITY__c = component.find("City").get("v.value");
        var Your_Address_Identifier__c = component.find("Your_Address_Identifier__c").get("v.value");
       console.log(Your_Address_Identifier__c);
        if( ADDRESS1__c && PINCODE__c /*&& CITY__c*/ && Your_Address_Identifier__c){
            component.set("v.isLoading",true);
         	component.find("recordEditForm").submit();
        }
        else {
            var fieldname='';
            var toastEvent = $A.get("e.force:showToast");
            if(!Your_Address_Identifier__c){
             fieldname='Address identifier is missing! Kindly enter.';   
            }
            if(!ADDRESS1__c){
             fieldname='Address1 Missing! Kindly Populate.';   
            }
            /*if(!CITY_AREA__c){
             fieldname='City Area Missing! Kindly Populate.';   
            }*/
            if(!PINCODE__c){
             fieldname='Pincode Missing! Kindly Populate.';   
            }
            /*if(!CITY__c){
             fieldname='City Missing! Kindly Populate.';   
            }*/
            toastEvent.setParams({
                title : 'Warning',
                message: fieldname,
                duration:' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'pester'
        	});
        toastEvent.fire();
            return;
        }
    },
    getCustomerId : function(component,event,helper) {
        var action = component.get("c.getCustomerMethod");
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var result = response.getReturnValue();
                component.find("Customer__c").set("v.value",result);
				component.set("v.NotaPortalUser",false);
                component.set("v.isCommunity",true);
                
				console.log('Result : '+ result);
			}else{
				console.log('Failed : '+ response.getError());
			}
		});
		$A.enqueueAction(action);
    },
    getRecordTypeId: function(component,event,helper) {
        var action = component.get("c.getRecordTypeIdMethod");
        action.setParams({
            "recTypeId": component.find("RecordTypeId").get("v.value")
        });
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var result = response.getReturnValue();
                component.find("RecordTypeId").set("v.value",result.RecrdTypeId);
                //alert(component.find("RecordTypeId").get("v.value")+' result::: '+result.RecrdTypeId);
				component.set("v.NotaPortalUser",result.NotaPortalUser);
                if(result.RecordtypeName == 'Shipping'){
                   component.set('v.isShipping',true); 
                }else{
                     component.set('v.isShipping',false); 
                }
				console.log('result.NotaPortalUser : '+ result.NotaPortalUser);
			}else{
				console.log('Failed : '+ response.getError());
			}
		});
		$A.enqueueAction(action);
    }
    
})