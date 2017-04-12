/* Created By 
use by Trigger UpdateOpportunityLastModified_Attachment,UpdateOpportunityLastModified_Note,
                UpdateOpportunity_Lastmodified_Event,UpdateOpportunity_Lastmodified_Task
UST-01281/TKT-3229
class to Update Opportunity LastmodifiedBYName(custom) and LastModifiedBYDate(custom) on creation and update with login user name and date 
It will update opportunity when IT_Team checkbox is Unchecked 
*/
public class UpdateLastmodified_Opportunity{
    public static void UpdateOpportunity(Boolean IT_team,Set<id> oppIds){ // method to call from trigger 
       List<Opportunity> OpportunityList = new List<Opportunity>();  
        if(oppIds.size()>0){ // hceck size of list of opportunity 
            opportunityList = [select id ,lastmodifiedbyName__c,Last_Modified_By_Date__c from opportunity where id in : oppIds];
        }
        if(opportunityList!=null && opportunityList.size()>0 && !IT_Team){ // list of opportunity is not nulll and IT_Team check box is not checked 
            for(opportunity opp : opportunityList){
                    opp.lastmodifiedbyName__c =UserInfo.getName(); //assign login user name 
                    opp.Last_Modified_By_Date__c= system.today();  // assign date 
            }
            try{
            update opportunityList;
            }
            catch(DMLException e){
               
            }
        }
    
    }

}