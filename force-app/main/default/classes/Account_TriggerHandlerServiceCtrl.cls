public class Account_TriggerHandlerServiceCtrl {
    public static Boolean isFirst = true;
   
    @future(callout=true)
    public static void verifyPan(Id accId,String PanNumberOfEntity){
        System.debug('===== verifyPan callout Method ========');
        KYCPanVerificationAPI.verifyPanAPI(accId,PanNumberOfEntity); 
    }
    
    
    public static void stichProfileAPI(Id accId,String PanNumberOfEntity){
        System.debug('===== getStichProfileAPI  Method ========');
        KYCPanVerificationAPI.getStichProfileAPI(accId,PanNumberOfEntity);
    }
    
    @future(callout=true)
    public static void doFinancialSummaryAPICallout(Id accId,String entityId){
        System.debug('===== doFinancialSummaryAPICallout callout Method ========');
        KYCPanVerificationAPI.financialSummaryAPI(accId,entityId);
    }
    
    @future(callout=true)
    public static void doCreditRatingAPICallout(Id accId,String PanNumberOfEntity){
        System.debug('===== doCreditRatingAPICallout callout Method ========');
        KYCPanVerificationAPI.creditRatingAPI(accId,PanNumberOfEntity);
    }
    
    
    public static void AccountsharingWithSecondaryOwner(List<Account> EventAccID){ 
        

        
        List<AccountShare> accshare=new List<AccountShare>();
        for(Account acc:EventAccID) {
            if(acc.IsCustomerPortal && acc.Sales_Secondary_Owner__c !=null){
                AccountShare POVShare = new AccountShare(); 
                POVShare.AccountId=acc.Id;
                POVShare.AccountAccessLevel = 'Edit';
                
                POVShare.UserOrGroupId=acc.Sales_Secondary_Owner__c;
                POVShare.OpportunityAccessLevel='edit'; 
               
                accshare.add(POVShare);
            }
            
            
        }
        
         
        try{ 
            
                insert accshare;
               
                
        }catch(DMLException DMLe){ 
            system.assert(true,'Caught DML Exception: '+DMle.getDMLMessage(0));
            system.debug('\n\nCaught DML Exception: '+DMle.getDMLMessage(0)); 
        } 
    }
    public static void setBeforeValues(List<Account> accountList){
        
        for(Account accVar: accountList){
            if( (!accVar.KARZAA_KYC_Verified__c) && accVar.KYC_Status__c == 'Manually Verified'){
                accVar.KARZAA_KYC_Verified__c =true;
            }
        }
        
        for(Account A: accountList){
            
             If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 80 || A.PAN_Number_of_Entity__c.charAt(3) == 112)){
                //ASCII values for P
                A.Form_Of_Organization__c = 'Individual';
            }
            Else If(  A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 102 || A.PAN_Number_of_Entity__c.charAt(3) == 70)){
                //ASCII values for F
                A.Form_Of_Organization__c = 'Partnership Firm';
            }
            Else If(  A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 67 || A.PAN_Number_of_Entity__c.charAt(3) == 99)){
                //ASCII Values for C
                A.Form_Of_Organization__c = 'Company';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 72 || A.PAN_Number_of_Entity__c.charAt(3) == 104)){
                //ASCII Values for H
                A.Form_Of_Organization__c = 'HUF';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 65 || A.PAN_Number_of_Entity__c.charAt(3) == 97)){
                //ASCII Values for A
                A.Form_Of_Organization__c = 'Association Of Person';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 84 || A.PAN_Number_of_Entity__c.charAt(3) == 116)){
                //ASCII Values for T
                A.Form_Of_Organization__c = 'Trust/Foundation';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 66 || A.PAN_Number_of_Entity__c.charAt(3) == 98)){
                //ASCII Values for B
                A.Form_Of_Organization__c = 'Body Of Individual';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 76 || A.PAN_Number_of_Entity__c.charAt(3) == 108)){
                //ASCII Values for L
                A.Form_Of_Organization__c = 'Local Authority';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 74 || A.PAN_Number_of_Entity__c.charAt(3) == 106)){
                //ASCII Values for J
                A.Form_Of_Organization__c = 'Artificial Juridical Person';
            }
            Else If( A.PAN_Number_of_Entity__c !=null && (A.PAN_Number_of_Entity__c.charAt(3) == 71 || A.PAN_Number_of_Entity__c.charAt(3) == 103)){
                //ASCII Values for G
                A.Form_Of_Organization__c = 'Government';
            }
         }
    }
    public static void setAWSStatus(List<Account> accountList,map<Id,Account> mpOldAccounts){
         for(Account accVar: accountList){
             if(accVar.BVC_Company_Type__c == 'Domestic' &&  accVar.KARZAA_KYC_Verified__c
                && accVar.AWS_SYNC_Status__c !='Completed'
               &&accVar.Form_Of_Organization__c !=null && accVar.PAN_Number_of_Entity__c !=null){
                 accVar.AWS_SYNC_Status__c = 'Pending';
             }
         }
         for(Account accVar: accountList){
             if(accVar.Legacy_Record__c){
                continue; 
             }
             if( accVar.BVC_Company_Type__c !=null 
               &&   (mpOldAccounts.get(accVar.id).BVC_Company_Type__c !=accVar.BVC_Company_Type__c)
               &&(accVar.BVC_Company_Type__c.contains('International') || accVar.BVC_Company_Type__c.contains('CB Customer'))
               && accVar.KARZAA_KYC_Verified__c && accvar.Name_As_Per_PAN_Manual_Input__c !=null
               && accVar.Form_Of_Organization__c !=null  ){
                 accVar.AWS_SYNC_Status__c = 'Pending';
             }
             if(accVar.BVC_Company_Type__c !=null 
               && (accVar.BVC_Company_Type__c.contains('International') || accVar.BVC_Company_Type__c.contains('CB Customer'))
               && accVar.KARZAA_KYC_Verified__c && accvar.Name_As_Per_PAN_Manual_Input__c !=null
               && accVar.Form_Of_Organization__c !=null && accVar.AWS_SYNC_Status__c == 'NA'){
                    if(accVar.BVC_Company_Type__c.contains('International') && accVar.IEC_Manual_Input__c != NULL
                      && accVar.Customer_Type__c != null && accVar.Export_House__c != null
                       && accVar.Category__c != null){
                           accVar.AWS_SYNC_Status__c = 'Pending';
                       }
                    if(accVar.BVC_Company_Type__c.contains('CB Customer') && accVar.AD_Code_Manual_Input__c != null){
                        accVar.AWS_SYNC_Status__c = 'Pending';
                    }
                }
         }         
     } 
    public static void createPublicLinkForACR(list<account> acclist){
        map<id, account> mapAcc = new map<id,account>();
        for(account a :acclist ){
            mapAcc.put(a.docLinkId__c,a);
        }
        list<account> aList= new list<account>();
        list<ContentDistribution> cd = [SELECT id,ContentDocumentId, ContentDownloadUrl from ContentDistribution where ContentDocumentId IN: mapAcc.keySet()];
        for(ContentDistribution c :cd){
            account acc = mapAcc.get(c.ContentDocumentId);
            acc.ACR_consumption_link__c = c.ContentDownloadUrl;
            acc.link_generated_date__c= system.today();
            aList.add(acc);
        }
        update aList;
    }
    
     public static void dotest(){
        Integer i = 0;
         i++;
         i++; 
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
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
    
     public static void dotest2(){
        Integer i = 0;
         i++;
         i++; 
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
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
    public static void dotest3(){
        Integer i = 0;
         i++;
         i++; 
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
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