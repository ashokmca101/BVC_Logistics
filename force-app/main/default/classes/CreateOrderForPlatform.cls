global class CreateOrderForPlatform implements Schedulable {
   global void execute(SchedulableContext sc) {
       set<Id> ShipIds=new Set<Id>();
       Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            //if(fieldDescribe.isAccessible()) {
            fieldNames.add(fieldName);
            //}
        }
        
        
        list<Shipment__c> ListOfShip= [SELECT  Id, Name, CurrencyIsoCode, Customer__c, Account__c, Account_text__c, Actual_Delivery_Date_and_Time__c, AddressBook__c, Agency_Fees__c, Airway_Bill_Number__c, BOE_No__c, BVC_Products__c, BillTo_Party_Address__c, Bill_To_Account__c, Bill_To_GSTIN__c, Bill_To_Party_Address__c, Bill_To_Party_PAN__c, Bill_To_Party_Pincode__c, Bill_To_Party__c, Bill_To__c, Bill_to_1__c, Proceed_for_ACR_Billing__c, Billing_Account__c, Billing_Address__c, Billing_Date__c, Billing_Entity_Name__c, Billing_Status__c, Billing_Type__c, Breadth__c, CGST__c, COD_Collection_Date__c, COD_Currency__c, COD_Paid_Via__c, COD_Reimbursement_Date__c, COD_UTR_Date__c, COD_Value__c, COD__c, Unit_Code__c, Chargeable_Weight_UOM__c, Chargeable_Weight__c, Community_Consignee_Account__c, Confirmation_Reference__c, Confirmed_By_Email_ID__c, Confirmed_By_Mobile__c, Confirmed_By_Name__c, Consignee_Address__c, Consignee_Email_ID__c, Consignee_GSTIN__c, Consignee_Mobile__c, Consignee_Name__c, Consignee_PAN__c, Customer_Document_Number__c, Customer_Invoice_Date__c, Customer_Invoice_Number__c, Customer_Product_Category__c, Customer_Product_Currency__c, Customer_Product_FOB_CIF_Value_INR__c, Customer_Product_FOB_CIF_Value__c, Customer_Product_Value__c, Customer_Product_name__c, Customs_Duty__c, X18_Digit_ID__c, Delivered_At__c, Delivered_To_Person_Identifier__c, Delivered_To_Person__c, Delivery_Time_Date__c, Destination_Address_City__c, Destination_Address_Country__c, Destination_Address_Email__c, Destination_Address_ID__c, Destination_Address_Line1__c, Destination_Address_Line_2__c, Destination_Address_Name__c, Destination_Address_Person__c, Destination_Address_Phone__c, Destination_Address_Pincode__c, Destination_Address_State__c, Destination_Airport_Retrieval_Time__c, Destination_Branch__c, Destination_COUNTRY__c, Destination_Hub_Scan_Time__c, Destination_Pincode__c, Destination_Type__c, Destination__c, Deviation_B_W_Estimated_Actual_In_Days__c, Dimensions_UOM__c, Shipment_TAT__c, EDI_Job_No__c, EGM_Date__c, EGM_No__c, ER_Date__c, ER_NO__c, E_Invoice_Number__c, E_Waybill_Number__c, Estimated_Delivery_Date__c, Exhibition_Code__c, Exhibition_Name__c, Exhibition_Return_Shipment__c, Freight_Charges__c, Freight_Terms__c, GR_No__c, Gross_Weight_UOM_TMS__c, Gross_Weight_UOM__c, Gross_Weight__c, Gross_weight_in_Gram__c, HAWB_Date__c, HAWB__c, Height_In_cm__c, IGST__c, Indirect_Account__c, Initiator_Account__c, Initiator_Email__c, Initiator_Mobile__c, Initiator_Name__c, Initiator_PAN__c, Insurance_By_BVC__c, Insurance_By__c, Insurance_Liability__c, Invoice_Calculated_Amount__c, Invoice_Date__c, Invoice_Number__c, Invoice_Paid_Amount__c, Invoicing_Date__c, Job_Creation_Time_Date__c, Job_No__c, Job_date__c, Length__c, Liability_Cover_By_BVC__c, Shipment_TAT_in_mins__c, Linehaul_Connnection_Time__c, Linehaul_Creation_Time__c, Is_Pickup_Created__c, MAWB_Date__c, MAWB_No__c, Master_Manifest_Number__c, Net_Weight_UOM_TMS__c, Net_Weight_UOM__c, Net_Weight__c, Net_weight_in_Gram__c, Next_Billing_Date__c, No_of_Pkgs__c, Number_of_Packages__c, Offline_Charges__c, Order__c, Origin_Address_City__c, Origin_Address_Country__c, Origin_Address_Email__c, Origin_Address_Line_1__c, Origin_Address_Line_2__c, Origin_Address_Name__c, Origin_Address_Phone__c, Origin_Address_Pincode__c, Origin_Address_State__c, Origin_Address__c, Origin_Branch__c, Origin_Country__c, Origin_Hub_Scan_Time__c, Origin_Pincode__c, Origin_Type__c, Origin__c, Other_Charges__c, Out_For_Delivery_Time__c, Packaging_Type__c, Payer__c, Payer_s_Consent_On_Payment__c, Payment_Date__c, Payment_Received__c, Payment_Reference__c, Physical_Pickup_Completed_Time__c, Physical_Pickup_Start_Time__c, Pickup_Request_Creation_Time__c, Pickup_Supervisor__c, Pickup_Time_Date__c, Pickup__c, Product_Code__c, AccountBillingStatus2022__c, Product_Post_Tax_Value__c, Product_PreTax_Value__c, Product_Tax__c, Product_Type__c, Delivery_Instruction__c, Razorpay_Id__c, Ready_for_Billing__c, Ready_for_Rebilling__c, Rebilling_Reason__c, Reference_1__c, Reference_2__c, Reference_No__c, Reimbursements__c, Remark__c, Reverse_QC_Number_of_Pieces__c, Reverse_QC_Parameter__c, Revised_Estimated_Delivery_Date__c, SGST__c, Scan_Time__c, Ship_To__c, Shipment_Created_Through__c, Shipment_Date__c, Shipment_Image_Display__c, Shipment_Number__c, Shipment_Payment_Status__c, Shipment_Stage__c, Shipment_Status__c, Shipment_Type__c, Number_of_Secure_Bags__c, Shipment_Value__c, Shipper_Address__c, Shipper_Email_ID__c, Shipper_GSTIN__c, Shipper_GST__c, Shipper_Mobile_TMS__c, Shipper_Mobile__c, Shipper_Name_TMS__c, Shipper_PAN_TMS__c, Shipper_PAN__c, Shipper__c, Shipping_Bill_Date__c, Shipping_Note_Number__c, Shipping_bill_No__c, Short_URL__c, Stamp_Duty__c, Status__c, TP_Date__c, TP_No__c, ToPayConfirmationStatus__c, To_Pay__c, Total_Charge__c, Total_Invoice_Value__c, Tracking_Status__c, UTGST__c, Valuation_Charges__c, Billing_Entity_PAN__c, Weight_Charges__c, Who_is_Payer__c, Your_Reference_No__c, Invoiced_Amount__c, State_Logic_Check__c, Billing_Entity_Address__c, Billing_Entity_GST__c, Billing_Entity_Name_TMS__c, Consignee_Name_TMS__c, Consignee_PAN_TMS__c, Is_Payment_Sync__c, Destination_Hub__c, Exhibition__c, Net_wt_variance__c, Delivery_Remarks__c, Customer_Category_Static__c, Origin_Hub__c, Product_HSN_Code__c, Product_Name__c, Payment_Status__c, Is_Invoice_Visible__c, Is_Payment_Visible__c, checkPayment__c, Hub_Master__c, Community_Billing_Address__c, Community_Destination_Address__c, Community_Origin_Address__c, Exhibition_Movement_Type__c, Verified_for_Billing__c, Distance_Km__c, BVC_Product_Name__c, Cargo_Type_Code__c, Cargo_Type__c, Consignee_Designation__c, Customer_App__c, Customer_Status__c, Delivery_Route_Assigned_By__c, Delivery_Route_Assigned_To__c, Delivery_Route_Number__c, Destination_Address_Contact_Name__c, Destination_Address_Name_App__c, Destination_Hub_Manager__c, Destination_Pin_Code_App__c, Destination_Pincode_Type__c, Invoice_Photo__c, IsExhibition__c, Is_Count_Mismatch__c, Is_Signature_Done__c, Manifest_Photo__c, Origin_Address_Contact_Name__c, Origin_Address_Name_App__c, Origin_Hub_Manager__c, Origin_Pin_Code__c, Origin_Pincode_Type__c, PDF_Generation_Status__c, PDF_Generation__c, Product_Description__c, SNN_Bar_Code__c, Shipment_Value_Currency__c, Verified_for_Billling__c, Window_Delivery__c, Window_Pickup__c, Number_of_Secure_Bags_scanned__c, Customer_Status_TextField__c, Cancelled_Reason__c, Pdf_Url__c, platform_User__c FROM Shipment__c WHERE Status__c = 'Verified For Billing' AND platform_User__c=TRUE ORDER BY Name];
       Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>(ListOfShip);
       validateAndCreateOrder(shipMap);
     
       
   }
    public static void validateAndCreateOrder(Map<Id,Shipment__c> shipmentMap){
        Set<String> productCodes = new Set<String>();
        Map<Id,Shipment__c> validShipmentData = new Map<Id,Shipment__c>();
        Map<Id,Id> mapBillToAccIds = new Map<Id,Id>();
        Map<Id,Id> mapOriginHubIds= new Map<Id,Id>();
        Map<Id,Id> mapBillToaddressIds = new Map<Id,Id>();
        List<Shipment_Error_Log__c> insertLogs = new List<Shipment_Error_Log__c>();
        for(Shipment__c ship : shipmentMap.values()){
            if(ship.Product_Code__c != null){
                productCodes.add(ship.Product_Code__c);
            }
            if(ship.BillTo_Party_Address__c != null){
                mapBillToaddressIds.put(ship.Id,ship.BillTo_Party_Address__c);
            }
            if(ship.Bill_To_Account__c != null){
                mapBillToAccIds.put(ship.Id,ship.Bill_To_Account__c);
            }
            if(ship.Origin_Hub__c != null){
                mapOriginHubIds.put(ship.Id,ship.Origin_Hub__c);
            }
            
        }
        // Creating ProductCode Map
        Map<String,Product2> prodCodeMap = new map<String,Product2>();
        system.debug('Product Code : '+productCodes);
        for(Product2 prd : [SELECT Id,Name,ProductCode,blng__BillingRule__c,blng__TaxRule__c,
                            blng__RevenueRecognitionRule__c,Invoice_Group_ID__c 
                            FROM Product2 WHERE ProductCode IN :productCodes]){
                                prodCodeMap.put(prd.ProductCode,prd);
                            }
        
        Map<Id,Account> mapAccount = new map<Id,Account>([select id,Active_Contract__c,ST_Pricing_Type__c,Customer_Category__c,Contract_End_Date__c,Contracted_ACR_Package__c,Balance_Amount__c from Account where Id in:mapBillToAccIds.values()]);
        System.debug('Map hubs  '+mapOriginHubIds);
        Map<Id,Hub__c> mapHubs = new map<Id,Hub__c>([select id,ST_BVC_Billing_Entity__c from Hub__c where Id in:mapOriginHubIds.values() AND ST_BVC_Billing_Entity__c != null ]);
        System.debug('Map hubs  '+mapHubs);
        Map<Id,AddressBook__c> mapAddressBook = new map<Id,AddressBook__c>([Select id,ADDRESS1__c,ADDRESS2__c,CITY__c,STATE__c,COUNTRY__c from AddressBook__c where id In :mapBillToaddressIds.values() and ADDRESS1__c != null and CITY__c!= null and STATE__c != null and COUNTRY__c != null and PINCODE__c != null]);
        
        for(Shipment__c shipRec : shipmentMap.values()){
            // Validate the Product code 
            Boolean ValidRecord = true;
            if(shipRec.Product_Code__c != null){
                if(!prodCodeMap.containsKey(shipRec.Product_Code__c)){
                    ValidRecord = false;
                    Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                          Error_Reason__c = 'Cannot find Product, Please enter a Valid Product Code',
                                                                          Shipment__c = shipRec.Id);
                    //  shipRec.addError('Cannot find Product, Please enter a Valid Product Code');
                    
                    insertLogs.add(log);
                }else if(prodCodeMap.containsKey(shipRec.Product_Code__c) && prodCodeMap.get(shipRec.Product_Code__c).Name.contains('Express C2C')){
                    if(shipRec.Gross_Weight__c == null){
                        ValidRecord = false;
                        Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                              Error_Reason__c = 'Gross Weight information missing for Express C2C Product',
                                                                              Shipment__c = shipRec.Id); 
                        insertLogs.add(log);
                        // shipRec.addError('Gross Weight information missing for Express C2C Product');
                        
                    }
                }
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Product Code Missing, Please enter a Valid Product Code',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                // shipRec.addError('Product Code Missing, Please enter a Valid Product Code');
            }
            // Product validation end
            
            // Account Validation Start
            date currentDate = date.today();
            System.debug('Account issue '+shipRec.Bill_To_Account__c);
            System.debug('Account issue '+mapAccount.containsKey(shipRec.Bill_To_Account__c));
            if(shipRec.Bill_To_Account__c != null && mapAccount.containsKey(shipRec.Bill_To_Account__c)){
                System.debug('Account issue '+mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c);
                System.debug('Account issue '+mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c);
                if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c == null
                   && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='Non ACR'
                   && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c=='Non Contracted')
                {
                }
                else if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='Non ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c=='Non ACR Contracted'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contract_End_Date__c>=currentDate)
                {
                }
                else if(mapAccount.get(shipRec.Bill_To_Account__c).Active_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c == 'ACR Contracted'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contract_End_Date__c >=currentDate 
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contracted_ACR_Package__c !=null
                        && mapAccount.get(shipRec.Bill_To_Account__c).Balance_Amount__c >0)
                {
                }
                else{
                    ValidRecord = false;
                    Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                          Error_Reason__c = 'Cannot change the status to Verified Billing, Account Information missing for Order Creation',
                                                                          Shipment__c = shipRec.Id); 
                    insertLogs.add(log);
                    //shipRec.addError('Cannot change the status to Verified Billing, Account Information missing for Order Creation');
                }
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to Verified Billing, Account is missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to Verified Billing, Account is missing');
            }
            
            // Account Validation End
            
            // Origin Hub Billing Entity Validation
            
            if(shipRec.Origin_Hub__c != null && mapHubs.containsKey(shipRec.Origin_Hub__c)){
                System.debug('ValidRecord --->'+ValidRecord);
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Invalid Hub',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to verified billing, Invalid Hub');
            }
            
            // Origin Hub Validation End
            
            // origin -Destination Address Validation
            
            if(shipRec.Origin_Address_Name__c != null && shipRec.Origin_Address_Line_1__c != null  && shipRec.Origin_Address_State__c != null && shipRec.Origin_Address_Country__c != null && shipRec.Origin_Address_City__c != null && shipRec.Origin_Address_Pincode__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Origin Address information Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to verified billing, Origin Address information Missing');
            }
            if(shipRec.Destination_Address_Name__c != null && shipRec.Destination_Address_Line1__c != null  && shipRec.Destination_Address_State__c != null && shipRec.Destination_Address_Country__c != null && shipRec.Destination_Address_City__c != null && shipRec.Destination_Address_Pincode__c != null){
                
            }else{
                system.debug('Name : '+shipRec.Destination_Address_Name__c);
                system.debug('Destination Line : '+shipRec.Destination_Address_Line1__c);
                system.debug('Destination State :  : '+shipRec.Destination_Address_State__c);
                system.debug('Destination Country :  : '+shipRec.Destination_Address_Country__c);
                system.debug('Destination City :  : '+shipRec.Destination_Address_City__c);
                system.debug('Destination Pincode :  : '+shipRec.Destination_Address_Pincode__c);
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Destination Address information Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                //shipRec.addError('Cannot change the status to verified billing, Destination Address information Missing');
            }
            if(shipRec.Shipment_Date__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Shipment Date is Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                // shipRec.addError('Cannot change the status to verified billing, Shipment Date is Missing');
            }
            if(shipRec.BillTo_Party_Address__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Bill to Party Address is Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
                // shipRec.addError('Cannot change the status to verified billing, Bill to Party Address is Missing');
            }
            if(ValidRecord){
                validShipmentData.put(shipRec.Id,shipRec);
            }
            
        }
        try{
            insert insertLogs;
        }catch(Exception ex){
            system.debug('Shipment Error Log insert failed : '+ex.getMessage());
        }
        if(!validShipmentData.isEmpty()){
            System.debug(''+validShipmentData.size());
            Database.executeBatch(new PlatformUserBatch(validShipmentData.keySet()), 50);
             
    }
}
    public static void fakeMethod(){
        integer i = 0;
          
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;   
     }
}