/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-09-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TMS_ProductCodeHandler {
    public static void UpdateProductDetails(List<Shipment__c> ShipList){
        Set<String> OriginCitySet = new Set<String>();
        Set<String> DestinationCitySet = new Set<String>();
        for(Shipment__c sh:ShipList){
            OriginCitySet.add(sh.Origin_Address_City__c);
            DestinationCitySet.add(sh.Destination_Address_City__c);
        }
        Map<String,Product_Name_Code__mdt> NameCodeMap = new Map<String,Product_Name_Code__mdt>();
        String defaultProduct = '';
        for(Product_Name_Code__mdt mdt :[select MasterLabel,Product_Name__c,Product_Code__c,Is_Default__c FROM Product_Name_Code__mdt ]){
            NameCodeMap.put(mdt.MasterLabel, mdt);
            if(mdt.Is_Default__c)
                defaultProduct = mdt.MasterLabel;
        }
        //System.debug('OriginCitySet: '+OriginCitySet);
        //System.debug('DestinationCitySet: '+DestinationCitySet);
        List<Origin_Destination__c> OD_PAirs = [select OriginCity__c,DestinationCity__c, Is_State_to_State__c,Destination_State__c, Origin_State__c, State_Mode_of_Service__c, Mode_Of_Service__c 
                                                FROM Origin_Destination__c 
                                                WHERE (Mode_Of_Service__c!=null AND OriginCity__c=:OriginCitySet AND DestinationCity__c=:DestinationCitySet) OR (Is_State_to_State__c = true) LIMIT 5000];
        Map<String,string> OD_PairMAp = new Map<string,string>();
        ////System.debug('OD_PAirs>>'+OD_PAirs.size());
        if(OD_PAirs != null && OD_PAirs.size()>0){
            for(Origin_Destination__c od:OD_PAirs){
                if(od.Is_State_to_State__c){
                    OD_PairMAp.put(od.Origin_State__c + od.Destination_State__c, od.State_Mode_of_Service__c);
                }else{
                    OD_PairMAp.put(od.OriginCity__c + od.DestinationCity__c, od.Mode_Of_Service__c);
                }
                
            }
        }
        if(NameCodeMap !=null && NameCodeMap.size()>0){
            for(Shipment__c sh:ShipList){
                String BVC_Service = '';
                if(sh.IsExhibition__c)
                    BVC_Service = 'ExhibiSHIP';
                else
                    BVC_Service = sh.Customer_Product_Category__c;
                
                string serviceMode = '';
                if(sh.State_Logic_Check__c== 'With-In-City'){
                    serviceMode = 'Within City';
                }
                
                if(sh.State_Logic_Check__c != 'With-In-City' && OD_PairMAp!=null && OD_PairMAp.containsKey(sh.Origin_Address_State__c+sh.Destination_Address_State__c)){
                    serviceMode = OD_PairMAp.get(sh.Origin_Address_State__c+sh.Destination_Address_State__c);

                }else if(sh.State_Logic_Check__c != 'With-In-City' && OD_PairMAp!=null && OD_PairMAp.containsKey(sh.Origin_Address_City__c+sh.Destination_Address_City__c)){
                    serviceMode = OD_PairMAp.get(sh.Origin_Address_City__c+sh.Destination_Address_City__c);

                } else if(string.isBlank(serviceMode)){
                    serviceMode = defaultProduct;
                }
                
                if(string.isNotBlank(serviceMode) && NameCodeMap.containsKey(serviceMode)){
                    sh.BVC_Product_Name__c = BVC_Service + ' ' + NameCodeMap.get(serviceMode).Product_Name__c;
                    sh.Product_Code__c = BVC_Service.toUpperCase().remove('SHIP') + '-' +NameCodeMap.get(serviceMode).Product_Code__c;
                }
                
                System.debug('===sh.Product_Code__c=='+sh.Product_Code__c);
                System.debug('===sh.BVC_Product_Name__c=='+sh.BVC_Product_Name__c);
            }
        }
    }
}