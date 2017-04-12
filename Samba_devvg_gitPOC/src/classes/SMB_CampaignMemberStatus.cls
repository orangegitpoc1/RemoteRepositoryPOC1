/*Ust- 1240 This class use by Trigger SMB_autoCampaignMemberStatusTrigger */

public class SMB_CampaignMemberStatus{
  public  static void insertCampaignMember(list<Campaign> cmlist)
  {
    Set<Id> camps = new Set<Id>();
    List<CampaignMemberStatus> cms2update = new List<CampaignMemberStatus>();
    List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
    List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
    Map<string,list<CampaignStatus__c>> MapCamp_type= new  Map<string,list<CampaignStatus__c>>();
    
    list<CampaignStatus__c> csList = new list<CampaignStatus__c>(); // create custom setting for making dynamic add value and order accordingly  
    csList = CampaignStatus__c.getAll().Values();
    for(CampaignStatus__c cs:csList ){
        if(MapCamp_type.containsKey(cs.Camp_Type__c)){
          List<CampaignStatus__c> campstatuslist= MapCamp_type.get(cs.Camp_Type__c);
          campstatuslist.add(cs); 
          MapCamp_type.put(cs.Camp_Type__c,campstatuslist);  
          
        }   
        else{
        
               MapCamp_type.put(cs.Camp_Type__c,new List<CampaignStatus__c>{cs});
        } 
    
    }
   
    for(Campaign cm : cmlist)
    { 
       camps.add(cm.id);
     if(MapCamp_type.get(cm.Type)!=null)  
       {
           for(CampaignStatus__c csItem : MapCamp_type.get(cm.Type))//custom setting CampaignStatus have list of status 
            {
            system.debug('csItem '+csItem );
            cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.id, HasResponded=csItem.HasResponded__c, IsDefault =csItem.IsDefault__c, 
            Label =csItem.Campaign_Status__c, SortOrder =integer.valueOf(csItem.SortOrder__c))); 
            
           }  
       } 
       else{
           for(CampaignStatus__c csItem : MapCamp_type.get('Other'))//custom setting CampaignStatus have list of status 
            {
            system.debug('csItem '+csItem );
            cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.id, HasResponded=csItem.HasResponded__c, IsDefault =csItem.IsDefault__c, 
            Label =csItem.Campaign_Status__c, SortOrder =integer.valueOf(csItem.SortOrder__c))); 
            
           } 
       
       
       }  
    }    
  cms2Delete =[select id,CampaignId,label,isDefault,SortOrder from CampaignMemberStatus  where CampaignId IN :camps];
   // salesforce dont allow to delete CampaignMemberStatus with default status so we are updating then deleting it 
   if(cms2Delete.size()>0){
        for(CampaignMemberStatus cm:cms2Delete){
            if(cm.label=='Sent'){
            cm.isDefault=false;   
            cms2update.add(cm); 
            }
            if(cm.label=='Selected'){
            cm.isDefault=false;   
            cms2update.add(cm); 
            }
         } 
      }
      try{
          if(cms2update.size()>0){ 
                update cms2update;  // update CampaignMemberStatus  of sent with default false 
            }
            system.debug('cms2Delete '+cms2Delete );
            if(cms2Delete.size()>0){ 
               delete cms2Delete;      // deleting all  CampaignMemberStatus  
            }
      }
      Catch(Exception e){
         system.debug(e);
     } 
      system.debug('cms2Insert'+cms2Insert);
      try{  
           if(cms2Insert.size()>0){
              insert cms2Insert;      // insert new CampaignMemberStatus  list 
           }
     }
      Catch(Exception e){
      system.debug(e); 
    } 
  
  }

}