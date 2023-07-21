({
    disableExcelInput: function(cmp) {
        cmp.set("v.disabled", true);
        cmp.set("v.isLoading", true);
    },
    
    enableExcelInput: function(cmp) {
        cmp.set("v.disabled", false);
        cmp.set("v.isLoading", false);
    },
    
    importTableAndThrowEvent: function(cmp, evt, helper) {
        evt.stopPropagation();
        evt.preventDefault();
        try {
            
            const file = helper.validateFile(cmp, evt);
            cmp.set("v.file",file);
            helper.readExcelFile(cmp, file, helper)
            .then($A.getCallback(excelFile => {helper.throwSuccessEvent(cmp, excelFile);}))
                .catch($A.getCallback(exceptionMessage => {helper.throwExceptionEvent(cmp, exceptionMessage);}))
                .finally($A.getCallback(() => {helper.enableExcelInput(cmp);}))
            }catch (exceptionMessage) {
                helper.throwExceptionEvent(cmp, exceptionMessage);
                helper.enableExcelInput(cmp);
            }
    },
                
    validateFile: function(cmp, evt) {
         const files = evt.getSource().get("v.files");
         if (!files || files.length === 0 || $A.util.isUndefinedOrNull(files[0])) {
             throw cmp.get("v.messageNoFileSpecified");
         }
                    
         const file = files[0];
         const fileSizeThreshold = cmp.get("v.fileSizeThreshold");
         if (file.size > fileSizeThreshold) {
              throw (cmp.get("v.messageFileSizeExceeded") + ': ' + fileSizeThreshold + 'b');
          }
          return file;
    },
                
    readExcelFile: function(cmp, file, helper) {
        return new Promise(function (resolve, reject) {
        const fileReader = new FileReader();
        fileReader.onload = event => {
            let filename = file.name;
            let binary = "";
            new Uint8Array(event.target.result).forEach(function (byte) {binary += String.fromCharCode(byte);});
            try {
                resolve({"fileName": filename,"xlsx": XLSX.read(binary, {type: 'binary', header: 1})});
                console.log('XLSX.read::'+XLSX.read(binary, {type: 'binary', header: 1}));
                console.log('END1::');
                var workbook = XLSX.read(binary, { type: 'binary' }); 
                var sheet_name_list = workbook.SheetNames;
                console.log(XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]));
                var XL_row_object = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]);
                console.log('XL_row_object::'+XL_row_object); 
                var json_object = JSON.stringify(XL_row_object);
                cmp.set("v.content", json_object);
                console.log('After content set::'+cmp.get("v.content"));
                helper.parseFile1(cmp);  
                console.log('END2::');
               } catch (error) {reject(error);}
          };
          console.log('After content set::'+cmp.get("v.content"));
          fileReader.readAsArrayBuffer(file);
        });
     },
                                 
     throwExceptionEvent: function(component, message) {
     	const errorEvent = component.getEvent("onImport");
        errorEvent.setParams({"type": "ERROR","message": message});
        errorEvent.fire();
      },
            
      throwSuccessEvent: function(component, parsedFile) {
         const successEvent = component.getEvent("onImport");
         successEvent.setParams({"type": "SUCCESS", "fileName": parsedFile.fileName,"table": parsedFile.xlsx});
         successEvent.fire();
       },
                
       parseFile1: function (cmp,evt) {
           console.log('json_object::');
           console.log('KInside::'+cmp.get("v.content"));
           var file = cmp.get("v.file");
           var action = cmp.get("c.parseFile");
           action.setParams({
               base64Data: cmp.get("v.content"),
               fileName: file.name,
           });
           cmp.set("v.hideSpinner",true);
           action.setCallback(this, function (response) {
           if (response.getState() == "SUCCESS") { 
               
                var toastEvent = $A.get("e.force:showToast");
        		toastEvent.setParams({
            		title : 'Success',
            		message: 'Shipments Created Successfully',
            		type: 'success'	
        		});
        		
        		var comments = response.getReturnValue();
                var Tsec= parseInt(comments)*1000;
                window.setTimeout($A.getCallback(function() {cmp.set("v.hideSpinner",false);}), Tsec);
               //toastEvent.fire();
           }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                
                if (errors) {                    
                    if (errors[0] && errors[0].message) {
                        cmp.set("v.hideSpinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            Title:'title',
                            type:'error',
                            message:'Some Thing Wrong In Excel Data'
                        });
                       
                        $A.get("e.force:closeQuickAction").fire();
                        toastEvent.fire();
                        //$A.get('e.force:refreshView').fire();
                        cmp.set("v.showError",true);
                		cmp.set("v.errorMessage",errors[0].message);
                    }
                } else {
                    cmp.set("v.hideSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        Title:'title',
                        type:'error',
                        message:'Unknown Error'
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                
            }
      });
        $A.enqueueAction(action);
   }
})