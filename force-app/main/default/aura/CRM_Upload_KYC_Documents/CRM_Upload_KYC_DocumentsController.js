({
    doInit: function (component, event, helper) {
        helper.fetchAccountDetail(component, event);
        
    },
    
    
    handleUploadFinished: function (component, event, helper) {
        var Doclabel = event.getSource().get("v.label");
        Doclabel = Doclabel.replace("Attach ", "");
        console.log('Doclabel:::'+Doclabel);
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        
        var fileName = uploadedFiles[0].name;
        console.log('fileName:::'+fileName);
        
        
        //var formData = new FormData();
        //formData.append('files', fileName, Doclabel);
        
        //fileName = newFileName;
        //console.log('fileName.name:::'+fileName.name);
        
        //var Doclabel = event.getSource().get("v.label");
        //Doclabel = Doclabel.replace("Attach ", "");
        // console.log('Doclabel:::'+Doclabel);
        
        
        var reqDoc = ["PAN card","GST Registration Copy","Proof of Address","IEC Certificate","Authorised Dealer Code Bank Letter"];
        if(reqDoc.includes(Doclabel))
        {
            component.set("v.isRequiredDoc",true);
        }
        else
        {
            component.set("v.isRequiredDoc",false);
        }
        
        var account = component.get("v.accountDetail");
        
        if (
            account.Documents_Uploaded__c != null &&
            account.Documents_Uploaded__c != ""
        ) {
            account.Documents_Uploaded__c += ";" + Doclabel;
        } else {
            account.Documents_Uploaded__c = Doclabel;
        }
        
        component.set("v.accountDetail",account);
        
        helper.doDocumentSave(component, event,Doclabel,documentId);
        
    },
    
    openInterKYCModal: function (component, event, helper) {
        component.set("v.interKYCModal",true);
    },
    submitIEC: function (component, event, helper) {
        console.log('IECManualInpt::'+component.get("v.IECManualInpt"));
        helper.saveIECToRecord(component,event);
        component.set("v.interKYCModal",false);
        helper.fetchAccountDetail(component, event);
    },
    closeInterKYCModal: function (component, event, helper) {
        component.set("v.interKYCModal",false);
    },
    openCBCustomerKYCModal: function (component, event, helper) {
        component.set("v.cbCustomerKYCModal",true);
    },
    submitADCode: function (component, event, helper) {
        console.log('ADCodeManualInpt::'+component.get("v.ADCodeManualInpt"));
        helper.saveADCodeToRecord(component,event);
        component.set("v.cbCustomerKYCModal",false);
        helper.fetchAccountDetail(component, event);
    },
    closeCBCustomerKYCModal: function (component, event, helper) {
        component.set("v.cbCustomerKYCModal",false);
    },
})