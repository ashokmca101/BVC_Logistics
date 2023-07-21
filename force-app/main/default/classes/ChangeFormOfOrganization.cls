public class ChangeFormOfOrganization {
    @InvocableMethod
    public static void ChangeFormOfOrganizationMethod(List<Id> AccountIdSet){
        List<Account> AccountList = [SELECT PAN_Number_of_Entity__c, Form_Of_Organization__c FROM Account
                                    WHERE Id IN :AccountIdSet AND PAN_Number_of_Entity__c != NULL];
        For(Account A : AccountList){
            If(A.PAN_Number_of_Entity__c.charAt(3) == 80 || A.PAN_Number_of_Entity__c.charAt(3) == 112){
                //ASCII values for P
                A.Form_Of_Organization__c = 'Individual';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 102 || A.PAN_Number_of_Entity__c.charAt(3) == 70){
                //ASCII values for F
                A.Form_Of_Organization__c = 'Partnership Firm';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 67 || A.PAN_Number_of_Entity__c.charAt(3) == 99){
                //ASCII Values for C
                A.Form_Of_Organization__c = 'Company';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 72 || A.PAN_Number_of_Entity__c.charAt(3) == 104){
                //ASCII Values for H
                A.Form_Of_Organization__c = 'HUF';
            }/*
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 65 || A.PAN_Number_of_Entity__c.charAt(3) == 97){
                //ASCII Values for A
                A.Form_Of_Organization__c = 'Association Of Person (AOP)';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 84 || A.PAN_Number_of_Entity__c.charAt(3) == 116){
                //ASCII Values for T
                A.Form_Of_Organization__c = 'Trust/Foundation';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 66 || A.PAN_Number_of_Entity__c.charAt(3) == 98){
                //ASCII Values for B
                A.Form_Of_Organization__c = 'Body Of Individual';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 76 || A.PAN_Number_of_Entity__c.charAt(3) == 108){
                //ASCII Values for L
                A.Form_Of_Organization__c = 'Local Authority';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 74 || A.PAN_Number_of_Entity__c.charAt(3) == 106){
                //ASCII Values for J
                A.Form_Of_Organization__c = 'Artificial Juridical Person';
            }
            Else If(A.PAN_Number_of_Entity__c.charAt(3) == 71 || A.PAN_Number_of_Entity__c.charAt(3) == 103){
                //ASCII Values for G
                A.Form_Of_Organization__c = 'Government';
            }*/
        }
        
        Update AccountList;
    }
}