({
  doInit: function (component, event, helper) {
    helper.fetchAccountDetail(component, event);
    //helper.populateRequiredFields(component,event);

    //helper.fetchDocumentTypePicklist(component,event);
    //this.missingDocument(component,event);
  },

  doSave: function (component, event, helper) {
    helper.doSave(component, event);
  },

  dataChange: function (component, event, helper) {
    component.set("v.showSaveButton", true);
  },

  handleUploadFinished: function (component, event, helper) {
    // Get the list of uploaded files
    var uploadedFiles = event.getParam("files");
    console.log('uploadedFiles'+uploadedFiles);
    var Doclabel = event.getSource().get("v.label");
    Doclabel = Doclabel.replace("Attach ", "");
      
      var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        
        var fileName = uploadedFiles[0].name;
        console.log('fileName:::'+fileName);
      
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
      console.log('Account:::'+account);
    if (
      account.Documents_Uploaded__c != null &&
      account.Documents_Uploaded__c != ""
    ) {
      account.Documents_Uploaded__c += ";" + Doclabel;
    } else {
      account.Documents_Uploaded__c = Doclabel;
    }
    
    component.set("v.accountDetail",account);

    //helper.doDocumentSave(component, event);
	helper.doDocumentSave(component, event,Doclabel,documentId);    
  },
    openInterKYCModal: function (component, event, helper) {
        component.set("v.interKYCModal",true);
    },
    submitIEC: function (component, event, helper) {
        console.log('IECManualInpt::'+component.get("v.IECManualInpt"));
        helper.saveIECToRecord(component,event);
        component.set("v.interKYCModal",false);
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
    },
    closeCBCustomerKYCModal: function (component, event, helper) {
        component.set("v.cbCustomerKYCModal",false);
    },
});