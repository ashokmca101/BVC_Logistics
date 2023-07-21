public class DealTriggerBVCHelper {

    /****************************************************************
    * Class                 : DealTriggerBVCHelper
    * Method				: insertRecord
    * Function              : To insert Opp Products to Deal related Products(related)
    * Developer             : Sonu Kuruvila
    * Status          		: Not using Now
    *****************************************************************/
    /*
    Public static void insertRecord(List<Opportunity> newOpp){
        List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
        //List<Pricebook2> standardBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        //List<Product2> productBath =[select Id,ProductCode from Product2 where ProductCode IN('BATH-001','BVC Eship service')];
		string BVCpriceBook='01s5g00000Kgm7eAAB';
        PricebookEntry pbEntry =new PricebookEntry();
        for(Opportunity opp:newOpp){
            if(opp.BVC_Product__c!=null){
               pbEntry = [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCpriceBook AND Product2.Id=:opp.BVC_Product__c];
                if(opp.Business_Type__c=='ACR'){
                  Integer unitPrice=Integer.valueOf(opp.Package_Amount__c);
                  lines.add(new OpportunityLineItem(PricebookEntryId=pbEntry.Id,SBQQ__SubscriptionType__c ='Renewable', OpportunityId=opp.Id, UnitPrice=unitPrice, Quantity=1));
                }else{
                  lines.add(new OpportunityLineItem(PricebookEntryId=pbEntry.Id,SBQQ__SubscriptionType__c ='Renewable', OpportunityId=opp.Id, UnitPrice=0, Quantity=1));
                }
            }     
        } 
        if(lines.size()>0){
            insert lines;
        }
    }*/
   
    Public static void updateProductFd(List<Opportunity> newOpp){
        String BATHRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC BATH Deal').getRecordTypeId();
        String eSHIPRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC eSHIP Deal').getRecordTypeId();
        String iValSHIPRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC iValSHIP Deal').getRecordTypeId();
        String ieSHIPRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC ieSHIP Deal').getRecordTypeId();
        String ExhibiSHIPRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC ExhibiSHIP Deal').getRecordTypeId();
        String MarketSHIPRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BVC MarketSHIP Deal').getRecordTypeId();//Pratik
        List<Product2> prodBATh = [select id,ProductCode from Product2 where ProductCode='BVC BATH'];
        List<Product2> prodESHIP = [select id,ProductCode from Product2 where ProductCode='BVC eSHIP'];
        List<Product2> prodiVALSHIP = [select id,ProductCode from Product2 where ProductCode='BVC iValSHIP'];
        List<Product2> prodiEVALSHIP = [select id,ProductCode from Product2 where ProductCode='BVC ieSHIP'];
        List<Product2> prodExibiSHIP = [select id,ProductCode from Product2 where ProductCode='BVC ExhibiSHIP'];
        List<Product2> prodMarketSHIP = [select id,ProductCode from Product2 where ProductCode='BVCMarketSHIP'];//Pratik
        for(Opportunity opp:newOpp){
            
            if(opp.RecordTypeId==BATHRecordTypeID){
                opp.BVC_Product__c=prodBATh[0].Id;
            }else if(opp.RecordTypeId==eSHIPRecordTypeID){
                opp.BVC_Product__c=prodESHIP[0].Id;
            }else if(opp.RecordTypeId==iValSHIPRecordTypeID){
                opp.BVC_Product__c=prodiVALSHIP[0].Id;
            }else if(opp.RecordTypeId==ieSHIPRecordTypeID){
                opp.BVC_Product__c=prodiEVALSHIP[0].Id;
            }else if(opp.RecordTypeId==ExhibiSHIPRecordTypeID){
                opp.BVC_Product__c=prodExibiSHIP[0].Id;
            }else if(opp.RecordTypeId==MarketSHIPRecordTypeID){//Pratik
                opp.BVC_Product__c=prodMarketSHIP[0].Id;
            }
        }
    }
    
    /******************************************
     * Created By: Anamika Shinde
     * *****************************************/
    Public static void insertPeopleRole(List<Opportunity> newOpp){
        List<OpportunityContactRole> oppconRole = new List<OpportunityContactRole>();
        List<OpportunityContactRole> oppconRole1 = new List<OpportunityContactRole>();
        List<OpportunityContactRole> oppconRole2 = new List<OpportunityContactRole>();
        List<OpportunityContactRole> oppconRole3 = new List<OpportunityContactRole>();
        for(Opportunity opp:newOpp){
            
            if(opp.Authorised_Signatory_People__c!=Null){
                    OpportunityContactRole role =new OpportunityContactRole();
                    role.OpportunityId= opp.Id;
                    role.ContactId=opp.Authorised_Signatory_People__c;
                    role.Role='Authorised Signatory';
                    oppconRole.add(role);
            }
            
              if(opp.Evaluator__c!=Null){
                    OpportunityContactRole role1 =new OpportunityContactRole();
                    role1.OpportunityId= opp.Id;
                    role1.ContactId=opp.Evaluator__c;
                    role1.Role='Evaluator';
                    oppconRole1.add(role1);
              }
            
            if(opp.Decision_Maker__c!=Null){
                    OpportunityContactRole role2 =new OpportunityContactRole();
                    role2.OpportunityId= opp.Id;
                    role2.ContactId=opp.Decision_Maker__c;
                    role2.Role='Decision Maker';
                    oppconRole2.add(role2);
              }
            
            if(opp.Influencer__c!=Null){
                    OpportunityContactRole role2 =new OpportunityContactRole();
                    role2.OpportunityId= opp.Id;
                    role2.ContactId=opp.Influencer__c;
                    role2.Role='Influencer';
                    oppconRole3.add(role2);
              }
            
        }
         if(oppconRole.size()>0){
             insert oppconRole;
         }
        if(oppconRole1.size()>0){
           insert oppconRole1;
         }
         if(oppconRole2.size()>0){
          insert oppconRole2;
         }
        if(oppconRole3.size()>0){
          insert oppconRole3;
         }
    }
}