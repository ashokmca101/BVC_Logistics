/**
 * @description       : 
 * @author            : Imran
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-11-2023   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
({
    doInit : function(component, event, helper) {
        console.log('Do Init Starts');
        //  helper.doInitHelper(component, event, helper);        
        console.log('Do doInitHelper Ends');
        /*
        var today = new Date();	
        
        var tomrorr = new Date(today.getTime()+1000*60*60*24);//today.setDate(today.getDate() + 1);	
        var date = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");	
        var tommorowdate = ($A.localizationService.formatDate(new Date()+1, "YYYY-MM-DD"));	
        
        component.set('v.currentDate', today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate());	
        component.set('v.TommorowDate', tomrorr.getFullYear()+'-'+(tomrorr.getMonth()+1)+'-'+tomrorr.getDate());	
       */ 
    },
    
    onCheck: function(cmp, evt) {         
        var checkCmp = cmp.find("checkbox");
        console.log('VVGG :'+checkCmp.get("v.value"));
        var test = checkCmp.get("v.value");
        if(test==true)
        {
            console.log('11 true');
            cmp.set("v.stag",true);
        }
        else
        {
            console.log('11 false');
            cmp.set("v.stag",false);  
        }
        
    },
    handleSave : function(component, event, helper){
        console.log('Customer Id :'+component.get("v.CAccount.val"));
        console.log('Shipping Account Id :'+component.get("v.SelHub.val"));
        console.log('Shipping Address Id :'+component.get("v.SelHub1.val"));
        console.log('Remarks :'+component.get("v.Remarks"));
        console.log('Pickup date and Time :'+component.get("v.P_Date"));
        var CustomerAcId = component.get("v.CAccount.val");
        var ShipAcId = component.get("v.SelHub.val");
        var ShipAddressId = component.get("v.SelHub1.val");
        var remarks = component.get("v.Remarks");
        var pdate = component.get("v.P_Date");
        var stg = component.get("v.stag");
        if(CustomerAcId == null){component.set("v.cac",false);}else{component.set("v.cac",true);}
        if(ShipAcId == null){component.set("v.sac",false);}else{component.set("v.sac",true);}
        if(ShipAddressId == null){component.set("v.sad",false);}else{component.set("v.sad",true);}
        
        if(CustomerAcId!=null && ShipAcId!=null && ShipAddressId!=null)
        {
            
            console.log('Satisfies');
            component.set("v.refresh",true);                        
            var action1 = component.get('c.SavePickup');
            action1.setParams({
                CAId : CustomerAcId,
                SAId : ShipAcId,
                SAddId : ShipAddressId,
                Remarks : remarks,
                P_date : pdate,
                stg : stg
            });
            console.log('22.CID :'+ShipAcId);
            action1.setCallback(this,function(a){
                var FVal;
                var PVal;
                var pkName;
                if (action1.getState() === 'SUCCESS') {
                    //var retObj = JSON.parse(res.getReturnValue());
                    console.log('=============success===================');
                    console.log('RES :'+a.getReturnValue());
                    var myList = a.getReturnValue();
                    for(const ele of myList){
                        console.log('Elememt : '+ele);
                        if(ele=='FAIL')
                        {
                            FVal=ele;
                            PVal='';
                        }
                        if(ele=='SUCCESS')
                        {
                            PVal=ele;
                            FVal='';
                        }                        
                        pkName=ele;
                    }
					console.log('FVal :'+FVal+' PVal'+PVal+' Name :'+pkName);
                   // if(a.getReturnValue()!='SUCCESS')
                    if(FVal=='FAIL')
                    {
                        component.set("v.dup",true);
                        component.set("v.refresh",false);  
                        component.set("v.PKName",a.getReturnValue());
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Duplcate Pickup Error',
                            message:'Pickup Already Exists : '+a.getReturnValue(),
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else
                    {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: "The Pickup "+pkName+" has been Created successfully.",
                            type: 'success'
                            
                        });
                        toastEvent.fire();  
                        
                        component.set("v.refresh",false);          
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/a2n/o"
                        });
                        urlEvent.fire();
                        
                    }
                    
                }else if (action1.getState() === 'ERROR'){
                    var errors = action1.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    } 
                    
                }
            });
            $A.enqueueAction(action1); 
            
            /*   
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/a2n/o"
        });
        urlEvent.fire();
          */  
        }        
        else
        {
            console.log('Fill Account and Address Details');
            
        }
    },
    
})