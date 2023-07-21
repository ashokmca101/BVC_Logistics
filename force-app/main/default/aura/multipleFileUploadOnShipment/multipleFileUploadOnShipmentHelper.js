({
  //method to fetch all existing Files on sObject record.
    getExistingFiles : function(component){
  //get sObject Id
        var sObjectId = component.get("v.sObjectId");

  //invoke Controller method to get All attached Files
        var action = component.get("c.getAllFilesOnsObjectRecord");
        action.setParams({sObjectId : sObjectId});
        action.setCallback(this, function(response){
           var state = response.getState();
               if(state === "SUCCESS"){
               var existingFilesArr = response.getReturnValue();
               if(existingFilesArr != null && existingFilesArr != undefined && existingFilesArr.length > 0){
                    component.set("v.sObjectAttachedFiles", existingFilesArr);
                }
            }
        });
        $A.enqueueAction(action);
    },

   //method invoked after uploading a File on sObject
    handleUploadFinished : function(component, event) {
        var uploadedFileArr = [];

  //get all attached files on sObject
        var sObjectAttachedFiles = component.get("v.sObjectAttachedFiles");
        var sObjectAttachedFilesArr = [];
        if(sObjectAttachedFiles != null && sObjectAttachedFiles != undefined && sObjectAttachedFiles.length > 0){
            [].forEach.call(sObjectAttachedFiles, function(file) {
                //get all attached files on sObject in an Array
                sObjectAttachedFilesArr.push({'Id' : file.Id,'Title': file.Title});
            });
        }

   //get uploaded Files
        var uploadedFiles = event.getParam("files");
        [].forEach.call(uploadedFiles, function(file) {
  //get all uploaded files in an array
        uploadedFileArr.push({'Id' : file.documentId,'Name': file.name});

  //get all uploaded files in an array to display on the UI
            sObjectAttachedFilesArr.push({'Id' : file.documentId,'Title': file.name});
        });

  //set all existing and uploaded Files in an attribute used to display on the UI
        component.set("v.sObjectAttachedFiles", sObjectAttachedFilesArr);

  //get all uploaded Files on different clicks/drops.
        var filesUploadedPreviously = component.get('v.uploadedFiles');
        if(filesUploadedPreviously != null && filesUploadedPreviously != undefined && filesUploadedPreviously.length > 0){
            [].forEach.call(filesUploadedPreviously, function(file) {
                uploadedFileArr.push({'Id' : file.Id,'Name': file.Name});
            });
        }

        //set all uploaded files in an array
        component.set("v.uploadedFiles",uploadedFileArr);
    },
})