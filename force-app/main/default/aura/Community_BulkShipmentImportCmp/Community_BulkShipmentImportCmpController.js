({    
   doInit: function(component, event, helper) {
       var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
       component.set('v.ShipmentDate', today);
       component.find("InputDate").set('v.value', today);
       helper.getProductPicklist(component, event);
    },
    dateChange: function(component, event, helper) {
        //get the value of select option
        var selectedDate = component.find("InputDate");
        component.set("v.ShipmentDate", selectedDate.get("v.value"));
    },
    handleProductOnChange : function(component, event, helper) {
        var productList = component.get("v.productList");
    },
    CreateRecord: function (component, event, helper) {
        var prdlst=component.get("v.productList");
        var shmtdate=component.get("v.ShipmentDate");
       	
       if((prdlst==null || prdlst=='' || typeof prdlst=='undefined') || (shmtdate==null || shmtdate=='' || typeof shmtdate=='undefined' )){
               //alert('Please insert Product');
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    title: "Required Field Missing",
                    message: "Kindly Select Product and Date",
                    type: "error",
                    duration : 10000
                });
                toastEvent.fire();
                return;
           }
        //component.set("v.isButtonHide", true);
        component.set("v.isButtonHide", true);
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        //alert(file);
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                //console.log("EVT FN");
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                helper.CreateShipment(component,result,prdlst,shmtdate);
                helper.refreshview(component, event, helper);
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }
    },
    
    showfiledata :  function (component, event, helper){   
        var csvDataPreview = [];
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        console.log("File");
        if (file) {
            component.set("v.showcard", true);
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var table = document.createElement("table");
                var arr = [];
                arr =  csv.split('\n');
                arr.pop();
                var headers = arr[1].split(',');
                var rows = helper.CSVtoArray(csv);
                //var headers=rows[1].split("\r");
                console.log(JSON.stringify(rows));
               // var headers = headers[0].split(',');
               
                console.log(JSON.stringify(headers));
               for (var i = 2; i < rows.length; i++) {//0--1(Start from 1 to fetch data from row 2)
                    console.log('inside loop'+rows[i]);
                    var cells = rows[i];
                    console.log('cells',cells);
                    var csvDataPreviewRow = [];
                    if (cells.length == headers.length) {
                        var row = table.insertRow(-1);
                        for (var j = 0; j < cells.length; j++) {
                             console.log('inside inner for',row);
                            var cell = row.insertCell(-1);
                            cell.innerHTML = cells[j];
                         
                            csvDataPreviewRow.push({"colname":headers[j],
                                                    "val":cells[j]});
                        }  
                        //csvDataPreviewRow.push({"colname":'Product',"val":''});
                        csvDataPreview.push(csvDataPreviewRow);
                         console.log('csvDataPreview',csvDataPreview);
                    }
                    console.log('csvDataPreviewRow'+csvDataPreview);
                }
                var gridData = new Object();
                gridData["rows"]=csvDataPreview;
                gridData["headers"]=headers;
                console.log('JSON'+JSON.stringify(gridData));
                component.set("v.gridData",gridData);
                //component.set("v.headers");
             }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }
    }    

})