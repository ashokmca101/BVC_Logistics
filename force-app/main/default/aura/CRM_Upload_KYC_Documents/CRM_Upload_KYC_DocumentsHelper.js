({
	fetchAccountDetail : function(component,event) {
		var action = component.get("c.fetchAccountDetails");
        action.setParams({	
			accId : component.get("v.recordId")
		});
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var result = response.getReturnValue();
				component.set("v.accountDetail",result);
                
				
				this.missingDocument(component,event,result);
				console.log('Result : '+ result);
			}else{
				console.log('Failed : '+ response.getError());
			}
		});
		$A.enqueueAction(action);

		
	},


	missingDocument : function (component,event,account) {
		//var KYCDocuments = component.get("v.KYCDocuments");
		//var account = component.get("v.accountDetail");
		var docSet = new Set(component.get("v.AllDocs"));
		var addReqDocSet = new Set();
		var reqDocSet = new Set();
        		
		var checkRequiredDocu = false;
        
        console.log('account.BVC_Company_Type__c:::'+account.BVC_Company_Type__c);
        var bvcCompTypeVal = account.BVC_Company_Type__c.split(';');
        console.log('bvcCompTypeValc:::'+bvcCompTypeVal);
       
        if(bvcCompTypeVal.includes('CB Customer')){
            console.log('CB Customer');
			reqDocSet = ["PAN card","GST Registration Copy","Proof of Address","IEC Certificate","Authorised Dealer Code Bank Letter"];
			if(account.Form_Of_Organization__c == 'Individual'){
				addReqDocSet = ["Passport","PAN card","Adhar Card","Ration card","Driving license","Bank account statement"];
			}else if(account.Form_Of_Organization__c == 'Company'){
				addReqDocSet = ["Certificate of incorporation","Memorandum of Association","Articles of Association","Power of Attorney granted to its managers, officers or employees to transact business on its behalf",
				"Copy of PAN allotment letter","Telephone bill"];
			}else if(account.Form_Of_Organization__c == 'Partnership firm'){
				addReqDocSet = ["Registration certificate (if registered)","Partnership deed","Power of Attorney granted to a partner or an employee of the firm to transact business on its behalf",
				"Any officially valid document identifying the partners and the person holding the Power of Attorney and their addresses","Telephone bill in the name of firm/ partners"];
			}else if(account.Form_Of_Organization__c == 'Trusts, Foundations'){
				addReqDocSet = ["Certificate of Registration, if registered","Power of Attorney granted to transact business on its behalf",
				"Any officially valid document to identify the trustees, settlers, beneficiaries and those holding the Power of Attorney, founders/ managers/ directors and their addresses",
				"Resolution of the managing body of the foundation/ association","Telephone bill"];
			}
            else
            {
               addReqDocSet = []; 
            }
            
		}else if(bvcCompTypeVal.includes('International')){
            console.log('International');
			reqDocSet = ["PAN card","GST Registration Copy","Proof of Address","IEC Certificate"];
            addReqDocSet = [];
		}else if(bvcCompTypeVal.includes('Domestic')){
            console.log('Domestic');
			reqDocSet = ["PAN card","GST Registration Copy"];
            addReqDocSet = [];
        }
		
        console.log('reqDocSet : :: '+JSON.stringify(reqDocSet) );
		var toremovestr = account.Documents_Uploaded__c;
        console.log('toremovestr :::'+toremovestr);
		if(toremovestr != null && toremovestr != '' && toremovestr != undefined){
				
			var toremove = toremovestr.split(";");
           
			var newSet;
			var newSetAdd;
			for(var i=0; i < toremove.length; i++){
                console.log('toremove length : :: '+toremove.length );
				newSet = reqDocSet.filter(s => s !== toremove[i]);
                //var addReqDocSetNew= JSON.stringify(addReqDocSet);
                /*if(addReqDocSetNew != undefined || addReqDocSetNew != null || addReqDocSetNew != '')
                {*/
                    console.log('Inside Additional Required Documents.');
                   newSetAdd = addReqDocSet.filter(s => s !== toremove[i]); 
                    console.log('Inside Additional Required Documents After.');
               /* }
				else
                {
                    console.log('inside else');
                }*/
                console.log('newSet : :: '+newSet );
                console.log('reqDocSet : :: '+reqDocSet );
                console.log('JSON.stringify(reqDocSet) : :: '+JSON.stringify(reqDocSet) );
				/*if(JSON.stringify(reqDocSet) == JSON.stringify(newSet))
                {
                    console.log('true');
                    checkRequiredDocu = true;
                }
                else
                {
                    console.log('false');
                    checkRequiredDocu = false;
                }*/
                reqDocSet = newSet;
				addReqDocSet = newSetAdd;
			}
			if(account.Form_Of_Organization__c == 'Individual' && bvcCompTypeVal.includes('CB Customer')){
				if(addReqDocSet.length<=4){
					addReqDocSet = [];
                    //console.log('toremovestr DocSet: 3 ' );	
				}
			}
			//console.log('toremovestr DocSet: 4 ' );	
		}
        var isRequiredDoc = component.get("v.isRequiredDoc");
        if(isRequiredDoc == true)
        {
            console.log('execute only required docs' );
            component.set("v.RequiredDocs", reqDocSet);
        }
        else
        {
            console.log('execute only Additional docs' );
            component.set("v.AddRequiredDocs", addReqDocSet);
        }
       
		console.log('Required DocSet: '+reqDocSet);
        console.log('AddRequiredDocs DocSet: '+addReqDocSet );
        
        //component.set("v.resetLayoutUI",false);
        component.set("v.RequiredDocs", reqDocSet);
        component.set("v.AddRequiredDocs", addReqDocSet);
		
        // component.set("v.resetLayoutUI",true);
		//component.set("v.AddRequiredDocs", addReqDocSet);
		console.log('End : ');
        
		 
	},

	
	doDocumentSave : function(component,event,Doclabel,documentId) {
		
		var action = component.get("c.saveAccountDocumentDetails");
		var acc = component.get("v.accountDetail");
		action.setParams({	
			acct : acc,
            doctitle : Doclabel,
            docid : documentId
		});
		action.setCallback(this,function(response){
			var state = response.getState();
            console.log('State in doDocumentSave:::'+state);
			if(state == 'SUCCESS'){
				var result = response.getReturnValue();
				console.log('SaveResult: '+ result);
				this.fetchAccountDetail(component,event);
				this.showToast(component,event, 'success', 'Success', 'Information updated Successfully.');
								
			}else{
				this.showToast(component,event, 'error', 'Error', 'Information could not be updated.');
			}
			
		});
		$A.enqueueAction(action);
				
	},
    
     saveIECToRecord : function(component,event) {
		var action = component.get("c.saveIECToApexClass");
        action.setParams({ 
            inputIEC : component.get("v.IECManualInpt"),
            accId : component.get("v.recordId")
        });
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'IEC is saved successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
			}else{
				console.log('Failed : '+ response.getError());
			}
		});
		$A.enqueueAction(action);
	},
    
    saveADCodeToRecord : function(component,event) {
		var action = component.get("c.saveADCodeToApexClass");
        action.setParams({ 
            inputADCode :  component.get("v.ADCodeManualInpt"),
            accId : component.get("v.recordId")
        });
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'AD Code is saved successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
			}else{
				console.log('Failed : '+ response.getError());
			}
		});
		$A.enqueueAction(action);
	},


})