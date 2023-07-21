global class BathFileUploadHpr{    
 
    public void sendMail(String message_Data){
        String userName = UserInfo.getUserName();
		User activeUser = [Select id,Email From User where Username = : userName limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{activeUser.Email});
        mail.setSubject('BATH File Uploader Update');
        mail.setPlainTextBody(message_Data);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});        
    }

	@AuraEnabled
	public static String parseFile(String base64Data, String fileName) {
        system.debug('blobData::::::'+base64Data);
        String Message;
        try{   
        	Blob blobData = Blob.valueOf(base64Data);
            List<JSON2ApexController> objList = new List<JSON2ApexController>();
         	objList = checkExcelColumns(blobData);
            if(objList.size()>0){
                for(integer i=objList.size()-1; i>=0; i--){
                    if(objList[i].BVCService!='BATH'){
                        if(i==objList.size()-1){
                           message='ROW -'+(i+1)+'- Validate BVC Service'; 
                        }else{
                           message='ROW -'+(i+1)+'- Validate BVC Service'+'--'+message; 
                        } 
                    }if(objList[i].CustomerNumber==null){
                        message='ROW -'+(i+1)+'- Validate Customer Number'+'--'+message;
                    }  
                }
                if(message!=null){
                  throw new applicationException(message);
                }else{
                	Message = createEmployeeBatchRecords(objList);  
            	}  
            }
            return Message;
        }catch(Exception e) {
            System.debug('sakjdhakdhsakhd '+e.getLineNumber());
            System.debug('sakjdhakdhsakhd dsadsadsadsa '+e.getMessage());
            throw new AuraHandledException(e.getMessage());    
        }
		  
	}
    
    public static List<JSON2ApexController> checkExcelColumns(Blob blobData){    
        system.debug('blobData::::::'+blobData);
        String XlsxAsAString;
        String[] csvFileLines;
        XlsxAsAString = blobData.toString();
        String XlsxAsAString1 = jsonFormator(XlsxAsAString);
        system.debug('XlsxAsAString1:::::'+XlsxAsAString1);
        List<JSON2ApexController> objList = new List<JSON2ApexController>();
        objList = JSON2ApexController.parse(XlsxAsAString1);
        system.debug('objList:::'+objList);
        return objList;
    }
    Public static string createEmployeeBatchRecords(List<JSON2ApexController> objList){
        String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranchBatheShip = [select id,Billing_Entity_Name__c,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        string ErrorMessage;
        integer List_Of_Data = objList.size(); 
        Map<Integer,String> Row_CusNumMap = new Map<Integer,String>();
        Map<Integer,String> Row_PincodeMap = new Map<Integer,String>();
        Map<Integer,String> Row_PhonNumMap = new Map<Integer,String>();
        Map<Integer,String> ConsigneeName = new Map<Integer,String>(); 
        Map<Integer,String> Row_JSANameMap = new Map<Integer,String>();       
        
        Integer Countrows=objList.size();
        for(integer i=0; i<objList.size(); i++){
            ConsigneeName.put(i,objList[i].ConsigneeName);              
            Row_CusNumMap.put(i,objList[i].CustomerNumber);
            Row_JSANameMap.put(i,objList[i].JSA);
            Row_PincodeMap.put(i,objList[i].Pincode);
            Row_PhonNumMap.put(i,objList[i].ConsigneePhoneNo);
        }
        //MAIN CUSTOMER
        Map<String, String> CusNumIdMap = new Map<String, String>(); 
        for(Account objCS : [select ID,Account_Number__c from Account where Account_Number__c IN :Row_CusNumMap.values()]){
            CusNumIdMap.put(objCS.Account_Number__c,objCS.Id);
        }
        Map<Integer, String> Row_cusIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_CusNumMap.keySet()){
            Row_cusIdMap_Final.put(cusNum,CusNumIdMap.get(Row_CusNumMap.get(cusNum)));
        }
        for(Integer csuId: Row_cusIdMap_Final.keySet()){
            if(Row_cusIdMap_Final.get(csuId)==null){
               throw new applicationException('ROW -'+(csuId+1)+' Customer Doesnt Exist in the System'); 
            }
        }
        //PINCODE
        Map<String, String> PincodeIdMap = new Map<String, String>(); 
        for(Active_Pincode__c objCS : [select ID,Name from Active_Pincode__c where Name IN:Row_PincodeMap.values()]){
            PincodeIdMap.put(objCS.Name,objCS.Id);
        }
        Map<Integer, String> Row_PincodeIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_PincodeMap.keySet()){
            Row_PincodeIdMap_Final.put(cusNum,PincodeIdMap.get(Row_PincodeMap.get(cusNum)));
        }
        for(Integer pinId: Row_PincodeIdMap_Final.keySet()){
            if(Row_PincodeIdMap_Final.get(pinId)==null){
               //throw new applicationException('ROW -'+(pinId+1)+' Pincode Doesnt Exist in the System'); 
            }
        }
        //Consignee PERSONAL ACCOUNT
        String ConsigneeAccRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consignee Account').getRecordTypeId();
        Map<String, String> PhonNumPAccMap = new Map<String, String>();
        if(Row_PhonNumMap.values()!=null){
           for(Account objCS : [select ID,Consinee_Phone__c from Account where Consinee_Phone__c IN:Row_PhonNumMap.values() And RecordTypeId=:ConsigneeAccRecTypeID limit 4000]){
        	PhonNumPAccMap.put(objCS.Consinee_Phone__c,objCS.Id);
        	} 
        }
        
        Map<Integer, String> Row_PAccIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_PhonNumMap.keySet()){
            Row_PAccIdMap_Final.put(cusNum,PhonNumPAccMap.get(Row_PhonNumMap.get(cusNum)));
        }

        Map<Integer,Account> ConsigneeAccList = new Map<Integer,Account>();
        for(Integer consigId: Row_PAccIdMap_Final.keySet()){
            if(Row_PAccIdMap_Final.get(consigId)==null && objList[consigId].ConsigneeName!=null){
                Account acc = new Account();  
                String AccountName =objList[consigId].ConsigneeName;
                if(String.isNotBlank(AccountName)) {          
                    if(AccountName.contains(' ')) {
                       acc.FirstName = AccountName.substringBefore(' ');
                       acc.LastName = AccountName.substringAfter(' ');      
                    }else{
                       acc.LastName = AccountName;
                    }
               }
               acc.Consinee_Phone__c=objList[consigId].ConsigneePhoneNo;
               if(objList[consigId].ConsigneeEmail!=null){
                   acc.Consignee_Email__c=objList[consigId].ConsigneeEmail; 
               }
               acc.RecordTypeId=ConsigneeAccRecTypeID;
               Row_PAccIdMap_Final.put(consigId,acc.id);
               ConsigneeAccList.put(consigId,acc);
            }   
        }
        if(ConsigneeAccList.size()>0){
           insert ConsigneeAccList.values();
        }
        for(Integer con:ConsigneeAccList.keySet()){
            Row_PAccIdMap_Final.put(con,ConsigneeAccList.get(con).id);
        }
        //ADDRESSBOOK
        String shippingAddressBKRecTypeID = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Map<String, String> Consignee_AdrsBookIdMap = new Map<String, String>();
        if(Row_PAccIdMap_Final.values()!=null){
          for(AddressBook__c objCS : [select ID,Customer__c from AddressBook__c where Customer__c IN:Row_PAccIdMap_Final.values()]){
            Consignee_AdrsBookIdMap.put(objCS.Customer__c,objCS.Id);
          }  
        }
        
        Map<Integer, String> Row_ConAddressIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_PAccIdMap_Final.keySet()){
            Row_ConAddressIdMap_Final.put(cusNum,Consignee_AdrsBookIdMap.get(Row_PAccIdMap_Final.get(cusNum)));
        }
        Map<Integer,AddressBook__c> listAddress = new Map<Integer,AddressBook__c>();
        for(Integer conaddressId: Row_ConAddressIdMap_Final.keySet()){
            if(Row_ConAddressIdMap_Final.get(conaddressId)==null && Row_PAccIdMap_Final.get(conaddressId)!=null){
                AddressBook__c AddressAccount = new AddressBook__c();
                AddressAccount.Is_Uploaded__c=true;
                AddressAccount.Name= objList[conaddressId].ConsigneeAddress; 
                AddressAccount.Customer__c=Row_PAccIdMap_Final.get(conaddressId);
                AddressAccount.ADDRESS1__c=objList[conaddressId].ConsigneeAddress;
                AddressAccount.Active_Pincode__c=Row_PincodeIdMap_Final.get(conaddressId);
                AddressAccount.Your_Address_Identifier__c= objList[conaddressId].ConsigneeName+'-'+conaddressId;
                AddressAccount.RecordTypeId=shippingAddressBKRecTypeID;
                listAddress.put(conaddressId,AddressAccount);
            }
        }
        if(listAddress.size()>0){
            insert listAddress.values();
        }
        for(Integer con:listAddress.keySet()){
            Row_ConAddressIdMap_Final.put(con,listAddress.get(con).id);
        }
        
        Map<String, String> JSAName_IdMap = new Map<String, String>(); 
        for(User objCS : [select ID,Name from User where Name IN:Row_JSANameMap.values()]){
            JSAName_IdMap.put(objCS.Name,objCS.Id);
        }
        Map<Integer, String> Row_JSAIdMap_Final = new Map<Integer, String>();
        for(Integer jsaNum: Row_JSANameMap.keySet()){
            Row_JSAIdMap_Final.put(jsaNum,JSAName_IdMap.get(Row_JSANameMap.get(jsaNum)));
        }
        String BATHshipRecTypeID = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('BATH').getRecordTypeId();
        List<Shipment__c> ListShipment_c = new List<Shipment__c>();
        
        Integer count=0;
        for(integer i=0; i<objList.size(); i++){
            if(objList[i].BVCService=='BATH'){ 
                count++;
                Shipment__c Shipment = new Shipment__c();
                Shipment.Is_Uploaded__c=true;
                Shipment.Excel_Sheet_Row__c=String.valueOf(count);
                if(Row_PAccIdMap_Final.get(i)!=null && objList[i].ConsigneePhoneNo!=null){
                    Shipment.Consignee_Name_TMS__c=Row_PAccIdMap_Final.get(i);
                }
                if(Row_ConAddressIdMap_Final.get(i)!=null && objList[i].ConsigneePhoneNo!=null){
                    Shipment.Destination_Address_Name__c=Row_ConAddressIdMap_Final.get(i);
                }
                if(Row_cusIdMap_Final.get(i)!=null){
                  Shipment.Customer__c=Row_cusIdMap_Final.get(i);
                  Shipment.Bill_To_Account__c=Row_cusIdMap_Final.get(i);
                }
                if(Row_JSAIdMap_Final.get(i)!=null){
                    Shipment.JSA__c=Row_JSAIdMap_Final.get(i);
                }else{
                    Shipment.Excel_Improper_Data__c='JSA -'+objList[i].JSA+'\n';
                } 
                if(objList[i].Month!=null){                    
                   Shipment.Month_Picklist_Field__c=objList[i].Month;
                }
                if(objList[i].LeadDate!=null){
                    Shipment.Lead_Date__c=Date.parse(objList[i].LeadDate);
                } 
                if(objList[i].ApptDate!=null){
                    Shipment.Appt_Date__c=Date.parse(objList[i].ApptDate);
                }
                if(objList[i].ReschduleDate!=null){
                    Shipment.Reschdule_Date__c=Date.parse(objList[i].ReschduleDate);
                }
                if(objList[i].Status!=null){
                    Shipment.Shipment_Status__c=objList[i].Status;
                }
                if(objList[i].ActualDateOfVisit!=null){
                    Shipment.Actual_Date_of_Visit__c=Date.parse(objList[i].ActualDateOfVisit);
                }
                if(objList[i].CustomerLeadId!=null){
                    Shipment.Lead_id__c=objList[i].CustomerLeadId;
                } 
                if(objList[i].Pincode!=null){
                    Shipment.Pincode__c=Decimal.valueOf(objList[i].Pincode) ;
                }
                if(objList[i].SKU!=null){
                    Shipment.SKU__c=objList[i].SKU ;
                }
                if(objList[i].price!=null){
                    Shipment.price__c=Decimal.valueOf(objList[i].price) ;
                }
                if(objList[i].Barcode!=null){
                    Shipment.Barcode__c=objList[i].Barcode ;
                }
                if(objList[i].BarcodeLocation!=null){
                    Shipment.Barcode_Location__c=objList[i].BarcodeLocation ;
                }
                if(objList[i].COMMENTS!=null){
                    Shipment.Comments__c=objList[i].COMMENTS ;
                }
                if(objList[i].ILONO!=null){ 
                    Shipment.ILO_No__c=objList[i].ILONO;
                }
                if(objList[i].BVCAWBNO!=null){
                    Shipment.BVC_AWB_No__c=objList[i].BVCAWBNO ;
                }
                if(objList[i].BagNO!=null){
                    Shipment.Bag_No__c=objList[i].BagNO ;
                }
                if(objList[i].HandoverDone!=null){
                    Shipment.Handover_Done__c=objList[i].HandoverDone=='Yes'?true:false ;
                }
               
                if(objList[i].DispatchDate!=null){
                    Shipment.Dispatch_Date__c=Date.parse(objList[i].DispatchDate) ;
                }
                if(objList[i].ILOInwardAtBVCFacility!=null){
                    Shipment.ILO_inward_at_BVC_facility__c=objList[i].ILOInwardAtBVCFacility=='Yes'?true:false ;
                }
                if(objList[i].TAHMemoDate!=null){
                    Shipment.TAH_Memo_Date__c=Date.parse(objList[i].TAHMemoDate) ;
                }
                
                if(objList[i].CustomerAppointmentConfimationDetails!=null){
                    Shipment.Customer_Appointment_Confimation_Details__c=objList[i].CustomerAppointmentConfimationDetails ;
                }
                if(objList[i].BVCDeliveryStatus!=null){
                    Shipment.BVC_Delivery_Status__c=objList[i].BVCDeliveryStatus ;
                }
                
                if(objList[i].DeliveryDate!=null){
                    Shipment.Delivery_Date__c=Date.parse(objList[i].DeliveryDate) ;
                }
                
                if(objList[i].BVCREMARK!=null){
                    Shipment.BVC_Remark__c=objList[i].BVCREMARK ;
                }
                
                if(objList[i].InwardDate!=null){      
                    Shipment.Inward_Date__c=Date.parse(objList[i].InwardDate) ;
                }
                if(objList[i].JewelleryCategory!=null){                     
                    Shipment.Jewellery_Category__c=objList[i].JewelleryCategory ;
                }
                if(objList[i].Success!=null){                                                               
                    Shipment.Success__c=objList[i].Success=='Yes'?true:false;
                }
                if(objList[i].SaleValue!=null){                                                                       
                    Shipment.Approx_Sale_Value__c=Decimal.valueOf(objList[i].SaleValue);
                }
                if(objList[i].PaymentMode!=null){  
                    Shipment.Payment_Mode__c=objList[i].PaymentMode;
                }
                if(objList[i].TotalInvoiceValue!=null){          
                    Shipment.Total_Invoice_Value__c=Decimal.ValueOf(objList[i].TotalInvoiceValue);
                }
                
                if(objList[i].VisitOutcome!=null){ 
                   Shipment.Visit_Outcome__c=objList[i].VisitOutcome;
                }
                if(objList[i].OriginDestinationPairing!=null){ 
                    Shipment.Origin_Destination_Pairing__c=objList[i].OriginDestinationPairing;
                }
                if(objList[i].ProductCategory!=null){ 
                    Shipment.Product_Category__c=objList[i].ProductCategory;
                } 
                if(objList[i].REVERSE!=null){                                
                    Shipment.Reverse__c=objList[i].REVERSE=='Yes'?true:false ;
                }
                if(objList[i].BVCService!=null){
                    Shipment.Customer_Product_Category__c=objList[i].BVCService;
                }
                if(!test.isRunningTest()){
                    if(BVCbranchBatheShip[0].Billing_Entity_Name__c!=null){
                        Shipment.Billing_Entity_Name_TMS__c=BVCbranchBatheShip[0].Billing_Entity_Name__c;
                    }
                }
                Shipment.Status__c='Pending Billing';
                Shipment.RecordTypeId=BATHshipRecTypeID;
                ListShipment_c.add(Shipment);        
            }
        }
        
        try{ 
            if(ListShipment_c.size()>0){
                System.debug('final list========'+ListShipment_c);
                BathFileBatchClass ListShipment = new BathFileBatchClass(ListShipment_c); 
        		ID batchprocessid = database.executeBatch(ListShipment,5);
                //system.enqueueJob(new BathFileUploadHpr2(ListShipment_c));  
            }
            if(ErrorMessage==null){
                ErrorMessage=string.valueOf(ListShipment_c.size());
            }            
        } 
        catch(DMLException e) {
            ErrorMessage=e.getMessage();
            ErrorMessage=ErrorMessage+'\n'+' Failed because of unproper data'+ '\n';            
        } 
         return ErrorMessage;
    }
 
    public static List<JSON2ApexController> parse(String XlsxAsAString1) {
        return (List<JSON2ApexController>) System.JSON.deserialize(XlsxAsAString1, List<JSON2ApexController>.class);
    } 
    public class JSON2ApexController {      
        public String Month;
        public String LeadDate;
        public String ApptDate;
        public String ReschduleDate;
        public String Status;
        public String ActualDateOfVisit;
        public String CustomerLeadId;
        public String ConsigneeName;
        public String ConsigneeEmail;
        public String ConsigneePhoneNo;
        public String ConsigneeAddress;
        public String Pincode;
        public String SKU;
        public String price;
        public String Barcode;
        public String BarcodeLocation;
        public String COMMENTS;
        public String ILONO;
        public String BVCAWBNO;
        public String BagNO;
        public String HandoverDone;
        public String DispatchDate;
        public String ILOInwardAtBVCFacility;
        public String TAHMemoDate;
        public String CustomerAppointmentConfimationDetails;
        public String BVCDeliveryStatus;
        public String DeliveryDate;
        public String BVCREMARK;
        public String InwardDate;
        public String JewelleryCategory;
        public String Success;
        public String SaleValue;
        public String PaymentMode;
        public String JSA;
        public String REVERSE;
        public String CustomerNumber;
        public String TotalInvoiceValue;
        public String VisitOutcome;
        public String OriginDestinationPairing;
        public String ProductCategory;
        public String BVCService;
        
    } 
    public static String jsonFormator(String jsonString) {   
        String target = 'Month';
        String replacement = 'Month';
        String jsonString1 = jsonString.replace(target, replacement);
        
        target = 'Lead Date';
        replacement = 'LeadDate';
        String jsonString2 = jsonString1.replace(target, replacement);
        
        target = 'Appt Date';
        replacement = 'ApptDate';
        String jsonString3 = jsonString2.replace(target, replacement);
        
        target = 'Reschdule Date';
        replacement = 'ReschduleDate';
        String jsonString4 = jsonString3.replace(target, replacement);
        
        target = 'Status';
        replacement = 'Status';
        String jsonString5 = jsonString4.replace(target, replacement);
        
        target = 'Actual Date Of Visit';
        replacement = 'ActualDateOfVisit';
        String jsonString6 = jsonString5.replace(target, replacement);
        
        target = 'Customer Lead Id';
        replacement = 'CustomerLeadId';
        String jsonString7 = jsonString6.replace(target, replacement);
        
        target = 'Consignee Name';
        replacement = 'ConsigneeName';
        String jsonString8 = jsonString7.replace(target, replacement);
        
        target = 'Consignee Email';
        replacement = 'ConsigneeEmail';
        String jsonString9 = jsonString8.replace(target, replacement);
        
        target = 'Consignee Phone No';
        replacement = 'ConsigneePhoneNo';
        String jsonString10 = jsonString9.replace(target, replacement);
        
        target = 'Consignee Address';
        replacement = 'ConsigneeAddress';
        String jsonString11 = jsonString10.replace(target, replacement);
        
        target = 'Pincode';
        replacement = 'Pincode';
        String jsonString12 = jsonString11.replace(target, replacement);
        
        target = 'SKU';
        replacement = 'SKU';
        String jsonString13 = jsonString12.replace(target, replacement);
        
        target = 'price';
        replacement = 'price';
        String jsonString14 = jsonString13.replace(target, replacement);
        
        target = 'Barcode';
        replacement = 'Barcode';
        String jsonString15 = jsonString14.replace(target, replacement);
        
        target = 'Barcode Location';
        replacement = 'BarcodeLocation';
        String jsonString16 = jsonString15.replace(target, replacement);
        
        target = 'COMMENTS';
        replacement = 'COMMENTS';
        String jsonString17 = jsonString16.replace(target, replacement);
        
        target = 'ILO NO';
        replacement = 'ILONO';
        String jsonString18 = jsonString17.replace(target, replacement);
        
        target = 'BVC AWB NO';
        replacement = 'BVCAWBNO';
        String jsonString19 = jsonString18.replace(target, replacement);
        
        target = 'Bag NO';
        replacement = 'BagNO';
        String jsonString20 = jsonString19.replace(target, replacement);
        
        target = 'Handover Done';
        replacement = 'HandoverDone';
        String jsonString21 = jsonString20.replace(target, replacement);
        
        target = 'Dispatch Date';
        replacement = 'DispatchDate';
        String jsonString22 = jsonString21.replace(target, replacement);
        
        target = 'ILO Inward At BVC Facility';
        replacement = 'ILOInwardAtBVCFacility';
        String jsonString23 = jsonString22.replace(target, replacement);
        
        target = 'TAH Memo Date';
        replacement = 'TAHMemoDate';
        String jsonString24 = jsonString23.replace(target, replacement);
        
        target = 'Customer Appointment Confimation Details';
        replacement = 'CustomerAppointmentConfimationDetails';
        String jsonString25 = jsonString24.replace(target, replacement);
        
        target = 'BVC Delivery Status';
        replacement = 'BVCDeliveryStatus';
        String jsonString26 = jsonString25.replace(target, replacement);
        
        target = 'Delivery Date';
        replacement = 'DeliveryDate';
        String jsonString27 = jsonString26.replace(target, replacement);
        
        target = 'BVC REMARK';
        replacement = 'BVCREMARK';
        String jsonString28 = jsonString27.replace(target, replacement);
        
        target = 'Inward Date';
        replacement = 'InwardDate';
        String jsonString29 = jsonString28.replace(target, replacement);
        
        target = 'Jewellery Category';
        replacement = 'JewelleryCategory';
        String jsonString30 = jsonString29.replace(target, replacement);
        
        target = 'Success';
        replacement = 'Success';
        String jsonString31 = jsonString30.replace(target, replacement);
        
        target = 'Sale Value';
        replacement = 'SaleValue';
        String jsonString32 = jsonString31.replace(target, replacement);
        
        target = 'Payment Mode';
        replacement = 'PaymentMode';
        String jsonString33 = jsonString32.replace(target, replacement);
        
        target = 'JSA';
        replacement = 'JSA';
        String jsonString34 = jsonString33.replace(target, replacement);
        
        target = 'REVERSE';
        replacement = 'REVERSE';
        String jsonString35 = jsonString34.replace(target, replacement);
        
        target = 'Customer Number';
        replacement = 'CustomerNumber';
        String jsonString36 = jsonString35.replace(target, replacement);
        
        target = 'Total Invoice Value';
        replacement = 'TotalInvoiceValue';
        String jsonString37 = jsonString36.replace(target, replacement);
        
        target = 'Visit Outcome';
        replacement = 'VisitOutcome';
        String jsonString38 = jsonString37.replace(target, replacement);
        
        target = 'Origin Destination Pairing';
        replacement = 'OriginDestinationPairing';
        String jsonString39 = jsonString38.replace(target, replacement);
        
        target = 'Product Category';
        replacement = 'ProductCategory';
        String jsonString40 = jsonString39.replace(target, replacement);
        
        target = 'BVC Service';
        replacement = 'BVCService';
        String jsonString41 = jsonString40.replace(target, replacement);
        
        return jsonString41;
    }
   
}