@IsTest
private class Test_TMS_UpdatePincode
{
    private static testMethod void updatePincode() 
    {
        Account acc = new Account();
        acc.name = 'Abdul';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Admin';
        insert acc;
        Hub__c hub = new Hub__c();
        hub.Name = 'Delhi';
        insert hub;
        Active_Pincode__c Pin = new Active_Pincode__c();
        Pin.Name = '110004';
        Pin.Hub__c = hub.Id;
        insert Pin;
        Active_Pincode__c Pincode = new Active_Pincode__c();
        Pincode.Name = '110000';
        Pincode.Hub__c = hub.Id;
        insert Pincode; 
        List<AddressBook__c> AddressList = new List<AddressBook__c>();
        AddressBook__c AddressBook=new AddressBook__c(Customer__c= acc.Id,PINCODE__c= '110004',
                                                      TRADE_NAME__c = 'Damco', Your_Address_Identifier__c = 'Hyderbad' , 
                                                      ADDRESS1__c = 'Tolichowki', CITY__c = 'Hyd', Pincode_TMS__c= Pin.Id );
        AddressList.add(AddressBook);
        AddressBook__c AddressBook1=new AddressBook__c(Customer__c= acc.Id,PINCODE__c= '110000',
                                                       TRADE_NAME__c = 'Damco', Your_Address_Identifier__c = 'Hyderbad' , 
                                                       ADDRESS1__c = 'Tolichowki', CITY__c = 'Hyd', Pincode_TMS__c= Pin.Id );
        AddressList.add(AddressBook1);
        insert AddressList;
        AddressBook__c AddressBooks = new AddressBook__c(Id=AddressBook.Id ,Pincode_TMS__c= Pincode.Id);
        update 	AddressBooks;
        
        Test.startTest();
        TMS_UpdatePincode.updatePincode(AddressList);
        Test.stopTest();
    }
}