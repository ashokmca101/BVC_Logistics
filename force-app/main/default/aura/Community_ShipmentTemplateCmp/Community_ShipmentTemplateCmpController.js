({
	openSingleFile: function(cmp, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": 'https://'+location.host+'/sfc/servlet.shepherd/document/download/0695g000000FYsaAAG'
            
            });
            urlEvent.fire();
        }	
})