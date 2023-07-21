({
	doinit : function(component, event, helper) {
        component.set('v.Spinner', false);
        var objectName = component.get("v.sObjectName");
        console.log('objectName: ',objectName); //debug object name
        if(objectName == 'Linehaul__c'){
            var recordIdLinehaul = component.get("v.recordId");
            console.log('recordIdLinehaul: ',recordIdLinehaul); //debug record line haul
            var action = component.get("c.getlinehaul");
            console.log('action: ',action); //debug Action
            action.setParams({
                "recordIdLinehaul" : recordIdLinehaul 
            });
            action.setCallback(this,function(resp){
                var state = resp.getState();
                console.log('state: ',state); //debug state
                if(state == 'SUCCESS'){
                    console.log('SUCCESS'); //debug 
                    debugger;
                    var response = resp.getReturnValue();
                    console.log('response: ',response); //debug response
                    if(response != null){
                        console.log('Success');  //debug
                        console.log('Response: '+response);  //debug
                        var airlineName = component.set("v.AirlineName",response.AirLine_Name__c);
                        component.set("v.linehaul",response);  //debug
                        component.set("v.showLinehaulObj",true);   //debug
                    }
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    createAWBOnClick : function(component, event, helper) {
        //call apex method
        console.log('entered create awb on click function');
        component.set('v.Spinner', true);
        debugger;
        var recordIdLinehaul = component.get("v.recordId"); 
        var objectName = component.get("v.sObjectName");
        var objLinehaulObj = component.get("v.linehaul");
        //component get
        
        var airlineName = component.get("v.AirlineName");
        console.log('recordIdLinehaul: '+recordIdLinehaul);
        console.log('>>>>>Object Linehaul>>>>'+objLinehaulObj);
        console.log('Objrct Name ==='+objectName);
        console.log('Airline Name'+airlineName);
        
        if(objectName == 'Linehaul__c' && airlineName == 'Indigo'){
            console.log('Entered in If part for Indigo');
            var action = component.get("c.indigoAWB");
            action.setParams({
                "recordIdLinehaul" : recordIdLinehaul
            });
            
            action.setCallback(this,function(resp){
                var state = action.getState();
                if(state == "SUCCESS"){
                    console.log('SUCCESS');
                    var response = resp.getReturnValue();
                    console.log('response: ',response);
                    //component set
                    if(response != null && response == 'Success'){
                       $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : "Success",
                            "message": "AWB Successfully Generated"
                        });
                        toastEvent.fire();
                    }
                    else if(response == 'awbNumberError'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "Error",
                            "message": "AWB Already Generated"
                        });
                        toastEvent.fire();
                        component.set('v.Spinner', false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                   
                }
                else{
                    alert("Error While Generating AWB");
                    component.set('v.Spinner', false);
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            console.log('Entered in else part');
            var action = component.get("c.spiceJetAWB");
            action.setParams({
                "recordIdLinehaul" : recordIdLinehaul
            });
            
            action.setCallback(this,function(resp){
                var state = action.getState();
                if(state == "SUCCESS"){
                    console.log('SUCCESS');
                    var response = resp.getReturnValue();
                    console.log('response: ',response);
                    if(response != null && response == 'Success'){
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : "Success",
                            "message": "AWB Successfully Generated"
                        });
                        toastEvent.fire();
                    }
                    else if(response == 'awbNumberError'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "Error",
                            "message": "AWB Already Generated"
                        });
                        toastEvent.fire();
                        component.set('v.Spinner', false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else if(response == 'flightoriginError' || response == 'FlightDestinationError' || response == 'FromError' || response == 'ModeError' || response == 'FlightCodeError'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "Error",
                            "message": "Please Fill the Flight Origin, Flight Destination, From, Mode, Flight Code"
                        });
                        toastEvent.fire();
                        component.set('v.Spinner', false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "Error",
                            "message": "AWB Was Not Generated"
                        });
                        toastEvent.fire();
                        component.set('v.Spinner', false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
                else{
                    alert("Error While Generating AWB");
                    component.set('v.Spinner', false);
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    handleSuccess: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
    
})