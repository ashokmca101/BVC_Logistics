public class StichProfileAPIResponseClass {
    
    public static APICallStatus updateResponseMethod(String getResponse, Id accountId, String pan_number) {
        
        System.debug('=====  StichProfileAPIResponseClass ---->updateResponseMethod ');
        Account customerHasAddress = [SELECT Id,name,HasAddress__c FROM Account WHERE Id =:accountId LIMIT 1];
        Map < String, Active_Pincode__c > pincodeMap = new Map < String, Active_Pincode__c > ();
        pincodeMap = Utility.getActivePinCode(); //get all active pincode from utility class.
        KYCPanVerificationResponseWrapper wrap = KYCPanVerificationResponseWrapper.parse(getResponse); 
        
        APICallStatus apistatus = new APICallStatus();
        apistatus.status = 'SUCCESS';
        
        apistatus.entityId = wrap.result.profile.entityId;
        Account customerRecObj = new Account(Id = accountId);
        String entityId = wrap.result.profile.entityId;
        if (entityId != null) {
            customerRecObj.Entity_Id__c = entityId;
        }
        
        boolean firstAddress = false;
        System.debug('=====  firstAddress ---->updateResponseMethod ' + firstAddress);
        Account lstAcc = [SELECT Name_As_Per_PAN_Manual_Input__c FROM Account WHERE id =: accountId LIMIT 1]; //SOQL to fetch name as per PAN from Account
        String nameAsPerPan = String.valueOf(lstAcc.Name_As_Per_PAN_Manual_Input__c);
        String tradeName; //varriable to assign trade name to address.
        
        List < AddressBook__c > lstAddrOfGST = new List < AddressBook__c > (); //List to insert Address of GST.
        List < AddressBook__c > lstAddrOfBranch = new List < AddressBook__c > (); //List to insert Address of Branch.
        Set < Account > setAccountToUpdate = new Set < Account > ();
        List < Account > listAccountToUpdateAddr = new List < Account > ();
        
        if (wrap.result.profile.type == 'INDIVIDUAL') {
            customerRecObj.Form_Of_Organization__c = 'Individual';
        } else if (wrap.result.profile.type == 'COMPANY') {
            customerRecObj.Form_Of_Organization__c = 'Company';
        } else if (wrap.result.profile.type == 'Partnership Firm') {
            customerRecObj.Form_Of_Organization__c = 'Partnership Firm';
        } else if (wrap.result.profile.type == 'Trust/Foundation') {
            customerRecObj.Form_Of_Organization__c = 'Trust/Foundation';
        }
        
        RecordType billingRecType = [select Id,Name from RecordType where sObjectType='AddressBook__c' AND Name='Billing'];
        RecordType shippingRecType = [select Id,Name from RecordType where sObjectType='AddressBook__c' AND Name='Shipping'];
        List < KYCPanVerificationResponseWrapper.GST > gstdetails = wrap.result.statutoryRegistration.gst;
        System.debug('=====  gstdetails ---->updateResponseMethod ' + gstdetails.Size());
        if (gstdetails.Size() > 0) {
            for (KYCPanVerificationResponseWrapper.GST listGST: wrap.result.statutoryRegistration.gst) {
                
                string dealerType = listGST.dealerType;
                string gstin = listGST.gstin;
                System.debug('=====  pan_number ---->updateResponseMethod ' +pan_number);
                if (gstin.contains(pan_number)) { //Check whether the GSTIN contains PAN number. 
                    
                    if (!(customerRecObj.GST_Registered__c)) {
                        customerRecObj.GST_Registered__c = true; 
                    }
                    
                    if ((listGST.tradeName) == null) { //Check whether the Trade Name is null.
                        tradeName = nameAsPerPan; //If Trade Name is null then assign Name as per PAN to Trade Name.
                    } else { 
                        tradeName = listGST.tradeName; //If Trade Name is not null then assign Trade Name from GST to tradeName.
                    } 
                    
                    String addressOfGST; //varriable to store address from GST.
                    String addrWithoutPincodeOfGST; //varriable to store address without Pincode.
                    String pincodeOfGST; //varriable to store Pincode.
                    String addressLine2; //varriable to store addressLine2.
                    
                    System.debug('=====  listGST.address ---->updateResponseMethod ' + listGST.address);
                    if ((listGST.address) != null) { //Check whether the address is not null.
                        addressOfGST = listGST.address;
                        addrWithoutPincodeOfGST = addressOfGST.Substring(0, addressOfGST.length() - 8); //remove Pincode from Address.
                        
                        if (addrWithoutPincodeOfGST.length() > 40) { //Check whether the address length is more than 40 characters.
                            addressLine2 = addrWithoutPincodeOfGST.Substring(40, addrWithoutPincodeOfGST.length()); //If address length is more than 40 characters then store the string from 255 character onwards into addressLine2.
                        }
                        
                        pincodeOfGST = addressOfGST.right(6); //getting Pincode from Address.
                        
                        //Only first Address is the Primary Address.
                        AddressBook__c objAddrOfGST = new AddressBook__c();
                        objAddrOfGST.Detail_Address__c = addressOfGST;
                        objAddrOfGST.RecordTypeId =  billingRecType.Id;
                        objAddrOfGST.GSTIN__c = gstin;
                        //objAddrOfGST.MOBILE1__c = listGST.SignatoriesContact[0].contact;
                        objAddrOfGST.EMAIL_ID__c = listGST.email;
                        objAddrOfGST.ADDRESS1__c = addrWithoutPincodeOfGST.left(40);
                        objAddrOfGST.ADDRESS2__c = addressLine2;
                        objAddrOfGST.PINCODE__c = pincodeOfGST;
                        objAddrOfGST.Dealer_Type__c = dealerType;
                        objAddrOfGST.Is_Billing_Address__c = true;
                        objAddrOfGST.Customer__c = accountId;
                        objAddrOfGST.TRADE_NAME__c = tradeName;
                        objAddrOfGST.Source__c = 'KARZAA';
                        
                        System.debug('=====  pincodeOfGS ---->updateResponseMethod ' +pincodeOfGST);
                        System.debug('===== pincodeMap ======='+pincodeMap.keySet());
                        if (pincodeMap.containsKey(pincodeOfGST)) {
                            Active_Pincode__c objPincode = pincodeMap.get(pincodeOfGST);
                            objAddrOfGST.CITY__c = objPincode.CITY__c;
                            objAddrOfGST.District__c = objPincode.CITY__c;
                            objAddrOfGST.STATE__c = objPincode.State__c;
                            objAddrOfGST.COUNTRY__c = objPincode.Country__c;
                            
                            System.debug('=====  firstAddress ---->updateResponseMethod ' +firstAddress);
                            if (!firstAddress) {
                                objAddrOfGST.Is_Primary__c = true;
                                customerRecObj.Is_Primary_Address_Present__c =true;
                                customerRecObj.Is_Billing_Address_Present__c = true;
                                customerRecObj.BillingCountry = objPincode.Country__c;
                                customerRecObj.BillingState = objPincode.State__c;
                                customerRecObj.BillingStreet = addrWithoutPincodeOfGST;
                                customerRecObj.GSTIN__c =  gstin;
                                customerRecObj.Trade_Name__c = tradeName;
                                if (addressLine2 != null) {
                                    customerRecObj.BillingStreet = ' ' + addressLine2;
                                }
                                customerRecObj.BillingCity = objPincode.CITY__c;
                                customerRecObj.BillingPostalCode = pincodeOfGST;
                            }
                            
                            firstAddress = true;
                        }
                        if(!lstAddrOfGST.contains(objAddrOfGST)){
                            lstAddrOfGST.add(objAddrOfGST);
                        }
                                                
                    }
                    
                    for (KYCPanVerificationResponseWrapper.Branches listBranches: listGST.branches) {
                        
                        String address = listBranches.address;
                        String addrWithoutPincode = address.Substring(0, address.length() - 8);
                        
                        String addressLine2Inner;
                        if (addrWithoutPincode.length() > 40) {
                            addressLine2Inner = addrWithoutPincode.Substring(40, addrWithoutPincode.length()); 
                        } 
                        String pincodeOfBranch = address.right(6); 
                        
                        AddressBook__c objAddr = new AddressBook__c();
                        objAddr.Detail_Address__c = address;
                        objAddr.RecordTypeId = shippingRecType.Id;                        
                        objAddr.GSTIN__c = gstin;
                        
                        if(gstin != null || gstin !='') {
                            objAddr.Is_Shipping_Address__c = true;
                        }
                        
                        objAddr.MOBILE1__c = listBranches.contact;
                        objAddr.EMAIL_ID__c = listBranches.email;
                        objAddr.ADDRESS1__c = addrWithoutPincode.left(40);
                        objAddr.ADDRESS2__c = addressLine2;
                        objAddr.PINCODE__c = pincodeOfBranch;
                        objAddr.Dealer_Type__c = dealerType;                        
                        objAddr.Customer__c = accountId;
                        objAddr.TRADE_NAME__c = tradeName;
                        objAddr.Source__c = 'KARZAA';
                        
                        if (pincodeMap.containsKey(pincodeOfBranch)) {
                            Active_Pincode__c objPincode = pincodeMap.get(pincodeOfBranch);
                            objAddr.CITY__c = objPincode.CITY__c;
                            objAddr.District__c = objPincode.CITY__c;
                            objAddr.STATE__c = objPincode.State__c;
                            objAddr.COUNTRY__c = objPincode.Country__c;
                        }
                        
                        if(!lstAddrOfBranch.contains(objAddr)){
                            lstAddrOfBranch.add(objAddr);
                        }
                        
                        
                    }
                } else {
                    continue;
                }
                
            }
        }
        if (lstAddrOfGST.Size() > 0 && !customerHasAddress.HasAddress__c) { 
            
            // Remove duplicate value before insert.
            Set<AddressBook__c> removeDuplicate = new Set<AddressBook__c>();
            removeDuplicate.addAll(lstAddrOfGST);
            lstAddrOfGST.clear();
            lstAddrOfGST.addAll(removeDuplicate);
            Database.insert(lstAddrOfGST);
        }
        if (lstAddrOfBranch.Size() > 0 && !customerHasAddress.HasAddress__c) { 
            
            // Remove duplicate value before insert.
            Set<AddressBook__c> removeDuplicate = new Set<AddressBook__c>();
            removeDuplicate.addAll(lstAddrOfBranch);
            lstAddrOfBranch.clear();
            lstAddrOfBranch.addAll(removeDuplicate);  
            Database.insert( lstAddrOfBranch);
        }
        
        
        List < Profile__c > lstOfProfileObj = new List < Profile__c > ();
        
        KYCPanVerificationResponseWrapper.Profile profiledetails = wrap.result.profile;
        
        if (profiledetails != null) {
            
            KYCPanVerificationResponseWrapper.Profile listProfile = wrap.result.profile;            

            if (listProfile != null) {
                Profile__c objProfile = new Profile__c();
                objProfile.Name = 'Customer Profile Record - '+listProfile.name;
                objProfile.Name__c = listProfile.name;
                objProfile.Activity_Class__c = listProfile.activityClass;
                objProfile.Activity_Group__c = listProfile.activityGroup;
                objProfile.Activity_Sub_Class__c = listProfile.activitySubClass;
                objProfile.City__c = listProfile.city;
                objProfile.Contact__c = listProfile.contact;
                objProfile.Date_Of_Birth__c = listProfile.dateOfBirth;
                objProfile.Date_Of_Incorporation__c = listProfile.dateOfIncorporation;
                objProfile.Date_Of_Vat_Registration__c = listProfile.dateOfVatRegistration;
                objProfile.Description_Of_Main_Division__c = listProfile.descriptionOfMainDivision;
                objProfile.Email__c = listProfile.email;
                objProfile.Entity_Class__c = listProfile.entityClass;
                objProfile.Entity_Id__c = listProfile.entityId;
                objProfile.Father_s_Name__c = listProfile.fatherName;
                objProfile.Industry__c = listProfile.industry;
                objProfile.Main_Divison_Of_Business_Activity__c = listProfile.mainDivisonOfBusinessActivity;
                objProfile.PAN_No__c = listProfile.pans[0];
                objProfile.Pin__c = listProfile.pin;
                objProfile.Registered_Address__c = listProfile.registeredAddress;
                objProfile.State__c = listProfile.state;
                objProfile.Sub_Industry__c = listProfile.subIndustry;
                objProfile.Trade_Name__c = listProfile.tradeName;
                objProfile.Type__c = listProfile.type;
                objProfile.Customer__c = accountId;
                List < String > lstString = listProfile.natureOfBusiness;
                objProfile.Nature_Of_Business__c = string.join(lstString, ',');
                
                if(! lstOfProfileObj.contains(objProfile)){
                    lstOfProfileObj.add(objProfile);
                }
                
                
            }
        }
        
        if (lstOfProfileObj.Size() > 0) { 
            
            // Remove Duplicate 
            Set<Profile__c> removeDeplicate = new Set<Profile__c>();
            removeDeplicate.addAll(lstOfProfileObj);
            lstOfProfileObj.clear();
            lstOfProfileObj.addAll(removeDeplicate);
            Database.insert(lstOfProfileObj); 
        }
        
        List < Profile__c > lstOfManagementObj = new List < Profile__c > ();
        
        KYCPanVerificationResponseWrapper.Management managementdetails = wrap.result.management;
        
        if (managementdetails != null) {
            
            String managementRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('Management Profile').getRecordTypeId();
            
            KYCPanVerificationResponseWrapper.Management listManagement = wrap.result.management;
            String managementSource = listManagement.source;
            
            
            for (KYCPanVerificationResponseWrapper.Current listCurrent: wrap.result.management.current) {
                Profile__c objProfileMang = new Profile__c();
                objProfileMang.RecordTypeId = managementRecordTypeID;
                objProfileMang.Name = 'Management Profile Record - '+listCurrent.name;
                objProfileMang.Customer__c = accountId;
                objProfileMang.source__c = managementSource;
                objProfileMang.kid__c = listCurrent.kid;
                objProfileMang.din__c = listCurrent.din;
                
                if (listCurrent.pans.Size() > 0) {
                    system.debug('listCurrent.pans[0]:::' + listCurrent.pans[0]);
                    objProfileMang.pans__c = listCurrent.pans[0];
                }
                
                objProfileMang.Name__c = listCurrent.name;
                
                objProfileMang.gender__c = listCurrent.gender;
                objProfileMang.Email__c = listCurrent.email;
                objProfileMang.isDscRegistered__c = listCurrent.isDscRegistered;
                objProfileMang.dscExpiryDate__c = listCurrent.dscExpiryDate;
                objProfileMang.designation__c = listCurrent.designation;
                objProfileMang.dateOfBirth__c = listCurrent.dateOfBirth;
                if (listCurrent.alerts.size() > 0) {
                    objProfileMang.alerts__c = listCurrent.alerts[0];
                }
                objProfileMang.tenureBeginDate__c = listCurrent.tenureBeginDate;
                objProfileMang.tenureEndDate__c = listCurrent.tenureEndDate;
                objProfileMang.fatherName__c = listCurrent.fatherName;
                objProfileMang.status__c = listCurrent.status;
                objProfileMang.address__c = listCurrent.address;
                objProfileMang.City__c = listCurrent.city;
                objProfileMang.State__c = listCurrent.state;
                objProfileMang.Pin__c = listCurrent.pin;
                objProfileMang.dinDateOfApproval__c = listCurrent.dinDateOfApproval;
                objProfileMang.nationality__c = listCurrent.nationality;
                
                if(!lstOfManagementObj.contains(objProfileMang)){
                    lstOfManagementObj.add(objProfileMang);
                }
                
            }
        }
        
        if (lstOfManagementObj.Size() > 0) {
            //Remove Duplicate
            Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
            removeDuplicate.addAll(lstOfManagementObj);
            lstOfManagementObj.clear();
            lstOfManagementObj.addAll(removeDuplicate);
            database.insert(lstOfManagementObj); 
        }
        
        List < Profile__c > lstOfMCAObj = new List < Profile__c > ();
        
        List < KYCPanVerificationResponseWrapper.MCA > detailsOfMCA = wrap.result.statutoryRegistration.mca;
        
        if (detailsOfMCA != null) {
            String mcaRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('MCA Registration').getRecordTypeId(); 
            
            for (KYCPanVerificationResponseWrapper.MCA listMCA: detailsOfMCA) {
                Profile__c objProfileMCA = new Profile__c();
                objProfileMCA.RecordTypeId = mcaRecordTypeID;
                objProfileMCA.Name = 'MCA Registrations Record ';
                objProfileMCA.Customer__c = accountId;
                objProfileMCA.activeCompliance__c = listMCA.activeCompliance;
                objProfileMCA.alternateAddress__c = listMCA.alternateAddress;
                objProfileMCA.authorisedCapital__c = listMCA.authorisedCapital;
                objProfileMCA.category__c = listMCA.category; 
                objProfileMCA.countryOfIncorporation__c = listMCA.countryOfIncorporation;
                objProfileMCA.dateOfAnnualReturnFiled__c = listMCA.dateOfAnnualReturnFiled;
                objProfileMCA.dateOfBalanceSheet__c = listMCA.dateOfBalanceSheet;
                objProfileMCA.dateOfIncorporation__c = listMCA.dateOfIncorporation;
                objProfileMCA.dateOfLastAgm__c = listMCA.dateOfLastAgm;
                objProfileMCA.dateOfStatementOfAccountsAndSolvencyFil__c = listMCA.dateOfStatementOfAccountsAndSolvencyFiled;
                
                if(!lstOfMCAObj.contains(objProfileMCA)){
                    lstOfMCAObj.add(objProfileMCA);
                }
                
            }
        }
        
        if (lstOfMCAObj.Size() > 0) { 
            Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
            removeDuplicate.addAll(lstOfMCAObj);
            lstOfMCAObj.clear();
            lstOfMCAObj.addAll(removeDuplicate);
            Database.insert(lstOfMCAObj); 
        }
        
        //Storing details of PAN 
        List < Profile__c > lstOfPANObj = new List < Profile__c > ();
        
        if(wrap.result.statutoryRegistration.pans != null){
            List < KYCPanVerificationResponseWrapper.PANS > detailsOfPAN = wrap.result.statutoryRegistration.pans;
            
            if (detailsOfMCA != null) {
                String panRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('PAN Registration').getRecordTypeId();
                
                
                for (KYCPanVerificationResponseWrapper.PANS listPANS: detailsOfPAN) {
                    Profile__c objProfilePAN = new Profile__c();
                    objProfilePAN.RecordTypeId = panRecordTypeID;
                    objProfilePAN.Name = 'PAN Registration Record - '+listPANS.name; 
                    objProfilePAN.Customer__c = accountId;
                    objProfilePAN.address__c = listPANS.address;
                    objProfilePAN.dateOfBirth__c = listPANS.dateOfBirth;
                    objProfilePAN.dateOfIssuance__c = listPANS.dateOfIssuance;
                    objProfilePAN.Email__c = listPANS.email;
                    objProfilePAN.emailDomains__c = listPANS.emailDomain;
                    objProfilePAN.isPanInactive__c = listPANS.isPanInactive;
                    objProfilePAN.mcaEntityId__c = listPANS.mcaEntityId;
                    objProfilePAN.mcaEntityType__c = listPANS.mcaEntityType;
                    objProfilePAN.Name__c = listPANS.name;
                    objProfilePAN.pan__c = listPANS.pans;
                    objProfilePAN.panType__c = listPANS.panType;
                    objProfilePAN.pincode__c = listPANS.pincode;
                    objProfilePAN.State__c = listPANS.state;
                    objProfilePAN.timestamp__c = listPANS.timestamp;
                    objProfilePAN.yearMonthOfIssuance__c = listPANS.yearMonthOfIssuance;
                    
                    if(!lstOfPANObj.contains(objProfilePAN)){                        
						lstOfPANObj.add(objProfilePAN);                    }
                    
                }
            }
            
            if (lstOfPANObj.Size() > 0) {
                Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
                removeDuplicate.addAll(lstOfPANObj);
                lstOfPANObj.clear();
                lstOfPANObj.addAll(removeDuplicate);
                Database.insert(lstOfPANObj); 
            }
        }
        //Storing details of TAN 
        List < Profile__c > lstOfTANObj = new List < Profile__c > ();
        
        List < KYCPanVerificationResponseWrapper.TAN > detailsOfTAN = wrap.result.statutoryRegistration.tan;
        
        if (detailsOfTAN != null) {
            String tanRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('TAN Registration').getRecordTypeId();
                        
            for (KYCPanVerificationResponseWrapper.TAN listTAN: detailsOfTAN) {
                Profile__c objProfileTAN = new Profile__c();
                objProfileTAN.RecordTypeId = tanRecordTypeID;
                objProfileTAN.Name = 'TAN Registration Record - '+listTAN.name;
                objProfileTAN.Customer__c = accountId;
                objProfileTAN.address__c = listTAN.address;
                objProfileTAN.areaCode__c = listTAN.areaCode;
                objProfileTAN.assessingOfficerNumber__c = listTAN.assessingOfficerNumber;
                objProfileTAN.branch__c = listTAN.branch;
                objProfileTAN.buildingName__c = listTAN.buildingName;
                objProfileTAN.category__c = listTAN.category;
                objProfileTAN.deductorCategory__c = listTAN.deductorCategory;
                objProfileTAN.divisionName__c = listTAN.divisionName;
                if (listTAN.emailDomains.Size() > 0) {
                    List < String > lstString = listTAN.emailDomains;
                    objProfileTAN.emailDomains__c = string.join(lstString, ',');
                    
                }
                //objProfileTAN.emailDomains__c = listTAN.emailDomains;
                
                if (listTAN.emails.Size() > 0) {
                    List < String > lstString = listTAN.emails;
                    objProfileTAN.Email__c = string.join(lstString, ',');
                    
                }
                
                //objProfileTAN.Email__c = listTAN.emails;
                objProfileTAN.kid__c = listTAN.kid;
                objProfileTAN.Name__c = listTAN.name;
                objProfileTAN.pan__c = listTAN.pan;
                objProfileTAN.sourceUri__c = listTAN.sourceUri;
                objProfileTAN.subCategory__c = listTAN.subCategory;
                objProfileTAN.tan__c = listTAN.tan;
                objProfileTAN.tanStatus__c = listTAN.tanStatus;
                objProfileTAN.timestamp__c = listTAN.timestamp;
                objProfileTAN.dispatchDate__c = listTAN.dispatchDate;
                
                if(!lstOfTANObj.contains(objProfileTAN)){
                    lstOfTANObj.add(objProfileTAN);
                }
                
            }
        }
        
        if (lstOfTANObj.Size() > 0) {
            Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
            removeDuplicate.addAll(lstOfTANObj);
            lstOfTANObj.clear();
            lstOfTANObj.addAll(removeDuplicate);
            insert lstOfTANObj;
        }
        
        //Storing details of IEC 
        List < Profile__c > lstOfIECObj = new List < Profile__c > ();
        List < Profile__c > lstOfIECRegObj = new List < Profile__c > ();
        
        List < KYCPanVerificationResponseWrapper.IEC > detailsOfIEC = wrap.result.statutoryRegistration.iec;
        
        if (detailsOfIEC != null) {
            String iecRecordId;
            String iecRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('IEC Registration').getRecordTypeId();
            system.debug('iecRecordTypeID::' + iecRecordTypeID);
            
            for (KYCPanVerificationResponseWrapper.IEC listIEC: detailsOfIEC) {
                
                Profile__c objProfileIEC = new Profile__c();
                objProfileIEC.RecordTypeId = iecRecordTypeID;
                objProfileIEC.Name ='IEC Registration Record - '+listIEC.name;
                objProfileIEC.Customer__c = accountId;
                objProfileIEC.accountNumber__c = listIEC.accountNumber;
                objProfileIEC.accountType__c = listIEC.accountType;
                objProfileIEC.address__c = listIEC.address;
                objProfileIEC.bank__c = listIEC.bank;
                objProfileIEC.bin__c = listIEC.bin;
                //objProfileIEC.branches__c = listTAN.category;
                objProfileIEC.Contact__c = listIEC.contact;
                objProfileIEC.dateOfIecAllotment__c = listIEC.dateOfIecAllotment;
                objProfileIEC.dateOfIncorporation__c = listIEC.dateOfIncorporation;
                objProfileIEC.Email__c = listIEC.email;
                objProfileIEC.emailDomains__c = listIEC.emailDomain;
                objProfileIEC.entityType__c = listIEC.entityType;
                objProfileIEC.exporterType__c = listIEC.exporterType;
                objProfileIEC.fileDate__c = listIEC.fileDate;
                objProfileIEC.fileNumber__c = listIEC.fileNumber;
                objProfileIEC.iec__c = listIEC.iec;
                objProfileIEC.iecGateStatus__c = listIEC.iecGateStatus;
                objProfileIEC.iecPrintStatus__c = listIEC.iecPrintStatus;
                objProfileIEC.Name__c = listIEC.name;
                
                if(!lstOfIECObj.contains(objProfileIEC)){
                     lstOfIECObj.add(objProfileIEC);
                     customerRecObj.IEC__c = listIEC.iec; 
                }
               
               
            }
            
            if (lstOfIECObj.Size() > 0) {
                Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
                removeDuplicate.addAll(lstOfIECObj);
                lstOfIECObj.clear();
                lstOfIECObj.addAll(removeDuplicate);
                Database.insert(lstOfIECObj); 
                iecRecordId = lstOfIECObj[0].Id;
            }
            
            String iecRegRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('IEC Registration (Registrations)').getRecordTypeId();
            
            
            for (KYCPanVerificationResponseWrapper.IEC listIEC: detailsOfIEC) {
                for (KYCPanVerificationResponseWrapper.REGISTRATIONS listOfRegistrations: listIEC.registrations) {
                    Profile__c objProfileIECReg = new Profile__c();
                    objProfileIECReg.RecordTypeId = iecRegRecordTypeID;
                    objProfileIECReg.Name = 'IEC Registration Record - '+listOfRegistrations.registrationNumber;
                    objProfileIECReg.registrationNumber__c = listOfRegistrations.registrationNumber;
                    objProfileIECReg.Type__c = listOfRegistrations.type;
                    objProfileIECReg.place__c = listOfRegistrations.place;
                    objProfileIECReg.dateOfRegistration__c = listOfRegistrations.dateOfRegistration;
                    objProfileIECReg.Profile_IEC__c = iecRecordId;
                    
                    if(lstOfIECRegObj.contains(objProfileIECReg)){
                        lstOfIECRegObj.add(objProfileIECReg);
                    }
                    
                }
            }
            
            if (lstOfIECRegObj.Size() > 0) {
                Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
                removeDuplicate.addAll(lstOfIECRegObj);
                lstOfIECRegObj.clear();
                lstOfIECRegObj.addAll(removeDuplicate);
                Database.insert(lstOfIECRegObj);
                
            }
            
        }
        
        //Storing details of GST 
        List < Profile__c > lstOfGSTObj = new List < Profile__c > ();
        List < Profile__c > lstOfGSTBranchObj = new List < Profile__c > ();
        
        List < KYCPanVerificationResponseWrapper.GST > detailsOfGST = wrap.result.statutoryRegistration.gst;
        
        if (detailsOfGST != null) {
            String gstRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('GST Registrations').getRecordTypeId();
            system.debug('gstRecordTypeID::' + gstRecordTypeID);
            
            String gstBranchRecordTypeID = Schema.getGlobalDescribe().get('Profile__c').getDescribe().getRecordTypeInfosByName().get('GST Registrations-Branches').getRecordTypeId();
            system.debug('gstBranchRecordTypeID::' + gstBranchRecordTypeID);
            
            String recordIdOfGST;
            for (KYCPanVerificationResponseWrapper.GST listGST: detailsOfGST) {
                Profile__c objProfileGST = new Profile__c();
                objProfileGST.RecordTypeId = gstRecordTypeID;
                objProfileGST.Customer__c = accountId;
                objProfileGST.Name = 'GST Registrations Record - '+listGST.legalName;
                objProfileGST.addr__c = listGST.addr;
                objProfileGST.address__c = listGST.address;
                objProfileGST.complianceRating__c = listGST.complianceRating;
                objProfileGST.constitutionOfBusiness__c = listGST.constitutionOfBusiness;
                objProfileGST.Contact__c = listGST.contact;
                objProfileGST.contacted__c = listGST.contacted;
                objProfileGST.dateOfRegistration__c = listGST.dateOfRegistration;
                objProfileGST.dateOfRegistrationCancellation__c = listGST.dateOfRegistrationCancellation;
                objProfileGST.dateOfVatRegistration__c = listGST.dateOfVatRegistration;
                objProfileGST.dealerType__c = listGST.dealerType;
                objProfileGST.Email__c = listGST.email;
                objProfileGST.emailDomains__c = listGST.emailDomain;
                objProfileGST.gstin__c = listGST.gstin;
                objProfileGST.isFieldVisitConducted__c = listGST.isFieldVisitConducted;
                objProfileGST.isMoreAdditionalPlaces__c = listGST.isMoreAdditionalPlaces;
                objProfileGST.kid__c = listGST.kid;
                objProfileGST.lastUpdatedDate__c = listGST.lastUpdatedDate;
                objProfileGST.legalName__c = listGST.legalName;
                if (listGST.natureOfBusiness.Size() > 0) {
                    List < String > lstString = listGST.natureOfBusiness;
                    objProfileGST.Nature_Of_Business__c = string.join(lstString, ',');
                    
                }
                //objProfileGST.Nature_Of_Business__c = listGST.natureOfBusiness;
                String tradeNature = listGST.natureOfTrade != null ? listGST.natureOfTrade : '';
                objProfileGST.natureOfTrade__c = tradeNature.left(255);
                objProfileGST.Nature_Of_Trade__c = listGST.natureOfTrade; 
                
                objProfileGST.pan__c = listGST.pan;
                if (listGST.signatories.Size() > 0) {
                    List < String > lstString = listGST.signatories;
                    objProfileGST.signatories__c = string.join(lstString, ',');
                    
                }
                //objProfileGST.signatories__c = listGST.signatories;
                objProfileGST.sourceUri__c = listGST.sourceUri;
                objProfileGST.status__c = listGST.status;
                objProfileGST.timestamp__c = listGST.timestamp;
                objProfileGST.tin__c = listGST.tin;
                objProfileGST.tradeName__c = listGST.tradeName;
                //lstOfGSTObj.add(objProfileGST);
                
                insert objProfileGST;
                
                
                recordIdOfGST = objProfileGST.Id;
                system.debug('recordIdOfGST:::' + recordIdOfGST);
                for (KYCPanVerificationResponseWrapper.Branches listBranches: listGST.branches) {
                    Profile__c objProfileGSTBranches = new Profile__c();
                    objProfileGSTBranches.Profile_IEC__c = recordIdOfGST;
                    objProfileGSTBranches.RecordTypeId = gstBranchRecordTypeID;
                    objProfileGSTBranches.Name = 'Branch Record - '+listBranches.addr;  
                    objProfileGSTBranches.addr__c = listBranches.addr;
                    objProfileGSTBranches.address__c = listBranches.address;
                    objProfileGSTBranches.Email__c = listBranches.email;
                    objProfileGSTBranches.emailDomains__c = listBranches.emailDomain;
                    objProfileGSTBranches.Contact__c = listBranches.contact;
                    String brancheTradeNature = listBranches.natureOfTrade != null ? listBranches.natureOfTrade : '';
                    objProfileGSTBranches.natureOfTrade__c = brancheTradeNature.left(255);
                    objProfileGSTBranches.Nature_Of_Trade__c = listBranches.natureOfTrade;
                    objProfileGSTBranches.lastUpdatedDate__c = listBranches.lastUpdatedDate;
                    
                    if(! lstOfGSTBranchObj.contains(objProfileGSTBranches)){
                        lstOfGSTBranchObj.add(objProfileGSTBranches);
                    }
                    
                }
                
            }
        }
        
        if (lstOfGSTBranchObj.Size() > 0) {
            Set<Profile__c> removeDuplicate = new  Set<Profile__c>();
            removeDuplicate.addAll(lstOfGSTBranchObj);
            lstOfGSTBranchObj.clear();
            lstOfGSTBranchObj.addAll(removeDuplicate);
            
            Database.insert(lstOfGSTBranchObj);
        }
        
        apistatus.customerRecObj = customerRecObj;
        return apistatus;
    }
    
}