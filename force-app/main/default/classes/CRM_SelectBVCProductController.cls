public class CRM_SelectBVCProductController {
    @AuraEnabled
    Public static List<String> retrieveBVCProduct(String recid) {
        Opportunity op=[Select BVC_Product__r.Name from opportunity where id=:recid];
        String level1prod=op.BVC_Product__r.Name;
        system.debug('level1prod '+level1prod);
        Set<String> bvcProdset=new Set<String>();
        List<Product2> prodlist=[Select Product_Level_2__c from product2 where Product_Level_1__c=:level1prod AND IsActive=true];
        for(Product2 prd:prodlist) {
            bvcProdset.add(prd.Product_Level_2__c);
        }
        List<String> p=new List<String>(bvcProdset);
        system.debug('==== '+p);
        return p;
    }
    @AuraEnabled
    Public Static void saveProductToDeal(List<String> secondlevelproduct,String recId) {
        String ProductString='';
        for(String s:secondlevelproduct) {
          ProductString=ProductString+s+',';
        }
        ProductString=ProductString.removeEnd(',');
        system.debug('Final Product String= '+ProductString);
        Opportunity Opp=[Select Id,Second_Level_Product__c from Opportunity where Id=:recId];
        Opp.Second_Level_Product__c=ProductString;
        update Opp;
    }
    
}