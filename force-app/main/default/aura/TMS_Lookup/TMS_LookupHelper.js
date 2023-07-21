({
	itemSelected : function(component, event, helper) {
        var target = event.target;
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");  
        if(SelIndex){
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem.val){
               component.set("v.selItem",selItem);
               component.set("v.last_ServerResult",serverResult);
            }
            component.set("v.server_result",null); 
        }
	}, 
    serverCall : function(component, event, helper) {
        console.log('serverCall 11');
        var target = event.target;  
        var searchText = target.value; 
        //Escape button pressed 
        if (event.keyCode == 27 || !searchText.trim() ) {
            helper.clearSelection(component, event, helper);
        }else if(searchText.length >= 2 ){
            //Save server call, if last text not changed
            //Search only when characters entered are more than 2
            this.onFocusServerCall(component, event, helper);
        }
	},
    onFocusServerCall : function(component, event, helper) {
        var target = event.target;  
        var searchText = target.value;
        var objectName = component.get("v.objectName");
        var field_API_text = component.get("v.field_API_text");
        var field_API_val = component.get("v.field_API_val");
        var field_API_search = component.get("v.field_API_search");
        var recType = component.get("v.RecordType");
        var limit = component.get("v.limit");
        var origin = component.get("v.OriginAirport");
        var dest = component.get("v.DestAirport");
        var secRecType = component.get("v.SecurePackType");
        var originval='';
        console.log("11.origin: ",origin)
        if(origin !==null){
            originval = origin.val;
        }
        var destval='';
        console.log("22.dest: ",dest)
        if(dest !==null){
            destval= dest.val
        }
        //console.log('on focus'+lt +' lon= '+ln+' objectName '+objectName+field_API_text+field_API_val+' accId '+accId);
        var action = component.get('c.searchDB');
        
        action.setParams({
            objectName : objectName,
            fld_API_Text : field_API_text,
            fld_API_Val : field_API_val,
            lim : limit,
            fld_API_Search : field_API_search,
            searchText : searchText,
            RecordType : recType,
            originPort : originval,
            DestPort : destval,
            SecPackType: secRecType
        });
        
        action.setCallback(this,function(a){
            this.handleResponse(a,component,helper);
        });
        $A.enqueueAction(action); 
    },
    handleResponse : function (res,component,helper){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
                component.set("v.server_result",noResult); 
            	component.set("v.last_ServerResult",noResult);
            }else{
                component.set("v.server_result",retObj); 
            	component.set("v.last_ServerResult",retObj);
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            } 
        }
    },
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
			SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    clearSelection: function(component, event, helper){
        component.set("v.selItem",null);
        component.set("v.server_result",null);
    } 
})