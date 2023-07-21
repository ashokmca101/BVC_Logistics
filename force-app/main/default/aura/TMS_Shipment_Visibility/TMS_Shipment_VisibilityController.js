({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            { label: 'Shipment Name',       fieldName: 'Name', type: 'text' },
            { label: 'Shipping Note Number',     fieldName: 'Shipping_Note_Number__c', type: 'text' },
            { label: 'Shipper Account',        fieldName: 'Shipper_Name_TMS_Name',  type: 'text' },
            { label: 'Origin Address Name',       fieldName: 'Origin_Address_Name_Name', type: 'text' },
            { label: 'Shipment Date',   fieldName: 'Shipment_Date__c', type: 'text' },
            { label: 'Created By', fieldName: 'CreatedByName', type: 'text' },
            { label: 'Generation Status',   fieldName: 'PDF_Generation__c', type: 'text' }
        ]);
        cmp.set('v.addProductsCols', [
            { label: 'Shipper Name', fieldName: 'Name', type: 'text' },
            { label: 'Shipping Note Number',     fieldName: 'Shipping_Note_Number__c', type: 'text' },
            { label: 'Shipper Account',        fieldName: 'Shipper_Name_TMS_Name',  type: 'text' },
            { label: 'Origin Address Name', fieldName: 'Origin_Address_Name_Name', 			type: 'text' },
            { label: 'Shipment Date', 		fieldName: 'Shipment_Date__c', 			type: 'text' },
            { label: 'Created By', 	fieldName: 'CreatedByName',		type: 'text' },
            { label: 'Generation Status',   fieldName: 'PDF_Generation_Status__c',  type: 'Formula' }
        ]);
        var OriginHub= cmp.get("v.OriginHub");
        var Origin = '';
        if(OriginHub !== null)
            Origin = OriginHub.val;
        var DestHub = cmp.get("v.DestHub");
        var Dest = '';
        if(DestHub !== null)
            Dest = DestHub.val;
        var ShippAcc = cmp.get("v.ShipAcc");
        var Shipp='';
        if(ShippAcc !== null)
            Shipp = ShippAcc.val;
        
        var action = cmp.get("c.getShipmentData");
        action.setParams({
            "ShippAcc": Shipp,
            "OriginHubId": Origin,
            "DestHubId": Dest,
            "ShipmentDate": cmp.get("v.ShipDate")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataRecord =  response.getReturnValue() ;
                for (var i = 0; i < dataRecord.length; i++) {  
                    if (dataRecord[i].Shipper_Name_TMS__r) {
                        dataRecord[i].Shipper_Name_TMS_Name = dataRecord[i].Shipper_Name_TMS__r.Name;
                        
                    } 
                    if(dataRecord[i].Origin_Address_Name__r) {
                        dataRecord[i].Origin_Address_Name_Name = dataRecord[i].Origin_Address_Name__r.Name;
                    }  
                    if(dataRecord[i].CreatedBy) {
                        dataRecord[i].CreatedByName = dataRecord[i].CreatedBy.Name;
                    } 
                    
                }
                cmp.set("v.filteredData", dataRecord);
                
                console.log('response=='+dataRecord);
            }
        });
        $A.enqueueAction(action);
    },
    searchTable : function(cmp,event,helper) {
        var allRecords = cmp.get("v.data");
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        
        var tempArray = [];
        var i;
        
        for(i=0; i < allRecords.length; i++){
            if((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1) ||
               (allRecords[i].Bill_To_GSTIN__c && allRecords[i].Bill_To_GSTIN__c.toUpperCase().indexOf(searchFilter) != -1 ) || 
               (allRecords[i].Bill_To_Party__c && allRecords[i].Bill_To_Party__c.toUpperCase().indexOf(searchFilter) != -1 ) || 
               (allRecords[i].Bill_To_Party_PAN__c && allRecords[i].Bill_To_Party_PAN__c.toUpperCase().indexOf(searchFilter) != -1 ) )
            {
                tempArray.push(allRecords[i]);
            }
        }
        
        for (var i = 0; i < tempArray.length; i++) {  
            if (tempArray[i].Shipper_Name_TMS__r) {
                tempArray[i].Shipper_Name_TMS_Name = tempArray[i].Shipper_Name_TMS__r.Name;
                
            } 
            if(tempArray[i].Origin_Address_Name__r) {
                tempArray[i].Origin_Address_Name_Name = tempArray[i].Origin_Address_Name__r.Name;
            }  
            if(tempArray[i].CreatedBy) {
                tempArray[i].CreatedByName = tempArray[i].CreatedBy.Name;
            } 
            
        }
        cmp.set("v.filteredData",tempArray);       
    },
    handleSelect : function(component, event, helper) {
        
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) 
        {
            setRows.push(selectedRows[i].Id);
        }
        component.set("v.selectedShipments", setRows);
    },
    
    showSelectedName : function(component, event, helper) {
        var sendShipping = component.get("v.sendShippingData");
        sendShipping(JSON.stringify(component.get("v.selectedShipments")), function(){
        }); 
    }  
})