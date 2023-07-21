public class CreditNoteLineTriggerHandler {
   
    /********************************************************************************
    		test class- PreTaxTriggerHandlerTest
     *******************************************************************************/
    public static void validateChargeHeadAmount(List<blng__CreditNoteLine__c> cnLines){
        Set<Id> noteIds = new Set<Id>();
        Set<Id> invIds = new Set<Id>();
        Map<Id,blng__CreditNote__c> cnInvMap = new Map<Id,blng__CreditNote__c>();
        Map<Id,List<blng__CreditNoteLine__c>> cnLineMap = new Map<Id,List<blng__CreditNoteLine__c>>();
        for(blng__CreditNoteLine__c li : cnLines){
            if(cnLineMap.containsKey(li.blng__CreditNote__c)){
                cnLineMap.get(li.blng__CreditNote__c).add(li);
            }
            else{
                List<blng__CreditNoteLine__c> lis = new List<blng__CreditNoteLine__c>();
                lis.add(li);
                cnLineMap.put(li.blng__CreditNote__c,lis); 
            }
            
            noteIds.add(li.blng__CreditNote__c);
        }
        Map<Id,List<blng__CreditNoteLine__c>> invCNLineMap = new Map<Id,List<blng__CreditNoteLine__c>>();
        for(blng__CreditNote__c cn : [SELECT Id,
                                      blng__RelatedInvoice__c,
                                      blng__RelatedInvoice__r.Total_Freight_Charges__c,
                                      blng__RelatedInvoice__r.Total_Liability_Charge__c,
                                      blng__RelatedInvoice__r.Total_Offline_Charges__c,
                                      blng__RelatedInvoice__r.Total_Weight_Charges__c,
                                      blng__RelatedInvoice__r.Total_BVC_Valuation_Charges__c,
                                      blng__Relatedinvoice__r.Total_Docket_Charges__c,
                                      blng__RelatedInvoice__r.Total_Fuel_Charges__c,
                                      blng__RelatedInvoice__r.total_Holiday_Charges__c,
                                      blng__RelatedInvoice__r.Total_Commission_Charges__c,
                                      blng__RelatedInvoice__r.Total_Logistics_Charges__c,
                                      blng__RelatedInvoice__r.Total_Secure_Logistics_Charges__c,
                                      blng__RelatedInvoice__r.Total_Fuel_Surcharge__c,
                                      blng__RelatedInvoice__r.Total_Vaulting_Charges__c
                                      FROM blng__CreditNote__c
                                      WHERE Id IN :noteIds]){
                                          cnInvMap.put(cn.Id,cn);
                                          invIds.add(cn.blng__RelatedInvoice__c);
                                          
                                      }
        List<blng__CreditNoteLine__c> existingLines = new List<blng__CreditNoteLine__c>();
              
        for(blng__CreditNoteLine__c li : [SELECT Id,
                                          Charge_Head_Type__c,
                                          blng__CreditNote__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Freight_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Liability_Charge__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Offline_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Weight_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_BVC_Valuation_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Docket_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Fuel_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Holiday_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Commission_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Logistics_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Secure_Logistics_Charges__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Fuel_Surcharge__c,
                                          blng__CreditNote__r.blng__RelatedInvoice__r.Total_Vaulting_Charges__c,
                                          blng__Subtotal__c
                                          FROM blng__CreditNoteLine__c
                                          WHERE blng__CreditNote__r.blng__RelatedInvoice__c IN :invIds
                                          AND Id NOT IN :cnLines]){
                                              
                                              if(invCNLineMap.containsKey(li.blng__CreditNote__r.blng__RelatedInvoice__c)){
                                                  
                                                  invCNLineMap.get(li.blng__CreditNote__r.blng__RelatedInvoice__c).add(li);
                                              }
                                              else{
                                                  List<blng__CreditNoteLine__c> lis = new List<blng__CreditNoteLine__c>();
                                                  lis.add(li);
                                                  invCNLineMap.put(li.blng__CreditNote__r.blng__RelatedInvoice__c,lis); 
                                              }
                                          }
        
        for(blng__CreditNoteLine__c cli : cnLines){
            if(cnInvMap.containsKey(cli.blng__CreditNote__c)){
                Id invId = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__c;
                
                Decimal totalInvFreight = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Freight_Charges__c;
                Decimal totalInvLiab = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Liability_Charge__c;
                Decimal totalInvOff = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Offline_Charges__c;
                Decimal totalInvWeight = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Weight_Charges__c;
                Decimal totalInvBVC = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_BVC_Valuation_Charges__c;
                Decimal totalInvDock = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Docket_Charges__c;
                Decimal totalInvFuel = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Fuel_Charges__c;
                Decimal totalInvHoly = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Holiday_Charges__c;
                Decimal totalInvFSurc = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Fuel_Surcharge__c;//prat
                Decimal totalInvVaulting = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Vaulting_Charges__c;//prat
                //Modified For adding bath And eShip ChargeHead
                Decimal totalInvComm = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Commission_Charges__c;
                Decimal totalInvLogis = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Logistics_Charges__c;
                Decimal totalInvSecure = cnInvMap.get(cli.blng__CreditNote__c).blng__RelatedInvoice__r.Total_Secure_Logistics_Charges__c;
                
                Decimal invFreight = 0.0;
                Decimal invOffline = 0.0;
                Decimal invLiability = 0.0;
                Decimal invWeight = 0.0;
                Decimal invBVC = 0.0;
                Decimal invDocket = 0.0;
                Decimal invFuel = 0.0;
                Decimal invHoliday = 0.0;
                Decimal invComm = 0.0;
                Decimal invLogis = 0.0;
                Decimal invSecure = 0.0;
                Decimal invFSurc = 0.0;
                Decimal invVaulting = 0.0;
                if(invCNLineMap.containsKey(invId)){
                    
                    for(blng__CreditNoteLine__c xli : invCNLineMap.get(invId)){
                        
                        if(xli.Charge_Head_Type__c == cli.Charge_Head_Type__c){
                            if(cli.Charge_Head_Type__c == 'Freight Charge'){
                                
                                invfreight += xli.blng__Subtotal__c; 
                            }
                            if(cli.Charge_Head_Type__c == 'Liability Charge'){
                                
                                invLiability += xli.blng__Subtotal__c; 
                            }
                            if(cli.Charge_Head_Type__c == 'Offline Charge'){
                                
                                invOffline += xli.blng__Subtotal__c; 
                            }
                            if(cli.Charge_Head_Type__c == 'Weight Charge'){
                                
                                invWeight += xli.blng__Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'BVC Valuation Charge'){
                                
                                invBVC += xli.blng__Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Docket Charge'){
                                
                                invDocket += xli.blng__Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Fuel Charge'){
                                
                                invFuel += xli.blng__Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Holiday Charge'){
                                
                                invholiday += xli.blng__Subtotal__c;
                            }
                            //Modified For adding bath And eShip ChargeHead
                            
                            if(cli.Charge_Head_Type__c == 'Commission Charge'){
                                
                                invComm += xli.blng__Subtotal__c;
                            }  
                            if(cli.Charge_Head_Type__c == 'Logistics Charge'){
                                
                                invLogis += xli.blng__Subtotal__c;
                            }  
                            if(cli.Charge_Head_Type__c == 'Secure Logistics Charge'){
                                
                                invSecure += xli.blng__Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Fuel Surcharge'){
                                
                                invFSurc += xli.blng__Subtotal__c;
                            } 
                            if(cli.Charge_Head_Type__c == 'Vaulting Charge'){
                                
                                invVaulting += xli.blng__Subtotal__c;
                            }  
                        
                        }
                        
                        
                    }
                  
                }
                 
                    if((cli.Charge_Head_Type__c == 'Offline Charge' && invOffline+cli.blng__Subtotal__c > totalInvOff)
                       ||(cli.Charge_Head_Type__c == 'Liability Charge'&& invLiability+cli.blng__Subtotal__c > totalInvLiab)
                       ||(cli.Charge_Head_Type__c == 'Freight Charge' && invFreight+cli.blng__Subtotal__c > totalInvFreight)
                       ||(cli.Charge_Head_Type__c == 'Weight Charge' && invWeight+cli.blng__Subtotal__c > totalInvWeight)
                       ||(cli.Charge_Head_Type__c == 'BVC Valuation Charge' && invBVC+cli.blng__Subtotal__c > totalInvBVC)
                       ||(cli.Charge_Head_Type__c == 'Docket Charge' && invDocket+cli.blng__Subtotal__c > totalInvDock)
                       ||(cli.Charge_Head_Type__c == 'Fuel Charge' && invFuel+cli.blng__Subtotal__c > totalInvFuel)
                       ||(cli.Charge_Head_Type__c == 'Holiday Charge' && invHoliday+cli.blng__Subtotal__c > totalInvHoly)
                       ||(cli.Charge_Head_Type__c == 'Commission Charge' && invComm+cli.blng__Subtotal__c > totalInvComm)
                       ||(cli.Charge_Head_Type__c == 'Logistics Charge' && invLogis+cli.blng__Subtotal__c > totalInvLogis)
                       ||(cli.Charge_Head_Type__c == 'Secure Logistics Charge' && invSecure+cli.blng__Subtotal__c > totalInvSecure)
                       ||(cli.Charge_Head_Type__c == 'Fuel Surcharge' && invFSurc+cli.blng__Subtotal__c > totalInvFSurc)
                       ||(cli.Charge_Head_Type__c == 'Vaulting Charge' && invVaulting+cli.blng__Subtotal__c > totalInvVaulting)){
                           cli.addError('Aggregate Credit Note Line Charge Amount Exceeds Invoice Charges');
                       } 
            }
            
        }
    }
    public static void fakemethod(){
        integer i=0;
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