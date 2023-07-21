({
    init: function(component){
        if($A.get("$Browser.formFactor") == 'DESKTOP'){
            this.focusTimerStart(component);
        }
        this.retrieveLocations(component);
        this.retrieveHubs(component);
        this.retrieveTransports(component);
    },
    retrieveLocations: function(component){

        var action = component.get("c.isExecutive");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let isExecutive = response.getReturnValue();
                let locationOptions = [];

                /*
                if(isExecutive){
                    locationOptions = [
                        { label: '-- Select --', value: null },
                        { label: 'Port', value: 'Port' }, 
                        { label: 'Out for Delivery', value: 'Out for Delivery' } 
                    ];
                }else{
                    locationOptions = [
                        { label: '-- Select --', value: null },
                        { label: 'Hub', value: 'Hub' },
                        { label: 'Port', value: 'Port' }, 
                        { label: 'Out for Delivery', value: 'Out for Delivery' } 
                    ];                    
                }
                */
                locationOptions=[{label: 'Hub', value: 'Hub'}];

                component.set('v.locationOptions',locationOptions);
                component.set('v.location','Hub');

            }else{
                this.showApexError(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    retrieveHubs:function(component){

        this.showSpinner(component);

        var action = component.get("c.retrieveHubs");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let options = response.getReturnValue();
                if(options.length > 0){
                    component.set('v.hubId',options[0].Id);
                    component.set('v.hubOptions',options);
                }else{
                    component.set('v.hubId',null);
                    component.set('v.hubOptions',null);
                }
            }else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    retrieveTransports:function(component){

        var action = component.get("c.retrieveTransports");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let options = response.getReturnValue();
                if(options.length > 0){
                    component.set('v.transportId',options[0].Id);
                    component.set('v.transportOptions',options);
                }else{
                    component.set('v.transportId',null);
                    component.set('v.transportOptions',null);
                }
            }else{
                this.showApexError(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getAttributes: function(component){

        let attr = {};

        attr.action = component.get('v.action');
        
        if(component.get('v.location'))
            attr.location = component.get('v.location');
        
        if(attr.location == 'Hub' && component.get('v.hubId'))
            attr.hubId = component.get('v.hubId');
        
        if(component.get('v.seal'))
            attr.sealId = component.get('v.seal').Id;

        if(attr.location == 'Port' && component.get('v.transportId'))
            attr.transportId = component.get('v.transportId');

        return attr;
    },
    scanSuccess: function(component,event){

        let result  = event ? event.getParam("result") : null;
        let success = event ? event.getParam("success") : null;
        let barcode = ((success && result && result[0]) ? result[0].data : null);

        this.process(component,barcode);
    },
    process: function(component, barcode){

        //if the bag is already in the grid, set the 'scanned' bit
        //otherwise, make a call to the server to retrieve the bag
        if(component.get('v.action') == 'scanBag' && this.updateBag(component,barcode)){
            return;
        }

        let self = this;
        
        let attr = this.getAttributes(component);
        if(barcode != null)
            attr.barcode = barcode;

        if(attr.action == 'scanSeal')
            this.showSpinner(component);

        var action = component.get("c.process");
        action.setParams({
            "strParams": JSON.stringify(attr),
            "listIdBag_scanned": []
        });
        action.setCallback(this, function(response){

            var state = response.getState();
            if(state === "SUCCESS"){

                let params = JSON.parse(response.getReturnValue());

                if(attr.action == 'scanSeal'){
                    component.set('v.seal',params.seal);
                    component.set('v.bags',params.bags);
                    component.set('v.action','scanBag');
                    self.updateCounts(component);

                }else if(attr.action == 'scanBag'){
                    self.upsertBag(component,params.bag);
                    self.upsertBags(component,params.bags);
                    self.updateCounts(component);
                }
            }
            else{
                self.showApexError(component, response.getError());
            }
            self.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    updateBag: function(component,barcode){
        //if the bag is already in the list, set the 'scanned' bit, and return true
        //otherwise, return false
        let bags = component.get('v.bags');
        let bagFound = false;

        for(var i=0; i<bags.length; i++){
            let bag = bags[i];

            if(bags[i].Secure_Bag__r.Name == barcode){
                bags[i].scanned = true;
                bagFound = true;
                break;
            }
        }
        if(bagFound){
            component.set('v.bags',bags);
            this.updateCounts(component);
            return true;
        }else{
            return false;
        }
    },
    upsertBag: function(component,bag){
        //if the bag is already in the list, set the 'scanned' bit.
        //otherwise, add the bag to the list.
        let bags = component.get('v.bags');
        let bagFound = false;
        let bagIndex = null;

        for(var i=0; i<bags.length; i++){
            if(bags[i].Id == bag.Id){

                bags[i].scanned = true;
                bagFound = true;
                bagIndex = i;
                
                break;
            }
        }

        if(!bagFound){
            bag.scanned = true;
            if(component.get('v.seal'))
                bag.extra = true;
            
            bags.push(bag);
        }

        component.set('v.bags',bags);
    },
    upsertBags: function(component,newBags){
        //if a new bag is not already in the list of bags, add it
        let oldBags = component.get('v.bags');
        let oldBagIds = [];
        
        //collect the Ids of the bags that are currently displayed
        for(var i=0; i<oldBags.length; i++){
            oldBagIds.push(oldBags[i].Id);
        }
        
        //if a new bag is not currently displayed, add it
        for(var i=0; i<newBags.length; i++){
            let newBag = newBags[i];
            if(!oldBagIds.includes(newBag.Id))
                oldBags.push(newBag);
        }
        
        component.set('v.bags',oldBags);
    },
    updateCounts: function(component){
        let bags = component.get('v.bags');
        let bagCount_seal = 0;
        let bagCount_scanned = 0;
        let bagCount_extra = 0;
        let bagCount_unscanned = 0;

        let sealId = null;
        if(component.get('v.seal'))
            sealId = component.get('v.seal').Id;

        for(var i=0; i<bags.length; i++){

            let bag = bags[i];

            if(sealId){
                if(bag.Seal_Id__c == sealId){
                    //console.log('*** count seal bag ***');
                    bagCount_seal = bagCount_seal + 1;
                }else{
                    bagCount_extra += 1;
                }
            }
            if(bag.scanned){
                bagCount_scanned += 1;
            }
        }

        if(sealId){
            bagCount_unscanned = bagCount_seal + bagCount_extra - bagCount_scanned;
        }

        component.set('v.bagCount_seal',bagCount_seal);
        component.set('v.bagCount_scanned',bagCount_scanned);
        component.set('v.bagCount_extra',bagCount_extra);
        component.set('v.bagCount_unscanned',bagCount_unscanned);

    },
    complete: function(component, barcode){

        let self = this;
        
        let attr = this.getAttributes(component);
        attr.action = 'complete';
        
        this.showSpinner(component);

        let bags = component.get('v.bags');
        let listIdBag_scanned = [];
        for(var i=0; i<bags.length; i++){
            
            let bag = bags[i];
            
            if(bag.scanned)
                listIdBag_scanned.push(bag.Id);
        }        

        var action = component.get("c.process");
        action.setParams({
            "strParams": JSON.stringify(attr),
            "listIdBag_scanned": listIdBag_scanned
        });
        action.setCallback(this, function(response){

            var state = response.getState();
            if(state === "SUCCESS"){

                if(component.get('v.seal')){
                    component.set('v.action','scanSeal')
                }else{
                    component.set('v.action','scanBag');
                }

                component.set('v.bags',[]);
                component.set('v.seal',null);
                self.resetCounts(component);
            }
            else{
                self.showApexError(component, response.getError());
            }
            self.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    reset:function(component){
        component.set('v.bags',[]);
        component.set('v.seal',null);
        component.set('v.action','selectLocation');
        this.resetCounts(component);
    },
    resetCounts:function(component){
        component.set('v.bagCount_seal',0);
        component.set('v.bagCount_scanned',0);
        component.set('v.bagCount_extra',0);
        component.set('v.bagCount_unscanned',0);
    },
    focusTimerStart: function(component){
        function setFocus(){
            if(component.find('laserScanner') &&
               (component.get('v.action') == 'scanSeal' || component.get('v.action') == 'scanBag')){
                component.find('laserScanner').focus();
            }
        }
        
        //run once soon after being called
        setTimeout($A.getCallback(setFocus),100);
        
        //run periodically
        let focusTimer = setInterval($A.getCallback(setFocus),1000);
        component.set('v.focusTimer',focusTimer);
    },    
    showSpinner: function (component){
        let spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component){
        let spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    hideMessage: function(component){
        $A.util.removeClass(cmp.find('myToast'), "slds-show");
        $A.util.addClass(cmp.find('myToast'), "slds-hide");		
    },
    showMessage: function (cmp, message){
        if($A.get("$Browser.formFactor") == 'DESKTOP'){
            cmp.set('v.pageMessages', message);
            $A.util.removeClass(cmp.find('myToast'), "slds-hide");
            $A.util.addClass(cmp.find('myToast'), "slds-show");
    
            window.setTimeout(
                $A.getCallback(function () {
                    let toast = cmp.find('myToast');
                    $A.util.removeClass(toast, "slds-show");
                    $A.util.addClass(toast, "slds-hide");
                }), 5000
            );
        }
        else{
            let showToastEvent = $A.get("e.force:showToast");
            showToastEvent.setParams({
                type: 'error',
                message: message
            });
            showToastEvent.fire();
        }
    },
    showApexError: function(cmp, errors){
        console.log(JSON.stringify(errors));
        if (!(errors && errors.length)) return;
    
        let messages = [];
    
        for (let i=0; i < errors.length; i++) {
            if (errors[i].message) {
                messages.push(errors[i].message);
            }
    
            if (errors[i].pageErrors && errors[i].pageErrors.length) {
                for (let j = 0; j < errors[i].pageErrors.length; j++) {
                    messages.push(errors[i].pageErrors[j].message);
                }
            }
        }
    
        if (messages.length)
            this.showMessage(cmp, messages.join('\n---\n'));
    }
})