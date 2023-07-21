@istest
public class sendContractAnnaxureEmailTest {
    
    
      @istest static void createCreateContractTest(){
          RecordType rec=[SELECT id FROM RecordType WHERE name = 'Billing' and sobjecttype ='Account']; 
          Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId=rec.id;
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test@bvc.com';
        insert acc;
    	Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        cc.AccountId=acc.id;
        cc.Email='contact@bvc.com';
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        Insert cc;
    
     	List<Contract> conlist=new List<Contract>();
        Contract con = new Contract();
        con.AccountId=acc.id;
        con.StartDate=System.today()+10;
        con.Status='Draft';
        con.ContractTerm=12;
        con.CustomerSignedId=cc.id;
        con.Primary_Customer_Email__c='Contract@bvc.com';
        insert con;
        conlist.add(con);
          
        string header = 'Heading for ACR Annexure\n';
        String recordString='Test';
        string finalstr = header + recordString;
        Attachment att=new Attachment();
        att.Body=Blob.valueOf(finalstr);
        att.Name='Contract.csv';
        att.parentId=con.id;
        insert att;
        SendContractAnnaxureEmail.SendContractDetails(con.id);
        SendContractAnnaxureEmail.sendConsumptionDetails(conlist);
        SendContractAnnaxureEmail.contractRenewal(conlist);
       }
     

}