@istest
public class sendAnnaxureEmailTest {
    
    @istest static void createCreateContractTest(){
         Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
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
        SBQQ__Quote__c newquote = new SBQQ__Quote__c();
        Contract con = new Contract();
        con.AccountId=acc.id;
        con.StartDate=Date.newInstance(2016, 12, 9);
        con.Status='Draft';
        con.ContractTerm=12;
        
        insert con;
        
        Order neword=new Order();
        neword.AccountId=acc.id;
        neword.EffectiveDate=Date.newInstance(2016, 12, 9);
        neword.Status='Draft';
        neword.ContractId=con.Id;
        //neword.Business_Type__c=;
       // neword.Shipment__c='a2p9D000002jwCJQAY';
        neword.Consignee_Name__c='Test';
        insert neword;
        
        
         blng__Invoice__c inv=new blng__Invoice__c();
       	inv.blng__Account__c=acc.id;
       	inv.blng__Order__c=neword.id;
      	inv.blng__BillToContact__c=cc.id;
        insert inv;
        
        
        
        string header2 = 'Heading for ACR Annexure\n';
        
        String recordString2='Test';
        string finalstr2 = header2 + recordString2;
        Attachment att2=new Attachment();
        att2.Body=Blob.valueOf(finalstr2);
        att2.Name='Annexure.csv';
        att2.parentId=inv.id;
        insert att2;
          
         string header1 = 'Heading for ACR Annexure\n';
        
        String recordString1='Test';
        string finalstr1 = header1 + recordString1;
        Attachment att1=new Attachment();
        att1.Body=Blob.valueOf(finalstr1);
        att1.Name='Bath Invoice.pdf';
        att1.parentId=inv.id;
        insert att1;
          
        sendAnnaxureEmail.SendContractDetails(inv.id);
         sendAnnaxureEmail.SendACRInvoice(inv.id);
       
    }

}