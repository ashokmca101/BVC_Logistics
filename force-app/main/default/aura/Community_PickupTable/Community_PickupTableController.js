({
    //get Address List from apex controller
    doInit : function(component, event, helper) {
        var action = component.get("c.getAddressList");
        action.setParams({
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log("result.getReturnValue():::"+result.getReturnValue());
                component.set("v.addressList",result.getReturnValue().addressList);
                component.set("v.customerId",result.getReturnValue().customerId);  
            }
            else{
                component.set("v.addressList",'');
            }
        });
        $A.enqueueAction(action);
    },
    
    //Select all Address
    handleSelectAllAddress: function(component, event, helper) {
        var getID = component.get("v.addressList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkAddress = component.find("checkAddress"); 
        if(checkvalue == true){
            for(var i=0; i<checkAddress.length; i++){
                checkAddress[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkAddress.length; i++){
                checkAddress[i].set("v.value",false);
            }
        }
         helper.onCheck(component, event, helper);
    },
    
    //Process the selected Address
    onCheck: function(component, event, helper) {
        helper.onCheck(component, event, helper);
    },
    //show Pickup Form
    handleSelectedAddress: function(component, event, helper) {
         var addressId = component.get("v.addressId");
        if(addressId.length>0 ){
            //component.set("v.showPickupModal", true);
            var a = component.get('c.handleSubmit');
        	$A.enqueueAction(a);
           
        }else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'Pelase select atlreast one address.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'warning',
                    mode: 'pester'
                });
                toastEvent.fire();
            return null;
        }
        
    },
    /*handleSelectedAddress: function(component, event, helper) {
        var selectedAddress = [];
        var checkvalue = component.find("checkAddress");
         
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedAddress.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedAddress.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedAddress-' + selectedAddress);
        component.set("v.addressId", selectedAddress);
        component.set("v.showPickupModal", true);
    },*/
    
    //Hide Pickup Form
    handleCloseModal: function(component, event, helper) {
        component.set("v.showPickupModal", false);
    },
     handleSubmit: function(component, event, helper) {
         
        //event.preventDefault();
        //const fields = event.getParam('fields');
        
          //fields.Customer__c = component.get("v.customerId");
         //console.log('fields'+JSON.stringify(fields));
         
         var action = component.get("c.insertPickupData1");
        action.setParams({
            selectedAddressId : component.get("v.addressId"),
            //pickupMap : fields,
            customerId : component.get("v.customerId")
            
        });
         console.log('Inside Submit 4');
        action.setCallback(this, function(result){
            var state = result.getState();
            console.log('state::'+state);
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Pickup is created successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                component.set("v.showPickupModal", false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Something went wrong.Please contact admin.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    
    },
    handleError: function(component, event, helper) {
        
    },
    handleSuccess : function(component,event,helper) {
        // Return to the contact page and
        // display the new case under the case related list
        var record = event.getParams();  
        console.log(record.id);
    
          
       
    },
    //saving the Pickup Form
    handleCreatePickupEntry : function(component, event, helper) {
        var ConPerName=component.find("Contact_Person_Name__c").get("v.value");
        var ConPerNum=component.find("Contact_Person_Number__c").get("v.value");
        var Dest=component.find("Destination__c").get("v.value");
        var Insur=component.find("Insurance_By__c").get("v.value");
        var NetWgt=component.find("Net_Weight__c").get("v.value");
        var NetWgtUOM=component.find("Net_Weight_UOM__c").get("v.value");
        var NoOfPar=component.find("No_Of_Parcels__c").get("v.value");
        var PickDate=component.find("Pickup_Date__c").get("v.value");
        var PickTime=component.find("Pickup_Time__c").get("v.value");
        var ProdType=component.find("Product_Type__c").get("v.value");
        var TypePick=component.find("TypeOfPickup__c").get("v.value");
        var MapOfPickup = [ConPerName,ConPerNum,Dest,Insur,NetWgt,NetWgtUOM,NoOfPar,PickDate,PickTime,ProdType,TypePick];
        
        //alert(MapOfPickup);
        //MapOfPickup.push[ ['Contact_Person_Name__c' , ConPerName],['Contact_Person_Number__c', ConPerNum],['Destination__c', Dest] ];
        //alert(JSON.stringify(MapOfPickup));
        
        
        var action = component.get("c.insertPickupData");
        action.setParams({
            selectedAddressId : component.get("v.addressId"),
            pickupMap : MapOfPickup,
            customerId : component.get("v.customerId")
            
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            console.log('state::'+state);
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Pickup is created successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                component.set("v.showPickupModal", false);
            }
        });
        $A.enqueueAction(action);
        
        /*var addressId = component.get("v.addressId"); 
        console.log("addressId before submit::"+addressId);
        component.find("pickupForm").submit();*/
    },
    handleOnLoad : function(component, event, helper) {
        var addressId = component.get("v.addressId"); 
        console.log("addressId on load ::"+addressId);
    },
    
    //Show Toast msg on creation of Pickup Record And Refresh the page.
    handleOnSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Pickup is created successfully.',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
        
        component.set("v.reloadForm", false);
        component.set("v.reloadForm", true);
        
    },
    
    handleOnError : function(component, event, helper) {
        
    },
})