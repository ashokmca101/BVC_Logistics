({
	onCheck: function(component, event, helper) {
        var selectedAddress = [];
        var checkvalue = component.find("checkAddress");
        
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedAddress.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedAddress.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedAddress-' + selectedAddress);
        console.log('selectedAddress .length() -' + selectedAddress.length);
        component.set("v.addressId", selectedAddress);
        var addressId = component.get("v.addressId"); 
        console.log("addressId oncheck::"+addressId);
    }
})