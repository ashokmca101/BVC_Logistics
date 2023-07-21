/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-28-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
          helper.getAirlines(component, event, helper);	
        var today = new Date();	
              //  var date = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");	
        var tomrorr = new Date(today.getTime()+1000*60*60*24);//today.setDate(today.getDate() + 1);	
        var date = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");	
        var tommorowdate = ($A.localizationService.formatDate(new Date()+1, "YYYY-MM-DD"));	
        	
        component.set('v.currentDate', today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate());	
        component.set('v.TommorowDate', tomrorr.getFullYear()+'-'+(tomrorr.getMonth()+1)+'-'+tomrorr.getDate());	
        //component.set('v.FlightDateTime',today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate());
    },
    SecureBags : function(component, event, helper){
        console.log("List: ",component.get("v.ShipmentList"));
        helper.SecureBagsHelper(component, event, helper);
    },
    /*SaveDraft : function(component, event, helper){
        helper.SaveDraftHelper(component, event, helper);
    },*/
    FilterBag : function(component, event, helper){
        helper.FilterBagHelper(component, event, helper);
    },
    handleSelect:function(component, event, helper){
		helper.handleSelectHelper(component, event, helper);
    },
    AddToLineHaul : function(component, event, helper) {
        helper.AddToLineHaulHelper(component, event, helper);
    },
    showModel: function(component, event, helper) {
        component.set("v.showModal", true);
    },
    
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
    },
    saveBox: function(component, event, helper) {
        helper.saveBoxHelper(component, event, helper);
    },
    Save: function(component, event, helper){
        console.log("type: "+component.get("v.LineHaulType"));
        console.log("Num: "+component.get("v.finalisedNumber"));
        helper.SaveHelper(component, event, helper);
    },
    BackToShip: function(component, event, helper){
        component.set("v.SelectedDestination","All");
        component.set("v.pageNum",1);
        helper.handleSelectHelper(component, event, helper);
    },
     AvailableAWB: function(component, event, helper){	
        var selectedFlight = component.get('v.flightscheduleId');	
        var airlineVal=  component.find("arlList").get("v.value");	
        if(airlineVal==='SPICEJET' ){	
        if(selectedFlight!==null && selectedFlight!==undefined && selectedFlight!== ''){	
            helper.AvailableAWBHelper(component, event, helper);	
        }else{	
              var toastEvent = $A.get("e.force:showToast");	
            toastEvent.setParams({	
                title: "Error!",	
                message: "Select a Flight Schedule to Fetch AWB",	
                duration:' 3000',	
                key: 'info_alt',	
                type: 'error',	
                mode: 'pester'	
            });	
            toastEvent.fire();	
        }	
        } else {	
            helper.AvailableAWBHelper(component, event, helper);	
        }	
    },
    BackToBag: function(component, event, helper){
        component.set("v.pageNum",2);
    },
    LineHaulChange:function(component, event, helper){
        if(component.get("v.LineHaulType")=="Road"){
            var fn = component.get("v.finalisedNumberRoad");
            component.set("v.finalisedNumber",fn);
        }else{
            component.set("v.finalisedNumber",'');
        }
    },
    DestHubChange : function(component, event, helper){
        var target = event.target;
        var searchText = target.value;
        console.log('===== ', searchText);
        if ( event.keyCode === 13 ){
            console.log('enter ', searchText);
            helper.DestHubChangeHelper(component, event, helper);
        }  
    },
    BagChange : function(component, event, helper){
        var target = event.target;
        var searchText = target.value;
        console.log('===== ', searchText);
        if ( event.keyCode === 13 ){
            console.log('enter ', searchText);
            helper.BagChangeHelper(component, event, helper);
        }  
    },
    selectAllBag: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("BagPack");
        if(! Array.isArray(getAllId)){
            component.find("BagPack").set("v.value", selectedHeaderCheck);
        }else{
            for (var i = 0; i < getAllId.length; i++) {
                component.find("BagPack")[i].set("v.value", selectedHeaderCheck);
            }
        }  
    },
    
    selectAll: function(component, event, helper) {
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array   
        if(! Array.isArray(getAllId)){
            component.find("boxPack").set("v.value", selectedHeaderCheck);
        }else{
            // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
            // and set the all selected checkbox length in selectedCount attribute.
            // if value is false then make all checkboxes false in else part with play for loop 
            // and select count as 0 
            for (var i = 0; i < getAllId.length; i++) {
                component.find("boxPack")[i].set("v.value", selectedHeaderCheck);
            }
        }  
    },
    showSpinner: function(component, event, helper) { 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){    
        component.set("v.spinner", false);
    },
    onClickScanBags: function(component,event,helper){
        component.set('v.showBarcodeModal',true);
    },
    hideBarcodeModal: function(component,event,helper){
        component.set('v.showBarcodeModal',false);
    },
    onScanSuccess:function(component,event,helper){
        helper.scanSuccess(component,event);
    },
    removeBag: function(component,event){ 
        var newbagList = [];
        var bagdatas = component.get("v.BagList");
        console.log('===== removeBag ====',bagdatas);
        bagdatas.forEach(item=>{
            console.log('process ' , item.process);
            if(item.process == false){
              newbagList.push(item);
          }
        }); 
        console.log('===== newbagList ====',newbagList);   
        component.set("v.BagList",newbagList); 
     },
            
    onSelectedAWBChange:function(component,event,helper){
        
       var selectedValue=  component.find("awbSelect").get("v.value");
        if(selectedValue === "--Select a Value--"){
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "Select from Available AWB",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else {
            component.set("v.finalisedNumber",selectedValue);
        }

    },
  
    onSelectedFlightSchedChange :function(component,event,helper){
            var originVal = component.get("v.Airport");
        var desitnationVal = component.get("v.DestAirport");
        var flightDateTime = component.get("v.FlightDateTime");
       var airlineVal=  component.find("arlList").get("v.value");
        if(airlineVal==='SPICEJET' ){
            component.set("v.showFlightSchedule",true);
             var availAWB = component.get("v.availFlightSchedule");
        availAWB = ["--Select a Value--"];
         component.set("v.availFlightSchedule", availAWB);
         if(originVal!==null && originVal!==''&& desitnationVal!==null && desitnationVal!=='' && flightDateTime!==null && flightDateTime!==''
                && airlineVal!=null && airlineVal!== ''){
            var action = component.get('c.getFlightSchedule');
            action.setParams({
                origin : originVal.text,
              destination : desitnationVal.text,
              flightDate : flightDateTime,
                airlineVal: airlineVal
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                result.forEach(key=>{
                    if(key.Airline_Name1__c=='Indigo'){
                      key.Actual_Flight_Departure__c = $A.localizationService.formatDateTime(key.Actual_Flight_Departure__c);
                  }else {
                      key.Schedule_Time_To_Departure__c = $A.localizationService.formatDateTime(key.Schedule_Time_To_Departure__c);//.getFullYear()+'-'+(key.Schedule_Time_To_Departure__c.getMonth()+1)+'-'+key.Schedule_Time_To_Departure__c.getDate();
                }
              });
                    var availAWB2 = component.get("v.availFlightSchedule");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availFlightSchedule", availAWB2);
                        if(airlineVal!==null && airlineVal!== undefined){
                                                helper.setCommodityCode(component,event,helper,airlineVal);

                    }
                            //component.set("v.spinner", false); 
//            component.set('v.availFlightSchedule',result);


            }
                console.log(JSON.stringify(result)+'@@@');
            
                               });
        $A.enqueueAction(action);
                               
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "Select from Origin, Destination, Flight Date and Airline to get Flight Schedule",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }

        } 
        
        else if(airlineVal==='Indigo'){
            component.set('v.showFlightSchedule',false);
            if(airlineVal!==null && airlineVal!== undefined){
                                                helper.setCommodityCode(component,event,helper,airlineVal);

                    }
      /*      var availAWB = component.get("v.availFlightSchedule");
        availAWB = ["--Select a Value--"];
         component.set("v.availFlightSchedule", availAWB);
         if(originVal!==null && originVal!==''&& desitnationVal!==null && desitnationVal!=='' && flightDateTime!==null && flightDateTime!==''
                && airlineVal!=null && airlineVal!== ''){
            var action = component.get('c.getFlightSchedule');
            action.setParams({
                origin : originVal.text,
              destination : desitnationVal.text,
              flightDate : flightDateTime,
                airlineVal: airlineVal
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                result.forEach(key=>{
                    if(key.Airline_Name1__c=='Indigo'){
                      key.Actual_Flight_Departure__c = $A.localizationService.formatDateTime(key.Actual_Flight_Departure__c);
                  }else {
                      key.Schedule_Time_To_Departure__c = $A.localizationService.formatDateTime(key.Schedule_Time_To_Departure__c);//.getFullYear()+'-'+(key.Schedule_Time_To_Departure__c.getMonth()+1)+'-'+key.Schedule_Time_To_Departure__c.getDate();
                }
              });
                    var availAWB2 = component.get("v.availFlightSchedule");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availFlightSchedule", availAWB2);
                        if(airlineVal!==null && airlineVal!== undefined){
                                                helper.setCommodityCode(component,event,helper,airlineVal);

                    }
                            //component.set("v.spinner", false); 
//            component.set('v.availFlightSchedule',result);


            }
                console.log(JSON.stringify(result)+'@@@');
            
                               });
        $A.enqueueAction(action);
                               
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "Select from Origin, Destination, Flight Date and Airline to get Flight Schedule",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
*/
        }
        else {
                        component.set('v.showFlightSchedule',false);

        }
      
    },
     
   onselectedFlightSchedule:function(component,event,helper){
                var selectedValue=  component.find("flightSched").get("v.value");
        if(selectedValue === "--Select a Value--"){
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "Select from Available Flight Schedule",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
            component.set('v.flightscheduleId',selectedValue);
        }
            },
            
            onSelectedAirline:function(component,event,helper){
                var selectedValue=  component.find("arlList").get("v.value");
                if(selectedValue === "--Select a Value--"){
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "Select from Available Airlines",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
                }else{
                    helper.setCommodityCode(component,event,helper,selectedValue);
                }
            },
            
            onSelectedComCode:function(component,event,helper){
                var selectedValue=  component.find("comCode").get("v.value");
                if(selectedValue === "--Select a Value--"){
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "Select from Commodity Code",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
                }else{
                    component.set('v.selectedComCode',selectedValue);
                }
            }
})