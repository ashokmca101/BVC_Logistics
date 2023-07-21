({
	init : function(component, event, helper) {
        var action = component.get("c.getRecord");
        action.setParams({ 
            rId: component.get("v.recordId"),
        });
		//component.set("v.temp",false);
    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {        
          console.log('res :',response.getReturnValue());
          console.log('res Flag :',response.getReturnValue().Flag__c);
          if(response.getReturnValue().Flag__c == 1){
             component.set("v.temp",true); 
              console.log('11');
          }
          else
          {
              component.set("v.temp",false); 
              console.log('00');
          }
        console.log('<==>Success');
      }
    });
    $A.enqueueAction(action);        
	},    
	closeModal : function(component, event, helper) {
        var action = component.get("c.updateShip");
        if(component.get("v.ds")==null){
                   console.log('<==>NULL'); 
        }
        if(component.get("v.ds")==''){
                    console.log('<==>Success');
        }        
        action.setParams({ 
            rId: component.get("v.recordId"),
            DStatus : component.get("v.ds") 
        });
		component.set("v.temp",false);
    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {        
        console.log(response.getReturnValue());
        console.log('<==>Success');
      }
    });
    $A.enqueueAction(action);        
	}
})