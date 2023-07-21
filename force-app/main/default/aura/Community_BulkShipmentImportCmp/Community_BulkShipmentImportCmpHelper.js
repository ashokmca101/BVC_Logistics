({
    CSV2JSON: function (component,csv) {
        var arr = []; 
        arr =  csv.split('\n');
        //console.log('arr = '+arr);
        arr.pop();
        //var attachmentfile=arr;
       // console.log('attachmentfile '+attachmentfile);
        var jsonObj = [];
        var headers = arr[1].split(',');//0->1 to read header from 2nd row in csv.
        var csvdata = this.CSVtoArray(csv);
         //console.log('csv'+JSON.stringify(csvdata));
        for(var i=2;i<this.CSVtoArray(csv).length;i++){
            //console.log('csv'+JSON.stringify(csvdata[i]));
           var obj = {};
            if(csvdata[i].length === headers.length ){
                var data = csvdata[i];
                 for(var j = 0; j < data.length; j++) {//j is to read data from 1st column.
                        if(data[j].trim()) {
                            obj[headers[j].trim()] = data[j].trim();
                        }
               }
                 jsonObj.push(obj);
            }
           
             //console.log('csv'+csvdata[i].length);
        }
        var json = JSON.stringify(jsonObj);
        console.log('json = '+ json);
        return json;
        
        
    },
    
    CreateShipment : function (component,jsonstr,prdlst,shmtdate){//31st
        component.set("v.loaded",true);
        var action = component.get('c.insertData');
        action.setParams({
            strfromle : jsonstr,
            Prdlist : prdlst,
            shpmtdt : shmtdate
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result=response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS" && result==='SUCCESS') {
                component.set("v.loaded",false);
                toastEvent.setParams({
                        type: 'success',
                      	variant: 'success',
                        title: 'Success!',
                        message: 'Shipment Created successfully.',
                        mode: 'pester'
                     });
                    toastEvent.fire();
                  $A.get('e.force:refreshView').fire();
                 
            }
            else if (result!='SUCCESS' || state === "ERROR") {//
                component.set("v.loaded",false);
                var result=response.getReturnValue();
                var errors = response.getError();
                if (errors) {
                    console.log("Error message in (else if error) " +JSON.stringify(result)+' '+ JSON.stringify(errors));
                    alert('You are facing some error. '+JSON.stringify(result)+' '+ JSON.stringify(errors)+' Kindly contact BVC team');
                    
                } else {
                    component.set("v.loaded",false);
                    console.log("Unknown error");
                    alert('You are facing some error. Kindly contact BVC team');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
    },
    refreshview : function (component, event, helper){
	$A.get('e.force:refreshView').fire();
    component.set("v.showcard", false);
    component.set("v.isButtonHide", false);
    component.find("file").getElement().value='';
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    component.set('v.ShipmentDate', today);
    component.find("InputDate").set('v.value', today);
    component.set("v.productList",'');
    },
    // Return array of string values, or NULL if CSV string not well formed.
    CSVtoArray  : function csvToArray(text) {
            let p = '', row = [''], ret = [row], i = 0, r = 0, s = !0, l;
            for (l of text) {
                if ('"' === l) {
                    if (s && l === p) row[i] += l;
                    s = !s;
                } else if (',' === l && s) l = row[++i] = '';
                else if ('\n' === l && s) {
                    if ('\r' === p) row[i] = row[i].slice(0, -1);
                    row = ret[++r] = [l = '']; i = 0;
                } else row[i] += l;
                p = l;
            }
            return ret;
     },
    getProductPicklist: function(component, event) {
        var action = component.get("c.getProducts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var productMap = [];
                for(var key in result){
                    productMap.push({key: key, value: result[key]});
                }
                component.set("v.productMap", productMap);
            }
        });
        $A.enqueueAction(action);
    }
    
})