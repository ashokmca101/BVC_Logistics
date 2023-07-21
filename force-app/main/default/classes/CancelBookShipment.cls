@RestResource(urlMapping = '/CancelShipment/*')
global class CancelBookShipment {

    global class CancelShipmentinfo{
        String Shipping_Note_Number{get;set;}
        String Status{get;set;}
        String ErrorDetails{get;set;}
        String Message{get;set;}

    }

    @HttpPatch
    global static void InsertCancelshipment(String Shipping_Note_Number , String Reason){

        RestResponse standardResponse = RestContext.response;
        
        List<CancelShipmentinfo> wraperlist = new List<CancelShipmentinfo>(); 

        if(Shipping_Note_Number != null && Shipping_Note_Number != '' && Reason != null && Reason != '' ){
        
        try{
            List<Shipment__c> listOfshipment = new List<Shipment__c>();
           
            // Query Shipment Records using Shipping_Note_Number__c Id  
            listOfshipment = [Select id , Status__c ,Cancelled_Reason__c,Shipping_Note_Number__c  from Shipment__c where Shipping_Note_Number__c =: Shipping_Note_Number ];
            
            //Updating Record 
            if(listOfshipment.size()>0){
                for(Shipment__c obj : listOfshipment){  
                    obj.Cancelled_Reason__c = Reason ; 
                }
                    update listOfshipment;    
            }


            if(listOfshipment.size()>0){
                for(Shipment__c obj : listOfshipment){  
                    CancelShipmentinfo objwrap = new CancelShipmentinfo();
                        
                    if(obj.Status__c != null  &&  obj.Status__c != '')
                    objwrap.Status = obj.Status__c;

                    if(obj.Shipping_Note_Number__c != null  &&  obj.Shipping_Note_Number__c != '')
                    objwrap.Shipping_Note_Number = obj.Shipping_Note_Number__c;
            
                    objwrap.Message = 'Success';
                    wraperlist.add(objwrap);

                    standardResponse.addHeader('Content-Type', 'application/json');         
                    standardResponse.statusCode = 200;
                    standardResponse.responseBody = blob.valueOf(JSON.serializePretty(wraperlist));
                }
                
            }
            
         }   
            catch(dmlexception e){
                    // If DML failed, ends up here.
                    standardResponse.addHeader('Content-Type', 'application/json');         
                    standardResponse.statusCode = 404;
                    standardResponse.responseBody = blob.valueOf('"Error" : '+(e.getMessage()));
                  }
           
            
            }else{
                    // Response for Error
                    standardResponse.addHeader('Content-Type', 'application/json');         
                    standardResponse.statusCode = 404;
                    standardResponse.responseBody = blob.valueOf('"Error": "Please Send Shipping_Note_Number and Reason"');
            }
             
        }
        
}