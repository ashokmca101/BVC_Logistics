@RestResource(UrlMapping = '/CreateShipment/*')

global class CreateShipments  
{

    global class CreateShipmentResponse{ 
        String Shipping_Note_Number{get;set;}
        String Status{get;set;}
        String ErrorDetails{get;set;}
        String Message{get;set;}
        String RecordId{get;set;}
        String URL{get;set;}  
    } 

    global class CreateShipmentRequest{
        Date ShipmentDate ;
        String BVC_Service ;
        String Origin_Address_Name ;
        String Origin_Address_Phone ;
        String Origin_Address_Email ;
        String Origin_Address_Person ;
        String Origin_Address_Line1 ;
        String Origin_Address_Line2 ;
        String Origin_Address_Pincode ;
        String Origin_Address_City ; 
        String Origin_Address_State ;
        String Origin_Address_Country ;
        String Shipper_Name ;
        String Shipper_PAN ;
        String Destination_Address_Name ;
        String Destination_Address_Phone ;
        String Destination_Phone_Country_Code ;
        String Destination_Address_Email ;
        String Destination_Address_Person ;
        String Destination_Address_Line1 ;
        String Destination_Address_Line2 ;
        String Destination_Address_Pincode ;
        String Destination_Address_City ;
        String Destination_Address_State ;
        String Destination_Address_Country ;
        String Consignee_Name ;
        String Consignee_PAN ;
        String Billing_Entity_Name ;
        String Billing_Entity_PAN ;
        String Billing_Entity_GST ;
        String Billing_Entity_Address ;
        String Product_Description ;
        String Net_Weight ;
        String Net_Weight_UOM ; 
        String Gross_Weight ;
        String Gross_Weight_UOM ; 
        String Number_of_Packages ;
        Boolean COD ; 
        String COD_Value ;
        String COD_Currency ;
        String COD_Paid_Via ;
        String Insurance ;
        String Shipment_Value_Currency ;
        String Shipment_Value;
        Boolean Exhibition;
        String Exhibition_Name ;
        string Exhibition_type;
        String Billing_Address;
        String Billing_Account;
        String Your_Address_Identifier_Origin;
        String Your_Address_Identifier_Destination;
        
    }


    @HttpPost 
    global static void  Createshipmentinfo()
    {	
        RestRequest request = RestContext.Request;
        RestResponse standardResponse = RestContext.response; 
        try
            {          
                String UniqId = request.requestURI.substring(request.RequestURI.lastIndexOf('/')+1); 
				
                if(UniqId != null && UniqId != ''){
                    list<string> listOfid = UniqId.split(',');
                    
                    Set<String> SetofId = new Set<String>(listOfid);

                    List<Account> lstOfAcnt  = new List<Account>(); 

                    //lstOfAcnt = [Select Id from Account where Customer_Reference__c IN : SetofId];
                    lstOfAcnt = [Select Id,Trade_Name__c from Account where Id IN : SetofId]; 
					
					if(!lstOfAcnt.isEmpty()){
                    
                    String Requestpayload = request.Requestbody.toString(); 
                    
                    system.debug('----'+UniqId); 

					Map<String,Id> MapOfadressvsAcounid = new Map<String,Id>(); 
                    Map<String,Id> MapoforidvsAdrss = new Map<String, Id>();
                    Set<String> setOfpincode = new Set<String>();
                    Set<String> setOfAdrsline1 = new Set<String>();
                    Set<String> setOfcity = new Set<String>(); 
                    
                    Map<String,Id> mapOfpanvsId = new Map<String,Id>(); 
                    set<String> setOfshipperPan = new set<String>();
                    set<String> setOfconsigneePan = new set<String>();
                        
                    //Error Handeling for shipper Name and Consignee Name 
                    set<String> setOfCPan  = new set<String>();
                    set<String> setOfSPan  = new set<String>();    
                        
                    List<Account> lstConsacnt = new list<Account>();
                    List<Account> lstShipAcnt = new list<Account>();    
                    //End    
                        
                    Set<String> setOfName = new Set<String>(); 
                    Map<string,String> mapOfNamevsId = new Map<string,String>();    
                        
                   Set<String> setOfexbitionName = new Set<String>();
                   Map<string,String> mapOfExhibitionvsId = new Map<string,String>();
                        
                   set<String> setOfbilingadsrss = new set<String>();
                   Map<string,String> mapOfbillingNamevsId = new Map<String,String>();
                    
                    set<string> setoffields = new set<string>(); 
                        
                   Map<String,String> mapOfpincode = new Map<String,String>();   
                   List<Account> shipperAccList = new List<Account>();
                     List<Account> consigneeAccList = new List<Account>();
                    If(String.IsNotBlank(Requestpayload)){
                        List<CreateShipmentRequest> requestList1 = (List<CreateShipmentRequest>) JSON.deserialize(Requestpayload, List<CreateShipmentRequest>.class);
                        
                        for(CreateShipmentRequest objvalid : requestList1){
                            if(objvalid.Consignee_PAN != null && objvalid.Consignee_PAN != ''){
                                setOfCPan.add(objvalid.Consignee_PAN);
                            }
                            if(objvalid.Shipper_PAN != null && objvalid.Shipper_PAN != ''){
                                setOfSPan.add(objvalid.Shipper_PAN);
                            }
                        }
                        
                        for(Account objpan : [Select Id,PAN_Number_of_Entity__c  from Account where PAN_Number_of_Entity__c IN :setOfCPan]){
                            lstConsacnt.add(objPan);
                        }
                        
                        for(Account objpan : [Select Id,PAN_Number_of_Entity__c  from Account where PAN_Number_of_Entity__c IN :setOfSPan]){
                            lstShipAcnt.add(objPan);
                        }
                        
                        for(CreateShipmentRequest objvalid : requestList1){
                            if(objvalid.Origin_Address_Name == null){
                                setoffields.add('Origin_Address_Name');
                            }
                            if(objvalid.Destination_Address_Name == null){
                                setoffields.add('Destination_Address_Name');
                            }
                            if(objvalid.Consignee_PAN == null){
                                setoffields.add('Consignee_PAN');
                            }
                            if(objvalid.Shipper_PAN == null){
                                setoffields.add('Shipper_PAN');
                            }
                            if(objvalid.ShipmentDate == null){
                                setoffields.add('ShipmentDate');
                            }
                            if(objvalid.BVC_Service == null){
                                setoffields.add('BVC_Service');
                            }
                            if(objvalid.Origin_Address_Person == null){
                                setoffields.add('Origin_Address_Person');
                            }
                            if(lstShipAcnt.size() == 0){
                                setoffields.add('Shipper_Name');
                            }
                            if(lstConsacnt.size() == 0){
                                setoffields.add('Consignee_Name');
                            }
                             
                            
                            if(objvalid.Destination_Address_Line1 == null){
                                setoffields.add('Destination_Address_Line1');
                            }
                            
                            if(objvalid.Origin_Address_Pincode == null){
                                setoffields.add('Origin_Address_Pincode');
                            }
                            if(objvalid.Origin_Address_City == null){
                                setoffields.add('Origin_Address_City');
                            }
                            if(objvalid.Destination_Address_Pincode == null){
                                setoffields.add('Destination_Address_Pincode');
                            }
                            if(objvalid.Destination_Address_City == null){
                                setoffields.add('Destination_Address_City');
                            }
                            if(objvalid.Billing_Entity_Name == null){
                                setoffields.add('Billing_Entity_Name');
                            }
                            if(objvalid.Product_Description == null){
                                setoffields.add('Product_Description');
                            }
                            if(objvalid.Net_Weight == null){
                                setoffields.add('Net_Weight');
                            }
                            if(objvalid.Net_Weight_UOM == null){
                                setoffields.add('Net_Weight_UOM');
                            }
                            if(objvalid.Insurance == null){
                                setoffields.add('Insurance');
                            }
                            if(objvalid.Shipment_Value_Currency == null){
                                setoffields.add('Shipment_Value_Currency');
                            }
                            if(objvalid.Shipment_Value == null){
                                setoffields.add('Shipment_Value');
                            }
                            if(objvalid.Your_Address_Identifier_Origin == null){
                                setoffields.add('Your_Address_Identifier_Origin');
                            }
                            if(objvalid.Your_Address_Identifier_Destination == null){
                                setoffields.add('Your_Address_Identifier_Destination');
                            }
                            
                         }    
                    }
                    
                    system.debug('setoffields-----'+setoffields);
                        
                        
                    If(setoffields.size() == 0){
                        
                    // Handeling  Origin/Destination Address Logic
                    	
                      system.debug('--Handeling  Origin/Destination Address Logic--');
                        List<CreateShipmentRequest> requestList = (List<CreateShipmentRequest>) JSON.deserialize(Requestpayload, List<CreateShipmentRequest>.class);
                        
                        for(CreateShipmentRequest obj : requestList){

                                if(obj.Origin_Address_Pincode != null && obj.Origin_Address_Pincode != ''){
                                    setOfpincode.add(obj.Origin_Address_Pincode);
                                }
                                
                                if(obj.Origin_Address_Line1 != null && obj.Origin_Address_Line1 != ''){
                                    setOfAdrsline1.add(obj.Origin_Address_Line1);
                                }
                                
                                if(obj.Origin_Address_City != null && obj.Origin_Address_City != ''){
                                    setOfcity.add(obj.Origin_Address_City);
                                }
                                if(obj.Destination_Address_Pincode != null && obj.Destination_Address_Pincode != ''){
                                    setOfpincode.add(obj.Destination_Address_Pincode);
                                }
                                
                                if(obj.Destination_Address_Line1 != null && obj.Destination_Address_Line1 != ''){
                                    setOfAdrsline1.add(obj.Destination_Address_Line1);
                                }
                                if(obj.Destination_Address_City != null && obj.Destination_Address_City != ''){
                                    setOfcity.add(obj.Destination_Address_City);
                                }
                            
                            	if(obj.Shipper_PAN != null && obj.Shipper_PAN != ''){
                                	setOfshipperPan.add(obj.Shipper_PAN);
                                }
                                  
                                if(obj.Consignee_PAN != null && obj.Consignee_PAN != ''){
                                	setOfconsigneePan.add(obj.Consignee_PAN);
                                }
                            
                            	if(obj.Billing_Entity_Name != null && obj.Billing_Entity_Name != ''){
                                	setOfName.add(obj.Billing_Entity_Name);
                                }
                            
                                if(obj.Exhibition_Name != null && obj.Exhibition_Name != ''){
                                	setOfexbitionName.add(obj.Exhibition_Name);
                                }
                                
                                if(obj.Billing_Address != null && obj.Billing_Address != ''){
                                	setOfbilingadsrss.add(obj.Billing_Address);
                                }
                             
                        }   
                       
                      // Logic for Billing Address    
                     if(!setOfbilingadsrss.IsEmpty()){
                        for(AddressBook__c objAb : [Select  Name from AddressBook__c where Name IN :setOfbilingadsrss]){
                            mapOfbillingNamevsId.put(objAb.Name,objAb.Id);
                        }
                    }                        
                        
                    // Logic for Billing Entity 
                    if(!setOfName.IsEmpty()){
                        for(blng__LegalEntity__c objl : [Select Id , Name from blng__LegalEntity__c where Name IN :setOfName]){
                            mapOfNamevsId.put(objl.Name,objl.Id);
                        }
                    }
                        
                    // Logic for Exhibition name
                    if(!setOfexbitionName.IsEmpty()){
                        for(ST_Exhibition__c objl : [Select Id , Name from ST_Exhibition__c where Name IN :setOfexbitionName]){
                            mapOfExhibitionvsId.put(objl.Name,objl.Id);
                        }
                    }
                    
                    List<ST_Exhibition__c> listexhib = new List<ST_Exhibition__c>();
                        for(CreateShipmentRequest obj : requestList){
                            if(!mapOfExhibitionvsId.containsKey(obj.Exhibition_Name)){
                                ST_Exhibition__c obj1 = new ST_Exhibition__c();
                                obj1.Name = obj.Exhibition_Name; 
                                listexhib.add(obj1);
                            }
                        }    
                        
                        if(listexhib.size()>0){
                            insert listexhib;
                            for(ST_Exhibition__c objexhib : listexhib){
                                mapOfExhibitionvsId.put(objexhib.Name , objexhib.Id);
                            }
                        }
                        
                  Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();

                    if(!setOfshipperPan.Isempty() && !setOfconsigneePan.Isempty()){
                        for(Account Objacnt : [SELECT RecordType.Name, PAN_Number_of_Entity__c, Id FROM Account
                                                WHERE PAN_Number_of_Entity__c IN:setOfshipperPan AND RecordTypeId =: devRecordTypeId]){
                            mapOfpanvsId.put(Objacnt.PAN_Number_of_Entity__c,Objacnt.Id);
                            shipperAccList.add(Objacnt);
                            system.debug('shipperAccList ==== '+shipperAccList);
                        }
                        
                        for(Account Objacnt : [SELECT RecordType.Name, PAN_Number_of_Entity__c, Id FROM Account
                                                WHERE PAN_Number_of_Entity__c IN:setOfconsigneePan AND RecordTypeId =: devRecordTypeId]){
                            mapOfpanvsId.put(Objacnt.PAN_Number_of_Entity__c,Objacnt.Id);
                            consigneeAccList.add(Objacnt);
                        }
                    }
                        
                        
                   /*Creating New Shipper/Consignee Account and putting into map*/ 
                         List<Account> listAcnts = new List<Account>();
                        for(CreateShipmentRequest obj : requestList){
                            if(!mapOfpanvsId.containsKey(obj.Shipper_PAN)){
                                Account obj1 = new Account();
                                obj1.Name = obj.Shipper_Name; 
                                obj1.RecordTypeId = devRecordTypeId;
                                obj1.First_Name__c = obj.Shipper_Name;
                                obj1.Last_Name__c = obj.Shipper_Name;  
                                obj1.PAN_Number_of_Entity__c = obj.Shipper_PAN;
                                obj1.Name_As_Per_PAN_Manual_Input__c = obj.Shipper_Name;
                                obj1.Email__c = 'test@gmail.com';
                                obj1.Mobile__c = '9999999999';
                                listAcnts.add(obj1);
                            }
                        
                        	if(!mapOfpanvsId.containsKey(obj.Consignee_PAN)){
                                Account obj2 = new Account();
                                obj2.Name = obj.Consignee_Name ; 
                                obj2.RecordTypeId = devRecordTypeId;
                                obj2.First_Name__c = obj.Consignee_Name;
                                obj2.Last_Name__c = obj.Consignee_Name;  
                                obj2.PAN_Number_of_Entity__c = obj.Consignee_PAN;
                                obj2.Name_As_Per_PAN_Manual_Input__c = obj.Consignee_Name;
                                obj2.Email__c = 'test@gmail.com';
                                obj2.Mobile__c = '9999999999';
                                listAcnts.add(obj2);
                            }
                        }
                        
                        
                        if(listAcnts.size()>0){
                            System.debug('---------before insert---------');
                            Insert listAcnts ;
                            System.debug('------------------'+listAcnts);
                            for(Account obhjacnt : listAcnts){
                                mapOfpanvsId.put(obhjacnt.PAN_Number_of_Entity__c , obhjacnt.Id);
                            }
                        }
                        
                         //Prepare map for Adress with Adress ID
                         system.debug('setOfpincode=== '+setOfpincode);
                        system.debug('setOfAdrsline1=== '+setOfAdrsline1);
                        system.debug('setOfcity ===='+setOfcity);
                    if(!setOfpincode.Isempty() && !setOfAdrsline1.Isempty() && !setOfcity.Isempty() ){
                        system.debug('enter in map logic for Address creation');
                        for(AddressBook__c objAb : [Select Id ,PINCODE__c ,Active_Pincode__c,Active_Pincode__r.Name,ADDRESS1__c,ADDRESS2__c,CITY__c, Name ,Customer__c from AddressBook__c 
                                                    where Active_Pincode__r.Name IN:setOfpincode AND ADDRESS1__c IN:setOfAdrsline1
                                                    AND CITY__c IN : setOfcity]){

                            String finaltxt='';   
                            if(objAb.Active_Pincode__c != null){
                                    finaltxt+= objAb.Active_Pincode__r.Name;
                                    finaltxt+=',';
                            }
                            if(objAb.ADDRESS1__c != null && objAb.ADDRESS1__c != ''){
                                finaltxt+= objAb.ADDRESS1__c;
                                finaltxt+=',';
                                
                            }
                            
                            if(objAb.ADDRESS2__c != null && objAb.ADDRESS2__c != ''){
                                finaltxt+= objAb.ADDRESS2__c;
                                finaltxt+=',';
                            }else{
                                 finaltxt+=' ,';
                            }
                            
                            if(objAb.CITY__c != null && objAb.CITY__c != ''){
                                finaltxt+= objAb.CITY__c;
                            } 
                                       
                                                        
                            MapoforidvsAdrss.put(finaltxt,objAb.Id);
                            system.debug('MapoforidvsAdrss---'+MapoforidvsAdrss);
                            MapOfadressvsAcounid.put(finaltxt,objAb.Customer__c); 
                            system.debug('==== MapOfadressvsAcounid==== '+MapOfadressvsAcounid);                            
                        }
                        
                    }
                        
                        
                    for(Active_Pincode__c objcode : [Select Id , Name from Active_Pincode__c where Name IN : setOfpincode]){
                            mapOfpincode.put(objcode.Name,objcode.Id);
                    }    
                        
                    List<AddressBook__c> newAddrs = new List<AddressBook__c>();
                    Id devRecordadrss = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
                        
                    for(CreateShipmentRequest obj : requestList){
                        String line1 = '';
                        String line2 = '';
                        if(!MapoforidvsAdrss.containsKey(obj.Origin_Address_Name)){
                            System.debug('=====Entered in Address Creation Origin=====');
                        	AddressBook__c objnew = new AddressBook__c();
                            objnew.Is_Active__c = true ;
                            objnew.RecordTypeId = devRecordadrss; 
                           // if(obj.Origin_Address_Line1.length() >= 40){
                            //     line1  = obj.Origin_Address_Line1.left(40);
                            ///}
                            // line1  =  obj.Origin_Address_Line1 != null ? obj.Origin_Address_Line1.left(40):' ';
                            objnew.ADDRESS1__c =obj.Origin_Address_Line1; 
                          
                             //line2  =  obj.Origin_Address_Line1.substring(40,obj.Origin_Address_Line1.length());
                           
                            //line2  =  obj.Origin_Address_Line1 != null ? obj.Origin_Address_Line1.substring(40,obj.Origin_Address_Line2.length()):' ';
                            //objnew.ADDRESS2__c =  line2 +' '+obj.Origin_Address_Line2;
                            objnew.ADDRESS2__c = obj.Origin_Address_Line2; 
                            //objnew.Customer__c = lstOfAcnt[0].Id != null ?lstOfAcnt[0].Id :null ;
                            objnew.Customer__c = shipperAccList[0].Id != null ? shipperAccList[0].Id : null;
                            objnew.TRADE_NAME__c = lstOfAcnt[0].Trade_Name__c != null ? lstOfAcnt[0].Trade_Name__c: ' ';
                            objnew.Source__c = 'API';
                            objnew.Active_Pincode__c = mapOfpincode.get(obj.Origin_Address_Pincode);
                            objnew.MOBILE1__c = obj.Origin_Address_Phone;
                            objnew.EMAIL_ID__c = obj.Origin_Address_Email; 
                            objnew.Your_Address_Identifier__c = obj.Your_Address_Identifier_Origin;
                            objnew.CITY__c = obj.Origin_Address_City;
                            //objnew.Name = objnew.Active_Pincode__r.Name +','+ objnew.ADDRESS1__c +','+' ,'+objnew.CITY__c;
                            if(obj.Origin_Address_Line2 != null && obj.Origin_Address_Line2 != ''){
                            objnew.Name = obj.Origin_Address_Pincode+','+ obj.Origin_Address_Line1 +','+ obj.Origin_Address_Line2 +','+obj.Origin_Address_City;
                            }else{
                                objnew.Name = obj.Origin_Address_Pincode+','+ obj.Origin_Address_Line1 +','+' ,'+obj.Origin_Address_City;
                            }
                            
                            system.debug('Address Name== '+objnew.Name);
                            newAddrs.add(objnew);
                        } 
                       if(!MapoforidvsAdrss.containsKey(obj.Destination_Address_Name)){
                            String dline1 = '';
                            String dline2 = '';
                        	AddressBook__c objnew1 = new AddressBook__c();
                            objnew1.Is_Active__c = true ;
                            objnew1.RecordTypeId = devRecordadrss;
                            //if(obj.Origin_Address_Line1.length() >= 40){
                                //dline1  =   obj.Origin_Address_Line1.left(40);
                            //}
                             // dline1  =  obj.Origin_Address_Line1 != null ? obj.Origin_Address_Line1.left(40):' ';
                            objnew1.ADDRESS1__c = obj.Destination_Address_Line1; 
                           
                             //   dline2  =  obj.Origin_Address_Line1.substring(40,obj.Origin_Address_Line1.length());
                            
                            // dline2  =  obj.Origin_Address_Line1 != null ? obj.Origin_Address_Line1.substring(40,obj.Origin_Address_Line2.length()):' ';
                            //objnew1.ADDRESS2__c = line2 +' '+obj.Origin_Address_Line2; 
                            objnew1.ADDRESS2__c = obj.Destination_Address_Line2; 
                            //objnew1.Customer__c = lstOfAcnt[0].Id != null ? lstOfAcnt[0].Id : null; 
                            objnew1.Customer__c = consigneeAccList[0].Id != null ? consigneeAccList[0].Id : null;
                            objnew1.TRADE_NAME__c = lstOfAcnt[0].Trade_Name__c != null ?lstOfAcnt[0].Trade_Name__c : ' ' ; 
                            objnew1.Active_Pincode__c = mapOfpincode.get(obj.Destination_Address_Pincode);
                            objnew1.Source__c = 'API'; 
                            objnew1.MOBILE1__c = obj.Origin_Address_Phone;
                            objnew1.EMAIL_ID__c = obj.Origin_Address_Email; 
                            objnew1.Your_Address_Identifier__c = obj.Your_Address_Identifier_Destination;
                            if(obj.Destination_Address_Line2 != null && obj.Destination_Address_Line2 != ''){
                               objnew1.Name = obj.Destination_Address_Pincode+','+ obj.Destination_Address_Line1 +','+obj.Destination_Address_Line2+','+obj.Destination_Address_City;
                            }else{ 
                                objnew1.Name = obj.Destination_Address_Pincode+','+ obj.Destination_Address_Line1 +','+' ,'+obj.Destination_Address_City;}
                           

                            newAddrs.add(objnew1);
                        }
                    }
                        
                    if(newAddrs.size()>0){
                    	Insert newAddrs;
                    	//Database.insert(newAddrs,false);
                        system.debug('=== newAddrs ===='+newAddrs);
                        system.debug('=== newAddrs ===='+newAddrs.size());
                        system.debug('First =='+newAddrs[0].Name);
                         system.debug('Second =='+newAddrs[1].Name);
                        
                        system.debug('First =='+newAddrs[0].Customer__c);
                         system.debug('Second =='+newAddrs[1].Customer__c);
                        for(AddressBook__c obj : newAddrs){
                            system.debug('Address Id =='+obj.Id);
                         
                            if(obj.Name != null && obj.Name != '' && obj.Customer__c != null){
                                MapoforidvsAdrss.put(obj.Name,obj.Id);
                                MapOfadressvsAcounid.put(obj.Name,obj.Customer__c);
                                system.debug('MapoforidvsAdrss'+MapoforidvsAdrss);
                                system.debug('MapOfadressvsAcounid'+MapOfadressvsAcounid);
                            }  
                        }
                    }
                        
                        system.debug('creating Shipment');
            
                        List<Shipment__c> newList = new List<Shipment__c>();
                        
                        for(CreateShipmentRequest obj : requestList){
                            Shipment__c objship = new Shipment__c();

                            if(!lstOfAcnt.Isempty()){
                                objship.Customer__c = lstOfAcnt[0].Id ;  
                            }
                            
                            objship.Shipment_Created_Through__c = 'API' ;
                            objship.API_or_Excel__c = true;
                            if(obj.ShipmentDate != null){
                                objship.Shipment_Date__c = obj.ShipmentDate ;
                                system.debug('obj.ShipmentDate'+obj.ShipmentDate);
                            }
                            
                            
                            if(obj.BVC_Service != null && obj.BVC_Service != ''){
                                objship.Customer_Product_Category__c = obj.BVC_Service ;
                                system.debug('obj.BVC_Service'+obj.BVC_Service);
                            }
                            
                            if(mapOfpanvsId.containsKey(obj.Shipper_PAN)){
                                objship.Shipper_Name_TMS__c = mapOfpanvsId.get(obj.Shipper_PAN) ;
                                system.debug('---mapOfpanvsId.get(obj.Shipper_PAN)----'+mapOfpanvsId.get(obj.Shipper_PAN));
                            }
                            
                             if(obj.Shipper_PAN != null && obj.Shipper_PAN != ''){
                                objship.Shipper_PAN__c = obj.Shipper_PAN ;
                                system.debug('obj.Shipper_PAN'+obj.Shipper_PAN);
                            }
                            
                            
                             if(mapOfpanvsId.containsKey(obj.Consignee_PAN)){
                                objship.Consignee_Name_TMS__c = mapOfpanvsId.get(obj.Consignee_PAN);
                                system.debug('mapOfpanvsId.get(obj.Consignee_PAN)'+mapOfpanvsId.get(obj.Consignee_PAN));
                            }
                            
                            if(obj.Consignee_PAN != null && obj.Consignee_PAN != '' ){
                                objship.Consignee_PAN__c  = obj.Consignee_PAN ;
                                system.debug('obj.Consignee_PAN'+obj.Consignee_PAN);
                            }
                            system.debug('===== Map of Address ===='+MapoforidvsAdrss.containsKey(obj.Origin_Address_Name));
                            system.debug('==== Shipper Pan=====+'+mapOfpanvsId.get(obj.Shipper_PAN));
                            system.debug('===== Map shipper pan ===='+MapOfadressvsAcounid.get(obj.Origin_Address_Name));
                            system.debug('obj.Origin_Address_Name---'+obj.Origin_Address_Name);
                            if(MapoforidvsAdrss.containsKey(obj.Origin_Address_Name) && mapOfpanvsId.get(obj.Shipper_PAN) == MapOfadressvsAcounid.get(obj.Origin_Address_Name)){
                             //if(MapoforidvsAdrss.containsKey(obj.Origin_Address_Name)){
                                objship.Origin_Address_Name__c = MapoforidvsAdrss.get(obj.Origin_Address_Name) ;
                                system.debug('MapoforidvsAdrss------'+MapoforidvsAdrss.get(obj.Origin_Address_Name));
                            }
                            
                          
                            if(obj.Origin_Address_Person != null){
                                objship.Origin_Address_Contact_Name__c = obj.Origin_Address_Person ;
                                system.debug('obj.Origin_Address_Person'+obj.Origin_Address_Person); 
                            }
                            
                           
                            
                            system.debug('obj.Destination_Address_Name---'+obj.Destination_Address_Name);
                            if(MapoforidvsAdrss.containsKey(obj.Destination_Address_Name) && mapOfpanvsId.get(obj.Consignee_PAN) == MapOfadressvsAcounid.get(obj.Destination_Address_Name)){
                                
                                objship.Destination_Address_Name__c = MapoforidvsAdrss.get(obj.Destination_Address_Name);
                                 system.debug('MapoforidvsAdrss------'+MapoforidvsAdrss.get(obj.Destination_Address_Name));
                            }
                            
                            if(mapOfbillingNamevsId.containsKey(obj.Billing_Address)){
                                
                                objship.Billing_Address__c = mapOfbillingNamevsId.get(obj.Billing_Address);
                                 //system.debug('MapoforidvsAdrss------'+MapoforidvsAdrss.get(obj.Destination_Address_Name));
                            }
                            
                            
                           
                            

                            
                            if(mapOfNamevsId.containsKey(obj.Billing_Entity_Name)){
                                objship.Billing_Entity_Name_TMS__c = mapOfNamevsId.get(obj.Billing_Entity_Name) ;
                            }
                            
                            
                            
                            if(obj.Product_Description != null && obj.Product_Description != ''){
                                objship.Product_Description__c = obj.Product_Description ;
                                system.debug('obj.Product_Description'+obj.Product_Description);
                            }
                            
                            if(obj.Exhibition_type != null && obj.Exhibition_type != ''){
                                objship.Exhibition_Movement_Type__c = obj.Exhibition_type ;
                            }
                            
                            if(mapOfExhibitionvsId.containsKey(obj.Exhibition_Name)){
                               objship.Exhibition__c = mapOfExhibitionvsId.get(obj.Exhibition_Name) ; 
                            }
                            
                            if(obj.Net_Weight != null && obj.Net_Weight != ''){
                                objship.Net_Weight__c = Decimal.valueof(obj.Net_Weight) ;
                                system.debug('obj.Net_Weight__c'+obj.Net_Weight);
                            }
                            
                            if(obj.Net_Weight_UOM != null && obj.Net_Weight_UOM != '' ){
                                objship.Net_Weight_UOM__c = obj.Net_Weight_UOM ;
                                system.debug('obj.Net_Weight_UOM'+obj.Net_Weight_UOM);
                            }
                            
                            if(obj.Gross_Weight != null && obj.Gross_Weight != ''){
                                objship.Gross_Weight__c = Decimal.valueof(obj.Gross_Weight) ;
                                 system.debug('obj.Gross_Weight'+obj.Gross_Weight);
                            }
                            
                            if(obj.Gross_Weight_UOM != null && obj.Gross_Weight_UOM != ''){
                                objship.Gross_Weight_UOM__c = obj.Gross_Weight_UOM ;
                                system.debug('obj.Gross_Weight'+obj.Gross_Weight_UOM);
                            }
                            
                            if(obj.Number_of_Packages != null && obj.Number_of_Packages != ''){
                                objship.Number_of_Packages__c = Decimal.valueOf(obj.Number_of_Packages) ;
                                system.debug('obj.Number_of_Packages'+obj.Number_of_Packages);
                            }
                            
                            if(obj.COD != null){
                                objship.COD__c = obj.COD ;
                                system.debug('obj.COD'+obj.COD);
                            }
                            
                            
                            if(obj.COD_Value != null && obj.COD_Value != '' ){
                                objship.COD_Value__c = Decimal.valueof(obj.COD_Value) ;
                                system.debug('obj.COD_Value'+obj.COD_Value);
                            }
                            
                            if(obj.COD_Currency != null && obj.COD_Currency != ''){
                                objship.COD_Currency__c = obj.COD_Currency ;
                                system.debug('obj.COD_Currency'+obj.COD_Currency);
                            }
                            
                            if(obj.COD_Paid_Via != null && obj.COD_Paid_Via != ''){
                                objship.COD_Paid_Via__c = obj.COD_Paid_Via ;
                                system.debug('obj.COD_Paid_Via'+obj.COD_Paid_Via);
                            }
                            
                            if(obj.Insurance != null && obj.Insurance != ''){
                                objship.Insurance_By__c = obj.Insurance ;
                                system.debug('obj.Insurance'+obj.Insurance);
                            }
                            
                            if(obj.Shipment_Value_Currency != null && obj.Shipment_Value_Currency != ''){
                                objship.Shipment_Value_Currency__c = obj.Shipment_Value_Currency ;
                                system.debug('obj.Shipment_Value_Currency'+obj.Shipment_Value_Currency);
                            }
                            
                            if(obj.Shipment_Value != null && obj.Shipment_Value != ''){
                                objship.Shipment_Value__c = Decimal.valueOf(obj.Shipment_Value) ;
                               // system.debug('obj.Shipment_Value_Currency'+obj.Shipment_Value_Currency);
                            }
                            
                            if(obj.Exhibition != null){
                                objship.IsExhibition__c = obj.Exhibition ;
                                //system.debug('obj.Shipment_Value_Currency'+obj.Shipment_Value_Currency);
                            }
                            
                            if(obj.Exhibition_Name != null){
                                objship.Exhibition_Name__c = obj.Exhibition_Name ;
                                //system.debug('obj.Shipment_Value_Currency'+obj.Shipment_Value_Currency);
                            }
                            
                            //objship.Billing_Account = lstOfAcnt[0].Id;
                            
                            newList.add(objship);
                            system.debug('obj.newList------------'+newList);  
                        }
                        if(newList != null && !newList.isEmpty()){ 
                            Database.Insert(newList);
                            system.debug('----------'+newList.size());
                            set<Id> shipmentRecords = new set<Id>();
                            
                            for(Shipment__c objshipment : newList){
                                system.debug('----objshipment-----'+objshipment.Id);
                                shipmentRecords.add(objshipment.Id);
                            }
 
                            system.debug('newList-----------'+newList.size());  
                            list<CreateShipmentResponse> listResponse = new list<CreateShipmentResponse>();
                            for(Shipment__c objshipp : [Select id,Status__c,Billing_Account__r.Name,Billing_Address__r.Name,Consignee_Name_TMS__r.Name,Billing_Account__c,Billing_Address__c,Origin_Address_Phone__c,Origin_Address_Line_1__c,Origin_Address_Line_2__c,
                                                        Consignee_Name_TMS__c,Origin_Address_Pincode__c,Origin_Address_City__c,Destination_Address_Line1__c,Destination_Address_Line_2__c,Destination_Address_Pincode__c,
                                                        Destination_Address_City__c,Destination_Address_State__c,Destination_Address_Country__c,Shipment_Value__c,Exhibition__c,Exhibition_Name__c,
                                                        Origin_Address_State__c,Origin_Address_Country__c,Pdf_Url__c,Shipping_Note_Number__c from Shipment__c where Id IN:shipmentRecords]){
                                CreateShipmentResponse objresp = new CreateShipmentResponse();
                                system.debug('---------objshipp.Shipping_Note_Number__c'+objshipp.Shipping_Note_Number__c);
                                system.debug('---------objshipp.Status__c'+objshipp.Status__c);
                                objresp.Shipping_Note_Number = objshipp.Shipping_Note_Number__c;
                                                          
                                objresp.Shipping_Note_Number = objshipp.Shipping_Note_Number__c;                            
                                objresp.RecordId = objshipp.Id;
                                objresp.Status = objshipp.Status__c;
                                objresp.URL = objshipp.Pdf_Url__c;
                                listResponse.add(objresp);
                            }
                            
                            standardResponse.addHeader('Content-Type', 'application/json');         
                            standardResponse.statusCode = 200;
                            standardResponse.responseBody = blob.valueOf(JSON.serializePretty(listResponse)) ;
                        }
                     
                    }
                    else{
                        List<CreateShipmentRequest> requestList1 = (List<CreateShipmentRequest>) JSON.deserialize(Requestpayload, List<CreateShipmentRequest>.class);
                        string Error;
                        for(CreateShipmentRequest objvalid : requestList1){
                             Error = '';
                            if(objvalid.Origin_Address_Name == null){
                                Error+= 'Origin_Address_Name';
                                Error+=',';
                            }
                            if(objvalid.Destination_Address_Name == null){
                                Error+= 'Destination_Address_Name';
                                Error+=',';
                            }
                            if(objvalid.Consignee_PAN == null){
                                Error+= 'Consignee_PAN';
                                Error+=',';
                            }
                            if(objvalid.Shipper_PAN == null){
                                Error+= 'Shipper_PAN';
                                Error+=',';
                            }
                            if(objvalid.ShipmentDate == null){
                                Error+='ShipmentDate';
                                Error+=',';
                            }
                            if(objvalid.BVC_Service == null){
                                Error+='BVC_Service';
                                Error+=',';
                            }
                            if(objvalid.Origin_Address_Person == null){
                                Error+='Origin_Address_Person';
                                Error+=',';
                            }
                             if(objvalid.Destination_Address_Line1 == null){
                                Error+='Destination_Address_Line1';
                                Error+=',';
                             }
                            if(objvalid.Origin_Address_Pincode == null){
                                Error+='Origin_Address_Pincode';
                                Error+=',';
                            }
                            if(objvalid.Origin_Address_City == null){
                                Error+='Origin_Address_City';
                                Error+=',';
                            }
                            if(objvalid.Destination_Address_Pincode == null){
                                Error+='Destination_Address_Pincode';
                                Error+=',';
                            }
                            if(objvalid.Destination_Address_City == null){
                                Error+='Destination_Address_City';
                                Error+=',';
                            }
                            if(objvalid.Billing_Entity_Name == null){
                                Error+='Billing_Entity_Name';
                                Error+=',';
                            }
                            if(objvalid.Shipper_Name == null){
                                Error+='Shipper_Name';
                                Error+=',';
                            }
                            if(objvalid.Consignee_Name == null){
                                Error+='Consignee_Name';
                                Error+=',';
                            }
                          
                            if(objvalid.Product_Description == null){
                                Error+='Product_Description';
                                Error+=',';
                            }
                            if(objvalid.Net_Weight == null){
                                Error+='Net_Weight';
                                Error+=',';
                            }
                            if(objvalid.Net_Weight_UOM == null){
                                Error+='Net_Weight_UOM';
                                Error+=',';
                            }
                            if(objvalid.Insurance == null){
                                Error+='Insurance';
                                Error+=',';
                            }
                            if(objvalid.Shipment_Value_Currency == null){
                               Error+='Shipment_Value_Currency';
                            }
                            if(objvalid.Shipment_Value == null){
                               Error+='Shipment_Value';
                            }
                        }
                        ErrorResponse(standardResponse ,Error);
                    }
					}else{
						ErrorResponse(standardResponse ,' Wrong Reference Number');
					}
                }
                else{
                    ErrorResponse(standardResponse ,'Reference Number');
                }      
            } 

        catch(dmlexception e){
            // If DML failed, ends up here.
            system.debug('--dmlexception---'+e.getLineNumber());
            system.debug('--dmlexception---'+e.getMessage());
            standardResponse.addHeader('Content-Type', 'application/json');         
            standardResponse.statusCode = 404;
            standardResponse.responseBody = blob.valueOf('"Error" :'+ e.getMessage());
        }
    }    

    global static void ErrorResponse( RestResponse standardResponse , String param){
        system.debug('Error method called'+param);
            standardResponse.addHeader('Content-Type', 'application/json');         
            standardResponse.statusCode = 404;
            standardResponse.responseBody = blob.valueOf('"Error": "' +param+ ' Not Found"');
    }
}