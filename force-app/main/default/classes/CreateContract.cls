/**********************************************************
 * Created By : Anamika Shinde
 * Created Date:23-08-2022
 * Purpose: Create Contract Annexure File
**********************************************************************/

public with sharing class CreateContract {
    
    @AuraEnabled
    public static void createCreateContract(String ContractId){
        System.debug('contract'+ContractId);
       
        List<Contract> contractList = [SELECT Id,SBQQ__Order__c, ContractNumber,AccountId,Account.Name,BVC_Service__c,Business_Type__c,Status,Pricebook2Id,CurrencyIsoCode,Total_Shipment_Value__c,BVC_Billing_Entity__c,X18_Digit_ID__c,OwnerExpirationNotice,Contract_Amount__c,Annexure_Contract__c,Is_Legacy_Contract__c,StartDate,EndDate,Original_Contract_End_Date__c,Adjusted_Contract_Amount__c,ContractTerm,Contracted_ACR_Package__c,Balance_Amount__c,Exhibition__c,Adjustment_Amount__c,SBQQ__RenewalForecast__c,SBQQ__RenewalOpportunityStage__c FROM Contract WHERE ID=:ContractId];
        String hed=',Annual Contract Consumption Report, , ,billing month\n'+',Customer Name,'+contractList[0].Account.Name+'\n'+',Contract Number,'+contractList[0].ContractNumber+',Start Date,'+contractList[0].StartDate+',End Date,'+contractList[0].EndDate+'\n'+',Contract Amount,'+contractList[0].Adjusted_Contract_Amount__c+'\n ,Consumtion Till date,'+'\n,Contract Balance,'+contractList[0].Balance_Amount__c+'\n\n';
        string header = 'Heading for ACR Annexure, billing month,Consignor Name,INvoice Number, Docket No,Order no,Pincode, Payment mode,RTO,Product,From city, to city,Docket Date, Booking Date,Matrix Type,  Declared Value, Weight,freight, Cod amount, cod charges, weight surcharges,Octroi Charge, RTO Charges, Fuel Surcharge,NO.of Attempts,Re Attempt Charges,Risk Surcharges, Total \n';
        string recordString;
        string finalstr =hed+ header ;
        // fetch last month orders and shipment basis on contract id 
       //   List<Order> listOrder= [SELECT Id, OrderNumber,BVC_Service__c,Shipment__c,Shipment__r.Docket_No__c,Shipment__r.Origin_Pincode__c,Shipment__r.Payment_Mode__c,Shipment__r.RTO__c,Shipment__r.From_City__c,Shipment__r.To_City__c,Shipment__r.Docket_Date__c,Shipment__r.Booking_Date__c,Shipment__r.Declared_Value__c,Shipment__r.COD_Amount__c,Shipment__r.No_Of_Attempts__c FROM Order WHERE ContractId=:ContractId AND CreatedDate>=LAST_MONTH];
        //List<Order> listOrder= [SELECT Id, AccountId,OrderNumber,Shipment__c,BVC_Service__c,SBQQ__Quote__c,SBQQ__Quote__r.Tariff_Plan_Bath_Eship__c,SBQQ__Quote__r.Package_Amount__c,Business_Type__c,Shipment__r.Docket_No__c,Shipment__r.Origin_Pincode__c,Shipment__r.Payment_Mode__c,Shipment__r.RTO__c,Shipment__r.From_City__c,Shipment__r.To_City__c,Shipment__r.Docket_Date__c,Shipment__r.Booking_Date__c,Shipment__r.Declared_Value__c,Shipment__r.COD_Amount__c,Shipment__r.No_Of_Attempts__c,Contract_ID_Map__c FROM Order where Contract_ID_Map__c=:ContractId AND CreatedDate>=LAST_MONTH];
        // create set of orderid, take order id from above list
         List<blng__Invoice__c> invoiceList = [SELECT id,Name,Consignee_Name__c, blng__Order__c,blng__Order__r.OrderNumber ,Product__r.Name,Gross_Weight__c,Total_Freight_Charges__c,blng__Account__c,Total_CGST_Amount__c,Total_SGST_Amount__c,Total_IGST_Amount__c,blng__Subtotal__c,blng__TaxAmount__c,blng__TotalAmount__c  FROM blng__Invoice__c WHERE blng__Account__c=:contractList[0].AccountId AND blng__InvoiceStatus__c='Posted'AND CreatedDate>=LAST_MONTH];
          List<blng__InvoiceLine__c> invlineList = [SELECT ID ,Commission_Charges__c,Weight_Charges_eSHIP__c,Additional_Charges_eSHIP__c,COD_Charges_eSHIP__c,Fuel_Surcharges_eSHIP__c,Freight_Charges_eSHIP__c, Name,Order_Number__c,Logistics_Charges__c,BATHeSHIPChargesMap__c,Shipment__c,Liability_Charges_eSHIP__c,Shipment__r.Docket_No__c,Shipment__r.Origin_Pincode__c,Shipment__r.Payment_Mode__c,Shipment__r.Visit_Outcome__c,Shipment__r.RTO__c,Shipment__r.From_City__c,Shipment__r.To_City__c,Shipment__r.Docket_Date__c,Shipment__r.Booking_Date__c,Shipment__r.Declared_Value__c,Shipment__r.COD_Amount__c,Shipment__r.No_Of_Attempts__c FROM blng__InvoiceLine__c WHERE  blng__Invoice__c=:invoiceList[0].ID];
           
            if(invlineList.size()>0){
                for(blng__InvoiceLine__c inv : invlineList){
                    if(inv.Name=='BVC BATH'){
                          System.debug('Shipment: '+inv.Shipment__c);
                           if(invoiceList.size()>0 && inv.Shipment__c!=Null){
                               if(inv.Shipment__r.Visit_Outcome__c=='Unsuccessful'){
                                 recordString = '"'+'","'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+inv.Shipment__r.Docket_No__c+'","'+inv.Order_Number__c+'","'+inv.Shipment__r.Origin_Pincode__c+'","'+inv.Shipment__r.Payment_Mode__c+'","'+inv.Shipment__r.RTO__c+'","'+inv.Name+'","'+inv.Shipment__r.From_City__c+'","'+inv.Shipment__r.To_City__c+'","'+inv.Shipment__r.Docket_Date__c+'","'+inv.Shipment__r.Booking_Date__c+'","'+'","'+inv.Shipment__r.Declared_Value__c+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Logistics_Charges__c+'","'+inv.Shipment__r.COD_Amount__c+'","'+'","'+'","'+'","'+'","'+'","'+inv.Shipment__r.No_Of_Attempts__c+'","'+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                           
                               }else if(inv.Shipment__r.Visit_Outcome__c=='Successful'){
                                    recordString = '"'+'","'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+inv.Shipment__r.Docket_No__c+'","'+inv.Order_Number__c+'","'+inv.Shipment__r.Origin_Pincode__c+'","'+inv.Shipment__r.Payment_Mode__c+'","'+inv.Shipment__r.RTO__c+'","'+inv.Name+'","'+inv.Shipment__r.From_City__c+'","'+inv.Shipment__r.To_City__c+'","'+inv.Shipment__r.Docket_Date__c+'","'+inv.Shipment__r.Booking_Date__c+'","'+'","'+inv.Shipment__r.Declared_Value__c+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Commission_Charges__c+'","'+inv.Shipment__r.COD_Amount__c+'","'+'","'+'","'+'","'+'","'+'","'+inv.Shipment__r.No_Of_Attempts__c+'","'+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                           
                               }
                                    
                           }else if(invoiceList.size()>0 && inv.Shipment__c==Null){
                                    recordString = '"'+'","'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+'","'+inv.Order_Number__c+'","'+'","'+'","'+'","'+invoiceList[0].Product__r.Name+'","'+'","'+'","'+'","'+'","'+'","'+'","'+invoiceList[0].Gross_Weight__c+'","'+invoiceList[0].Total_Freight_Charges__c+'","'+'","'+'","'+'","'+'","'+'","'+'","'+'","'+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                            }   
                            finalstr = finalstr +recordString;
                    }else if(inv.Name=='BVC eSHIP'){
                        //if(inv.BATHeSHIPChargesMap__c != null){
                                   // eShipCharges eshipj=(eShipCharges)JSON.deserialize(inv.BATHeSHIPChargesMap__c,eShipCharges.class );
                                 //Create Annaxure
                                if(invoiceList.size()> 0 && inv.Shipment__c!=Null ){   
                                     recordString = '"'+'","'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+inv.Shipment__r.Docket_No__c+'","'+inv.Order_Number__c+'","'+inv.Shipment__r.Origin_Pincode__c+'","'+inv.Shipment__r.Payment_Mode__c+'","'+inv.Shipment__r.RTO__c+'","'+invoiceList[0].Product__r.Name+'","'+inv.Shipment__r.From_City__c+'","'+inv.Shipment__r.To_City__c+'","'+inv.Shipment__r.Docket_Date__c+'","'+inv.Shipment__r.Booking_Date__c+'","'+'","'+inv.Shipment__r.Declared_Value__c+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Freight_Charges_eSHIP__c+'","'+inv.Shipment__r.COD_Amount__c+'","'+inv.COD_Charges_eSHIP__c+'","'+ inv.Weight_Charges_eSHIP__c+'","'+inv.Liability_Charges_eSHIP__c+'","'+'","'+ inv.Fuel_Surcharges_eSHIP__c+'","'+inv.Shipment__r.No_Of_Attempts__c+'","'+inv.Additional_Charges_eSHIP__c+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
                                }else if(invoiceList.size()>0 && inv.Shipment__c==Null){
                                     recordString = '"'+'","'+System.today()+'","'+invoiceList[0].Consignee_Name__c+'","'+invoiceList[0].Name+'","'+'","'+inv.Order_Number__c+'","'+'","'+'","'+'","'+invoiceList[0].Product__r.Name+'","'+'","'+'","'+'","'+'","'+'","'+'","'+invoiceList[0].Gross_Weight__c+'","'+inv.Freight_Charges_eSHIP__c+'","'+'","'+inv.COD_Charges_eSHIP__c+'","'+inv.Weight_Charges_eSHIP__c+'","'+inv.Liability_Charges_eSHIP__c+'","'+'","'+inv.Fuel_Surcharges_eSHIP__c+'","'+'","'+inv.Additional_Charges_eSHIP__c+'","'+'","'+invoiceList[0].blng__Subtotal__c+'"\n';
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
                   att.Name='Contract.csv';
                    att.parentId=ContractId;
                   insert att;
              
                }
    }

        
                    
    
    
}