/*
 * Created By: PwC
 * Specification:AutoConvertLeads class use to convert all HOT leads automatically into a contact,Account and an Opportunity.
 * Date:11/02/2021
*/
Public class AutoConvertLeads {        
    public static void LeadAssign(Set<Id> LeadIds) {         
        List<lead> hotleads=new List<Lead>();
        hotleads=[Select id,rating from Lead where Id IN :LeadIds AND Rating='Hot' AND isConverted=False /*AND PostalCode != NULL*/ ];
        Set<Id> hotLeadIds=(new Map<Id,SObject>(hotleads)).keySet();
        LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];    
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();    
        for(id currentlead: hotLeadIds) {                
            Database.LeadConvert Leadconvert = new Database.LeadConvert();    
            Leadconvert.setLeadId(currentlead);                               
            Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);             
            //Leadconvert.setDoNotCreateOpportunity(TRUE); //UnComment this line if you want to skip opportunity creation from Lead Conversion  
            MassLeadconvert.add(Leadconvert);    
        }                  
        if (!MassLeadconvert.isEmpty()) {            
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);       
        }    
    } 
}