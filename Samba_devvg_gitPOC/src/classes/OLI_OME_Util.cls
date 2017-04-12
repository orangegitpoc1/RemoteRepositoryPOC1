public class OLI_OME_Util {
/* [15/10/27] OLE UST-1243/WIT-2164  Merge OME opty product related fields to samba
   Provides method callable from process builder 
   setEndDate: called from OLI_OME_Set_Contract_Dates process builder
			   to set start date = end date - contract length
			   Note: alternatives are
        		-WF/FU with formula: OME_OPPPR_Contract_End_Date__c - ( ( 365 / 12 ) * Term_in_months__c ) => Cheap but 
		         inaccurate, result can be offset by one or two days. An accurate formula is extremely verbose and hard to decipher for maintenance.
		        -Trigger: trigger.new[i].Contract_Start_Date__c = trigger.new[i].Contract_End_Date__c.addMonths(-integer.valueOf(trigger.new[i].Contract_Length__c));
		        The trigger is slightly more complex to build (must manage bulk calls) but is probably more robust at least
		        in W16 since I'm not convinced that process builder is yet ready for bulk.
		        For now (POC Nov 2015) I'm building a process builder as an experiment and for the fun of it.
*/
    @InvocableMethod  
    public static void setEndDate(List<Id> listOLIId)
    {        
        list<OpportunityLineItem> listOLI = new list<OpportunityLineItem>();
        listOLI = [
            select 
                 id
                ,OME_OPPPR_Contract_End_Date__c 
                ,OME_OPPPR_Contract_Start_Date__c 
                ,Term_in_months__c 
            from OpportunityLineItem
            where id = :listOLIId
        ];

        for (OpportunityLineItem oOLI :listOLI)
        {
            oOLI.OME_OPPPR_Contract_End_Date__c = 
                oOLI.OME_OPPPR_Contract_Start_Date__c.addMonths(Integer.valueof(oOLI.Term_in_months__c));
            //update oOLI; //nah.... not bulkified
        }
        update listOLI; //better
    }
}