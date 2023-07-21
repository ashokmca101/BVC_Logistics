({
	saveProd : function(component,selectedProd,currentrecord) {
	var action=component.get("c.saveProductToDeal");
        action.setParams({
            secondlevelproduct:selectedProd,
            recId:currentrecord
        });
        action.setCallback(this,function(e){
            if(e.getState()=='SUCCESS'){
                var result=e.getReturnValue();
                console.log('Product Saved');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Product is saved successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                this.close(component);
            } 
        });
        $A.enqueueAction(action);	
	},
    close :function(component) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})