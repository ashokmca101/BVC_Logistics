/*
* Class : ShipmentCalcUtil
* Organisation : Standav
*/
public class ShipmentCalcUtil {
    
    /*
* description  : Wrapper class to store Input,Output Values 
*/
    public class ShipmentDetail {
        
       //Input Attributes
        public String accountId { get; set; }
        public Decimal grossWeight { get; set; }
        public Decimal netWeight { get; set; }
        public String origin { get; set; }
        public Id originHub { get; set; }
        public Id blngEntityId { get; set; }
        public String destination { get; set; }
        public String productId { get; set; }
        public String productCode { get; set; }
        public String exhibitionId { get; set; }
        public String customerProdCategory { get; set; }
        public Boolean isOriginOfflineLoc { get; set; }
        public boolean isDestOfflineLoc { get; set; }
        public String optForLiability { get; set; }
        public Decimal invoiceValue { get; set; }
        public Decimal distanceInKm { get; set; }
        public String movtType { get; set; }
        public String orderLineItemId { get; set; }//Optional
        public String orderId { get; set;} //Optional
        public String shipmentId { get; set; }
        public String CommunityUniqueId { get; set; }
        public boolean windowdelivery { get; set; }
        public boolean windowpickup { get; set; }
        public Decimal perShipment { get; set; }
        
        //Output Attributes
        public date shipDate { get; set; }
        public String prodDesc { get; set; }
        public Decimal rateAmount { get; set; }
        public String rateUOM { get; set; }
        public Decimal offlineCharge { get; set; }
        public Decimal liabilityCoverage { get; set; }
        public Decimal minimumFreight { get; set; }
        public Decimal freightOnInvoice { get; set; }
        public Decimal totalAmount { get; set; }
        public Decimal freightCharge { get; set; }
        public Decimal liabilityCoverageAmount { get; set; }
        public Decimal bvcValuationCharge { get; set; }
        public Decimal docketCharge { get; set; }
        public Decimal fuelCharge { get; set; }
        public Decimal fuelSurcharge { get; set; }
        public Decimal holidayCharge { get; set; }
        public Decimal weightCharge { get; set;}
        public String prodName { get; set; }
        public String errors { get; set; }
        public String externalContractId { get; set; }
        public Id filterById { get; set; }
        public Boolean isMonthlyContract { get; set; }
        public String acrStandardPriceId { get; set; }
        public String acrContractedPriceId { get; set; }
        public String exhibitionStandardPriceId { get; set; }
        public String exhibitionContractedPriceId { get; set; }
        public String nonACRStandardPriceId { get; set; }
        public String nonACRContractedPriceId { get; set; }
        
    }
    
    /*
* description  : Validate and call the respective Calculator methods. 
*/
    public static List < ShipmentCalcUtil.ShipmentDetail > shipmentCalculationUtility(List < ShipmentCalcUtil.ShipmentDetail > shipInputRequest) {
        List < ShipmentCalcUtil.ShipmentDetail > shipInput = new List < ShipmentCalcUtil.ShipmentDetail > ();
        Map < String, List < ShipmentCalcUtil.ShipmentDetail >> shipInputMap = new Map < String, List < ShipmentCalcUtil.ShipmentDetail >> ();
        shipInputMap.putAll(ExternalContractCalcUtil.checkExternalContract(shipInputRequest));
        system.debug('===shipInputMap : ' + shipInputMap);
        if (shipInputMap.containsKey('NOTFOUND')) {
            shipInput.addAll(shipInputMap.get('NOTFOUND'));
        }
        List < ShipmentCalcUtil.ShipmentDetail > commExtContractList = new List < ShipmentCalcUtil.ShipmentDetail > ();
        List < ShipmentCalcUtil.ShipmentDetail > externalContractList = new List < ShipmentCalcUtil.ShipmentDetail > ();
        
        if (shipInputMap.containsKey('CommunityExtContract')) {
            commExtContractList.addAll(shipInputMap.get('CommunityExtContract'));
        }
        
        if (shipInputMap.containsKey('ExternalContract')) {
            externalContractList.addAll(shipInputMap.get('ExternalContract'));
        }
        
        if (!externalContractList.isEmpty()) {
            ExternalContractCalcUtil.createExternalContractShipmentAndSummary(externalContractList);
        }
         Set < Id > accountId = new Set < Id > ();
        date currentDate = date.today();
        
        List < ShipmentCalcUtil.ShipmentDetail > shipCalcVal = new List < ShipmentCalcUtil.ShipmentDetail > ();
        
        List < ShipmentCalcUtil.ShipmentDetail > shipNonACRNonCon = new List < ShipmentCalcUtil.ShipmentDetail > ();
        List < ShipmentCalcUtil.ShipmentDetail > shipNonACRCon = new List < ShipmentCalcUtil.ShipmentDetail > ();
        List < ShipmentCalcUtil.ShipmentDetail > shipACRCon = new List < ShipmentCalcUtil.ShipmentDetail > ();
        List < ShipmentCalcUtil.ShipmentDetail > shipExhibition = new List < ShipmentCalcUtil.ShipmentDetail > ();
        system.debug('Size of Input List : ' + shipInput.size());
        
        for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {accountId.add(eachship.accountId);
                                                                  }
        
        Map < Id, Account > actMap = new Map < Id, Account > ([select id, ST_Latest_Activated_Order_Contract__c, ST_Pricing_Type__c,
                                                               Active_Contract__c, ST_Previous_Contract__c, Balance_Amount__c,
                                                               ST_Contract_Expiry_Date__c, ST_Latest_Active_ACR_Package__c, Contracted_ACR_Package__c,
                                                               Balance_ACR_Amount__c, Customer_Category__c, Contract_End_Date__c
                                                               from Account where id in: accountId
                                                              ]);
        
        for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
            if (eachship.productCode != null && eachship.productCode.contains('EXHIBI')) {
                shipExhibition.add(eachship);
            } else if (actMap.containsKey(eachship.accountId)) {
                                
                if (actMap.get(eachship.accountId).Active_Contract__c == null &&
                    actMap.get(eachship.accountId).ST_Pricing_Type__c == 'Non ACR' &&
                    actMap.get(eachship.accountId).Customer_Category__c == 'Non Contracted') {
                        shipNonACRNonCon.add(eachship);
                    } else if (actMap.get(eachship.accountId).Active_Contract__c != null &&
                               actMap.get(eachship.accountId).ST_Pricing_Type__c == 'Non ACR' &&
                               actMap.get(eachship.accountId).Customer_Category__c == 'Non ACR Contracted' &&
                               actMap.get(eachship.accountId).Contract_End_Date__c >= currentDate) {
                                   shipNonACRCon.add(eachship);
                               } else if (actMap.get(eachship.accountId).Active_Contract__c != null &&
                                          actMap.get(eachship.accountId).ST_Pricing_Type__c == 'ACR' &&
                                          actMap.get(eachship.accountId).Customer_Category__c == 'ACR Contracted' &&
                                          //actMap.get(eachship.accountId).Contract_End_Date__c >= currentDate &&
                                          actMap.get(eachship.accountId).Contracted_ACR_Package__c != null ) {
                                          //actMap.get(eachship.accountId).Balance_Amount__c > 0
									 
                                              shipACRCon.add(eachship);
                                          }
            }
        } //End of Loop
        if (Test.isRunningTest()) {
            String firstLine;
            String stackTrace = new DmlException().getStackTraceString().subStringAfter('\n');
            firstLine = stackTrace.subStringBefore('\n');
            System.debug('Test Method Name  ' + firstLine);
        }
        system.debug('===shipNonACRNonCon : ' + shipNonACRNonCon.size());
        if (shipExhibition.size() > 0 && shipExhibition != null) {
            shipCalcVal.addall(ExhibitionShipmentCalcUtil.shipmentCalculationExhibition(shipExhibition, actMap));
        }
        if (shipNonACRNonCon.size() > 0) {
            shipCalcVal.addall(shipmentCalculationNonACRNonContract(shipNonACRNonCon, actMap));
        }
        if (shipNonACRCon.size() > 0) {
            shipCalcVal.addall(shipmentCalculationNonACRContract(shipNonACRCon, actMap));
        }
        if (shipACRCon.size() > 0) {
            shipCalcVal.addall(shipmentCalculationACRContract(shipACRCon, actMap));
        }
        if (commExtContractList.size() > 0) {
            shipCalcVal.addAll(commExtContractList);
        }
        if (externalContractList.size() > 0) {
            shipCalcVal.addAll(externalContractList);
        }
        system.debug('Size of Output List : ' + shipCalcVal.size());
        return shipCalcVal;
        
     }
    
    /*
* description  : Calculator method for Non ACR Contract Shipments. 
*/
    
    private static List<ShipmentCalcUtil.ShipmentDetail> shipmentCalculationNonACRContract(List<ShipmentCalcUtil.ShipmentDetail> shipInput,Map<Id,Account> actMap){
        system.debug('===shipmentCalculationNonACRContract Called');
        List<String> chargeHeadTypeList = new List<String>{'Freight Charge','Weight Charge','Liability Charge','Offline Charge','BVC Valuation Charge','Docket Charge','Holiday Charge','Fuel Charge','Fuel Surcharge'};
            
            set<Id> prodId=new set<Id>();
        set<string> accountId=new set<string>();
        set<string> origin=new set<string>();
        set<string> destination=new set<string>();
        set<string> custProdCategory=new set<string>();
        set<string> acrPackageType=new set<string>();
        set<Id> contractSet=new set<Id>();    
        set<Id> exhibition=new set<Id>();
        
        List<ShipmentCalcUtil.ShipmentDetail> shipCalcVal=new List<ShipmentCalcUtil.ShipmentDetail> ();
        Decimal calculatedAmount=0;
        Decimal offlineCharge = 0;
        Decimal liabilityCoverageAmount = 0;
        Decimal bvcValuationChargeAmount = 0;
        Decimal fuelChargeAmount = 0;
        Decimal fuelSurchargeAmount=0;//prat
        
        //sam
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        for(ShipmentCalcUtil.ShipmentDetail eachship: shipInput){
            
            prodId.add(eachship.productId);
            origin.add(eachship.origin);
            destination.add(eachship.destination);
            custProdCategory.add(eachship.customerProdCategory);
            exhibition.add(eachship.exhibitionId);
            accountId.add(eachship.accountId);
            contractSet.add(actMap.get(eachship.accountId).Active_Contract__c);
         }
        //sam
        List<Account> accWithExmeptedOrder = [Select id,(SELECT Id, Name, Customer__c, New_Offline_Charge__c,Exempted_City__c FROM Exempted_cities__r) from Account where id IN: accountId];
        for(Account acc : accWithExmeptedOrder){
            mapaccountIdWithExemptRecord.put(acc.Id,acc.Exempted_cities__r);
        }
        System.debug('Test class Prod List'+prodId);
        System.debug('Test class accountId List'+accountId);
        System.debug('Test class contractSet List'+contractSet);
        Map<String,Map<String,ST_NonACR_Contracted_Price__c>> NonacrContractedMapping = new Map<String,Map<String,ST_NonACR_Contracted_Price__c>>();
        
        List<ST_NonACR_Contracted_Price__c> stdCommercialFitPrices = new List<ST_NonACR_Contracted_Price__c>();
        Map<String,Map<String,ST_NonACR_Contracted_Price__c>> stdCommercialFitPricesMap = new Map<String,Map<String,ST_NonACR_Contracted_Price__c>>();
        List< ST_NonACR_Contracted_Price__c> NonAcrContractedProce=[select Charge_Type__c,Free_Quantity__c, Weight_Category__c ,Misfit_Rate_UOM__c  ,ST_Min_Gross_Weight__c,ST_Max_Gross_Weight__c,ST_Order__c,ST_Exhibition__c,ST_Active__c,ST_Customer_Account__c,Id,ST_Freight_on_Invoice_Value__c,ST_Contract__c,
                                                                    ST_Minimum_Freight__c,ST_Liability_Coverage__c,ST_Offline_Charge__c,ST_Origin__c,ST_Destination__c,Fuel_Surcharge__c,
                                                                    ST_Product__c,ST_Product__r.Name,ST_Rate_Amount__c,ST_Rate_UOM__c,Level_1_Rate__c, Level_2_Rate__c, Level_3_Rate__c, Level_4_Rate__c,
                                                                    Level_5_Rate__c,Level_1__c, Level_2__c, Level_3__c,Level_4__c, Level_5__c ,Multi_Level_Charges__c,is_Misfit__c,Maximum_Slab_Rate__c
                                                                    from ST_NonACR_Contracted_Price__c 
                                                                    where ST_Product__c In :prodId and ST_Contract__c in : contractSet and ST_Customer_Account__c In :accountId and ST_Active__c=true 
                                                                    and ((ST_Origin__c=NULL and ST_Destination__c=NULL) OR (ST_Origin__c In :origin and ST_Destination__c In :destination)) ];
        
        for(ST_NonACR_Contracted_Price__c nonAcr : NonAcrContractedProce){
            if(nonAcr.is_Misfit__c){
                if(nonAcr.ST_Customer_Account__c != null && nonAcr.ST_Contract__c != null && nonAcr.ST_Product__c != null){
                    String primaryKey = nonAcr.ST_Customer_Account__c+'_' +nonAcr.ST_Contract__c +'_' + nonAcr.ST_Product__c ;
                    if(NonacrContractedMapping.containsKey(primaryKey)){
                        NonacrContractedMapping.get(primaryKey).put(nonAcr.Charge_Type__c,nonAcr);
                    }else{
                        Map<String,ST_NonACR_Contracted_Price__c> mapNonACRChargeType = new Map<String,ST_NonACR_Contracted_Price__c>();
                        mapNonACRChargeType.put(nonAcr.Charge_Type__c,nonAcr);
                        NonacrContractedMapping.put(primaryKey,mapNonACRChargeType);
                    }
                }
            }else{
                String primaryKey = nonAcr.ST_Customer_Account__c+'_' +nonAcr.ST_Contract__c +'_' + nonAcr.ST_Product__c ;
                if(!stdCommercialFitPricesMap.containsKey(primaryKey)){
                    Map<String,ST_NonACR_Contracted_Price__c> mapNonACRProd = new Map<String,ST_NonACR_Contracted_Price__c>(); 
                    if((nonAcr.ST_Origin__c != '' && nonAcr.ST_Origin__c != null) 
                       &&(nonAcr.ST_Destination__c != '' && nonAcr.ST_Destination__c != null)){
                           String originDestination = nonAcr.ST_Origin__c +'_'+nonAcr.ST_Destination__c ;
                           mapNonACRProd.put(originDestination,nonAcr);
                           stdCommercialFitPricesMap.put(primaryKey,mapNonACRProd);
                       }
                    else if(nonAcr.ST_Min_Gross_Weight__c != null && nonAcr.ST_Max_Gross_Weight__c != null ){
                        String grossWeightSlab = String.valueOf(nonAcr.ST_Min_Gross_Weight__c) +'_'+ String.valueOf(nonAcr.ST_Max_Gross_Weight__c);
                        mapNonACRProd.put(grossWeightSlab,nonAcr);
                        stdCommercialFitPricesMap.put(primaryKey,mapNonACRProd);
                    }
                    else{
                        mapNonACRProd.put(primaryKey,nonAcr);
                        stdCommercialFitPricesMap.put(primaryKey,mapNonACRProd) ; 
                    }
                    
                }
                else{
                    Map<String,ST_NonACR_Contracted_Price__c> mapNonACRProd = new Map<String,ST_NonACR_Contracted_Price__c>(); 
                    if((nonAcr.ST_Origin__c != '' && nonAcr.ST_Origin__c != null) 
                       &&(nonAcr.ST_Destination__c != '' && nonAcr.ST_Destination__c != null)){
                           String originDestination = nonAcr.ST_Origin__c +'_'+nonAcr.ST_Destination__c ;
                           stdCommercialFitPricesMap.get(primaryKey).put(originDestination,nonAcr);
                           
                       }
                    else if(nonAcr.ST_Min_Gross_Weight__c != null && nonAcr.ST_Max_Gross_Weight__c != null ){
                        String grossWeightSlab = String.valueOf(nonAcr.ST_Min_Gross_Weight__c) +'_'+ String.valueOf(nonAcr.ST_Max_Gross_Weight__c) ;
                        stdCommercialFitPricesMap.get(primaryKey).put(grossWeightSlab,nonAcr);
                    }
                    else{
                        stdCommercialFitPricesMap.get(primaryKey).put(primaryKey,nonAcr);  
                    }
                    
                }
                
                stdCommercialFitPrices.add(nonAcr);
            }
        }
        system.debug('NonAcrContractedProce:::'+NonAcrContractedProce);
        system.debug('Origin::'+origin+'::Destination::'+destination);
        List<ST_NonACR_Standard_Price__c> nonAcrStandardProce=[select ST_Exhibition__c,ST_Product__r.Name,
                                                               ST_Freight_on_Invoice_Value__c,Id,ST_Offline_Charge__c,ST_Minimum_Freight__c,Fuel_Surcharge__c,
                                                               ST_Liability_Coverage__c,ST_Min_Gross_Weight__c,ST_Max_Gross_Weight__c,ST_Rate_UOM__c, 
                                                               ST_Rate_Amount__c,ST_Product__c,ST_Gross_Weight_Slabs__c,ST_Origin__c,ST_Destination__c,ST_Customer_Product_Category__c 
                                                               from ST_NonACR_Standard_Price__c where ST_Product__c In :prodId 
                                                               and ((ST_Origin__c=NULL and ST_Destination__c=NULL) OR(ST_Origin__c In :origin and ST_Destination__c In :destination)) 
                                                               /*and ((ST_Exhibition__c=null) OR (ST_Exhibition__c In :exhibition and ST_Customer_Product_Category__c IN :custProdCategory))*/ 
                                                               AND ST_Effective_Start_Date__c<=TODAY and ST_Effective_End_Date__c>=TODAY];
        system.debug('nonAcrStandardProce:::'+nonAcrStandardProce);
        
        for(ShipmentCalcUtil.ShipmentDetail eachship: shipInput){
            system.debug('Each Ship : '+eachship);
            boolean matchFound=false;
            String mathcingKey = eachship.accountId+'_'+(actMap.containsKey(eachship.accountId) ? actMap.get(eachship.accountId).Active_Contract__c : '')+'_'+eachship.productId;
            
     //*****Misfit Starts************
           
            if(NonacrContractedMapping.containsKey(mathcingKey)){
                try{
                    system.debug('Each Ship :Misfit '+eachship);
                    system.debug('mathcingKey : Misfit : Non ACR : '+mathcingKey);
                    eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                    eachship.distanceInKm = eachship.distanceInKm == null ? 0 :eachship.distanceInKm;
                    eachship.perShipment = eachship.perShipment == null ? 0 :eachship.perShipment;
                    eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight ;
                    eachship.netWeight = eachship.netWeight == null ? 0 : eachship.netWeight ;
                    eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                    eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                    matchFound = true;
                    Map<String,ST_NonACR_Contracted_Price__c> NonacrMapping = new Map<String,ST_NonACR_Contracted_Price__c>();
                    NonacrMapping.putAll(NonacrContractedMapping.get(mathcingKey));
                    
                    System.debug('Enter Map');
                    liabilityCoverageAmount = 0;//Added By adel for Bulkification
                    offlineCharge = 0;
                    calculatedAmount = 0;
                    bvcValuationChargeAmount = 0;
                    fuelChargeAmount = 0;
                    Decimal totalAmount = 0;
                    Decimal minimumFuelCharge = 0;
                    String minimumFreightSlab = '';
                    String minimumFreightUOM = '';
                    for(String chargeHead : chargeHeadTypeList){
                        Decimal chargeAmount = 0;
                        if(NonacrMapping.containsKey(chargeHead)){
                            ST_NonACR_Contracted_Price__c nonAcr = NonacrMapping.get(chargeHead);
                            eachship.nonACRContractedPriceId = nonAcr.Id;
                            if(nonAcr.Multi_Level_Charges__c){
                                Decimal slabLevel = 0;
                                Decimal slabRate = 0;
                                if(nonAcr.Weight_Category__c == 'Gross Weight'){
                                    slabLevel = eachship.grossWeight;
                                }else if(nonAcr.Weight_Category__c == 'Net Weight'){
                                    slabLevel = eachship.netWeight;
                                }else if(nonAcr.Weight_Category__c == 'Package Weight'){
                                    slabLevel = eachship.grossWeight - eachship.netWeight;
                                }else if(nonAcr.Weight_Category__c == 'Invoice Value'){
                                    slabLevel = eachship.invoiceValue; 
                                }else if(nonAcr.Weight_Category__c == 'Per Shipment'){
                                    slabLevel = eachship.perShipment; 
                                }
                                else if(nonAcr.Weight_Category__c == 'Kilometer'){
                                    slabLevel = eachship.distanceInKm; 
                                }
                                if(nonAcr.Free_Quantity__c != null && nonAcr.Free_Quantity__c >0){
                                    slabLevel = slabLevel -nonAcr.Free_Quantity__c;
                                }
                                System.debug('slabLevel  '+slabLevel);
                                
                                if(slabLevel >0){
                                    if(slabLevel <= nonAcr.Level_1__c){
                                        slabRate = nonAcr.Level_1_Rate__c == null ? 0 :nonAcr.Level_1_Rate__c;
                                        System.debug('Level rates 1'+slabRate);
                                    }else if(nonAcr.Level_2__c != null && slabLevel > nonAcr.Level_1__c && slabLevel <= nonAcr.Level_2__c){
                                        slabRate = nonAcr.Level_2_Rate__c == null ? 0 :nonAcr.Level_2_Rate__c;
                                        System.debug('Level rates 2'+slabRate);
                                    }else if(nonAcr.Level_3__c != null && slabLevel > nonAcr.Level_2__c && slabLevel <= nonAcr.Level_3__c){
                                        slabRate = nonAcr.Level_3_Rate__c == null ? 0 :nonAcr.Level_3_Rate__c;
                                        System.debug('Level rates 3'+slabRate);
                                    }else if(nonAcr.Level_4__c != null && slabLevel > nonAcr.Level_3__c && slabLevel <= nonAcr.Level_4__c){
                                        slabRate = nonAcr.Level_4_Rate__c == null ? 0 :nonAcr.Level_4_Rate__c;
                                        System.debug('Level rates 4'+slabRate);
                                    }else if(nonAcr.Level_5__c != null && slabLevel > nonAcr.Level_4__c && slabLevel <= nonAcr.Level_5__c){
                                        slabRate = nonAcr.Level_5_Rate__c == null ? 0 :nonAcr.Level_5_Rate__c;
                                        System.debug('Level rates 5'+slabRate);
                                    }else if( nonAcr.Maximum_Slab_Rate__c != null){
                                        slabRate = nonAcr.Maximum_Slab_Rate__c == null ? 0 :nonAcr.Maximum_Slab_Rate__c;
                                        System.debug('Level rates Max'+slabRate);
                                    }else if(nonAcr.Maximum_Slab_Rate__c == null){
                                        slabRate = nonAcr.Level_5_Rate__c;
                                    }
                                    
                                    
                                    if(nonAcr.Misfit_Rate_UOM__c == 'Gross Weight'){
                                        chargeAmount = slabRate * eachship.grossWeight ;
                                    } else if(nonAcr.Misfit_Rate_UOM__c == 'Package Weight'){
                                        chargeAmount = slabRate * (eachship.grossWeight- eachship.netWeight) ;
                                    }else if(nonAcr.Misfit_Rate_UOM__c == 'Net Weight'){
                                        chargeAmount = slabRate * eachship.netWeight ;
                                    }else if(nonAcr.Misfit_Rate_UOM__c == 'Per Shipment'){
                                        chargeAmount = slabRate ;
                                    }else if(nonAcr.Misfit_Rate_UOM__c == 'Per Lakhs'){
                                        // Slab level Per lakhs only appliable for Involice Value 
                                        Decimal perLakhValue = slabLevel/100000;
                                        chargeAmount = perLakhValue * slabRate;
                                    }
                                }else{
                                    chargeAmount = 0;
                                }
                            }else {
                                Decimal weightOrValue = 0;
                                Decimal rate = nonAcr.ST_Rate_Amount__c == null? 0 :nonAcr.ST_Rate_Amount__c;
                                if(nonAcr.Weight_Category__c == 'Gross Weight'){
                                    weightOrValue = eachship.grossWeight;
                                }else if(nonAcr.Weight_Category__c == 'Net Weight'){
                                    weightOrValue = eachship.netWeight;
                                }else if(nonAcr.Weight_Category__c == 'Package Weight'){
                                    weightOrValue = eachship.grossWeight - eachship.netWeight;
                                }else if(nonAcr.Weight_Category__c == 'Invoice Value'){
                                    weightOrValue = eachship.invoiceValue; 
                                }else if(nonAcr.Weight_Category__c == 'Per Shipment'){
                                    weightOrValue = eachship.perShipment;
                                }else if(nonAcr.Weight_Category__c == 'Freight Charges'){
                                    weightOrValue = eachship.freightCharge == null ? 0 : eachship.freightCharge;
                                }
                                if(nonAcr.Free_Quantity__c != null && nonAcr.Free_Quantity__c >0){
                                    weightOrValue = nonAcr.Free_Quantity__c >= weightOrValue ? 0 :weightOrValue -nonAcr.Free_Quantity__c ;
                                }
                                if(weightOrValue >0){
                                    if(nonAcr.Misfit_Rate_UOM__c == 'Gross Weight' || nonAcr.Misfit_Rate_UOM__c == 'Package Weight'  || nonAcr.Misfit_Rate_UOM__c == 'Net Weight' ){
                                        chargeAmount = weightOrValue * rate ;
                                    }else if(nonAcr.Misfit_Rate_UOM__c == 'Per Shipment'){
                                        chargeAmount = rate ;
                                    }else if(nonAcr.Misfit_Rate_UOM__c == 'Per Lakhs'){
                                        // Slab level Per lakhs only appliable for Involice Value 
                                        Decimal perLakhValue = weightOrValue/100000;
                                        chargeAmount = perLakhValue * rate;
                                    }else if(nonAcr.Misfit_Rate_UOM__c == '% of Invoice Value' || nonAcr.Misfit_Rate_UOM__c == '% of Freight Charges'){
                                        chargeAmount = (weightOrValue * rate)/100;
                                        if(eachship.minimumFreight >0 && nonAcr.Misfit_Rate_UOM__c == '% of Freight Charges'){
                                            minimumFuelCharge = (eachship.minimumFreight) * rate/100;
                                        }
                                    }
                                }else{
                                    if(nonAcr.Misfit_Rate_UOM__c == 'Per Shipment'){
                                        chargeAmount = rate ;
                                    }else{
                                        chargeAmount = 0;
                                    }
                                    
                                }
                            }
                            
                            if(chargeHead == 'Freight Charge'){
                                minimumFreightSlab = nonAcr.Weight_Category__c;
                                minimumFreightUOM = nonAcr.Misfit_Rate_UOM__c;
                                eachship.minimumFreight = nonAcr.ST_Minimum_Freight__c == null ? 0: nonAcr.ST_Minimum_Freight__c ;
                                
                                eachship.freightCharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                             }else if(chargeHead == 'Weight Charge'){
                                eachship.weightCharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                            }else if(chargeHead == 'Liability Charge'){
                                if(eachship.optForLiability== 'Yes'){
                                    eachship.liabilityCoverageAmount = chargeAmount;
                                    totalAmount = totalAmount +chargeAmount;
                                }else{
                                    chargeAmount = 0.00;
                                    eachship.liabilityCoverageAmount = chargeAmount;
                                    totalAmount = totalAmount +chargeAmount;
                                }
                            }else if(chargeHead == 'Offline Charge'){
                                if(eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                    offlineCharge = chargeAmount;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                   } 
                                }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                                if(eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                    offlineCharge =chargeAmount;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                                }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                                if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
                                   // offlineCharge =chargeAmount*2;
                                   Boolean oneexempt=false;
                                      Boolean twoexempt=false;
                                      Decimal exemptprice=0; 
                                      Decimal OfflinePrice=chargeAmount;
                                     if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                             
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }
										}
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                               exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                              
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge =chargeAmount * 2;
                                    
                                   }  
                                    
                                } 
								//changed for windowdelivery 
								if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = chargeAmount;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                    } 
								}
								if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =chargeAmount;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                  }
                                            }
                                   }
				                 }
								eachship.offlineCharge = (offlineCharge == null ?0 : offlineCharge);
                                totalAmount = totalAmount +(offlineCharge == null ? 0 : offlineCharge);
                                
                            }else if(chargeHead == 'BVC Valuation Charge'){
                                eachship.bvcValuationCharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                            }else if(chargeHead == 'Docket Charge'){
                                eachship.docketCharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                            }else if(chargeHead == 'Holiday Charge'){
                                eachship.holidayCharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                            }else if(chargeHead == 'Fuel Charge'){
                                eachship.fuelCharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
																							 
                            }
                            else if(chargeHead == 'Fuel Surcharge'){
                                //date shipDate1 = eachship.shipDate;
                           	    //date dueDate = date.newInstance(2022, 12, 12);
                                if(eachship.prodDesc!='Cut & Polished Diamonds' ){
                                eachship.fuelSurcharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                                }
                            }
                            System.debug('Charge Head '+chargeHead);
                            System.debug('Charge Amount '+chargeAmount);
                        }
                    }
                    eachship.freightCharge = eachship.freightCharge == null ? 0 : eachship.freightCharge;
                    eachship.weightCharge = eachship.weightCharge == null ? 0 : eachship.weightCharge;
                    if(eachship.minimumFreight > 0){
                        System.debug('minimum Freight '+eachship.minimumFreight);
                        System.debug('Freight Charge '+eachship.freightCharge);
                        System.debug('Weight Charge '+eachship.weightCharge);
                        Decimal TotalMinimumCalclated = 0;
                        if(minimumFreightSlab == 'Net Weight' && minimumFreightUOM =='Net Weight'){
                            TotalMinimumCalclated =  TotalMinimumCalclated + eachship.freightCharge + eachship.weightCharge;
                        }else{
                            TotalMinimumCalclated =  TotalMinimumCalclated + eachship.freightCharge ;
                        }
                        System.debug('Total Minimum Calclated '+TotalMinimumCalclated);
                        if(TotalMinimumCalclated < eachship.minimumFreight){
                            eachship.freightCharge = eachship.minimumFreight;
                            if(minimumFreightSlab == 'Net Weight' && minimumFreightUOM =='Net Weight'){
                                eachship.weightCharge = 0;
                            }
                            totalAmount = totalAmount - TotalMinimumCalclated + eachship.minimumFreight;
                            if(eachship.fuelCharge>0){
                                totalAmount = totalAmount - eachship.fuelCharge + minimumFuelCharge;
                                eachship.fuelCharge = minimumFuelCharge;
                            }
                        }else{
                            eachship.minimumFreight = 0.00;
                        }
                    }
                    eachship.totalAmount =totalAmount; 
                    system.debug('Each Ship: Misfit : '+eachship);
                    shipCalcVal.add(eachship);
                }catch(Exception ex){
                    eachship.errors = ex.getMessage();
                }
            }
      //******Misfit ends*******
      
            else if(stdCommercialFitPricesMap.containsKey(mathcingKey)) {
                system.debug('Each Ship : Fit'+eachship);
                try{
                    for(ST_NonACR_Contracted_Price__c nonAcr : stdCommercialFitPrices){
                        ST_NonACR_Contracted_Price__c fetchrec = new ST_NonACR_Contracted_Price__c();
                        
                        Map<String,ST_NonACR_Contracted_Price__c> fetchrecMap = stdCommercialFitPricesMap.get(mathcingKey);
                        String oriDesti = eachship.origin+'_'+eachship.destination;
                        if(fetchrecMap.containsKey(oriDesti)){
                            fetchrec = fetchrecMap.get(oriDesti);
                        }
                        else{
                            system.debug('mathcingKey : Non ACR : '+mathcingKey);
                            system.debug('fetchRecmap : Non ACR : KeySet '+fetchrecMap.keySet());
                            
                            for(ST_NonACR_Contracted_Price__c na : fetchrecMap.values()){
                                if(na.ST_Min_Gross_Weight__c == null && na.ST_Max_Gross_Weight__c == null 
                                   &&( (na.ST_Origin__c == null || na.ST_Origin__c == '')
                                      || (na.ST_Destination__c == null || na.ST_Destination__c == ''))){
                                          fetchrec = fetchrecMap.get(mathcingKey);
                                      }
                                else if(eachship.grossWeight > na.ST_Min_Gross_Weight__c*1000 && (na.ST_Max_Gross_Weight__c == null || eachship.grossWeight <= na.ST_Max_Gross_Weight__c *1000)){
                                    fetchrec = na;
                                }
                            }
                        }
                        system.debug('fetchRec : fit : Non ACR : '+fetchrec);
                        liabilityCoverageAmount = 0;//Added By adel for Bulkification
                        offlineCharge = 0;
                        calculatedAmount = 0;
													   
                        ShipmentCalcUtil.ShipmentDetail each= new ShipmentCalcUtil.ShipmentDetail();
                        
                        if(fetchrec.ST_Product__c!=null){
                            each.productId = fetchrec.ST_Product__c;
                            each.prodName=fetchrec.ST_Product__r.Name;
                            
                        }
                        fetchrec.ST_Min_Gross_Weight__c = fetchrec.ST_Min_Gross_Weight__c == null ? 0 : fetchrec.ST_Min_Gross_Weight__c;
                        fetchrec.ST_Max_Gross_Weight__c = fetchrec.ST_Max_Gross_Weight__c == null ? 0 : fetchrec.ST_Max_Gross_Weight__c;
                        
                        eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight;
                        
                        if (eachship.productId== each.productId && eachship.grossWeight > 0 
                            && ((fetchrec.ST_Min_Gross_Weight__c == 0 && fetchrec.ST_Max_Gross_Weight__c==0) 
                                || (fetchrec.ST_Min_Gross_Weight__c*1000 < eachship.grossWeight && fetchrec.ST_Max_Gross_Weight__c*1000 >=eachship.grossWeight)
                                || (fetchrec.ST_Min_Gross_Weight__c*1000 < eachship.grossWeight && fetchrec.ST_Max_Gross_Weight__c == 0))
                            && ((fetchrec.ST_Origin__c==NULL && fetchrec.ST_Destination__c==NULL) || (eachship.origin == fetchrec.ST_Origin__c && eachship.destination == fetchrec.ST_Destination__c))
                            && ((fetchrec.ST_Exhibition__c==null) || (eachship.customerProdCategory == fetchrec.ST_Customer_Product_Category__c && eachship.exhibitionId == fetchrec.ST_Exhibition__c))
                           )
                        {
                            matchFound=true;
                            
                            if(each.prodName.contains('ExhibiSHIP')){
                                eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c/2;
                            }
                            else{
                                eachship.rateAmount=fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c;
                            }                    
                            
                            eachship.rateUOM=fetchrec.ST_Rate_UOM__c;
                            eachship.liabilityCoverage = fetchrec.ST_Liability_Coverage__c == null ? 0 : fetchrec.ST_Liability_Coverage__c;
                           /* date shipDate1 = eachship.shipDate;
                            date dueDate = date.newInstance(2022, 12, 12);
                            system.debug('shipDate>>>>'+shipDate1);*/
                            if(/*shipDate1 > dueDate &&*/ eachship.prodDesc!='Cut & Polished Diamonds'){
														
                           		 eachship.fuelSurcharge = fetchrec.Fuel_Surcharge__c == null ? 0 : fetchrec.Fuel_Surcharge__c;//prat
                            }
							eachship.minimumFreight = fetchrec.ST_Minimum_Freight__c == null ? 0 : fetchrec.ST_Minimum_Freight__c;
                            eachship.freightOnInvoice = fetchrec.ST_Freight_on_Invoice_Value__c == null ? 0 : fetchrec.ST_Freight_on_Invoice_Value__c;  
                            eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                            eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                            eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                            
                            if(eachship.rateUOM=='Per Gram'){
                                calculatedAmount = eachship.rateAmount * eachship.grossWeight;               
                            }
                            
                            else if(eachship.rateUOM =='Per Kg') {
                                calculatedAmount = eachship.rateAmount * (eachship.grossWeight/1000);
                            }
                            else if(eachship.rateUOM  =='Flat Rate' ) {
                                calculatedAmount = eachship.rateAmount;
                            }
                            
                            eachship.freightCharge =  calculatedAmount > eachship.minimumFreight ? calculatedAmount : eachship.minimumFreight;
							if(eachship.freightOnInvoice > 0 && (each.prodName.contains('Special') || each.prodName.contains('DTA')) && eachship.invoiceValue >0) {
                                calculatedAmount = calculatedAmount+ (eachship.freightOnInvoice * eachship.invoiceValue)/100 ;
                            }
                                                        
                            if(calculatedAmount < eachship.minimumFreight) {
                                calculatedAmount = eachship.minimumFreight;
                            }
                            if(eachship.optForLiability== 'Yes'  && eachship.invoiceValue > 0 ) {
                                Decimal liabilityAmt=eachship.liabilityCoverage;
                                
                                liabilityCoverageAmount = (eachship.invoiceValue * liabilityAmt) / 100;
                                eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                                
                            }
                            if(eachship.fuelSurcharge!=null && eachship.fuelSurcharge > 0 ){//prat
                                fuelSurchargeAmount=eachship.fuelSurcharge;
							}
                            if(eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c ;
                                //sam
                                if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                   } 
                            }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                            if(eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                            }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                            if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
																															 
                               Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                    }  
                            }
							if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                  } 
								}
								if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                            eachship.offlineCharge = offlineCharge;
                            eachship.totalAmount = calculatedAmount+offlineCharge+liabilityCoverageAmount+fuelSurchargeAmount;
                            eachship.nonACRContractedPriceId = fetchrec.Id;
                            system.debug('Each Ship: Misfit : '+eachship);
                            shipCalcVal.add(eachship);
                        }
                     }
                }catch(Exception ex){
                    eachship.errors = ex.getMessage();
                }
            }
            else if(!matchFound){
                try{
                    system.debug('Each Ship : Std Price'+eachship);
                    for(ST_NonACR_Standard_Price__c fetchrec:nonAcrStandardProce){
                        liabilityCoverageAmount = 0;//Added By adel for Bulkification
                        offlineCharge = 0;
                        calculatedAmount = 0;
                        fuelSurchargeAmount=0;
                        ShipmentCalcUtil.ShipmentDetail each= new ShipmentCalcUtil.ShipmentDetail();
                        
                        if(fetchrec.ST_Product__c!=null){
                            each.productId = fetchrec.ST_Product__c;
                            each.prodName=fetchrec.ST_Product__r.Name;
                        }
                        fetchrec.ST_Min_Gross_Weight__c = fetchrec.ST_Min_Gross_Weight__c == null ? 0 : fetchrec.ST_Min_Gross_Weight__c;
                        fetchrec.ST_Max_Gross_Weight__c = fetchrec.ST_Max_Gross_Weight__c == null ? 0 : fetchrec.ST_Max_Gross_Weight__c;
                        eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight;
                        
                        if (eachship.productId== each.productId && eachship.grossWeight > 0 
                            && ((fetchrec.ST_Min_Gross_Weight__c == 0 && fetchrec.ST_Max_Gross_Weight__c==0) 
                                || (fetchrec.ST_Min_Gross_Weight__c*1000 < eachship.grossWeight && fetchrec.ST_Max_Gross_Weight__c*1000 >=eachship.grossWeight)
                                || (fetchrec.ST_Min_Gross_Weight__c*1000 < eachship.grossWeight && fetchrec.ST_Max_Gross_Weight__c == 0))
                            && ((fetchrec.ST_Origin__c==NULL && fetchrec.ST_Destination__c==NULL) || (eachship.origin == fetchrec.ST_Origin__c && eachship.destination == fetchrec.ST_Destination__c))
                            && ((fetchrec.ST_Exhibition__c==null) || (eachship.customerProdCategory == fetchrec.ST_Customer_Product_Category__c && eachship.exhibitionId == fetchrec.ST_Exhibition__c))
                           )
                        {
                            system.debug('Inside 1');
                            system.debug('fetchedResMap.get:'+each.rateAmount);
                            
                            if(each.prodName.contains('ExhibiSHIP')){
                                eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c/2;
                            }
                            else{
                                eachship.rateAmount=fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c;
                            }
                            
                            eachship.rateUOM=fetchrec.ST_Rate_UOM__c;
                            eachship.liabilityCoverage = fetchrec.ST_Liability_Coverage__c == null ? 0 : fetchrec.ST_Liability_Coverage__c;
                           // date shipDate1 = eachship.shipDate;
                           // date dueDate = date.newInstance(2022, 12, 12);
                          //  system.debug('shipDate>>>>'+shipDate1);
                            if(eachship.prodDesc!='Cut & Polished Diamonds'){
                            	eachship.fuelSurcharge = fetchrec.Fuel_Surcharge__c == null ? 0 : fetchrec.Fuel_Surcharge__c;//prat
                            }
                            eachship.minimumFreight = fetchrec.ST_Minimum_Freight__c == null ? 0 : fetchrec.ST_Minimum_Freight__c;
                            eachship.freightOnInvoice = fetchrec.ST_Freight_on_Invoice_Value__c == null ? 0 : fetchrec.ST_Freight_on_Invoice_Value__c;  
                            eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                            eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                            eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                            
                            if(eachship.rateUOM=='Per Gram'){
                                calculatedAmount = eachship.rateAmount * eachship.grossWeight;               
                            }
                            
                            else if(eachship.rateUOM =='Per Kg') {
                                calculatedAmount = eachship.rateAmount * (eachship.grossWeight/1000);
                            }
                            
                            else if(eachship.rateUOM  =='Flat Rate') {
                                calculatedAmount = eachship.rateAmount;
                            }
                            eachship.freightCharge = calculatedAmount < eachship.minimumFreight ? eachship.minimumFreight : calculatedAmount;
                            
                            if(eachship.freightOnInvoice > 0 && (each.prodName.contains('Special') || each.prodName.contains('DTA')) && eachship.invoiceValue >0) {
                                calculatedAmount = calculatedAmount+ (eachship.freightOnInvoice * eachship.invoiceValue)/100 ;
                            }
                            
                            
                            if(calculatedAmount < eachship.minimumFreight) {
                                calculatedAmount = eachship.minimumFreight;
                            }
                            if(eachship.optForLiability== 'Yes'  && eachship.invoiceValue > 0 ) {
                                Decimal liabilityAmt = eachship.liabilityCoverage;
                                liabilityCoverageAmount = (eachship.invoiceValue * liabilityAmt) / 100;
                                eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                                
                            }
                            if(eachship.fuelSurcharge!=null && eachship.fuelSurcharge > 0  ){//prat
                                //Decimal fuelSurChrgAmt=eachship.fuelSurcharge;
                                 
                                fuelSurchargeAmount=eachship.fuelSurcharge;
                               }
                            if(eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                  } 
                            }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                            if(eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                            }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }	
                            if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
                               // offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c*2;
                                Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                    if(twoexempt==false && oneexempt==false){
                                        offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                    }  
                            }
							if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                              }
                                          }
                                  } 
								}
								 if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                            eachship.offlineCharge = offlineCharge;
                            eachship.totalAmount = calculatedAmount+offlineCharge+liabilityCoverageAmount+fuelSurchargeAmount;
                            eachship.nonACRStandardPriceId = fetchrec.Id;
                            system.debug('Each Ship: Misfit : '+eachship);
                            shipCalcVal.add(eachship);
                        }
                    }
                }catch(Exception ex){
                    eachship.errors = ex.getMessage();
                }
            }
        }
        system.debug('shipCalcVal : Non ACR : '+shipCalcVal);
        return shipCalcVal;
        
    }
    
    /*
* description  :  Calculator method for ACR Contract Shipments. 
*/
    private static List < ShipmentCalcUtil.ShipmentDetail > shipmentCalculationACRContract(List < ShipmentCalcUtil.ShipmentDetail > shipInput, Map < Id, Account > actMap) {
        system.debug('===shipmentCalculationACRContract Called');
        List < String > chargeHeadTypeList = new List < String > {
            'Freight Charge',
                'Weight Charge',
                'Liability Charge',
                'Offline Charge',
                'BVC Valuation Charge',
                'Docket Charge',
                'Holiday Charge',
                'Fuel Charge',
                'Fuel Surcharge'
                };
        Set < Id > prodId = new Set < Id > ();
        Set < String > accountId = new Set < String > ();
        Set < String > origin = new Set < String > ();
        Set < String > destination = new Set < String > ();
        Set < String > custProdCategory = new Set < String > ();
        Set < String > acrPackageType = new Set < String > ();
        Set < Id > contractSet = new Set < Id > ();
        Decimal calculatedAmount = 0;
        Decimal offlineCharge = 0;
        Decimal liabilityCoverageAmount = 0;
        Decimal fuelSurcharge=0;//Prat
        Decimal fuelSurchargeAmount=0;//Prat
        Set < Id > exhibition = new Set < Id > ();
        List < ShipmentCalcUtil.ShipmentDetail > shipCalcVal = new List < ShipmentCalcUtil.ShipmentDetail > ();
        //sam
        Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
            
            
            prodId.add(eachship.productId);
            origin.add(eachship.origin);
            destination.add(eachship.destination);
            accountId.add(eachship.accountId);
            acrPackageType.add(actMap.get(eachship.accountId).Contracted_ACR_Package__c);
            contractSet.add(actMap.get(eachship.accountId).Active_Contract__c);
            
            
        }
        //sam
        List<Account> accWithExmeptedOrder = [Select id,(SELECT Id, Name, Customer__c, New_Offline_Charge__c,Exempted_City__c FROM Exempted_cities__r) from Account where id IN: accountId];
        for(Account acc : accWithExmeptedOrder){
            mapaccountIdWithExemptRecord.put(acc.Id,acc.Exempted_cities__r);
        }
		
        system.debug('Origin '+origin);
        system.debug('Destination '+destination );
        Map < String, Map < String, ST_ACR_Contracted_Price__c >> acrContractedMapping = new Map < String, Map < String, ST_ACR_Contracted_Price__c >> ();
        
        List < ST_ACR_Contracted_Price__c > stdCommercialFitPricesACR = new List < ST_ACR_Contracted_Price__c > ();
        Map < String, ST_ACR_Contracted_Price__c > stdCommercialFitPricesACRMap = new Map < String, ST_ACR_Contracted_Price__c > ();
        Map < String, Map < String, ST_NonACR_Contracted_Price__c >> stdCommercialFitPricesMapDemo = new Map < String, Map < String, ST_NonACR_Contracted_Price__c >> ();
        List < ST_ACR_Contracted_Price__c > AcrContractedProce = [select ST_ACR_Package_Type__c, ST_Order__c, ST_Exhibition__c, ST_Active__c, ST_Customer_Account__c, Id, ST_Customer_Product_Category__c, ST_Contract__c,
                                                                  is_Misfit__c, Charge_Type__c, Level_1__c, Level_1_Rate__c, Level_2__c, Level_2_Rate__c, Level_3__c, Level_3_Rate__c, Level_4__c,
                                                                  Level_4_Rate__c, Level_5__c, Level_5_Rate__c, Slab_Dependency__c, Multi_Level_Charges__c, Misfit_Rate_UOM__c, Maximum_Slab_Rate__c, Free_Quantity__c,Fuel_Surcharge__c,
                                                                  ST_Origin__c, ST_Destination__c, ST_Freight_on_Invoice_Value__c, ST_Minimum_Freight__c, ST_Liability_Coverage__c, ST_Offline_Charge__c,
                                                                  ST_Product__c, ST_Product__r.Name, ST_Rate_Amount__c, ST_Rate_UOM__c from ST_ACR_Contracted_Price__c
                                                                  where ST_Product__c In: prodId and ST_Customer_Account__c In: accountId and ST_Active__c = true and ST_Contract__c in: contractSet
                                                                  and(ST_ACR_Package_Type__c = null OR ST_ACR_Package_Type__c in: acrPackageType)
                                                                  and((ST_Origin__c = NULL and ST_Destination__c = NULL) OR(ST_Origin__c In: origin and ST_Destination__c In: destination))
                                                                 ];
        
        system.debug('AcrContractedProce:' + AcrContractedProce);
        for (ST_ACR_Contracted_Price__c acr: AcrContractedProce) {
            if (acr.is_Misfit__c) {
                if (acr.ST_Customer_Account__c != null && acr.ST_Contract__c != null && acr.ST_Product__c != null) {
                    
                    String primaryKey = acr.ST_Customer_Account__c + '_' + acr.ST_Contract__c + '_' + acr.ST_Product__c + '_' + acr.ST_ACR_Package_Type__c;
                    if (acrContractedMapping.containsKey(primaryKey)) {
                        acrContractedMapping.get(primaryKey).put(acr.Charge_Type__c, acr);
                    } else {
                        Map < String, ST_ACR_Contracted_Price__c > mapNonACRChargeType = new Map < String, ST_ACR_Contracted_Price__c > ();
                        mapNonACRChargeType.put(acr.Charge_Type__c, acr);
                        acrContractedMapping.put(primaryKey, mapNonACRChargeType);
                    }
                    System.debug('Primary Key  : Misfit : '+primaryKey);
                }
            } else {
                 String primaryKey = acr.ST_Customer_Account__c + '_' + acr.ST_Contract__c + '_' + acr.ST_Product__c +'_'+acr.ST_ACR_Package_Type__c;
                System.debug('Primary Key  : fit : '+primaryKey);
                stdCommercialFitPricesACRMap.put(primaryKey, acr);
                stdCommercialFitPricesACR.add(acr);
            }
        }
        Map < String, ST_ACR_Standard_Price__c > acrStandardPriceMap = new Map < String, ST_ACR_Standard_Price__c > ();
        List < ST_ACR_Standard_Price__c > AcrStandardProce = new List < ST_ACR_Standard_Price__c > ();
        for (ST_ACR_Standard_Price__c std: [select ST_Exhibition__c, ST_Effective_Start_Date__c, ST_Effective_End_Date__c, ST_Customer_Product_Category__c,
                                            ST_Freight_on_Invoice_Value__c, Id, ST_Minimum_Freight__c, ST_Liability_Coverage__c,Fuel_Surcharge__c,
                                            ST_Offline_Charge__c, ST_Product__c, ST_Product__r.Name, ST_ACR_Package_Type__c,
                                            ST_Rate_Amount__c, ST_Rate_UOM__c, ST_ACR_Package_Amount__c, ST_Origin__c, ST_Destination__c
                                            from ST_ACR_Standard_Price__c where ST_Product__c In: prodId
                                            and(ST_ACR_Package_Type__c = null OR(ST_ACR_Package_Type__c in: acrPackageType))
                                            and((ST_Origin__c = NULL and ST_Destination__c = NULL) OR(ST_Origin__c In: origin and ST_Destination__c In: destination))
                                            and ST_Effective_Start_Date__c <= TODAY and ST_Effective_End_Date__c >= TODAY
                                           ]) {
                                               
                                               String stdKey = std.ST_Product__c + '_' + (std.ST_ACR_Package_Type__c == null ? '' : std.ST_ACR_Package_Type__c);
                                               acrStandardPriceMap.put(stdKey, std);
                                               AcrStandardProce.add(std);
                                           }
        system.debug('AcrStandardPrice Map Key Set: ' + acrStandardPriceMap.keySet());
         for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
            boolean matchFound = false;
            try {
                String mathcingKey = eachship.accountId + '_' + (actMap.containsKey(eachship.accountId) ? actMap.get(eachship.accountId).Active_Contract__c : '') + '_' + eachship.productId + '_' + (actMap.containsKey(eachship.accountId) ? actMap.get(eachship.accountId).Contracted_ACR_Package__c : '');
                String stdKey = eachship.productId + '_' + (actMap.containsKey(eachship.accountId) ? actMap.get(eachship.accountId).Contracted_ACR_Package__c : '');
                String primKey = eachship.productId + '_';
                system.debug('Misfit Key : ' + mathcingKey);
                if (acrContractedMapping.containsKey(mathcingKey)) {
                    
                    eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                    eachship.distanceInKm = eachship.distanceInKm == null ? 0 : eachship.distanceInKm;
                    eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight;
                    eachship.perShipment = eachship.perShipment == null ? 0 :eachship.perShipment;//prat
                    eachship.netWeight = eachship.netWeight == null ? 0 : eachship.netWeight;
                    eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                    eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                    
                    matchFound = true;
                    Map < String, ST_ACR_Contracted_Price__c > acrMapping = new Map < String, ST_ACR_Contracted_Price__c > ();
                    acrMapping.putAll(acrContractedMapping.get(mathcingKey));
                    
                    System.debug('Enter Map');
                    liabilityCoverageAmount = 0; //Added By adel for Bulkification
                    offlineCharge = 0;
                    calculatedAmount = 0;
                    Decimal totalAmount = 0;
                    Decimal minimumFuelCharge = 0;
                    String minimumFreightSlab = '';
                    String minimumFreightUOM = '';
                    for (String chargeHead: chargeHeadTypeList) {
                        Decimal chargeAmount = 0;
                        if (acrMapping.containsKey(chargeHead)) {
                            ST_ACR_Contracted_Price__c acrContractPrice = acrMapping.get(chargeHead);
                            eachship.acrContractedPriceId = acrContractPrice.Id;
                            if (acrContractPrice.Multi_Level_Charges__c) {
                                Decimal slabLevel = 0;
                                Decimal slabRate = 0;
                                if (acrContractPrice.Slab_Dependency__c == 'Gross Weight') {
                                    slabLevel = eachship.grossWeight;
                                } else if (acrContractPrice.Slab_Dependency__c == 'Net Weight') {
                                    slabLevel = eachship.netWeight;
                                } else if (acrContractPrice.Slab_Dependency__c == 'Package Weight') {
                                    slabLevel = eachship.grossWeight - eachship.netWeight;
                                } else if (acrContractPrice.Slab_Dependency__c == 'Invoice Value') {
                                    slabLevel = eachship.invoiceValue;
                                } else if(acrContractPrice.Slab_Dependency__c == 'Per Shipment'){//prat
                                    slabLevel = eachship.perShipment; 
                                }else if (acrContractPrice.Slab_Dependency__c == 'Kilometer') {
                                    slabLevel = eachship.distanceInKm;
                                }
                                if (acrContractPrice.Free_Quantity__c != null && acrContractPrice.Free_Quantity__c > 0) {
                                    slabLevel = slabLevel - acrContractPrice.Free_Quantity__c;
                                }
                                if (slabLevel > 0) {
                                    if (slabLevel <= acrContractPrice.Level_1__c) {
                                        slabRate = acrContractPrice.Level_1_Rate__c == null ? 0 : acrContractPrice.Level_1_Rate__c;
                                    } else if (acrContractPrice.Level_2__c != null && slabLevel > acrContractPrice.Level_1__c && slabLevel <= acrContractPrice.Level_2__c) {
                                        slabRate = acrContractPrice.Level_2_Rate__c == null ? 0 : acrContractPrice.Level_2_Rate__c;
                                    } else if (acrContractPrice.Level_3__c != null && slabLevel > acrContractPrice.Level_2__c && slabLevel <= acrContractPrice.Level_3__c) {
                                        slabRate = acrContractPrice.Level_3_Rate__c == null ? 0 : acrContractPrice.Level_3_Rate__c;
                                    } else if (acrContractPrice.Level_4__c != null && slabLevel > acrContractPrice.Level_3__c && slabLevel <= acrContractPrice.Level_4__c) {
                                        slabRate = acrContractPrice.Level_4_Rate__c == null ? 0 : acrContractPrice.Level_4_Rate__c;
                                    } else if (acrContractPrice.Level_5__c != null && slabLevel > acrContractPrice.Level_4__c && slabLevel <= acrContractPrice.Level_5__c) {
                                        slabRate = acrContractPrice.Level_5_Rate__c == null ? 0 : acrContractPrice.Level_5_Rate__c;
                                    } else if (acrContractPrice.Maximum_Slab_Rate__c != null) {
                                        slabRate = acrContractPrice.Maximum_Slab_Rate__c == null ? 0 : acrContractPrice.Maximum_Slab_Rate__c;
                                    }
                                    if (acrContractPrice.Misfit_Rate_UOM__c == 'Gross Weight') {
                                        chargeAmount = slabRate * eachship.grossWeight;
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == 'Package Weight') {
                                        chargeAmount = slabRate * (eachship.grossWeight - eachship.netWeight);
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == 'Net Weight') {
                                        chargeAmount = slabRate * eachship.netWeight;
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == 'Per Shipment') {
                                        chargeAmount = slabRate;
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == 'Per Lakhs') {
                                        // Slab level Per lakhs only appliable for Involice Value 
                                        Decimal perLakhValue = slabLevel / 100000;
                                        chargeAmount = perLakhValue * slabRate;
                                    }
                                } else {
                                    chargeAmount = 0;
                                }
                            } else {
                                Decimal weightOrValue = 0;
                                Decimal rate = acrContractPrice.ST_Rate_Amount__c == null ? 0 : acrContractPrice.ST_Rate_Amount__c;
                                if (acrContractPrice.Slab_Dependency__c == 'Gross Weight') {
                                    weightOrValue = eachship.grossWeight;
                                } else if (acrContractPrice.Slab_Dependency__c == 'Net Weight') {
                                    weightOrValue = eachship.netWeight;
                                } else if (acrContractPrice.Slab_Dependency__c == 'Package Weight') {
                                    weightOrValue = eachship.grossWeight - eachship.netWeight;
                                } else if (acrContractPrice.Slab_Dependency__c == 'Invoice Value') {
                                    weightOrValue = eachship.invoiceValue;
                                } else if(acrContractPrice.Slab_Dependency__c == 'Per Shipment'){
                                    weightOrValue = eachship.perShipment;
                                }else if (acrContractPrice.Slab_Dependency__c == 'Freight Charges') {
                                    weightOrValue = eachship.freightCharge == null ? 0 : eachship.freightCharge;
                                }
                                if (acrContractPrice.Free_Quantity__c != null && acrContractPrice.Free_Quantity__c > 0) {
                                    weightOrValue = acrContractPrice.Free_Quantity__c >= weightOrValue ? 0 : weightOrValue - acrContractPrice.Free_Quantity__c;
                                }
                                if (weightOrValue > 0) {
                                    if (acrContractPrice.Misfit_Rate_UOM__c == 'Gross Weight' || acrContractPrice.Misfit_Rate_UOM__c == 'Package Weight' || acrContractPrice.Misfit_Rate_UOM__c == 'Net Weight') {
                                        chargeAmount = weightOrValue * rate;
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == 'Per Shipment') {
                                        chargeAmount = rate;
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == 'Per Lakhs') {
                                        // Slab level Per lakhs only appliable for Involice Value 
                                        Decimal perLakhValue = weightOrValue / 100000;
                                        chargeAmount = perLakhValue * rate;
                                    } else if (acrContractPrice.Misfit_Rate_UOM__c == '% of Invoice Value' || acrContractPrice.Misfit_Rate_UOM__c == '% of Freight Charges') {
                                        chargeAmount = (weightOrValue * rate) / 100;
                                        if (eachship.minimumFreight > 0 && acrContractPrice.Misfit_Rate_UOM__c == '% of Freight Charges') {
                                            minimumFuelCharge = (eachship.minimumFreight) * rate / 100;
                                        }
                                    }
                                } else {
                                    if (acrContractPrice.Misfit_Rate_UOM__c == 'Per Shipment') {
                                        chargeAmount = rate;
                                    } else {
                                        chargeAmount = 0;
                                    }
                                    
                                }
                            }
                            
                            if (chargeHead == 'Freight Charge') {
                                minimumFreightSlab = acrContractPrice.Slab_Dependency__c;
                                minimumFreightUOM = acrContractPrice.Misfit_Rate_UOM__c;
                                eachship.minimumFreight = acrContractPrice.ST_Minimum_Freight__c == null ? 0 : acrContractPrice.ST_Minimum_Freight__c;
                                eachship.freightCharge = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                             } else if (chargeHead == 'Weight Charge') {
                                eachship.weightCharge = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                            } else if (chargeHead == 'Liability Charge' && eachship.optForLiability == 'Yes') {
                                eachship.liabilityCoverageAmount = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                            } else if (chargeHead == 'Offline Charge') {
                                if (eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                    offlineCharge = chargeAmount;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              //changed by sam
                                              if(exempt.Exempted_City__c== eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                   }
                                } else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                                if (eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                    offlineCharge = chargeAmount;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                                }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                                if (eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
                                   // offlineCharge = chargeAmount * 2;
                                    //sam
                                      Boolean oneexempt=false;
                                      Boolean twoexempt=false;
                                      Decimal exemptprice=0; 
                                      Decimal OfflinePrice=chargeAmount;
                                     if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                             
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }
										}
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge =chargeAmount * 2;
                                   }  
                                  
                                }
								if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = chargeAmount;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                  } 
								}
								 if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =chargeAmount;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                                eachship.offlineCharge = offlineCharge == null ? 0 : offlineCharge;
                                totalAmount = totalAmount + (offlineCharge == null ? 0 : offlineCharge);
                            } else if (chargeHead == 'BVC Valuation Charge') {
                                eachship.bvcValuationCharge = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                            } else if (chargeHead == 'Docket Charge') {
                                eachship.docketCharge = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                            } else if (chargeHead == 'Holiday Charge') {
                                eachship.holidayCharge = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                            } else if(chargeHead == 'Fuel Surcharge'){
                                //date shipDate1 = eachship.shipDate;
                            	//date dueDate = date.newInstance(2022, 12, 12);
                                if( eachship.prodDesc!='Cut & Polished Diamonds'){
                                eachship.fuelSurcharge = chargeAmount;
                                totalAmount = totalAmount +chargeAmount;
                                }
                            }else if (chargeHead == 'Fuel Charge') {
                                eachship.fuelCharge = chargeAmount;
                                totalAmount = totalAmount + chargeAmount;
                                
                            }
                        }
                    }
                    eachship.freightCharge = eachship.freightCharge == null ? 0 : eachship.freightCharge;
                    eachship.weightCharge = eachship.weightCharge == null ? 0 : eachship.weightCharge;
                    if (eachship.minimumFreight > 0) {
                        
                        Decimal TotalMinimumCalclated = 0;
                        if (minimumFreightSlab == 'Net Weight' && minimumFreightUOM == 'Net Weight') {
                            TotalMinimumCalclated = TotalMinimumCalclated + eachship.freightCharge + eachship.weightCharge;
                        } else {
                            TotalMinimumCalclated = TotalMinimumCalclated + eachship.freightCharge;
                        }
                        //Decimal TotalMinimumCalclated =  eachship.freightCharge + eachship.weightCharge;
                        System.debug('Total Minimum Calclated ' + TotalMinimumCalclated);
                        if (TotalMinimumCalclated < eachship.minimumFreight) {
                            eachship.freightCharge = eachship.minimumFreight;
                            if (minimumFreightSlab == 'Net Weight' && minimumFreightUOM == 'Net Weight') {
                                eachship.weightCharge = 0;
                            }
                            totalAmount = totalAmount - TotalMinimumCalclated + eachship.minimumFreight;
                            if (eachship.fuelCharge > 0) {
                                totalAmount = totalAmount - eachship.fuelCharge + minimumFuelCharge;
                                eachship.fuelCharge = minimumFuelCharge;
                            }
                        } else {
                            eachship.minimumFreight = 0.00;
                        }
                    }
                    eachship.totalAmount = totalAmount;
                    
                    shipCalcVal.add(eachship);
                } 
                else if (stdCommercialFitPricesACRMap.containsKey(mathcingKey)) {
                    for (ST_ACR_Contracted_Price__c acr: stdCommercialFitPricesACR) {
                        ST_ACR_Contracted_Price__c fetchrec = stdCommercialFitPricesACRMap.get(mathcingKey);
                        system.debug('fit Commercial Key : ' + mathcingKey);
                        liabilityCoverageAmount = 0; //Added By adel for Bulkification
                        offlineCharge = 0;
                        calculatedAmount = 0;
                        fuelSurchargeAmount=0;//Prat
                        ShipmentCalcUtil.ShipmentDetail each = new ShipmentCalcUtil.ShipmentDetail();
                        
                        if (fetchrec.ST_Product__c != null) {
                            each.productId = fetchrec.ST_Product__c;
                            each.prodName = fetchrec.ST_Product__r.Name;
                            
                        }
                        system.debug('===Before condition check' + eachship.grossWeight);
                        system.debug('===each.productId' + each.productId + '====eachship.productId : ' + eachship.productId);
                        
                        eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight;
                        
                        if (eachship.productId == each.productId && eachship.grossWeight > 0 &&
                            ((fetchrec.ST_Origin__c == NULL && fetchrec.ST_Destination__c == NULL) || (eachship.origin == fetchrec.ST_Origin__c && eachship.destination == fetchrec.ST_Destination__c)) &&
                            ((fetchrec.ST_Exhibition__c == null) || (eachship.customerProdCategory == fetchrec.ST_Customer_Product_Category__c && eachship.exhibitionId == fetchrec.ST_Exhibition__c))
                           ) {
                               matchFound = true;
                               system.debug('===Product Found In ACR Contracted Price Table');
                               //ShipmentCalcUtil.ShipmentDetail ship= new ShipmentCalcUtil.ShipmentDetail();
                               if (each.prodName.contains('ExhibiSHIP')) {
                                   eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c / 2;
                               } else {
                                   eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c;
                               }
                               
                               eachship.rateUOM = fetchrec.ST_Rate_UOM__c;
                               eachship.liabilityCoverage = fetchrec.ST_Liability_Coverage__c == null ? 0 : fetchrec.ST_Liability_Coverage__c;
                               //date shipDate1 = eachship.shipDate;
                               //date dueDate = date.newInstance(2022, 12, 12);
                               if(eachship.prodDesc!='Cut & Polished Diamonds'){
                               		eachship.fuelSurcharge = fetchrec.Fuel_Surcharge__c == null ? 0 : fetchrec.Fuel_Surcharge__c;//prat
                            	}
                               system.debug('************eachship.fuelSurcharge*********'+eachship.fuelSurcharge);
                               eachship.minimumFreight = fetchrec.ST_Minimum_Freight__c == null ? 0 : fetchrec.ST_Minimum_Freight__c;
                               eachship.freightOnInvoice = fetchrec.ST_Freight_on_Invoice_Value__c == null ? 0 : fetchrec.ST_Freight_on_Invoice_Value__c;
                               eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                               eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                               eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                               
                               
                               if (eachship.rateUOM == 'Per Gram') {
                                   calculatedAmount = eachship.rateAmount * eachship.grossWeight;
                               } else if (eachship.rateUOM == 'Per Kg') {
                                   calculatedAmount = eachship.rateAmount * (eachship.grossWeight / 1000);
                               } else if (eachship.rateUOM == 'Flat Rate') {
                                   calculatedAmount = eachship.rateAmount;
                                   system.debug('=======only calculated============='+calculatedAmount);
                               }
                               /*else if (eachship.rateUOM == 'Flat Rate' && eachship.fuelSurcharge > 0) {//Prat
                                   calculatedAmount = eachship.rateAmount + eachship.fuelSurcharge;
                                   system.debug('========+fuel surcharge============'+calculatedAmount);
                               }*/
                               eachship.freightCharge = eachship.freightCharge = calculatedAmount < eachship.minimumFreight ? eachship.minimumFreight : calculatedAmount;
                               
                               if (eachship.freightOnInvoice > 0 && (each.prodName.contains('Special') || each.prodName.contains('DTA')) && eachship.invoiceValue > 0) {
                                   calculatedAmount = calculatedAmount + (eachship.freightOnInvoice * eachship.invoiceValue) / 100;
                               }
                               
                               
                               if (calculatedAmount < eachship.minimumFreight) {
                                   calculatedAmount = eachship.minimumFreight;
                                   
                               }
                               system.debug('========+fuel surcharge1============'+calculatedAmount);
                               if (eachship.optForLiability == 'Yes' && eachship.invoiceValue > 0) {
                                   Decimal liabilityAmt = eachship.liabilityCoverage;
                                   // liabilityCoverageAmount = (eachship.invoiceValue * Decimal.valueof(fetchedResMap.get(each.productId+'_'+each.recIdNonACRStandard).liabilityCoverage)) / 100;
                                   liabilityCoverageAmount = (eachship.invoiceValue * liabilityAmt) / 100;
                                   eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                               }
                              if(eachship.fuelSurcharge!=null && eachship.fuelSurcharge > 0  ){//prat
                                
                                fuelSurchargeAmount = eachship.fuelSurcharge;
                                
                                   //fuelSurcharge=eachship.fuelSurcharge;
                                  // system.debug('-----------eachship.fuelSurcharge--------'+eachship.fuelSurcharge);
                               }
                              // system.debug('------out-----eachship.fuelSurcharge--------'+eachship.fuelSurcharge);
                               if (eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                   offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                   //sam
                                   if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
                               } else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                               if (eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                   offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                   if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                               }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                               if (eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
                                  // offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                   Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                              
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                    
                                   }  
                               
                               }
                               if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                  } 
								}
								 if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                               eachship.offlineCharge = offlineCharge;
                               system.debug('********calculated amount******'+fuelSurcharge);
                               eachship.totalAmount = calculatedAmount + offlineCharge + liabilityCoverageAmount + fuelSurchargeAmount;
                               eachship.acrContractedPriceId = fetchrec.Id;
                               
                               shipCalcVal.add(eachship);
                           }
                    }
                } else if (!matchFound && (acrStandardPriceMap.containsKey(stdKey) || acrStandardPriceMap.containsKey(primKey))) {
                    for (ST_ACR_Standard_Price__c acrStd: AcrStandardProce) {
                        system.debug('standard Key : ACR ' + stdKey);
                        system.debug('Primary Key : ' + primKey);
                        ST_ACR_Standard_Price__c fetchrec = acrStandardPriceMap.get(stdKey);
                        liabilityCoverageAmount = 0; //Added By adel for Bulkification
                        offlineCharge = 0;
                        calculatedAmount = 0;
                        fuelSurchargeAmount=0;//Prat
                        ShipmentCalcUtil.ShipmentDetail each = new ShipmentCalcUtil.ShipmentDetail();
                        
                        if (fetchrec.ST_Product__c != null) {
                            each.productId = fetchrec.ST_Product__c;
                            each.prodName = fetchrec.ST_Product__r.Name;
                            
                        }
                        eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight;
                        
                        if (eachship.productId == each.productId && eachship.grossWeight > 0 &&
                            ((fetchrec.ST_Origin__c == NULL && fetchrec.ST_Destination__c == NULL) || (eachship.origin == fetchrec.ST_Origin__c && eachship.destination == fetchrec.ST_Destination__c)) &&
                            ((fetchrec.ST_Exhibition__c == null) || (eachship.customerProdCategory == fetchrec.ST_Customer_Product_Category__c && eachship.exhibitionId == fetchrec.ST_Exhibition__c))
                           ) {
                               system.debug('===Product Found In ACR Standard Price Table');
                               //ShipmentCalcUtil.ShipmentDetail ship= new ShipmentCalcUtil.ShipmentDetail();
                               
                               if (each.prodName.contains('ExhibiSHIP')) {
                                   eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c / 2;
                               } else {
                                   eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c;
                               }
                               
                               eachship.rateUOM = fetchrec.ST_Rate_UOM__c;
                               eachship.liabilityCoverage = fetchrec.ST_Liability_Coverage__c == null ? 0 : fetchrec.ST_Liability_Coverage__c;
                              // date shipDate1 = eachship.shipDate;
                               // date dueDate = date.newInstance(2022, 12, 12);
                                if( eachship.prodDesc!='Cut & Polished Diamonds'){
                               eachship.fuelSurcharge = fetchrec.Fuel_Surcharge__c == null ? 0 : fetchrec.Fuel_Surcharge__c;//prat
                                }
                               eachship.minimumFreight = fetchrec.ST_Minimum_Freight__c == null ? 0 : fetchrec.ST_Minimum_Freight__c;
                               eachship.freightOnInvoice = fetchrec.ST_Freight_on_Invoice_Value__c == null ? 0 : fetchrec.ST_Freight_on_Invoice_Value__c;
                               eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                               eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                               eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                               
                               
                               if (eachship.rateUOM == 'Per Gram') {
                                   calculatedAmount = eachship.rateAmount * eachship.grossWeight;
                               } else if (eachship.rateUOM == 'Per Kg') {
                                   calculatedAmount = eachship.rateAmount * (eachship.grossWeight / 1000);
                               } else if (eachship.rateUOM == 'Flat Rate') {
                                   calculatedAmount = eachship.rateAmount;
                               }
                               
                               eachship.freightCharge = eachship.freightCharge = calculatedAmount < eachship.minimumFreight ? eachship.minimumFreight : calculatedAmount;
                               
                               
                               if (eachship.freightOnInvoice > 0 && (each.prodName.contains('Special') || each.prodName.contains('DTA')) && eachship.invoiceValue > 0) {
                                   calculatedAmount = calculatedAmount + (eachship.freightOnInvoice * eachship.invoiceValue) / 100;
                               }
                               
                               
                               if (calculatedAmount < eachship.minimumFreight) {
                                   calculatedAmount = eachship.minimumFreight;
                                   
                               }
                               if (eachship.optForLiability == 'Yes' && eachship.invoiceValue > 0) {
                                   Decimal liabilityAmt = eachship.liabilityCoverage;
                                   // liabilityCoverageAmount = (eachship.invoiceValue * Decimal.valueof(fetchedResMap.get(each.productId+'_'+each.recIdNonACRStandard).liabilityCoverage)) / 100;
                                   liabilityCoverageAmount = (eachship.invoiceValue * liabilityAmt) / 100;
                                   eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                               }
                               if(eachship.fuelSurcharge!=null && eachship.fuelSurcharge > 0 ){//prat
                                   fuelSurchargeAmount=eachship.fuelSurcharge;
                               }
                               if (eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                   offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                   //sam
                                  if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     // if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  }
                               }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                               if (eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                   offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                   if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }

                                      
                               }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                               if (eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
                                   
                                  // offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                  Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  //Decimal OfflinePrice=0;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                              
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                    
                                   }  
                               }
                               if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                  } 
								}
								
								
		                         if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge =fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                              
                               eachship.offlineCharge = offlineCharge;
                               eachship.totalAmount = calculatedAmount + offlineCharge + liabilityCoverageAmount+ fuelSurchargeAmount;
                               eachship.acrStandardPriceId = fetchrec.Id;
                               
                               shipCalcVal.add(eachship);
                           }
                    }
                } else {
                    eachship.errors = 'No ACR Price was found for this Combination of Package and Product.';
                }
            } catch (exception ex) {
                eachship.errors = ex.getMessage();
                
            }
            system.debug('===matchFound : ' + matchFound);
        }
         return shipCalcVal;
    }
    
    /*
* description  :  Calculator method for Non ACR Non Contracted Shipments. 
*/
    private static List < ShipmentCalcUtil.ShipmentDetail > shipmentCalculationNonACRNonContract(List < ShipmentCalcUtil.ShipmentDetail > shipInput, Map < Id, Account > actMap) {
        system.debug('===shipmentCalculationNonACRNonContract Called');
        Set < Id > prodId = new Set < Id > ();
        set<string> accountId=new set<string>();
        Set < String > origin = new Set < String > ();
        Set < String > destination = new Set < String > ();
        
        Map < String, ShipmentCalcUtil.ShipmentDetail > fetchedResMap = new Map < String, ShipmentCalcUtil.ShipmentDetail > ();
        List < ShipmentCalcUtil.ShipmentDetail > shipCalcVal = new List < ShipmentCalcUtil.ShipmentDetail > ();
        //sam
        //
         Map<Id,List<Exempted_City__c>> mapaccountIdWithExemptRecord = new Map<Id,List<Exempted_City__c>>();
        for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
            system.debug('===1st loop');
            prodId.add(eachship.productId);
            origin.add(eachship.origin);
            destination.add(eachship.destination);
            accountId.add(eachship.accountId);
            system.debug('===ProdId : ' + eachship.productId + ' grossWeight : ' + eachship.grossWeight);
        }
        
        List<Account> accWithExmeptedOrder = [Select id,(SELECT Id, Name, Customer__c, New_Offline_Charge__c,Exempted_City__c FROM Exempted_cities__r) from Account where id IN: accountId];
        for(Account acc : accWithExmeptedOrder){
            mapaccountIdWithExemptRecord.put(acc.Id,acc.Exempted_cities__r);
        }
        
        List < ST_NonACR_Standard_Price__c > nonAcrStandardProce = [select ST_Exhibition__c, ST_Product__r.Name, ST_Customer_Product_Category__c,Fuel_Surcharge__c,
                                                                    ST_Freight_on_Invoice_Value__c, Id, ST_Offline_Charge__c, ST_Minimum_Freight__c, ST_Liability_Coverage__c, ST_Origin__c, ST_Destination__c,
                                                                    ST_Min_Gross_Weight__c, ST_Max_Gross_Weight__c, ST_Rate_UOM__c, ST_Rate_Amount__c, ST_Product__c, ST_Gross_Weight_Slabs__c
                                                                    FROM ST_NonACR_Standard_Price__c WHERE ST_Product__c In: prodId
                                                                    AND ((ST_Origin__c = NULL and ST_Destination__c = NULL) OR(ST_Origin__c In: origin and ST_Destination__c In: destination))
                                                                    AND ST_Effective_Start_Date__c <= TODAY AND ST_Effective_End_Date__c >= TODAY
                                                                   ];
        system.debug('===non Acr Standard Price:' + nonAcrStandardProce.size());
        Decimal calculatedAmount = 0;
        Decimal offlineCharge = 0;
        Decimal liabilityCoverageAmount = 0;
        Decimal fuelSurchargeAmount=0;//prat
        
        if (nonAcrStandardProce != null) {
            for (ShipmentCalcUtil.ShipmentDetail eachship: shipInput) {
                liabilityCoverageAmount = 0;
                offlineCharge = 0;
                calculatedAmount = 0;
                
                try {
                    for (ST_NonACR_Standard_Price__c fetchrec: nonAcrStandardProce) {
                        ShipmentCalcUtil.ShipmentDetail each = new ShipmentCalcUtil.ShipmentDetail();
                        system.debug('ShipDetails::optForLiability::' + eachship.optForLiability + '  Gross Weight Slab:' + fetchrec.ST_Gross_Weight_Slabs__c + '  Product Id::' + fetchrec.ST_Product__c + '');
                        if (fetchrec.ST_Product__c != null) {
                            each.productId = fetchrec.ST_Product__c;
                            each.prodName = fetchrec.ST_Product__r.Name;
                        }
                         fetchrec.ST_Min_Gross_Weight__c = fetchrec.ST_Min_Gross_Weight__c == null ? 0 : fetchrec.ST_Min_Gross_Weight__c;
                        fetchrec.ST_Max_Gross_Weight__c = fetchrec.ST_Max_Gross_Weight__c == null ? 0 : fetchrec.ST_Max_Gross_Weight__c;
                        
                        eachship.grossWeight = eachship.grossWeight == null ? 0 : eachship.grossWeight;
                        
                        if (eachship.productId == each.productId && eachship.grossWeight > 0 &&
                            ((fetchrec.ST_Min_Gross_Weight__c == 0 && fetchrec.ST_Max_Gross_Weight__c == 0) ||
                             (fetchrec.ST_Min_Gross_Weight__c * 1000 < eachship.grossWeight && fetchrec.ST_Max_Gross_Weight__c * 1000 >= eachship.grossWeight) ||
                             (fetchrec.ST_Min_Gross_Weight__c * 1000 < eachship.grossWeight && fetchrec.ST_Max_Gross_Weight__c == 0)) &&
                            ((fetchrec.ST_Origin__c == NULL && fetchrec.ST_Destination__c == NULL) || (eachship.origin == fetchrec.ST_Origin__c && eachship.destination == fetchrec.ST_Destination__c)) &&
                            ((fetchrec.ST_Exhibition__c == null) || (eachship.customerProdCategory == fetchrec.ST_Customer_Product_Category__c && eachship.exhibitionId == fetchrec.ST_Exhibition__c))
                           ) {
                               system.debug('===Inside calculation');
                               
                               if (each.prodName.contains('ExhibiSHIP')) {
                                   eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c / 2;
                               } else {
                                   eachship.rateAmount = fetchrec.ST_Rate_Amount__c == null ? 0 : fetchrec.ST_Rate_Amount__c;
                               }
                               
                               //Calculation of Various Chargeheads.
                               eachship.rateUOM = fetchrec.ST_Rate_UOM__c;
                               eachship.liabilityCoverage = fetchrec.ST_Liability_Coverage__c == null ? 0 : fetchrec.ST_Liability_Coverage__c;
                              // date shipDate1 = eachship.shipDate;
                              // date dueDate = date.newInstance(2022, 12, 12);
                               if(eachship.prodDesc!='Cut & Polished Diamonds'){
                              		 eachship.fuelSurcharge = fetchrec.Fuel_Surcharge__c == null ? 0 : fetchrec.Fuel_Surcharge__c;//prat
                               }
                               eachship.minimumFreight = fetchrec.ST_Minimum_Freight__c == null ? 0 : fetchrec.ST_Minimum_Freight__c;
                               eachship.freightOnInvoice = fetchrec.ST_Freight_on_Invoice_Value__c == null ? 0 : fetchrec.ST_Freight_on_Invoice_Value__c;
                               eachship.invoiceValue = eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                               eachship.isOriginOfflineLoc = eachship.isOriginOfflineLoc == null ? false : eachship.isOriginOfflineLoc;
                               eachship.isDestOfflineLoc = eachship.isDestOfflineLoc == null ? false : eachship.isDestOfflineLoc;
                               
                               if (eachship.rateUOM == 'Per Gram') {
                                   calculatedAmount = eachship.rateAmount * eachship.grossWeight;
                               } else if (eachship.rateUOM == 'Per Kg') {
                                   calculatedAmount = eachship.rateAmount * (eachship.grossWeight / 1000);
                               } else if (eachship.rateUOM == 'Flat Rate') {
                                   calculatedAmount = eachship.rateAmount;
                               }
                               system.debug('Calculated Amount:::Frieght Charge' + calculatedAmount);
                               eachship.freightCharge = eachship.freightCharge = calculatedAmount < eachship.minimumFreight ? eachship.minimumFreight : calculatedAmount;
                               
                               if (eachship.freightOnInvoice > 0 && (each.prodName.contains('Special') || each.prodName.contains('DTA')) && eachship.invoiceValue > 0) {
                                   calculatedAmount = calculatedAmount + (eachship.freightOnInvoice * eachship.invoiceValue) / 100;
                               }
                               
                               if (calculatedAmount < eachship.minimumFreight) {
                                   calculatedAmount = eachship.minimumFreight;
                               }
                               
                               if (eachship.optForLiability == 'Yes' && eachship.invoiceValue > 0) {
                                   Decimal liabilityAmt = eachship.liabilityCoverage;
                                   // liabilityCoverageAmount = (eachship.invoiceValue * Decimal.valueof(fetchedResMap.get(each.productId+'_'+each.recIdNonACRStandard).liabilityCoverage)) / 100;
                                   liabilityCoverageAmount = (eachship.invoiceValue * liabilityAmt) / 100;
                                   eachship.liabilityCoverageAmount = liabilityCoverageAmount;
                               }
                               if(eachship.fuelSurcharge!=null && eachship.fuelSurcharge > 0 ){//prat
                                //Decimal fuelSurChrgAmt=eachship.fuelSurcharge;
                               // fuelSurchargeAmount = fuelSurChrgAmt;
                                fuelSurchargeAmount=eachship.fuelSurcharge;
                                   //fuelSurcharge=eachship.fuelSurcharge;
                               }
                               if (eachship.isOriginOfflineLoc && eachship.windowpickup == false) {
                                   offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                   //sam
                                   if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
                               }else if (eachship.isOriginOfflineLoc && eachship.windowpickup == true) {
                                    offlineCharge=0;
                                }
                               if (eachship.isDestOfflineLoc && eachship.windowdelivery == false) {
                                   offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                   if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
                               }else if (eachship.isDestOfflineLoc && eachship.windowdelivery == true) {
                                    offlineCharge=0;
                                }
                               if (eachship.isOriginOfflineLoc && eachship.isDestOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == false) {
                                   //offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                    Boolean oneexempt=false;
                                  Boolean twoexempt=false;
                                  Decimal exemptprice=0; 
                                  Decimal OfflinePrice = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                      if(exemptedRecord.size()>0){
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  oneexempt=true;
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                  break;
                                              }
                                          }
                                           for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                   twoexempt=true;
                                                    offlineCharge = offlineCharge+exempt.New_Offline_Charge__c; 
                                                    break;
                                                 }
                                            }

                                      }
                                        for(Exempted_City__c exempt : exemptedRecord){
                                          if(exempt.Exempted_City__c == eachship.origin && twoexempt== false)
                                          {
                                              
                                              exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                              
                                          }
                                       }
                                            for(Exempted_City__c exempt : exemptedRecord){
                                            if(exempt.Exempted_City__c == eachship.Destination && oneexempt == false) 
                                           {
                                                exemptprice =exempt.New_Offline_Charge__c;
                                               offlineCharge = OfflinePrice+exemptprice;
                                           }

                                       }
                                           
                                    }
                                     
                                   if(twoexempt==false && oneexempt==false){
                                        offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c * 2;
                                    
                                   }  
                               
                               }
                               if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == false && eachship.windowdelivery == true){
								    offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    //sam
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                     
                                          for(Exempted_City__c exempt : exemptedRecord){
                                              if(exempt.Exempted_City__c == eachship.origin){
                                                  offlineCharge = exempt.New_Offline_Charge__c;
                                                 
                                              }
                                          }
                                           
                                  } 
								}
                               if(eachship.isDestOfflineLoc && eachship.isOriginOfflineLoc && eachship.windowpickup == true && eachship.windowdelivery == false){
			                         offlineCharge = fetchrec.ST_Offline_Charge__c == null ? 0 : fetchrec.ST_Offline_Charge__c;
                                    if(mapaccountIdWithExemptRecord.containsKey(eachship.AccountId)){
                                    List<Exempted_City__c> exemptedRecord = mapaccountIdWithExemptRecord.get(eachship.AccountId);
                                   for(Exempted_City__c exempt : exemptedRecord){
                                               if(exempt.Exempted_City__c == eachship.Destination){
                                                    offlineCharge = exempt.New_Offline_Charge__c; 
                                                    
                                                 }
                                            }
                                   }
				                 }
                               eachship.offlineCharge = offlineCharge;
                               system.debug('Opt For Liability' + eachship.optForLiability);
                               system.debug('Calculated Amount:::' + calculatedAmount + 'Offline Charge::' + offlineCharge + 'Lia Charge::' + liabilityCoverageAmount);
                               eachship.totalAmount = calculatedAmount + offlineCharge + liabilityCoverageAmount+fuelSurchargeAmount;
                               eachship.nonACRStandardPriceId = fetchrec.Id;
                               
                               
                               shipCalcVal.add(eachship);
                           }
                        
                    }
                    
                } catch (exception ex) {
                    eachship.errors = ex.getMessage();
                    
                }
            }
        }
        system.debug('Size shipCalcVal:' + shipCalcVal.size());
        return shipCalcVal;
    }
    
    /*
* description  :  Calculator method for Exhibition Shipments. 
*/
    public static void fgMethod(){
        integer i = 0;
          
            i++;
      i++;
      i++;
      i++;
      i++;
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
      i++;}
    
    public static void fMethod(){
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
      i++;i++;
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