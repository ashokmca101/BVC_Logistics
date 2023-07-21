@isTest
public class ExpireContractBatchTest {

    
    
    
    @testSetup
    static void activationTest(){
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Entity__c ent = TestUtility.createBVCEntity();
        insert ent;
        
        Active_Pincode__c pin = TestUtility.createPinCode();
        insert pin;
        
        blng__LegalEntity__c legEntity = TestUtility.createLegalEntity(ent);
        insert legEntity;
        
        List<Hub__c> branches = new  List<Hub__c>();
        Hub__c bvcBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(bvcBranch);
        Hub__c originBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(originBranch);
        Hub__c destinationBranch = TestUtility.createBVCBranch(legEntity, pin);
        branches.add(destinationBranch);
        insert branches;
        Active_Pincode__c suratPin = TestUtility.createBengaluruPinCode(branches[1]);
        insert suratPin;
        Account acc = new Account();
        acc.name = 'non ACR Non Contracted Account1234321';
        /*acc.Last_Name__c = 'Last';
        acc.Mobile__c = '1234567889';*/
        acc.ST_Pricing_Type__c = 'Non ACR';
        acc.Customer_Category__c = 'Non ACR Contracted';
        acc.Billing_Frequency__c = 'Monthly';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acc.GST_Registered__c = true;
        acc.Billing_Cycle__c = '26-25';
        acc.KYC_Status__c = 'API Verified';
        acc.KYC_Indicator_for_Domestic_Flag__c = true;
        
        insert acc;

        Contract cont = new Contract(AccountId = acc.Id,
                                     //SBQQ__Order__c = o.Id,
                                     StartDate = System.today().addDays(-30),
                                     EndDate = System.today(),
                                     Original_Contract_End_Date__c = system.today().addDays(45),
                                     Contract_Signed_Date__c = system.today(),
                                     Business_Type__c = 'ACR',
                                     Status = 'Draft',
                                     Contracted_ACR_Package__c = 'Package 2 : 60K',
                                     Contract_Amount__c = 60000,
                                     BVC_Branch__c = branches[0].Id,
                                     BVC_Billing_Entity__c = branches[0].ST_BVC_Billing_Entity__c,
                                     BVC_Entity__c = branches[0].BVC_Entity__c);   
        
        insert cont;

        Contract con = [select Id, Status from Contract limit 1];
        con.Status = 'Activated';
        update con;
        
        Database.executeBatch(new ExpireContractBatch());
        
    }
    
    @isTest 
    static void scheduleBatchTest(){
        Test.startTest();
        String cronExpr = '0 0 0 15 12 ? 2022';
        ExpireContractBatch abs= new ExpireContractBatch();
        String jobId = System.schedule('myJobTestJobName', cronExpr, abs);
        abs.execute(null);
        Test.stopTest();
    }  
    @isTest 
    static void expireBatchTest(){
        Test.startTest();
        String cronExpr = '0 0 0 15 12 ? 2022';
        Contract con = [select Id, Status from Contract limit 1];
        con.EndDate = Date.Today().addDays(-2);
        update con;
        ExpireContractBatch abs= new ExpireContractBatch();
        String jobId = System.schedule('myJobTestJobName', cronExpr, abs);
        abs.execute(null);
        Test.stopTest();
    }   
}