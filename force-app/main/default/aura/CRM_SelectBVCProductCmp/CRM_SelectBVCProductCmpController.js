({
	doInit : function(component, event, helper) {
		var action = component.get("c.retrieveBVCProduct");
        var currentrecord = component.get("v.recordId");
        console.log('record id '+currentrecord);
        action.setParams({	
			recid : currentrecord
		});
		action.setCallback(this,function(response){
			var state = response.getState();
            var result = response.getReturnValue();
			//console.log('State in doDocumentSave:::'+state);
			if(state === 'SUCCESS'){
                console.log('Result in doDocumentSave:::'+result);
                component.set("v.relatedproduct",result);
            }else{
                console.log('Error '+result);
			}
			
		});
		$A.enqueueAction(action);
				
	},
	getSelectedProduct : function(component, event,helper) { 
        var selectedId='';
        //when using <ui:inputCheckbox> instead html checkbox
        //selectedId=event.getSource().get("v.text");                
        selectedId = event.target.getAttribute('id');
        if(document.getElementById(selectedId).checked && component.get("v.SelectedProduct").indexOf(selectedId) < 0)
            component.get('v.SelectedProduct').push(selectedId);
        else{
            var index = component.get("v.SelectedProduct").indexOf(selectedId);
            if (index > -1) {
                component.get("v.SelectedProduct").splice(index, 1); 
            }
        }
        console.log("Selected Product --> "+component.get("v.SelectedProduct"));
    },
    saveProduct : function(component, event, helper) {
        console.log('Hi');
        var selectedProd = component.get("v.SelectedProduct");
        var currentrecord = component.get("v.recordId");
        console.log('Outside Before SelectedProduct Condition '+selectedProd+' === '+currentrecord);
        if(selectedProd.length>0){
            console.log('Under SelectedProduct');
            helper.saveProd(component,selectedProd,currentrecord);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Product Missing',
                    message: 'Kindly select a product.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
        }
    },
    Cancel : function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
    }
})