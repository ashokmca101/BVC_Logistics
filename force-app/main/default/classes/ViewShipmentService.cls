@RestResource(urlMapping ='/ViewShipment/*')

global class ViewShipmentService { 

    // Response Wrapper 
    global class ViewShipmentinfo{
        String Billing_Account{get;set;}
        Date ShipmentDate{get;set;}
        String Pickup_RegistrationNo{get;set;} 
        String Shipper_Name{get;set;}
        //String Shipper_PAN{get;set;} Removed
        String Consignee_Name{get;set;}
        String Consignee_PAN{get;set;}
        String Product_Description{get;set;}
        Decimal Net_Weight{get;set;}
        String Net_WeightUOM{get;set;}
        Decimal Gross_Weight{get;set;}
        String Gross_WeightUOM{get;set;}
        Decimal Number_of_Packages{get;set;}
        String BVC_Insurance{get;set;}
        //String EInvoice_Number{get;set;}	Removed
        //String Status{get;set;} Removed
        String ErrorDetails{get;set;}
        String Message{get;set;}
        
        string Shipping_Note_Number{get;set;}
        string Reference_Number{get;set;}
        string Billing_Address{get;set;}
        string Shipper_Account{get;set;}
        string Origin_Address_Number{get;set;}
        string Origin_Address_Line1{get;set;}
        string Origin_Address_Line2{get;set;}
        string Origin_Address_Pincode{get;set;}
        string Origin_Address_City{get;set;}
        string Origin_Address_State{get;set;}
        string Origin_Address_Country{get;set;}
        string Consignee_Account{get;set;}
        string Destination_Address_Number{get;set;}
        string Destination_Address_Line1{get;set;}
        string Destination_Address_Line2{get;set;}
        string Destination_Address_Pincode{get;set;}
        string Destination_Address_City{get;set;}
        string Destination_Address_State{get;set;}
        string Destination_Address_Country{get;set;}
        string BVC_Service{get;set;}
        string Cargo_Type{get;set;}
        Double Shipment_Value{get;set;}
        string Currency_c{get;set;}
        string Insurance_By{get;set;}
        string Pickup_DateTime{get;set;}
        string Tracking_Status{get;set;}
        Boolean Exhibition{get;set;}
        string Exhibition_Name{get;set;}
        string Exhibition_Movement_Type{get;set;}
        String Your_Address_Identifier {get;set;}
        

    }
   //https://bvc2--bvcuat.my.salesforce.com/services/apexrest/ViewShipment?Shipping_Number=EB103006&Reference_Number=0011m00000SoVi7AAF
    @HttpGet
    global static void GetviewShipment(){

        RestRequest request = RestContext.Request; 
        
        RestResponse standardResponse = RestContext.response;
                
        String SNNO  = request.params.get('Shipping_Number');
        String ReferenceNumber  = request.params.get('Reference_Number');
        System.debug('test--'+SNNO);
        System.debug('test2--'+ReferenceNumber);
        
      
            List<ViewShipmentinfo> wraperlist = new List<ViewShipmentinfo>();
        
            if(SNNO != null && SNNO != '' && ReferenceNumber != null && ReferenceNumber != '' ){ 
                List<Shipment__c> listOfshipment = new List<Shipment__c>();
                
                System.debug('---SNNO--'+SNNO);
                System.debug('---ReferenceNumber--'+ReferenceNumber);
                
               
                // Query Shipment Records using Account Id  
                listOfshipment = [Select id ,Billing_Account__c,Billing_Account__r.Name,Shipping_Note_Number__c,Origin_Address_Country__c,Origin_Address_City__c,Origin_Address_State__c,Billing_Address__c,Origin_Address_Line_2__c,Origin_Address_Line_1__c,Origin_Address_Phone__c,Billing_Address__r.Name, Shipment_Date__c ,Pickup__c,Pickup__r.Name,Shipper_Name_TMS__r.Name ,Shipper_PAN__c, Consignee_Name__c ,
                                  Consignee_PAN__c,Consignee_PAN_TMS__c,Origin_Address_Name__r.Your_Address_Identifier__c,Product_Description__c , Destination_Address_Phone__c,Destination_Address_Pincode__c,Destination_Address_State__c,Destination_Address_Line1__c,Destination_Address_Line_2__c,Destination_Address_Country__c,Net_Weight__c ,Net_Weight_UOM__c ,Consignee_Name_TMS__c,
                                  Gross_Weight__c ,Gross_Weight_UOM__c ,Number_of_Packages__c ,Insurance_By_BVC__c,Destination_Address_City__c,Insurance_By__c,Pickup_Time_Date__c,Tracking_Status__c,IsExhibition__c,Exhibition_Name__c,Exhibition_Movement_Type__c,Net_Weight_UOM_TMS__c,Gross_Weight_UOM_TMS__c,Consignee_Name_TMS__r.Name,Shipper_Name_TMS__c,Customer_Product_Category__c,Origin_Address_Pincode__c,
                                  E_Invoice_Number__c ,Status__c,Cargo_Type__c,Shipment_Value__c,CurrencyIsoCode  from Shipment__c where Shipping_Note_Number__c =: SNNO AND Customer__c =:ReferenceNumber];
                
                //Creating Response for Success 
                if(listOfshipment.size()>0){
                    for(Shipment__c obj : listOfshipment){
                            ViewShipmentinfo objwrap = new ViewShipmentinfo();
                        
                        if(obj.Billing_Account__c != null ){
                            objwrap.Billing_Account = obj.Billing_Account__r.Name;
                        }
                        if(obj.Shipment_Date__c != null ){
                            objwrap.ShipmentDate = obj.Shipment_Date__c;
                        }
                        if(obj.Pickup__c != null ){
                            objwrap.Pickup_RegistrationNo = obj.Pickup__r.Name;
                        }
                        if(obj.Shipper_Name_TMS__c != null ){
                            objwrap.Shipper_Name = obj.Shipper_Name_TMS__r.Name;
                        }
                            //if(obj.Shipper_PAN__c != null  &&  obj.Shipper_PAN__c != '')
                            //objwrap.Shipper_PAN = obj.Shipper_PAN__c;
                            
                            if(obj.Consignee_Name_TMS__r.Name != null){
                            objwrap.Consignee_Name = obj.Consignee_Name_TMS__r.Name;
                            }
                        if(obj.Consignee_PAN_TMS__c != null  &&  obj.Consignee_PAN_TMS__c != ''){
                            objwrap.Consignee_PAN = obj.Consignee_PAN_TMS__c;
                        }
                        if(obj.Shipment_Value__c != null && obj.Shipment_Value__c != 0){
                            objwrap.Shipment_Value = obj.Shipment_Value__c;
                        }  
                        if(obj.Product_Description__c != null  &&  obj.Product_Description__c != ''){
                            objwrap.Product_Description = obj.Product_Description__c;
                        }
                        if(obj.Net_Weight__c != null ){
                            objwrap.Net_Weight = obj.Net_Weight__c;
                        }
                        if(obj.Net_Weight_UOM_TMS__c != null  &&  obj.Net_Weight_UOM_TMS__c != ''){
                            objwrap.Net_WeightUOM = obj.Net_Weight_UOM_TMS__c;
                        }
                        if(obj.Gross_Weight__c != null ){
                            objwrap.Gross_Weight = obj.Gross_Weight__c;
                        } 
                        if(obj.Gross_Weight_UOM_TMS__c != null  &&  obj.Gross_Weight_UOM_TMS__c != ''){
                            objwrap.Gross_WeightUOM = obj.Gross_Weight_UOM_TMS__c;
                        } 
                        if(obj.Number_of_Packages__c != null){
                            objwrap.Number_of_Packages = obj.Number_of_Packages__c;
                        }
                        if(obj.Insurance_By_BVC__c != null  &&  obj.Insurance_By_BVC__c != ''){
                            objwrap.Insurance_By = obj.Insurance_By_BVC__c;
                        }
                        if(obj.Insurance_By__c != null  &&  obj.Insurance_By__c != ''){
                            objwrap.BVC_Insurance = obj.Insurance_By__c;
                        }
                           // if(obj.E_Invoice_Number__c != null  &&  obj.E_Invoice_Number__c != '')
                            //objwrap.EInvoice_Number = obj.E_Invoice_Number__c;
                            
                           // if(obj.Status__c != null  &&  obj.Status__c != '')
                            //objwrap.Status = obj.Status__c;
                            
                                
                        if(obj.Shipping_Note_Number__c != null  &&  obj.Shipping_Note_Number__c != ''){
                            	objwrap.Shipping_Note_Number = obj.Shipping_Note_Number__c ;    
                        }
                        if(obj.Id != null){
                            	objwrap.Reference_Number = obj.Id ;  
                        }
                        if(obj.Origin_Address_Country__c != null  &&  obj.Origin_Address_Country__c != ''){
                            	objwrap.Origin_Address_Country = obj.Origin_Address_Country__c;
                        }                                      
                        if(obj.Origin_Address_City__c != null  &&  obj.Origin_Address_City__c != ''){
                            	objwrap.Origin_Address_City = obj.Origin_Address_City__c; 
                        }
                        if(obj.Origin_Address_Pincode__c != null && obj.Origin_Address_Pincode__c != ''){
                           objwrap.Origin_Address_Pincode = obj.Origin_Address_Pincode__c;
                        }
                        if(obj.Origin_Address_State__c != null  &&  obj.Origin_Address_State__c != ''){
		                    	objwrap.Origin_Address_State = obj.Origin_Address_State__c; 
                        }
                        
                        if(obj.Billing_Address__c != null ) {
                               objwrap.Billing_Address = obj.Billing_Address__r.Name;
                        }
                        if(obj.Shipper_Name_TMS__c != null){
                           objwrap.Shipper_Account = obj.Shipper_Name_TMS__c;
                        }
                        if(obj.Origin_Address_Line_2__c != null  &&  obj.Origin_Address_Line_2__c != ''){
                               objwrap.Origin_Address_Line2 = obj.Origin_Address_Line_2__c;
                        }
                        if(obj.Origin_Address_Line_1__c != null  &&  obj.Origin_Address_Line_1__c != ''){
                               objwrap.Origin_Address_Line1 =  obj.Origin_Address_Line_1__c ;
                        }
                        if(obj.Origin_Address_Phone__c != null  &&  obj.Origin_Address_Phone__c != ''){
                               objwrap.Origin_Address_Number = obj.Origin_Address_Phone__c;
                        }
                        if(obj.Consignee_Name_TMS__c != null){
                               objwrap.Consignee_Account = obj.Consignee_Name_TMS__c;
                        }
                        if(obj.Destination_Address_Phone__c != null  &&  obj.Destination_Address_Phone__c != ''){
                               objwrap.Destination_Address_Number = obj.Destination_Address_Phone__c;
                        }
                        if(obj.Destination_Address_Pincode__c != null  &&  obj.Destination_Address_Pincode__c != ''){
                               objwrap.Destination_Address_Pincode =  obj.Destination_Address_Pincode__c;
                        }
                        if(obj.Destination_Address_State__c != null  &&  obj.Destination_Address_State__c != ''){
                               objwrap.Destination_Address_State = obj.Destination_Address_State__c ;
                        }
                        if(obj.Destination_Address_City__c != null  &&  obj.Destination_Address_City__c != ''){
                               objwrap.Destination_Address_City = obj.Destination_Address_City__c;
                        }
                        if(obj.Destination_Address_Country__c != null  &&  obj.Destination_Address_Country__c != ''){
                               objwrap.Destination_Address_Country = obj.Destination_Address_Country__c ;
                        }
                        if(obj.Destination_Address_Line_2__c != null  &&  obj.Destination_Address_Line_2__c != '') {
                               objwrap.Destination_Address_Line2 = obj.Destination_Address_Line_2__c;
                        }
                        if(obj.Destination_Address_Line1__c != null  &&  obj.Destination_Address_Line1__c != ''){
                               objwrap.Destination_Address_Line1 = obj.Destination_Address_Line1__c ;
                        }
                        if(obj.Cargo_Type__c != null  &&  obj.Cargo_Type__c != ''){
                               objwrap.Cargo_Type = obj.Cargo_Type__c;
                        }
                        if(obj.CurrencyIsoCode != null  &&  obj.CurrencyIsoCode != ''){
                               objwrap.Currency_c = obj.CurrencyIsoCode;
                        }
                        if(obj.Pickup_Time_Date__c != null){
                               objwrap.Pickup_DateTime = String.ValueOf(obj.Pickup_Time_Date__c) ;
                        }
                           if(obj.Tracking_Status__c != null  &&  obj.Tracking_Status__c != '') {
                               objwrap.Tracking_Status = obj.Tracking_Status__c;
                           }
                        if(obj.IsExhibition__c != null){
                               objwrap.Exhibition = obj.IsExhibition__c;
                        }
                        if(obj.Exhibition_Name__c != null  &&  obj.Exhibition_Name__c != ''){
                               objwrap.Exhibition_Name = obj.Exhibition_Name__c;
                        }
                        if(obj.Exhibition_Movement_Type__c != null  &&  obj.Exhibition_Movement_Type__c != ''){
                               objwrap.Exhibition_Movement_Type = obj.Exhibition_Movement_Type__c ;
                        }
                        if(obj.Origin_Address_Name__r.Your_Address_Identifier__c != null && obj.Origin_Address_Name__r.Your_Address_Identifier__c != ''){
                                 objwrap.Your_Address_Identifier = obj.Origin_Address_Name__r.Your_Address_Identifier__c;           
                        }
                           if(obj.Customer_Product_Category__c != null && obj.Customer_Product_Category__c != '')
                           {
                              objwrap.BVC_Service  = obj.Customer_Product_Category__c;   
                           }
                            objwrap.Message = 'Success';
                            wraperlist.add(objwrap);
                            standardResponse.addHeader('Content-Type', 'application/json');               
                            standardResponse.statusCode = 200;
                            standardResponse.responseBody = blob.valueOf(JSON.serializePretty(wraperlist)) ;
                    }
                }
                else{
                        standardResponse.addHeader('Content-Type', 'application/json');               
                        standardResponse.statusCode = 404;
                        standardResponse.responseBody = blob.valueOf(' "Error" : "Record Not found" ') ;    
                }
                
			}
        
            else{
                // Response for Error
                standardResponse.addHeader('Content-Type', 'application/json');               
                standardResponse.statusCode = 404;
                standardResponse.responseBody = blob.valueOf(' "Error" : "Please send the Shipping Note Number and Customer Reference Number" ') ;
            }
                
            //return wraperlist ;
        }    
            
}