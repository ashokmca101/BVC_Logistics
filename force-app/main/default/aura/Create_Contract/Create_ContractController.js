({
	doInit : function(component, event, helper) {
	var recordId = component.get('v.recordId');
        //alert(recordId);
        var createContract = component.get('c.createCreateContract');
       createContract.setParams({
            ContractId : recordId
        });
        createContract.setCallback(this, function( response ){
            var state = response.getState();
            if(state == 'SUCCESS') {
                //alert ( response.getReturnValue ()+': Pricebook and Entries are created');
                //alert (' Pricebook and Entries are created');
                //component.set('v.sObjList', a.getReturnValue());
                //window.open('/servlet/servlet.FileDownload?file=00P0w000006G8wJEAS&operationContext=S1');
                //alert ('Annexure Created');
                 //$A.get('e.force:refreshView').fire();
                 
                var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                      
                    });
                    navEvt.fire();
                
            } else {
                alert ( response.getReturnValue () );
            }
        });
        $A.enqueueAction(createContract);
        
    }
})