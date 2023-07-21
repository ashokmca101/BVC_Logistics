/**********************************************************
 * Created By : Anamika Shinde
 * Created Date:19-08-2022
 * Purpose: Create Invoice Annexure File
**********************************************************************/
public with sharing class CreateAnnexure {
    
    
    @future
    public static void createAnnexureInvoice(String InvoiceId ){
        
       //System.debug('invoice '+InvoiceId);
         List<blng__Invoice__c> invoiceList = [SELECT id,Name,Consignee_Name__c,blng__Subtotal__c,BVC_Service__c, blng__Order__c,blng__Order__r.OrderNumber ,Product__r.Name,Gross_Weight__c,Total_Freight_Charges__c,blng__Account__c,Total_CGST_Amount__c,Total_SGST_Amount__c,Total_IGST_Amount__c  FROM blng__Invoice__c WHERE ID =:InvoiceId];
        //string header = 'Invoice Number , Customer \n';
        //System.debug('id :'+invoiceList[0].blng__Order__r.Name);
       
        string header = 'billing month,Consignee Name,Invoice Number, Docket No,Order no,Pincode, Payment mode,RTO,Product,From city, to city,Docket Date, Booking Date,Matrix Type,  Declared Value, Weight,freight, Cod amount, cod charges, weight surcharges,Liability Charge, RTO Charges, Fuel Surcharge,NO.of Attempts,Re Attempt Charges,Risk Surcharges,  Total \n';
        string finalstr = header ;
        string recordString;
        
            //List<Order> listOrder= [SELECT Id, AccountId,OrderNumber,Shipment__c,BVC_Service__c,SBQQ__Quote__c,SBQQ__Quote__r.Tariff_Plan_Bath_Eship__c,SBQQ__Quote__r.Package_Amount__c,Business_Type__c,Shipment__r.Docket_No__c,Shipment__r.Origin_Pincode__c,Shipment__r.Payment_Mode__c,Shipment__r.RTO__c,Shipment__r.From_City__c,Shipment__r.To_City__c,Shipment__r.Docket_Date__c,Shipment__r.Booking_Date__c,Shipment__r.Declared_Value__c,Shipment__r.COD_Amount__c,Shipment__r.No_Of_Attempts__c FROM Order WHERE ID=:invoiceList[0].blng__Order__c];
            //System.debug('Order Number'+invoiceList[0].blng__Order__r.OrderNumber);
            //List<Shipment__c> shipmentList= [SELECT ID ,Docket_No__c,Origin_Pincode__c,Payment_Mode__c,RTO__c,From_City__c,To_City__c,Docket_Date__c,Booking_Date__c,Declared_Value__c,COD_Amount__c,No_Of_Attempts__c FROM Shipment__c WHERE ID=:listOrder[0].Shipment__c];
            List<blng__InvoiceLine__c> invlineList = [SELECT ID ,Commission_Charges__c,Weight_Charges_eSHIP__c,Additional_Charges_eSHIP__c,COD_Charges_eSHIP__c,Fuel_Surcharges_eSHIP__c,Freight_Charges_eSHIP__c, Name,Order_Number__c,Logistics_Charges__c,BATHeSHIPChargesMap__c,Shipment__c,Liability_Charges_eSHIP__c,Shipment__r.Docket_No__c,Shipment__r.Origin_Pincode__c,Shipment__r.Payment_Mode__c,Shipment__r.Visit_Outcome__c,Shipment__r.RTO__c,Shipment__r.From_City__c,Shipment__r.To_City__c,Shipment__r.Docket_Date__c,Shipment__r.Booking_Date__c,Shipment__r.Declared_Value__c,Shipment__r.COD_Amount__c,Shipment__r.No_Of_Attempts__c FROM blng__InvoiceLine__c WHERE  blng__Invoice__c=:invoiceList[0].ID];
           
            if(invlineList.size()>0){
                for(blng__InvoiceLine__c inv : invlineList){
                    if(inv.Name=='BVC BATH'){
                          System.debug('Shipment: '+inv.Shipment__c);
                           if(invoiceList.size()>0 && inv.Shipment__c!=Null){
                               if(inv.Shipment__r.Visit_Outcome__c=='Unsuccessful'){recordString = '"'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+inv.Shipment__r.Docket_No__c+'","'+inv.Order_Number__c+'","'+inv.Shipment__r.Origin_Pincode__c+'","'+inv.Shipment__r.Payment_Mode__c+'","'+inv.Shipment__r.RTO__c+'","'+inv.Name+'","'+inv.Shipment__r.From_City__c+'","'+inv.Shipment__r.To_City__c+'","'+inv.Shipment__r.Docket_Date__c+'","'+inv.Shipment__r.Booking_Date__c+'","'+'","'+inv.Shipment__r.Declared_Value__c+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Logistics_Charges__c+'","'+inv.Shipment__r.COD_Amount__c+'","'+'","'+'","'+'","'+'","'+'","'+inv.Shipment__r.No_Of_Attempts__c+'","'+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                           
                               }else if(inv.Shipment__r.Visit_Outcome__c=='Successful'){recordString = '"'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+inv.Shipment__r.Docket_No__c+'","'+inv.Order_Number__c+'","'+inv.Shipment__r.Origin_Pincode__c+'","'+inv.Shipment__r.Payment_Mode__c+'","'+inv.Shipment__r.RTO__c+'","'+inv.Name+'","'+inv.Shipment__r.From_City__c+'","'+inv.Shipment__r.To_City__c+'","'+inv.Shipment__r.Docket_Date__c+'","'+inv.Shipment__r.Booking_Date__c+'","'+'","'+inv.Shipment__r.Declared_Value__c+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Commission_Charges__c+'","'+inv.Shipment__r.COD_Amount__c+'","'+'","'+'","'+'","'+'","'+'","'+inv.Shipment__r.No_Of_Attempts__c+'","'+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                           
                               }
                           			
                           }else if(invoiceList.size()>0 && inv.Shipment__c==Null){
                                	recordString = '"'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+'","'+inv.Order_Number__c+'","'+'","'+'","'+'","'+invoiceList[0].Product__r.Name+'","'+'","'+'","'+'","'+'","'+'","'+'","'+invoiceList[0].Gross_Weight__c+'","'+invoiceList[0].Total_Freight_Charges__c+'","'+'","'+'","'+'","'+'","'+'","'+'","'+'","'+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                         	}   
                            finalstr = finalstr +recordString;
                    }else if(inv.Name=='BVC eSHIP'){
                    	//if(inv.BATHeSHIPChargesMap__c != null){
                                   // eShipCharges eshipj=(eShipCharges)JSON.deserialize(inv.BATHeSHIPChargesMap__c,eShipCharges.class );
                            	 //Create Annaxure
                                if(invoiceList.size()> 0 && inv.Shipment__c!=Null ){   
                                     recordString = '"'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+inv.Shipment__r.Docket_No__c+'","'+inv.Order_Number__c+'","'+inv.Shipment__r.Origin_Pincode__c+'","'+inv.Shipment__r.Payment_Mode__c+'","'+inv.Shipment__r.RTO__c+'","'+invoiceList[0].Product__r.Name+'","'+inv.Shipment__r.From_City__c+'","'+inv.Shipment__r.To_City__c+'","'+inv.Shipment__r.Docket_Date__c+'","'+inv.Shipment__r.Booking_Date__c+'","'+'","'+inv.Shipment__r.Declared_Value__c+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Freight_Charges_eSHIP__c+'","'+inv.Shipment__r.COD_Amount__c+'","'+inv.COD_Charges_eSHIP__c+'","'+ inv.Weight_Charges_eSHIP__c+'","'+inv.Liability_Charges_eSHIP__c+'","'+'","'+ inv.Fuel_Surcharges_eSHIP__c+'","'+inv.Shipment__r.No_Of_Attempts__c+'","'+inv.Additional_Charges_eSHIP__c+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                                }else if(invoiceList.size()>0 && inv.Shipment__c==Null){
                                     recordString = '"'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+'","'+inv.Order_Number__c+'","'+'","'+'","'+'","'+invoiceList[0].Product__r.Name+'","'+'","'+'","'+'","'+'","'+'","'+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Freight_Charges_eSHIP__c+'","'+'","'+inv.COD_Charges_eSHIP__c+'","'+inv.Weight_Charges_eSHIP__c+'","'+inv.Liability_Charges_eSHIP__c+'","'+'","'+inv.Fuel_Surcharges_eSHIP__c+'","'+'","'+inv.Additional_Charges_eSHIP__c+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                                }
                                  finalstr = finalstr +recordString;
                                }
                   // }
                }
            }
            
            
                if(recordString!=Null){
                     //finalstr = finalstr +recordString;
                    System.debug(recordString);
                    Attachment att=new Attachment();
                    att.Body=Blob.valueOf(finalstr);
                    att.Name='Annexure.csv';
                    att.parentId=invoiceList[0].Id;
                   insert att;
              
                }
    }

    
        /**********************************************************************************
    * Name : generateDocumentBathEShip
    * Description : Generate A5 document for Invoice and send email with Doc BATH ESHIP
    * Param : newList and OldMap
    * Return : None
    ***********************************************************************************/ 
    @future
    public static void generateDocumentBathEShip(String InvoiceId){
        List<blng__Invoice__c> newList = [SELECT id,Name,Consignee_Name__c,BVC_Service__c, blng__Order__c,blng__Order__r.OrderNumber ,Product__r.Name,Gross_Weight__c,Total_Freight_Charges__c,blng__Account__c,Total_CGST_Amount__c,Total_SGST_Amount__c,Total_IGST_Amount__c  FROM blng__Invoice__c WHERE ID  =:InvoiceId];

         List<rsdoc__Document_Request__c> listDocRequest = new List<rsdoc__Document_Request__c>();
		 
		 Map<String,rsdoc__Document_Action__c> mapInvoiceDocAction = new Map<String,rsdoc__Document_Action__c>();
		 
		 
		 for(rsdoc__Document_Action__c docaction: [SELECT id,rsdoc__Template_Name__c from rsdoc__Document_Action__c where rsdoc__Base_object_API__c = 'blng__Invoice__c']){
             if(newList[0].BVC_Service__c=='BATH'){if(docaction.rsdoc__Template_Name__c == 'BATH INVOICE'){ mapInvoiceDocAction.put('BATH',docaction);
                     }
             }else if(newList[0].BVC_Service__c=='eSHIP'){if( docaction.rsdoc__Template_Name__c == 'ESHIP INVOICE' ){mapInvoiceDocAction.put('BATH',docaction);
                  }
             }
                 
             
        }
		
		for(blng__Invoice__c inv : newList){
            System.debug('bvc service'+inv.BVC_Service__c);
			if(inv.BVC_Service__c=='BATH' || inv.BVC_Service__c=='eSHIP'){
                if(!mapInvoiceDocAction.isEmpty()){
                    rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();docReq.rsdoc__Record_Id__c = inv.Id;
                     docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('BATH').Id;
                     listDocRequest.add(docReq);
                }
			 
			}
			
		
		}
		
		 if(!listDocRequest.isEmpty()){
            System.debug('insert listDocRequest. '+listDocRequest);
            insert listDocRequest;
        }

    }

}