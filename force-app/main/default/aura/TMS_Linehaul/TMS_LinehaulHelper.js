/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-22-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-17-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
({
    saveBoxHelper : function(component, event, helper) {
        var s = component.get("v.SelectedSeal");
        var sval = '';
        var stext = '';
        console.log("sss: ",s);
        var isError = false;
        
        
        if(s !== null && s !==undefined){
            sval = s.val;
            stext = s.text;
        }
        else{
            isError = true;
        }
        var destination = component.get("v.SelectedDest");
        var destinationValue = "";
        console.log('Value of Destination: ',component.get("v.SelectedDest"));
        if(destination !== null && destination !==undefined && destination !== ""){
            destinationValue = destination;
            console.log('value: ',destinationValue);
        }
        else{
            isError = true;
        }
        console.log("dest: ",component.get("v.SelectedDest"));
        
        //component.find("BagSelect").set("v.value", false);
        
        
        if(isError){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "This Next Destination and Secure Seal are required",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
        else{
            component.set("v.showModal", false);
            var action = component.get("c.AddBox");
            action.setParams({
                "BagWrapJson": JSON.stringify(component.get("v.BagList")),
                "seal":stext,
                "SealId":sval,
                "Dest": component.get("v.SelectedDest")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("state: "+state);
                
                if (state === "SUCCESS") {                
                    component.set("v.BagList", response.getReturnValue());
                    console.log("success: "+component.get("v.BagList"));
                    component.set("v.SelectedSeal",null);
                    component.set("v.SelectedDest",'');
                }
            }); 
            $A.enqueueAction(action);
        }
    },
    doInitHelper: function (component, event, helper) {
        window.console.log('====doInitHelper====');
        component.set("v.pageNum",1);
        component.set("v.Filter","Inbound");
        var hubObj = component.get("v.SelHub");
        var hubval = '';
        if(hubObj !== null){
            hubval = hubObj.text;
        }
        var action = component.get("c.Shipments");
        action.setParams({
            "filter":"Inbound",
            "Hub":hubval
        });
        
        var origin = component.get("v.OriginCity");
        var dest = component.get("v.DestCity");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var err = response.getReturnValue().error;
                component.set("v.ShipmentList", response.getReturnValue().lineHaulWrapList);
                component.set("v.ShowHub", response.getReturnValue().showHubFilter);
                if(err ==""){
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            } else {
                console.log("list: Error ");
            }
        }); 
        $A.enqueueAction(action);

        this.focusTimerStart(component);
    },
    handleSelectHelper : function(component, event, helper){
        console.log('===== ',component.find("select").get("v.value"));
        component.set("v.Filter",component.find("select").get("v.value"));
        var filt = component.get("v.Filter");
        if(filt =="Outbound"){
            component.set("v.DisableAddBox",false);
            component.set("v.DisableAddLineHaul",false);
            //component.set("v.DisableAddDest",false);
            component.set("v.DisableSaveDraft",false);
        }else if(filt =="Inbound"){
            component.set("v.DisableAddBox",true);
            component.set("v.DisableAddLineHaul",true);
            //component.set("v.DisableAddDest",true);
            component.set("v.DisableSaveDraft",true);
        }else if(filt =="Finalised"){
            component.set("v.DisableAddBox",false);
            component.set("v.DisableAddLineHaul",false);
            //component.set("v.DisableAddDest",false);
            component.set("v.DisableSaveDraft",false);
        }
        var hubObj = component.get("v.SelHub");
        var hubval = '';
        if(hubObj !== null){
            hubval = hubObj.text;
        }
        var action = component.get("c.Shipments");
        action.setParams({
            "filter":component.find("select").get("v.value"),
            "Hub":hubval
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var err = response.getReturnValue().error;
                component.set("v.ShipmentList", response.getReturnValue().lineHaulWrapList);
                component.set("v.ShowHub", response.getReturnValue().showHubFilter);
                if(err ==""){
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            } else {
                console.log("list: Error ");
            }
        });
        $A.enqueueAction(action);
    },
    AddToLineHaulHelper : function(component, event, helper){
        
        var shipList = component.get("v.BagList");
        var LineHaulType = shipList[0].sb.Linehaul_Type__c;
        var fnlNum;
        console.log("in add to line");
        var action = component.get("c.AddBagToLineHaul");
        action.setParams({
            "BagWrapJson": JSON.stringify(shipList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue().options;
                var err = response.getReturnValue().error;
                var fnlBag = response.getReturnValue().finalBag;
                fnlNum = response.getReturnValue().FinalizedLHNumber;
                
                if(err==""){
                    component.set("v.pageNum",3);
                    var BPval = [];
                    for(var key in result){
                        BPval.push({key: key, value: result[key]});
                    }
                    component.set("v.picklistVal", BPval);
                    console.log("fnlBag",fnlBag);
                    component.set("v.Airport",response.getReturnValue().Originport);
                    component.set("v.DestAirport",response.getReturnValue().Destport);
                    component.set("v.FlightSchedule",response.getReturnValue().Flight);
                    component.set("v.Vehicle",response.getReturnValue().Vehicle);
                    if(response.getReturnValue().haulType !==undefined){
                        LineHaulType = response.getReturnValue().haulType;
                    }
                    if(fnlBag !==undefined){
                        component.set("v.finalisedNumber",fnlBag.Finalised_Linehaul_Number__c);
                        component.set("v.FlightDateTime",fnlBag.Flight_Date_Time__c);
                    }
                    component.set("v.finalisedNumberRoad",fnlNum);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                
            }
            window.setTimeout(
                $A.getCallback( function() {
                    if(fnlBag !==undefined){
                        component.set("v.LineHaulType",fnlBag.Linehaul_Type__c);
                    }
                    // Now set our preferred value
                    //component.find("a_opt").set("v.value", accounts[4].Id);
                }));
        });
        $A.enqueueAction(action);
    },
    SecureBagsHelper : function(component, event, helper){
        component.set("v.pageNum", 2);
        console.log("======== Shipment =======", component.get("v.ShipmentList"));
        let shipment = component.get("v.ShipmentList");
        var selectedBags = [];
        
        for (var i= 0 ; i < shipment.length ; i++){
            if(shipment[i].process == true){
                for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                    if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                        selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                            return currentValue
                        }));
                    }else {
                        selectedBags.push(Object.values(shipment[i].BagList)[j]);
                    }
                }
            }
        }
        console.log("===== selectedBags ===",selectedBags);
        var action = component.get("c.SecureBagsList");
        action.setParams({
            "BagList": selectedBags
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.BagList", response.getReturnValue().BagWrapList);
                console.log("success: ",component.get("v.BagList"));
                
                var result = response.getReturnValue().BranchOptions;
                var BPval = [];
                for(var key in result){
                    BPval.push({key: key, value: result[key]});
                }
                component.set("v.CityVal", BPval);
            }
        }); 
        $A.enqueueAction(action);
    },
    FilterBagHelper : function(component, event, helper){
        //helper.SecureBagsHelper(component, event, helper);
        console.log("filter bag");
        var d = component.get("v.FilterDest");
        var s = component.get("v.FilterSeal");
        var c = component.get("v.FilterCargo");
        
        let shipment = component.get("v.ShipmentList");
        var selectedBags = [];
        
        for (var i= 0 ; i < shipment.length ; i++){
            if(shipment[i].process == true){
                for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                    if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                        selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                            return currentValue
                        }));
                    }else {
                        selectedBags.push(Object.values(shipment[i].BagList)[j]);
                    }
                }
            }
        }
        
        var action = component.get("c.FilteredBagList");
        action.setParams({
            "bags":selectedBags,
            "Dest":d,
            "SealId":s,
            "CargoType":c
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.BagList", response.getReturnValue());
                console.log("success: ",component.get("v.BagList"));
            }
        }); 
        $A.enqueueAction(action);
    },
    SaveHelper : function(component, event, helper){
        var action = component.get("c.SaveProcess");
        var fli = (component.get("v.FlightSchedule"));
        var veh = (component.get("v.Vehicle"));
        var flival = '';
        if(fli !== null && fli !==undefined)
            flival = fli.val;
        var vehval = '';
        if(veh !== null && veh !==undefined)
            vehval = veh.val;        
        action.setParams({
            "BagWrapJson": JSON.stringify(component.get("v.BagList")),
            "LHType": (component.get("v.LineHaulType")),
            "LHNumber":(component.get("v.finalisedNumber")),
            "Flight" : flival,
            "FlightDate" : (component.get("v.FlightDateTime")),
            "Vehicle" : vehval
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state: "+state);
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(result ==="Success"){
                    $A.get('e.force:refreshView').fire();
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Added to Linehaul successfully.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }else{
                    toastEvent.setParams({
                        title: "Error!",
                        message: result,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                }
                
                toastEvent.fire();
            }
            else if(state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: errors[0].message,
                    duration:' 10000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        }); 
        $A.enqueueAction(action);
    },
    DestHubChangeHelper :function(component, event, helper){
        var target = event.target;
        var searchText = target.value;
        console.log('helper= ', searchText);
        if(searchText===""){
            helper.SecureBagsHelper(component, event, helper);
        }else{
            let shipment = component.get("v.ShipmentList");
            var selectedBags = [];
            
            for (var i= 0 ; i < shipment.length ; i++){
                if(shipment[i].process == true){
                    for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                        if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                            selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                                return currentValue
                            }));
                        }else {
                            selectedBags.push(Object.values(shipment[i].BagList)[j]);
                        }
                    }
                }
            }
            
            var action = component.get("c.FilteredBagByDest");
            action.setParams({
                "bags":selectedBags,
                "SearchText":searchText
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.BagList", response.getReturnValue());
                    console.log("success: ",component.get("v.BagList"));
                }
            }); 
            $A.enqueueAction(action);
        }
        
    },
    BagChangeHelper :function(component, event, helper){
        var target = event.target;
        var searchText = target.value;
        console.log('helper= ', searchText);
        if(searchText===""){
            helper.SecureBagsHelper(component, event, helper);
        }else{
            let shipment = component.get("v.ShipmentList");
            var selectedBags = [];
            
            for (var i= 0 ; i < shipment.length ; i++){
                if(shipment[i].process == true){
                    for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                        if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                            selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                                return currentValue
                            }));
                        }else {
                            selectedBags.push(Object.values(shipment[i].BagList)[j]);
                        }
                    }
                }
            }
            console.log('calll ', JSON.stringify(component.get("v.BagList")));
            var action = component.get("c.FilteredByBagNo");
            action.setParams({
                "BagWrapJson":JSON.stringify(component.get("v.BagList")),
                "bags":selectedBags,
                "SearchText":searchText
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // added by Imran BVC
                    var responseData = response.getReturnValue();
                     component.set("v.BagList", response.getReturnValue().reverse());
                     console.log("success: ",responseData);
                    if(responseData != 0)
                    {
                        console.log("Err:");
                     component.set("v.NewBagList", response.getReturnValue());
                    }
                    if(responseData)
                    {
                        function isEmpty(str) {
                            return (!str || 0 === str.length);
                        }
                    }
                    if(responseData == 0 )
                    {
                        helper.invokeErrorMessage(component, event, helper);
                        var vals = component.get("v.NewBagList");
                       console.log("Err:1222");
                         component.set("v.BagList", vals);

                    }
                    helper.handleReset(component, event, helper, searchText);
                }
            }); 
            $A.enqueueAction(action);
        }
        
    },
    handleReset : function(component, event, helper,src)
    {
        event.target.value = "";

    },
    invokeErrorMessage: function(component,event,helper)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error!",
            message: "The Bag Identifier  is not in the list.",
            duration:' 3000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    //Imran code ends
    focusTimerStart: function(component){
        function setFocus(){
            if(component.find('laserScanner') && component.get('v.showBarcodeModal')){
                    component.find('laserScanner').focus();
            }
        }
        
        //run periodically
        setInterval($A.getCallback(setFocus),1000);
    },
    scanSuccess: function(component,event){
        let result  = event ? event.getParam("result") : null;
        let success = event ? event.getParam("success") : null;
        let barcode = ((success && result && result[0]) ? result[0].data : null);
        this.process(component,barcode);    
    },
    process: function(component,barcode){
        let bags = component.get('v.BagList');
        let bagFound = false;
        let bagIndex = null;

        for(var i=0; i<bags.length; i++){
            if(bags[i].sb.Secure_Packaging_Identifier__c == barcode){

                bags[i].process = true;
                bagFound = true;
                bagIndex = i;
                
                break;
            }
        }
        if(bagFound){
            let bag = bags.splice(i,1);
            bags.unshift(bag[0]);
            component.set('v.BagList',bags);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "The Bag Identifier "+barcode+" is not in the list.",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
     AvailableAWBHelper: function(component, event,helper){
        var originVal = component.get("v.Airport");
        var desitnationVal = component.get("v.DestAirport");
        var flightDateTime = component.get("v.FlightDateTime");
        var action = component.get("c.getAvailableAwb");
        var availAWB = component.get("v.availAWB");
        var airlineName = component.find("arlList").get("v.value");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
        action.setParams({
            origin : originVal.text,
            destination : desitnationVal.text,
            flightDate : flightDateTime,
            flightscheduleId:component.get('v.flightscheduleId'),
            airlineName: airlineName
        });
        console.log('origin ',originVal.text);
        console.log('desti ',desitnationVal.text);
        console.log('Date ',flightDateTime);
        console.log('Flight ID ',component.get('v.flightscheduleId'));
        console.log('airline name ',airlineName);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length===0){
                    if(airlineName === 'Indigo'){
                        helper.makecalloutforIndigoawb(component,event,helper,originVal.text,desitnationVal.text,flightDateTime);
                    }else{
                        helper.makecalloutforSpiceJetawb(component,event,helper,originVal.text,desitnationVal.text,flightDateTime);
                    }
                }else{
                    var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
                }
                console.log(result);
            }
        });
        $A.enqueueAction(action);
    },
    
  makecalloutforSpiceJetawb : function(component,event,helper,originVal,desitnationVal,flightDateTime){
        console.log(JSON.stringify(component.get("v.ShipmentList")));
        console.log(JSON.stringify(component.get("v.BagList")));
        var availAWB = component.get("v.availAWB");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
        var action2 = component.get("c.getAWBFromAPICalloutSpiceJet");
        action2.setParams({
            origin : originVal,
            destination : desitnationVal,
            flightDate : flightDateTime,
            shipmentList: JSON.stringify(component.get("v.ShipmentList")),
            baglist: JSON.stringify(component.get("v.BagList")),
            flightscheduleId: component.get('v.flightscheduleId'),
            commodityCode: component.get('v.selectedComCode')
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null && result.length>=0){
                      var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
            
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: result.message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
                    }
              }
        });
        $A.enqueueAction(action2);
        
    },

    makecalloutforIndigoawb : function(component,event,helper,originVal,desitnationVal,flightDateTime){
        console.log(JSON.stringify(component.get("v.ShipmentList")));
        console.log(JSON.stringify(component.get("v.BagList")));
        var availAWB = component.get("v.availAWB");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
        var action2 = component.get("c.getAWBFromAPICalloutIndigo");
        action2.setParams({
            origin : originVal,
            destination : desitnationVal,
            flightDate : flightDateTime,
            shipmentList: JSON.stringify(component.get("v.ShipmentList")),
            baglist: JSON.stringify(component.get("v.BagList")),
           // flightscheduleId: component.get('v.flightscheduleId'),
            commodityCode: component.get('v.selectedComCode')
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null && result.length>=0){
                      var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
            
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: result.message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
                    }
              }
        });
        $A.enqueueAction(action2);
        
    },
                        getAirlines: function (component, event, helper){
                            var availAWB = component.get("v.airlineList");
                            availAWB = [{"Id":"--Select a Value--","Airline_Name__c":"--Select a Value--"}];
         component.set("v.airlineList", availAWB);
                            var action2 = component.get("c.getAirlinesDetails");
                            action2.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var result = response.getReturnValue();
                                     var availAWB2 = component.get("v.airlineList");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                                    component.set('v.airlineList',availAWB2);
                                }
                            });
                            $A.enqueueAction(action2);
                        },
                        
                        setCommodityCode :function (component, event, helper,airlineName){
                          var availAWB = component.get("v.commodityCodeList");
                            availAWB = [{"Id":"--Select a Value--","Commodity_Code__c":"--Select a Value--"}];
         component.set("v.commodityCodeList", availAWB);
                            var action2 = component.get("c.getCommodityCode");
                             action2.setParams({
                                 airlineName : airlineName});
                            action2.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var result = response.getReturnValue();
                                     var availAWB2 = component.get("v.commodityCodeList");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                                    component.set('v.commodityCodeList',availAWB2);
                                }
                            });
                            $A.enqueueAction(action2);
                        },
    
    /*,SaveDraftHelper : function(component, event, helper){
        console.log("in draft helper");
	var action = component.get("c.SaveDraftBags");
        action.setParams({
            "BagWrapJson": JSON.stringify(component.get("v.BagList"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.BagList", response.getReturnValue());
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(result ==="success"){
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Bags drafted successfully.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }else{
                    toastEvent.setParams({
                        title: "Error!",
                        message: result,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                }
                
                toastEvent.fire();                
            }
        }); 
        $A.enqueueAction(action);
    }*/
})