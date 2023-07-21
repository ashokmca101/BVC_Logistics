public with sharing class eShipFileUploadHpr{ 
   
    public void sendMail(String message_Data){   
       String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{activeUser.Email});
        mail.setSubject('eSHIP File Uploader Update');
        mail.setPlainTextBody(message_Data);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});         
    }

    @AuraEnabled
    public static String parseFile(String base64Data, String fileName) {
        system.debug('base64Data::::::'+base64Data);
        String Message;
        try{   
            Blob blobData = Blob.valueOf(base64Data);
            List<JSON2ApexController> objList = new List<JSON2ApexController>();
            objList = checkExcelColumns(blobData);
            if(objList.size()>0){
                for(integer i=objList.size()-1; i>=0; i--){
                    if(objList[i].BVCService!='eSHIP'){
                        if(i==objList.size()-1){
                           message='ROW -'+(i+1)+'- Validate BVC Service'; 
                        }else{
                           message='ROW -'+(i+1)+'- Validate BVC Service'+','+message; 
                        } 
                    }if(objList[i].CustomerNumber==null){
                        message='ROW -'+(i+1)+'- Validate Customer Number'+','+message;
                    }
                    if(objList[i].DocketNo==null){
                        message='ROW -'+(i+1)+'- Validate Docket Number'+','+message;
                    }
                    if(objList[i].RTO==null){
                        message='ROW -'+(i+1)+'- Validate RTO'+','+message;
                    }
                    if(objList[i].ShipperAccount==null){
                        message='ROW -'+(i+1)+'- Validate Shipper Account'+','+message;
                    }
                    System.debug('checking ShipperAddress '+objList[i].ShipperAddress);
                    
                    if(objList[i].ShipperAddress==null){
                        message='ROW -'+(i+1)+'- Validate Shipper Address'+','+message;
                    }
                    /*
                    if(objList[i].ProductCategory!=null){
                        if(objList[i].ProductCategory!='Studded Jewellery' || objList[i].ProductCategory!='Plain Jewellery' || objList[i].ProductCategory!='Preset Solitaire' || objList[i].ProductCategory!='UnStud-Jwry'){
                            //message='ROW -'+(i+1)+'- Validate Product Category'+','+message;
                        }
                    }
                    if(objList[i].ShipmentType!=null){
                        if(objList[i].ShipmentType!='Intercity' || objList[i].ShipmentType!='Intracity'){
                            system.debug('====================='+objList[i].ShipmentType);
                            //message='ROW -'+(i+1)+'- Validate Shipment Type'+','+message;
                        }
                    }*/
                }
                if(message!=null){
                  throw new applicationException(message);
                }else{
                    Message = createEmployeeBatchRecords(objList); 
                    system.debug('message test++++++'+Message);
                }  
            }
            return Message;
          
        }/*catch(Exception e) {
            System.debug('e.getMessdasdasdsada '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());    
}*/finally{}
          
    }
    public static List<JSON2ApexController> checkExcelColumns(Blob blobData){    
        
        String XlsxAsAString;
        String[] csvFileLines;
        XlsxAsAString = blobData.toString();
        String XlsxAsAString1 = jsonFormator(XlsxAsAString);
        List<JSON2ApexController> objList = new List<JSON2ApexController>();
        objList = JSON2ApexController.parse(XlsxAsAString1);
        return objList;
    }
    public static string createEmployeeBatchRecords(List<JSON2ApexController> objList){
        String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        System.debug('Usr for checking dasdsadsad '+Usr.BATH_eSHIP_Billing_Branch__c);
            
        System.debug('Usr for checking  '+Usr.BATH_eSHIP_Billing_Branch__c);
        List<Hub__c> BVCbranchBatheShip = [select id,Billing_Entity_Name__c,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        
        System.debug('BVCbranchBatheShip for checking '+BVCbranchBatheShip);
        System.debug('BVCbranchBatheShip for checking size '+BVCbranchBatheShip.size());
        string ErrorMessage;
        String InvalidCustomer;
        integer List_Of_Data = objList.size();
        Map<Integer,String> Row_ShipperNameMap = new Map<Integer,String>();
        Map<Integer,String> Row_ShipperAddressMap = new Map<Integer,String>();
        Map<Integer,String> Row_CusNumMap = new Map<Integer,String>();
        Map<Integer,String> Row_PincodeMap = new Map<Integer,String>();
        Map<Integer,String> Row_PhonNumMap = new Map<Integer,String>();
        Map<Integer,String> Row_DocketNoMap = new Map<Integer,String>();        
        
        Integer Countrows=objList.size();
        for(integer i=0; i<objList.size(); i++){
            Row_ShipperNameMap.put(i,objList[i].ShipperAccount);              
            Row_CusNumMap.put(i,objList[i].CustomerNumber);
            Row_PincodeMap.put(i,objList[i].Pincode);
            Row_PhonNumMap.put(i,objList[i].ConsigneePhoneNo);
            Row_DocketNoMap.put(i,objList[i].DocketNo);
            Row_ShipperAddressMap.put(i,objList[i].ShipperAddress);
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
        //Docket Number
        Map<String, String> DocNumIdMap = new Map<String, String>(); 
        for(Shipment__c objCS : [select ID,Docket_No__c from Shipment__c where Docket_No__c IN :Row_DocketNoMap.values()]){
            DocNumIdMap.put(objCS.Docket_No__c,objCS.Id);
        }
        Map<Integer, String> Row_DocNumIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_DocketNoMap.keySet()){
            Row_DocNumIdMap_Final.put(cusNum,DocNumIdMap.get(Row_DocketNoMap.get(cusNum)));
        }
        for(Integer csuId: Row_DocNumIdMap_Final.keySet()){
            if(Row_DocNumIdMap_Final.get(csuId)!=null && objList[csuId].RTO!='Yes'){
               throw new applicationException('ROW -'+(csuId+1)+'Docket Number already exist in the system'); 
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
            for(Account objCS : [select ID,Consinee_Phone__c from Account where Consinee_Phone__c IN:Row_PhonNumMap.values() And RecordTypeId =:ConsigneeAccRecTypeID Limit 4000]){
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
        // Consignee ADDRESSBOOK
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
        //Shipper Account
        Map<String, String> ShipperNameIdMap = new Map<String, String>(); 
        for(Account objCS : [select ID,Account_Number__c from Account where Account_Number__c IN:Row_ShipperNameMap.values()]){
            ShipperNameIdMap.put(objCS.Account_Number__c,objCS.Id);
        }
        Map<Integer, String> Row_shipperIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_ShipperNameMap.keySet()){
            Row_shipperIdMap_Final.put(cusNum,ShipperNameIdMap.get(Row_ShipperNameMap.get(cusNum)));
        }
        for(Integer pinId: Row_shipperIdMap_Final.keySet()){
            if(Row_shipperIdMap_Final.get(pinId)==null){
               throw new applicationException('ROW -'+(pinId+1)+' Shipper Account Doesnt Exist in the System'); 
            }
        }
        //Shipper Address
        Map<String, String> ShippAddressIdMap = new Map<String, String>(); 
        System.debug('Row_ShipperAddressMap.values() '+Row_ShipperAddressMap.values());
        for(AddressBook__c objCS : [Select ID,Address_Number__c from AddressBook__c where Address_Number__c IN:Row_ShipperAddressMap.values()]){
            ShippAddressIdMap.put(objCS.Address_Number__c,objCS.Id);
        }
        Map<Integer, String> Row_shipAddressIdMap_Final = new Map<Integer, String>();
        for(Integer cusNum: Row_ShipperAddressMap.keySet()){
            Row_shipAddressIdMap_Final.put(cusNum,ShippAddressIdMap.get(Row_ShipperAddressMap.get(cusNum)));
        }
        for(Integer pinId: Row_shipAddressIdMap_Final.keySet()){
            if(Row_shipAddressIdMap_Final.get(pinId)==null){
               throw new applicationException('ROW -'+(pinId+1)+' Shipper Address Doesnt Exist in the System'); 
            }
        }
        
        String eSHIPshipRecTypeID = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('eSHIP').getRecordTypeId();
        List<Shipment__c> ListShipment_c = new List<Shipment__c>();
       
        Integer count=0;
        for(integer i=0; i<objList.size(); i++){
            if(objList[i].BVCService=='eSHIP'){
                count++;
                Shipment__c Shipment = new Shipment__c();
                Shipment.Is_Uploaded__c=true;
                Shipment.Excel_Sheet_Row__c=String.valueOf(count);
                if(Row_cusIdMap_Final.get(i)!=null){
                    Shipment.Customer__c=Row_cusIdMap_Final.get(i);
                    Shipment.Bill_To_Account__c=Row_cusIdMap_Final.get(i);
                }
                if(Row_PAccIdMap_Final.get(i)!=null && objList[i].ConsigneePhoneNo!=null){
                    Shipment.Consignee_Name_TMS__c=Row_PAccIdMap_Final.get(i);
                }
                if(Row_ConAddressIdMap_Final.get(i)!=null && objList[i].ConsigneePhoneNo!=null){
                    Shipment.Destination_Address_Name__c=Row_ConAddressIdMap_Final.get(i);
                }
                if(Row_shipperIdMap_Final.get(i)!=null){
                    Shipment.Shipper_Name_TMS__c=Row_shipperIdMap_Final.get(i);
                }
                if(Row_shipAddressIdMap_Final.get(i)!=null){
                    Shipment.Origin_Address_Name__c=Row_shipAddressIdMap_Final.get(i);
                }
                if(objList[i].DocketNo!=null){
                    Shipment.Docket_No__c=objList[i].DocketNo;
                }
                if(objList[i].OrderNo!=null){
                    Shipment.Order_No__c=objList[i].OrderNo;
                }
                if(objList[i].Pincode!=null){
                    String s1 = objList[i].Pincode;
                    Boolean b1 = s1.isAlpha();
                    if(B1==false){
                    Shipment.Pincode__c=integer.valueOf(objList[i].Pincode);
                    }
                    else{
                        Shipment.Excel_Improper_Data__c=Shipment.Excel_Improper_Data__c+'\n'+'Pincode - '+objList[i].Pincode;   
                    }
                }
                if(objList[i].PaymentMode!=null){
                    if(objList[i].PaymentMode=='COD'||objList[i].PaymentMode=='cod'||objList[i].PaymentMode=='Cod'){
                    Shipment.Payment_Mode__c='COD';
                    }
                    else{
                        if(objList[i].PaymentMode=='Prepaid'||objList[i].PaymentMode=='PREPAID'){
                           Shipment.Payment_Mode__c='Prepaid'; 
                        }
                        else{     
                           Shipment.Excel_Improper_Data__c=Shipment.Excel_Improper_Data__c+'\n'+'PaymentMode - '+objList[i].PaymentMode;  
                        }     
                    }
                }
                if(objList[i].RTO!=null){
                    if(objList[i].RTO=='Yes'||objList[i].RTO=='yes'||objList[i].RTO=='Y'||objList[i].RTO=='y'){
                        Shipment.RTO__c=true;
                    }
                    else{
                        if(objList[i].RTO=='No'||objList[i].RTO=='no'||objList[i].RTO=='N'||objList[i].RTO=='n'){
                            Shipment.RTO__c=false;
                        }
                        else{
                            Shipment.Excel_Improper_Data__c=Shipment.Excel_Improper_Data__c+'\n'+'RTO -'+objList[i].RTO;   
                        }
                    }
                } 
                //need to discuse
                if(objList[i].FromCity!=null){
                    Shipment.From_City__c=objList[i].FromCity;
                }
                if(objList[i].ToCity!=null){
                    Shipment.To_City__c=objList[i].ToCity;
                }
                if(objList[i].DocketDate!=null){
                    Shipment.Docket_Date__c= Date.Parse(objList[i].DocketDate);
                    //Shipment.Docket_Date__c= System.now();//Date.Parse(objList[i].DocketDate);
                }
                if(objList[i].BookingDate!=null){
                    Shipment.Shipment_Date__c=Date.parse(objList[i].BookingDate);
                    Shipment.Booking_Date__c=Date.parse(objList[i].BookingDate);
                    // Shipment.Shipment_Date__c=System.today(); //Date.parse(objList[i].BookingDate);
                    //Shipment.Booking_Date__c= System.now();//Date.parse(objList[i].BookingDate);
                }
                if(objList[i].DeclaredValue!=null){
                    Shipment.Declared_Value__c=Decimal.valueOf(objList[i].DeclaredValue);
                }
                if(objList[i].CODAmount!=null){
                    String s1 = objList[i].CODAmount;
                    Boolean b1 = s1.isAlpha();
                    if(B1==false){
                        Shipment.COD_Amount__c=Decimal.valueOf(objList[i].CODAmount);
                        Shipment.Total_Invoice_Value__c=Decimal.valueOf(objList[i].CODAmount);
                    }
                    else{
                        Shipment.Excel_Improper_Data__c=Shipment.Excel_Improper_Data__c+'\n'+'COD Amount -'+objList[i].CODAmount;
                    }
                }
                if(objList[i].NoOfAttempts!=null){
                    String s1 = objList[i].CODAmount;
                    Boolean b1 = s1.isAlpha();
                    if(B1==false){
                    Shipment.No_Of_Attempts__c=integer.valueOf(objList[i].NoOfAttempts);
                    }
                    else{
                       Shipment.Excel_Improper_Data__c=Shipment.Excel_Improper_Data__c+'\n'+'No Of Attempts -'+objList[i].NoOfAttempts; 
                    }
                }
                if(objList[i].ShipperAddress!=null){
                    Shipment.Shipper_Address__c=objList[i].ShipperAddress;
                }
                if(objList[i].NetweightinGram!=null){ 
                    Shipment.Net_Weight__c=Decimal.valueOf(objList[i].NetweightinGram); 
                }
                if(objList[i].GrossweightinGram!=null){ 
                    Shipment.Gross_Weight__c=Decimal.valueOf(objList[i].GrossweightinGram);
                }
                if(objList[i].ProductCategory!=null){
                  Shipment.Product_Category__c=objList[i].ProductCategory;
                }  
                if(objList[i].ShipmentType!=null){
                    Shipment.Shipment_Type__c=objList[i].ShipmentType;
                } 
                if(objList[i].TotalInvoiceValue!=null){
                    Shipment.Total_Invoice_Value__c=Decimal.ValueOf(objList[i].TotalInvoiceValue);
                }
                if(objList[i].BVCService!=null){
                  Shipment.Customer_Product_Category__c=objList[i].BVCService;  
                }
                Shipment.RecordTypeId=eSHIPshipRecTypeID;
                //system.debug('recordTypeId++++++'+Shipment.RecordTypeId);
                //system.debug('Billing Entity======'+BVCbranchBatheShip[0].Billing_Entity_Name__c);
                if(!test.isRunningTest()){
                    if(BVCbranchBatheShip[0].Billing_Entity_Name__c!=null){
                    Shipment.Billing_Entity_Name_TMS__c=BVCbranchBatheShip[0].Billing_Entity_Name__c;
                    
                } 
                }
               
                Shipment.Status__c='Pending Billing';
                ListShipment_c.add(Shipment);
                
            }
        }
        
        try{              
        System.debug('ListShipment_c.size  '+ListShipment_c.size()); 
            if(ListShipment_c.size()>0){
                eShipFileBatchClass ListShipment = new eShipFileBatchClass(ListShipment_c); 
                ID batchprocessid = database.executeBatch(ListShipment,5);
                System.debug('for checking batchprocessid '+batchprocessid);
                //system.enqueueJob(new eShipFileUploadHpr2(ListShipment_c));
            }

            if(ErrorMessage==null){
                ErrorMessage=string.valueOf(ListShipment_c.size());
            }
        } 
        catch(DMLException e) 
        {
            System.debug('error Occre line numner '+e.getLineNumber());
            ErrorMessage=e.getMessage();
            ErrorMessage=ErrorMessage+'\n'+' Failed because of unproper data'+ '\n';
        } 
        return ErrorMessage;
    }
    
    public static List<JSON2ApexController> parse(String XlsxAsAString1){
        return (List<JSON2ApexController>) System.JSON.deserialize(XlsxAsAString1, List<JSON2ApexController>.class);
    } 
  
    public class JSON2ApexController 
    {              
        //public String ConsignorCode;
        //public String ConsignorName;
        public String DocketNo;
        public String OrderNo;
        public String Pincode;
        public String ConsigneeAccount;
        public String PaymentMode;
        public String ShipmentType;
        public String RTO;
        public String FromCity;
        public String ToCity;
        public String DocketDate;
        public String BookingDate;
        public String DeclaredValue;
        public String CODAmount;
        public String NoOfAttempts;
        public String ShipperAccount;
        public String OriginAddressName;
        public String ShipperAddress;
        public String NetweightinGram;
        public String BVCService;
        public String TotalInvoiceValue;
        public String ProductCategory;
        public String CustomerNumber;
        public String ConsigneePhoneNo;
        public String ConsigneeName;
        public String ConsigneeEmail;
        public String ConsigneeAddress;
        public String GrossweightinGram;
        
    
    } 
    public static String jsonFormator(String jsonString) 
    {   
        String target = 'Consignor Code';
        String replacement = 'ConsignorCode';
        String jsonString1 = jsonString.replace(target, replacement);
        
        target = 'Consignor Name';
        replacement = 'ConsignorName';
        String jsonString2 = jsonString1.replace(target, replacement);
        
        target = 'Docket No';
        replacement = 'DocketNo';
        String jsonString3 = jsonString2.replace(target, replacement);
        
        target = 'Order No';
        replacement = 'OrderNo';
        String jsonString4 = jsonString3.replace(target, replacement);
        
        target = 'Pincode';
        replacement = 'Pincode';
        String jsonString5 = jsonString4.replace(target, replacement);
        
        target = 'Consignee Account';
        replacement = 'ConsigneeAccount';
        String jsonString6 = jsonString5.replace(target, replacement);
        
        target = 'Payment Mode';
        replacement = 'PaymentMode';
        String jsonString7 = jsonString6.replace(target, replacement);
        
        target = 'Shipment Type';
        replacement = 'ShipmentType';
        String jsonString8 = jsonString7.replace(target, replacement);
        
        target = 'RTO';
        replacement = 'RTO';
        String jsonString9 = jsonString8.replace(target, replacement);        
        
        target = 'From City';
        replacement = 'FromCity';
        String jsonString10 = jsonString9.replace(target, replacement);
        
        target = 'To City';
        replacement = 'ToCity';
        String jsonString11 = jsonString10.replace(target, replacement);
        
        target = 'Docket Date';
        replacement = 'DocketDate';
        String jsonString12 = jsonString11.replace(target, replacement);
        
        target = 'Booking Date';
        replacement = 'BookingDate';
        String jsonString13 = jsonString12.replace(target, replacement);
        
        target = 'Declared Value';
        replacement = 'DeclaredValue';
        String jsonString14 = jsonString13.replace(target, replacement);
        
        target = 'COD Amount';
        replacement = 'CODAmount';
        String jsonString15 = jsonString14.replace(target, replacement);
        
        target = 'No Of Attempts';
        replacement = 'NoOfAttempts';
        String jsonString16 = jsonString15.replace(target, replacement);
        
        target = 'Shipper Account';
        replacement = 'ShipperAccount';
        String jsonString17 = jsonString16.replace(target, replacement);
        
        target = 'Origin Address Name';
        replacement = 'OriginAddressName';
        String jsonString18 = jsonString17.replace(target, replacement);
        
        target = 'Shipper Address';
        replacement = 'ShipperAddress';
        String jsonString19 = jsonString18.replace(target, replacement);
        
        target = 'Net weight in Gram';
        replacement = 'NetweightinGram';
        String jsonString20 = jsonString19.replace(target, replacement);
        
        target = 'BVC Service';
        replacement = 'BVCService';
        String jsonString21 = jsonString20.replace(target, replacement);
        
        target = 'Total Invoice Value';
        replacement = 'TotalInvoiceValue';
        String jsonString22 = jsonString21.replace(target, replacement);
        
        target = 'Product Category';
        replacement = 'ProductCategory';
        String jsonString23 = jsonString22.replace(target, replacement);
        
        target = 'Customer Number';
        replacement = 'CustomerNumber';
        String jsonString24 = jsonString23.replace(target, replacement);
        
        target = 'Consignee Phone No';
        replacement = 'ConsigneePhoneNo';
        String jsonString25 = jsonString24.replace(target, replacement);
        
        target = 'Consignee Name';
        replacement = 'ConsigneeName';
        String jsonString26 = jsonString25.replace(target, replacement);
        
        target = 'Consignee Email';
        replacement = 'ConsigneeEmail';
        String jsonString27 = jsonString26.replace(target, replacement);
        
        target = 'Consignee Address';
        replacement = 'ConsigneeAddress';
        String jsonString28 = jsonString27.replace(target, replacement); 
        
        target = 'Gross weight in Gram';
        replacement = 'GrossweightinGram';
        String jsonString29 = jsonString28.replace(target, replacement);
        
        
        return jsonString29;
    }

}